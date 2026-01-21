import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsEnum,
  IsBoolean,
  IsInt,
  MaxLength,
  Min,
  Matches,
} from 'class-validator';
import { Expose } from 'class-transformer';
import { TicketPriority } from '../enums/ticket-priority.enum';

export class CreateSlaConfigurationDto {
  @Expose()
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  name!: string;

  @Expose()
  @IsString()
  @IsOptional()
  description?: string;

  @Expose()
  @IsEnum(TicketPriority)
  priority!: TicketPriority;

  @Expose()
  @IsInt()
  @Min(1)
  first_response_time_minutes!: number;

  @Expose()
  @IsInt()
  @Min(1)
  acknowledgement_time_minutes!: number;

  @Expose()
  @IsInt()
  @Min(1)
  @IsOptional()
  start_work_time_minutes?: number;

  @Expose()
  @IsInt()
  @Min(1)
  resolution_time_minutes!: number;

  @Expose()
  @IsInt()
  @Min(1)
  @IsOptional()
  escalation_level_1_minutes?: number;

  @Expose()
  @IsInt()
  @Min(1)
  @IsOptional()
  escalation_level_2_minutes?: number;

  @Expose()
  @IsInt()
  @Min(1)
  @IsOptional()
  escalation_level_3_minutes?: number;

  @Expose()
  @IsBoolean()
  @IsOptional()
  apply_business_hours?: boolean;

  @Expose()
  @IsString()
  @Matches(/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/, {
    message: 'business_start_time must be in HH:MM format',
  })
  @IsOptional()
  business_start_time?: string;

  @Expose()
  @IsString()
  @Matches(/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/, {
    message: 'business_end_time must be in HH:MM format',
  })
  @IsOptional()
  business_end_time?: string;

  @Expose()
  @IsString()
  @Matches(/^[1-7](,[1-7])*$/, {
    message: 'working_days must be comma-separated day numbers (1=Mon, 7=Sun)',
  })
  @IsOptional()
  working_days?: string;

  @Expose()
  @IsBoolean()
  @IsOptional()
  exclude_holidays?: boolean;
}

