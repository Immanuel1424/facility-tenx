import {
  IsString,
  IsNotEmpty,
  IsInt,
  Min,
  Max,
  IsOptional,
  MaxLength,
  IsEnum,
} from 'class-validator';
import { Expose } from 'class-transformer';

/**
 * Supported entity types for file uploads
 */
export enum UploadEntityType {
  MAINTENANCE_TICKET = 'maintenance-ticket',
  VILLA = 'villa',
  USER = 'user',
  ANNOUNCEMENT = 'announcement',
  // Add more entity types as needed
}

/**
 * DTO for generating pre-signed S3 upload URLs
 * Follows industry-standard pattern: client requests URL, uploads directly to S3
 */
export class GeneratePresignedUrlDto {
  @Expose()
  @IsString()
  @IsNotEmpty()
  @MaxLength(255)
  fileName!: string;

  @Expose()
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  mimeType!: string;

  @Expose()
  @IsInt()
  @Min(1)
  @Max(10485760) // 10MB max
  fileSize!: number;

  @Expose()
  @IsEnum(UploadEntityType)
  @IsNotEmpty()
  entityType!: UploadEntityType;

  @Expose()
  @IsString()
  @IsNotEmpty()
  entityId!: string;

  @Expose()
  @IsString()
  @IsOptional()
  @MaxLength(64)
  checksum?: string;
}
