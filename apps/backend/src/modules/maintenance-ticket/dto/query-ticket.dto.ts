import {
  IsOptional,
  IsEnum,
  IsInt,
  IsUUID,
  Min,
  Max,
  IsString,
  IsDateString,
  IsBoolean,
} from 'class-validator';
import { Type, Expose, Transform } from 'class-transformer';
import { TicketStatus } from '../enums/ticket-status.enum';
import { TicketPriority } from '../enums/ticket-priority.enum';

export class QueryTicketDto {
  @Expose()
  @IsOptional()
  @IsEnum(TicketStatus)
  status?: TicketStatus;

  @Expose()
  @IsOptional()
  @IsEnum(TicketPriority)
  priority?: TicketPriority;

  @Expose()
  @IsOptional()
  @Transform(({ value }) => {
    if (value === undefined || value === null) return value;
    return Array.isArray(value) ? value : [value];
  })
  @Type(() => String)
  @IsString({ each: true })
  villa_numbers?: string[];

  @Expose()
  @IsOptional()
  @IsUUID()
  department_id?: string;

  @Expose()
  @IsOptional()
  @IsUUID()
  category_id?: string;

  @Expose()
  @IsOptional()
  @IsUUID()
  assigned_supervisor_id?: string;

  @Expose()
  @IsOptional()
  @IsUUID()
  assigned_technician_id?: string;

  @Expose()
  @IsOptional()
  @IsString()
  search?: string;

  @Expose()
  @IsOptional()
  @IsDateString()
  created_from?: string;

  @Expose()
  @IsOptional()
  @IsDateString()
  created_to?: string;

  @Expose()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @Expose()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 20;

  @Expose()
  @IsOptional()
  @Transform(({ value }) => {
    if (value === undefined || value === null) return value;
    if (value === 'true' || value === true) return true;
    if (value === 'false' || value === false) return false;
    return value;
  })
  @Type(() => Boolean)
  @IsBoolean()
  is_escalated?: boolean;
}

