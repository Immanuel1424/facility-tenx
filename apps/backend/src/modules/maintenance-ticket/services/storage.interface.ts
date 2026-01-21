import { SavedFileInfo } from './file-storage.service';

/**
 * Common interface for storage services
 * Allows switching between different storage providers (local, S3, etc.)
 */
export interface IStorageService {
  /**
   * Save uploaded file
   * @param file - File to save
   * @param ticketId - Ticket ID (or entity ID)
   * @returns Saved file information
   */
  saveFile(
    file: Express.Multer.File | undefined,
    ticketId: string,
  ): Promise<SavedFileInfo>;

  /**
   * Generate presigned URL for direct upload (S3) or return direct URL (local)
   * @param entityId - Entity ID
   * @param fileName - Original file name
   * @param mimeType - MIME type
   * @param fileSize - File size in bytes
   * @param checksum - Optional checksum
   * @param expiresIn - Expiration time in seconds
   * @param entityType - Entity type (default: 'maintenance-ticket')
   * @returns Presigned URL data or direct URL
   */
  generatePresignedUploadUrl(
    entityId: string,
    fileName: string,
    mimeType: string,
    fileSize: number,
    checksum?: string,
    expiresIn?: number,
    entityType?: string,
  ): Promise<{
    presignedUrl: string;
    s3Key?: string;
    storageUrl: string;
    expiresAt: Date;
  }>;

  /**
   * Get presigned URL for download/viewing
   * @param storagePath - Storage path (S3 key or file path)
   * @param expiresIn - Expiration time in seconds
   * @returns Presigned URL or direct URL
   */
  getPresignedUrl(storagePath: string, expiresIn?: number): Promise<string>;

  /**
   * Delete file from storage
   * @param storagePath - Storage path to delete
   */
  deleteFile(storagePath: string): Promise<void>;

  /**
   * Get file URL from storage path
   * @param storagePath - Storage path
   * @param ticketId - Optional ticket ID for local storage
   * @returns File URL
   */
  getFileUrl(storagePath: string, ticketId?: string): string;
}
