import {
  IsString,
  IsNotEmpty,
  IsInt,
  Min,
  Max,
  IsOptional,
  MaxLength,
} from 'class-validator';
import { Expose } from 'class-transformer';

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
  @IsString()
  @IsOptional()
  @MaxLength(64)
  checksum?: string;
}
