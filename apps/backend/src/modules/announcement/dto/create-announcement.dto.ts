import {
  IsString,
  IsNotEmpty,
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

export class CreateAnnouncementDto {
  @Expose()
  @IsString()
  @IsNotEmpty()
  @MaxLength(255)
  title!: string;

  @Expose()
  @IsString()
  @IsNotEmpty()
  message!: string;

  @Expose()
  @IsEnum(AnnouncementCategory)
  @IsNotEmpty()
  category!: AnnouncementCategory;

  @Expose()
  @IsEnum(AnnouncementPriority)
  @IsNotEmpty()
  priority!: AnnouncementPriority;

  @Expose()
  @IsEnum(AnnouncementTargetAudience)
  @IsNotEmpty()
  targetAudience!: AnnouncementTargetAudience;

  @Expose()
  @IsArray()
  @IsString({ each: true })
  @ValidateIf((o) => o.targetAudience === AnnouncementTargetAudience.ROLES)
  @IsNotEmpty()
  targetRoles?: string[];

  @Expose()
  @IsDateString()
  @IsOptional()
  scheduledAt?: string;

  @Expose()
  @IsDateString()
  @IsOptional()
  expiresAt?: string;

  @Expose()
  @IsBoolean()
  @IsOptional()
  publishImmediately?: boolean;
}

