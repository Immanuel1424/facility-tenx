import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsEnum,
  MaxLength,
} from 'class-validator';
import { Expose } from 'class-transformer';
import { TicketPriority } from '../enums/ticket-priority.enum';

export class CreateTicketDto {
  @Expose()
  @IsString()
  @IsNotEmpty()
  @MaxLength(255)
  title!: string;

  @Expose()
  @IsString()
  @IsOptional()
  description?: string;

  @Expose()
  @IsEnum(TicketPriority)
  @IsOptional()
  priority?: TicketPriority;

  @Expose()
  @IsString()
  @IsOptional()
  @MaxLength(50)
  villa_number?: string;

  @Expose()
  @IsString()
  @IsOptional()
  @MaxLength(50)
  contact_number?: string;

  @Expose()
  @IsString()
  @IsOptional()
  @MaxLength(50)
  alternate_contact?: string;

  @Expose()
  @IsString()
  @IsOptional()
  @MaxLength(255)
  preferred_time?: string;

  @Expose()
  @IsString()
  @IsOptional()
  @MaxLength(255)
  location_detail?: string;

  @Expose()
  @IsString()
  @IsOptional()
  category?: string;

  @Expose()
  @IsString()
  @IsOptional()
  category_id?: string;
}

