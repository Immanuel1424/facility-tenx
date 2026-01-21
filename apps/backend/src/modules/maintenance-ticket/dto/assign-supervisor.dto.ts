import {
  IsUUID,
  IsNotEmpty,
  IsOptional,
  IsEnum,
} from 'class-validator';
import { Expose } from 'class-transformer';
import { TicketPriority } from '../enums/ticket-priority.enum';

export class AssignSupervisorDto {
  @Expose()
  @IsUUID()
  @IsNotEmpty()
  supervisor_id!: string;

  @Expose()
  @IsUUID()
  @IsOptional()
  department_id?: string;

  @Expose()
  @IsEnum(TicketPriority)
  @IsOptional()
  priority?: TicketPriority;
}

