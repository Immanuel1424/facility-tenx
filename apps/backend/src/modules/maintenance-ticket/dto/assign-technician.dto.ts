import {
  IsUUID,
  IsNotEmpty,
  IsOptional,
  IsDateString,
} from 'class-validator';
import { Expose } from 'class-transformer';

export class AssignTechnicianDto {
  @Expose()
  @IsUUID()
  @IsNotEmpty()
  technician_id!: string;

  @Expose()
  @IsDateString()
  @IsOptional()
  scheduled_at?: string;
}

