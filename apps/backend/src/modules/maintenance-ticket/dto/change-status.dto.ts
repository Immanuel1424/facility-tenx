import { IsEnum, IsOptional, IsString } from 'class-validator';
import { TicketStatus } from '../enums/ticket-status.enum';

export class ChangeStatusDto {
  @IsEnum(TicketStatus)
  status!: TicketStatus;

  @IsString()
  @IsOptional()
  notes?: string;
}

