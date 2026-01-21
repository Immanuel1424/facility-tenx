import { Injectable, BadRequestException, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as fs from 'fs/promises';
import * as path from 'path';
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
export class FileStorageService implements IStorageService {
  private readonly uploadsBaseDir: string;
  private readonly baseUrl: string;
  private readonly logger = new Logger(FileStorageService.name);

  constructor(private readonly configService: ConfigService) {
    // Use environment variable or default to 'uploads' directory
    const uploadsDir = this.configService.get<string>('UPLOADS_DIR') || 'uploads';
    this.uploadsBaseDir = path.resolve(process.cwd(), uploadsDir);
    // Default to /api/uploads to match the global API prefix
    this.baseUrl = this.configService.get<string>('UPLOADS_BASE_URL') || '/api/uploads';

    // Ensure base directory exists
    this.ensureDirectoryExists(this.uploadsBaseDir)
      .then(() => {
        this.logger.log(`Uploads directory initialized: ${this.uploadsBaseDir}`);
      })
      .catch((err) => {
        this.logger.error(
          `Failed to create uploads directory: ${this.uploadsBaseDir}`,
          err,
        );
      });
  }

  /**
   * Save uploaded file to disk
   */
  async saveFile(
    file: Express.Multer.File | undefined,
    ticketId: string,
  ): Promise<SavedFileInfo> {
    // Validate file (throws if invalid, so file is guaranteed to be defined after this)
    this.validateFile(file);
    
    // After validation, file is guaranteed to be defined
    const validatedFile = file!;

    // Create ticket-specific directory
    const ticketDir = path.join(this.uploadsBaseDir, 'tickets', ticketId);
    try {
      await this.ensureDirectoryExists(ticketDir);
    } catch (error: unknown) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error(
        `Failed to create ticket directory: ${ticketDir}. Error: ${errorMessage}`,
        error,
      );
      throw new BadRequestException(
        `Failed to create upload directory: ${errorMessage}`,
      );
    }

    // Generate unique file name
    const fileExtension = path.extname(validatedFile.originalname);
    const uniqueFileName = `${crypto.randomUUID()}${fileExtension}`;
    const filePath = path.join(ticketDir, uniqueFileName);

    // Write file to disk
    try {
      await fs.writeFile(filePath, validatedFile.buffer);
      this.logger.debug(`File saved successfully: ${filePath}`);
    } catch (error: unknown) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error(
        `Failed to write file: ${filePath}. Error: ${errorMessage}`,
        error,
      );
      throw new BadRequestException(`Failed to save file: ${errorMessage}`);
    }

    // Calculate checksum (optional, for integrity verification)
    const checksum = this.calculateChecksum(validatedFile.buffer);

    // Generate storage URL
    const storageUrl = `${this.baseUrl}/tickets/${ticketId}/${uniqueFileName}`;

    // Store relative path for storage_path (relative to uploads base dir)
    const relativePath = path.relative(this.uploadsBaseDir, filePath);

    return {
      fileName: uniqueFileName,
      originalName: validatedFile.originalname,
      storagePath: relativePath,
      storageUrl,
      fileSize: validatedFile.size,
      mimeType: validatedFile.mimetype,
      checksum,
    };
  }

  /**
   * Delete file from disk
   */
  async deleteFile(storagePath: string): Promise<void> {
    try {
      // Resolve full path if relative path is provided
      const fullPath = path.isAbsolute(storagePath)
        ? storagePath
        : path.join(this.uploadsBaseDir, storagePath);
      await fs.unlink(fullPath);
    } catch (error: unknown) {
      // Ignore if file doesn't exist
      if (error && typeof error === 'object' && 'code' in error && error.code === 'ENOENT') {
        return; // File doesn't exist, which is fine
      }
      throw error;
    }
  }

  /**
   * Generate presigned URL for upload (local storage doesn't need presigning)
   * For local storage, we return a direct URL since files are uploaded via multipart form
   */
  async generatePresignedUploadUrl(
    entityId: string,
    fileName: string,
    mimeType: string,
    fileSize: number,
    checksum?: string,
    expiresIn: number = 900,
    entityType: string = 'maintenance-ticket',
  ): Promise<{
    presignedUrl: string;
    s3Key?: string;
    storageUrl: string;
    expiresAt: Date;
  }> {
    // Validate file metadata
    this.validateFileMetadata(fileName, mimeType, fileSize);

    // Generate unique file name
    const fileExtension = path.extname(fileName);
    const uniqueFileName = `${crypto.randomUUID()}${fileExtension}`;

    // For local storage, we don't use presigned URLs
    // Files are uploaded directly via multipart form to the backend
    // Return a direct URL that will be used after upload
    const storagePath = `tickets/${entityId}/${uniqueFileName}`;
    const storageUrl = `${this.baseUrl}/${storagePath}`;

    // Calculate expiration (for consistency with S3 interface)
    const expiresAt = new Date(Date.now() + expiresIn * 1000);

    // Return direct URL (not presigned, since local storage doesn't need it)
    return {
      presignedUrl: storageUrl, // For local storage, this is just the direct URL
      storageUrl,
      expiresAt,
    };
  }

  /**
   * Get presigned URL for download/viewing (local storage returns direct URL)
   */
  async getPresignedUrl(storagePath: string, expiresIn: number = 3600): Promise<string> {
    // For local storage, return direct URL (no presigning needed)
    // storagePath is relative to uploads base dir (e.g., "tickets/{ticketId}/{fileName}")
    return `${this.baseUrl}/${storagePath}`;
  }

  /**
   * Get file URL from storage path
   */
  getFileUrl(storagePath: string, ticketId?: string): string {
    // If storagePath is already a full path, use it directly
    if (storagePath.startsWith('/') || storagePath.startsWith('http')) {
      return storagePath;
    }

    // If ticketId is provided, construct URL from it
    if (ticketId) {
      const fileName = path.basename(storagePath);
      return `${this.baseUrl}/tickets/${ticketId}/${fileName}`;
    }

    // Otherwise, assume storagePath is relative to uploads base dir
    return `${this.baseUrl}/${storagePath}`;
  }

  /**
   * Validate file metadata (for presigned URL generation)
   */
  private validateFileMetadata(fileName: string, mimeType: string, fileSize: number): void {
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
  }

  /**
   * Validate file before saving
   */
  private validateFile(file: Express.Multer.File | undefined): void {
    if (!file) {
      throw new BadRequestException('No file provided');
    }
    // Check file size
    if (file.size > MAX_FILE_SIZE) {
      throw new BadRequestException(
        `File size exceeds maximum allowed size of ${MAX_FILE_SIZE / 1024 / 1024}MB`,
      );
    }

    // Check MIME type
    if (!ALLOWED_MIME_TYPES.includes(file.mimetype)) {
      throw new BadRequestException(
        `File type ${file.mimetype} is not allowed. Allowed types: ${ALLOWED_MIME_TYPES.join(', ')}`,
      );
    }

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
   * Ensure directory exists, create if it doesn't
   */
  private async ensureDirectoryExists(dirPath: string): Promise<void> {
    try {
      await fs.access(dirPath);
    } catch {
      // Directory doesn't exist, create it recursively
      await fs.mkdir(dirPath, { recursive: true });
    }
  }
}
