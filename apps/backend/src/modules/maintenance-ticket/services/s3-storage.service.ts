import { Injectable, BadRequestException, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  S3Client,
  PutObjectCommand,
  DeleteObjectCommand,
  GetObjectCommand,
} from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import * as crypto from 'crypto';
import { IStorageService } from './storage.interface';

const MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
const ALLOWED_MIME_TYPES = [
  'image/jpeg',
  'image/jpg',
  'image/png',
  'image/webp',
];

export interface SavedFileInfo {
  fileName: string;
  originalName: string;
  storagePath: string;
  storageUrl: string;
  fileSize: number;
  mimeType: string;
  checksum?: string;
}

@Injectable()
export class S3StorageService implements IStorageService {
  private readonly s3Client: S3Client;
  private readonly bucketName: string;
  private readonly region: string;
  private readonly basePrefix: string;
  private readonly logger = new Logger(S3StorageService.name);

  constructor(private readonly configService: ConfigService) {
    // Get S3 configuration from environment variables
    const accessKeyId = this.configService.get<string>('AWS_S3_ACCESS_KEY_ID');
    const secretAccessKey = this.configService.get<string>('AWS_S3_SECRET_ACCESS_KEY');
    this.region = this.configService.get<string>('AWS_S3_REGION') || 'ap-south-1';
    this.bucketName = this.configService.get<string>('AWS_S3_BUCKET_NAME') || 'user1-bucket-test';
    this.basePrefix = this.configService.get<string>('AWS_S3_BASE_PREFIX') || 'tenx-attachments';

    if (!accessKeyId || !secretAccessKey) {
      throw new Error(
        'AWS S3 credentials are required. Please set AWS_S3_ACCESS_KEY_ID and AWS_S3_SECRET_ACCESS_KEY environment variables.',
      );
    }

    // Initialize S3 client
    // Configure to avoid automatic checksum calculation which can cause
    // signature mismatches in presigned URLs
    // AWS SDK v3.729.0+ automatically calculates CRC32 checksum by default
    // We explicitly disable checksum calculation to prevent checksum parameters
    // in presigned URLs, which cause 403 Forbidden errors when clients don't send checksums
    this.s3Client = new S3Client({
      region: this.region,
      credentials: {
        accessKeyId,
        secretAccessKey,
      },
      // Disable automatic checksum calculation
      // This prevents SDK from adding checksum parameters to presigned URLs
      // that would require matching checksum headers from the client
      requestChecksumCalculation: 'WHEN_REQUIRED', // Only calculate when explicitly required
      responseChecksumValidation: 'WHEN_REQUIRED', // Only validate when explicitly required
    });

    this.logger.log(`S3 Storage Service initialized for bucket: ${this.bucketName}, region: ${this.region}`);
  }

