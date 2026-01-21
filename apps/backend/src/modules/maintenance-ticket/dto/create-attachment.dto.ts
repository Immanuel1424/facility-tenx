import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsEnum,
  IsUUID,
  IsInt,
  MaxLength,
  Min,
  Max,
} from 'class-validator';
import { Expose } from 'class-transformer';
import { AttachmentType, AttachmentContext } from '../entities/ticket-attachment.entity';

export class CreateAttachmentDto {
  @Expose()
  @IsString()
  @IsNotEmpty()
  @MaxLength(255)
  file_name!: string;

  @Expose()
  @IsString()
  @IsNotEmpty()
  @MaxLength(255)
  original_name!: string;

  @Expose()
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  mime_type!: string;

  @Expose()
  @IsInt()
  @Min(1)
  @Max(52428800) // 50MB max
  file_size!: number;

  @Expose()
  @IsString()
  @IsNotEmpty()
  @MaxLength(500)
  storage_path!: string;

  @Expose()
  @IsString()
  @IsOptional()
  @MaxLength(1000)
  storage_url?: string;

  @Expose()
  @IsEnum(AttachmentType)
  @IsOptional()
  attachment_type?: AttachmentType;

  @Expose()
  @IsEnum(AttachmentContext)
  @IsOptional()
  attachment_context?: AttachmentContext;

  @Expose()
  @IsString()
  @IsOptional()
  description?: string;

  @Expose()
  @IsString()
  @IsOptional()
  @MaxLength(64)
  checksum?: string;

  @Expose()
  @IsUUID()
  @IsOptional()
  comment_id?: string;

  @Expose()
  @IsInt()
  @IsOptional()
  image_width?: number;

  @Expose()
  @IsInt()
  @IsOptional()
  image_height?: number;

  @Expose()
  @IsString()
  @IsOptional()
  @MaxLength(500)
  thumbnail_url?: string;
}

