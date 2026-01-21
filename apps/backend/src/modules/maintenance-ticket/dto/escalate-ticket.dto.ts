import { IsOptional, IsString, IsInt, Min, Max } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class EscalateTicketDto {
  @ApiProperty({
    description: 'Escalation level (1, 2, or 3)',
    example: 2,
    minimum: 1,
    maximum: 3,
  })
  @IsInt()
  @Min(1)
  @Max(3)
  escalation_level!: number;

  @ApiPropertyOptional({
    description: 'Reason for escalation',
    example: 'Ticket unresolved beyond SLA threshold',
  })
  @IsOptional()
  @IsString()
  reason?: string;
}