  /**
   * Save uploaded file to S3
   */
  async saveFile(
    file: Express.Multer.File | undefined,
    ticketId: string,
  ): Promise<SavedFileInfo> {
    // Validate file (throws if invalid, so file is guaranteed to be defined after this)
    this.validateFile(file);

    // After validation, file is guaranteed to be defined
    const validatedFile = file!;

    // Generate unique file name
    const fileExtension = this.getFileExtension(validatedFile.originalname);
    const uniqueFileName = `${crypto.randomUUID()}${fileExtension}`;

    // Construct S3 key (path in bucket)
    // Format: tenx-attachments/maintenance-ticket/{ticketId}/{uniqueFileName}
    // Using 'maintenance-ticket' for consistency with presigned URL generation
    const s3Key = `${this.basePrefix}/maintenance-ticket/${ticketId}/${uniqueFileName}`;

    // Calculate checksum (optional, for integrity verification)
    const checksum = this.calculateChecksum(validatedFile.buffer);

    try {
      // Upload file to S3
      const putCommand = new PutObjectCommand({
        Bucket: this.bucketName,
        Key: s3Key,
        Body: validatedFile.buffer,
        ContentType: validatedFile.mimetype,
        Metadata: {
          originalName: validatedFile.originalname,
          ticketId: ticketId,
          checksum: checksum,
        },
      });

      await this.s3Client.send(putCommand);

      this.logger.log(`File uploaded to S3: ${s3Key}`);

      // Generate storage URL (S3 object URL)
      // For private buckets, we'll use presigned URLs when needed
      // For now, store the S3 key as storage_path and construct URL
      const storageUrl = this.getFileUrl(s3Key);

      return {
        fileName: uniqueFileName,
        originalName: validatedFile.originalname,
        storagePath: s3Key, // Store S3 key as storage path
        storageUrl,
        fileSize: validatedFile.size,
        mimeType: validatedFile.mimetype,
        checksum,
      };
    } catch (error: unknown) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error(`Failed to upload file to S3: ${errorMessage}`, error);
      throw new BadRequestException(`Failed to upload file to S3: ${errorMessage}`);
    }
  }

  /**
   * Delete file from S3
   */
  async deleteFile(storagePath: string): Promise<void> {
    try {
      // storagePath is the S3 key
      const deleteCommand = new DeleteObjectCommand({
        Bucket: this.bucketName,
        Key: storagePath,
      });

      await this.s3Client.send(deleteCommand);
      this.logger.log(`File deleted from S3: ${storagePath}`);
    } catch (error: unknown) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error(`Failed to delete file from S3: ${errorMessage}`, error);
      // Don't throw - file might not exist, which is fine
      // Log the error but don't fail the operation
    }
  }

  /**
   * Generate presigned URL for PUT operation (direct upload from client)
   * Returns presigned URL, S3 key, and metadata for client-side upload
   * Uses the same approach as the test file - simple PutObjectCommand without checksum parameters
   * 
   * @param entityId - ID of the entity (ticket, villa, user, etc.)
   * @param fileName - Original file name
   * @param mimeType - MIME type of the file
   * @param fileSize - File size in bytes
   * @param checksum - Optional checksum for integrity verification
   * @param expiresIn - URL expiration time in seconds (default: 900 = 15 minutes, max: 900)
   * @param entityType - Type of entity (default: 'maintenance-ticket' for backward compatibility)
   */
  async generatePresignedUploadUrl(
    entityId: string,
    fileName: string,
    mimeType: string,
    fileSize: number,
    checksum?: string,
    expiresIn: number = 900, // 15 minutes default (industry standard)
    entityType: string = 'maintenance-ticket', // Default for backward compatibility
  ): Promise<{
    presignedUrl: string;
    s3Key: string;
    storageUrl: string;
    expiresAt: Date;
  }> {
    // Validate file before generating presigned URL
    this.validateFileMetadata(fileName, mimeType, fileSize);

    // Enforce maximum expiry of 15 minutes (900 seconds) for security
    // Industry standard: pre-signed URLs should expire quickly
    const maxExpiry = 900; // 15 minutes
    const actualExpiresIn = Math.min(expiresIn, maxExpiry);
    
    if (expiresIn > maxExpiry) {
      this.logger.warn(
        `Requested expiry ${expiresIn}s exceeds maximum ${maxExpiry}s. Using ${maxExpiry}s.`,
      );
    }

    // Generate unique file name
    const fileExtension = this.getFileExtension(fileName);
    const uniqueFileName = `${crypto.randomUUID()}${fileExtension}`;

    // Construct S3 key (path in bucket)
    // Format: <basePrefix>/<entityType>/<entityId>/<uuid>.<ext>
    // Example: tenx-attachments/maintenance-ticket/123/abc-123.jpg
    const normalizedEntityType = entityType.toLowerCase().replace(/[^a-z0-9-]/g, '-');
    const s3Key = `${this.basePrefix}/${normalizedEntityType}/${entityId}/${uniqueFileName}`;

    try {
      // Generate presigned URL using PutObjectCommand
      // IMPORTANT: Do NOT include any checksum-related parameters to avoid
      // signature mismatch errors. The presigned URL signature must match exactly
      // what the client sends. Checksum parameters in the URL require matching
      // checksum headers/body from the client, which can cause failures.
      //
      // Note: We explicitly omit checksum from metadata when generating presigned URLs
      // to prevent the AWS SDK from automatically adding checksum headers to the request.
      // The checksum can be stored in the database after upload if needed.
      const putCommand = new PutObjectCommand({
        Bucket: this.bucketName,
        Key: s3Key,
        ContentType: mimeType,
        Metadata: {
          originalName: fileName,
          entityId: entityId,
          entityType: entityType,
          // Explicitly omit checksum from metadata to prevent SDK from adding checksum headers
          // Checksum can be calculated and stored in DB after successful upload if needed
        },
        // Explicitly DO NOT include:
        // - ChecksumAlgorithm
        // - ChecksumCRC32
        // - ChecksumCRC32C
        // - ChecksumSHA1
        // - ChecksumSHA256
        // These would require the client to send matching checksums, causing signature failures
      });

      // Generate presigned URL
      // Note: Checksum calculation should be disabled in S3Client configuration
      // If checksum parameters still appear, the SDK version may have changed behavior
      const presignedUrl = await getSignedUrl(this.s3Client, putCommand, {
        expiresIn: actualExpiresIn,
      });

      // Check if URL contains checksum parameters
      // CRITICAL: Checksum parameters in presigned URLs cause 403 Forbidden errors
      // because they require matching checksum headers from the client
      // If checksum parameters are found, the middleware configuration failed
      if (
        presignedUrl.includes('x-amz-checksum') ||
        presignedUrl.includes('x-amz-sdk-checksum')
      ) {
        this.logger.error(
          `⚠️ CRITICAL: Presigned URL contains checksum parameters for ${s3Key}. ` +
            `This will cause upload failures (403 Forbidden) because the client doesn't send matching checksums. ` +
            `The checksum middleware configuration may not be working correctly. ` +
            `URL preview: ${presignedUrl.substring(0, 200)}...`,
        );
        // Still return the URL, but log the error for debugging
        // In production, this should be fixed before deployment
      } else {
        this.logger.debug(
          `✅ Presigned URL generated without checksum parameters for ${s3Key}`,
        );
      }

      const expiresAt = new Date(Date.now() + actualExpiresIn * 1000);

      this.logger.log(
        `Presigned upload URL generated for: ${s3Key}, expires at: ${expiresAt.toISOString()}`,
      );

      return {
        presignedUrl,
        s3Key,
        storageUrl: this.getFileUrl(s3Key),
        expiresAt,
      };
    } catch (error: unknown) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error(
        `Failed to generate presigned upload URL: ${errorMessage}`,
        error,
      );
      throw new BadRequestException(
        `Failed to generate presigned upload URL: ${errorMessage}`,
      );
    }
  }

  /**
   * Get presigned URL from storage path (S3 key) for GET operations
   * Returns a presigned URL for private buckets (expires after specified time)
   */
  async getPresignedUrl(storagePath: string, expiresIn: number = 3600): Promise<string> {
    try {
      // Generate presigned URL for private bucket access
      const getCommand = new GetObjectCommand({
        Bucket: this.bucketName,
        Key: storagePath,
      });

      const presignedUrl = await getSignedUrl(this.s3Client, getCommand, { expiresIn });
      return presignedUrl;
    } catch (error: unknown) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error(`Failed to generate presigned URL: ${errorMessage}`, error);
      // Fallback to public URL format if presigned URL generation fails
      return this.getPublicUrl(storagePath);
    }
  }

  /**
   * Get public URL format (for public buckets or as fallback)
   */
  private getPublicUrl(storagePath: string): string {
    return `https://${this.bucketName}.s3.${this.region}.amazonaws.com/${storagePath}`;
  }

  /**
   * Get file URL from storage path (synchronous version for database storage)
   * This is used when storing the URL in the database
   * For private buckets, use getPresignedUrl() when actually accessing the file
   * @param storagePath - S3 key (storage path)
   * @param ticketId - Optional ticket ID (not used for S3, kept for interface compatibility)
   */
  getFileUrl(storagePath: string, ticketId?: string): string {
    // Return public URL format (will be replaced with presigned URL when accessed)
    // ticketId parameter is ignored for S3 storage
    return this.getPublicUrl(storagePath);
  }

  /**
   * Validate file metadata (for presigned URL generation)
   */
  private validateFileMetadata(
    fileName: string,
    mimeType: string,
    fileSize: number,
  ): void {
    // Check file size
    if (fileSize > MAX_FILE_SIZE) {
      throw new BadRequestException(
        `File size exceeds maximum allowed size of ${MAX_FILE_SIZE / 1024 / 1024}MB`,
      );
    }

    // Check MIME type
    if (!ALLOWED_MIME_TYPES.includes(mimeType)) {
      throw new BadRequestException(
        `File type ${mimeType} is not allowed. Allowed types: ${ALLOWED_MIME_TYPES.join(', ')}`,
      );
    }

    // Validate file name
    if (!fileName || fileName.trim().length === 0) {
      throw new BadRequestException('File name is required');
    }
  }

  /**
   * Validate file before saving (for server-side uploads)
   */
  private validateFile(file: Express.Multer.File | undefined): void {
    if (!file) {
      throw new BadRequestException('No file provided');
    }

    this.validateFileMetadata(file.originalname, file.mimetype, file.size);

    // Check if file has buffer
    if (!file.buffer || file.buffer.length === 0) {
      throw new BadRequestException('File buffer is empty');
    }
  }

  /**
   * Calculate MD5 checksum of file buffer
   */
  private calculateChecksum(buffer: Buffer): string {
    return crypto.createHash('md5').update(buffer).digest('hex');
  }

  /**
   * Get file extension from filename
   */
  private getFileExtension(filename: string): string {
    const lastDot = filename.lastIndexOf('.');
    return lastDot >= 0 ? filename.substring(lastDot) : '';
  }
}

