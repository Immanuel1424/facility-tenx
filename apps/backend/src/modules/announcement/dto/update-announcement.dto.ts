import {
  IsString,
  IsOptional,
  IsEnum,
  IsArray,
  IsBoolean,
  IsDateString,
  MaxLength,
  ValidateIf,
} from 'class-validator';
import { Expose } from 'class-transformer';
import { AnnouncementCategory } from '../enums/announcement-category.enum';
import { AnnouncementPriority } from '../enums/announcement-priority.enum';
import { AnnouncementTargetAudience } from '../enums/announcement-target-audience.enum';

export class UpdateAnnouncementDto {
  @Expose()
  @IsString()
  @IsOptional()
  @MaxLength(255)
  title?: string;

  @Expose()
  @IsString()
  @IsOptional()
  message?: string;

  @Expose()
  @IsEnum(AnnouncementCategory)
  @IsOptional()
  category?: AnnouncementCategory;

  @Expose()
  @IsEnum(AnnouncementPriority)
  @IsOptional()
  priority?: AnnouncementPriority;

  @Expose()
  @IsEnum(AnnouncementTargetAudience)
  @IsOptional()
  targetAudience?: AnnouncementTargetAudience;

  @Expose()
  @IsArray()
  @IsString({ each: true })
  @ValidateIf((o) => o.targetAudience === AnnouncementTargetAudience.ROLES)
  @IsOptional()
  targetRoles?: string[];

  @Expose()
  @IsDateString()
  @IsOptional()
  scheduledAt?: string;

  @Expose()
  @IsDateString()
  @IsOptional()
  expiresAt?: string;
}

