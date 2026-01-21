import { IsInt, Min, Max } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class UpdateEscalationSchedulerConfigDto {
  @ApiProperty({
    description: 'Interval in minutes for escalation check (1-60)',
    example: 1,
    minimum: 1,
    maximum: 60,
  })
  @IsInt()
  @Min(1)
  @Max(60)
  intervalMinutes!: number;
}
