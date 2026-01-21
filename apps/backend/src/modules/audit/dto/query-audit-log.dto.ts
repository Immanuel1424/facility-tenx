import {
  IsOptional,
  IsEnum,
  IsUUID,
  IsString,
  IsInt,
  IsDateString,
  Min,
  Max,
} from 'class-validator';
import { Expose, Type } from 'class-transformer';
import { AuditAction, AuditResourceType } from '../entities/audit-log.entity';

export class QueryAuditLogDto {
  @Expose()
  @IsUUID()
  @IsOptional()
  user_id?: string;

  @Expose()
  @IsEnum(AuditAction)
  @IsOptional()
  action?: AuditAction;

  @Expose()
  @IsEnum(AuditResourceType)
  @IsOptional()
  resource_type?: AuditResourceType;

  @Expose()
  @IsUUID()
  @IsOptional()
  resource_id?: string;

  @Expose()
  @IsString()
  @IsOptional()
  search?: string;

  @Expose()
  @IsDateString()
  @IsOptional()
  start_date?: string;

  @Expose()
  @IsDateString()
  @IsOptional()
  end_date?: string;

  @Expose()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @IsOptional()
  page?: number = 1;

  @Expose()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  @IsOptional()
  limit?: number = 20;
}

