import {
  IsUUID,
  IsOptional,
  IsDateString,
  IsEnum,
} from 'class-validator';
import { Expose } from 'class-transformer';
import { UserRole } from '../enums/user-role.enum';

export class AssignTicketDto {
  @Expose()
  @IsUUID()
  @IsOptional()
  department_id?: string;

  @Expose()
  @IsUUID()
  @IsOptional()
  technician_id?: string;

  @Expose()
  @IsDateString()
  @IsOptional()
  scheduled_at?: string;

  @Expose()
  @IsEnum(UserRole)
  @IsOptional()
  technician_role?: UserRole;
}

