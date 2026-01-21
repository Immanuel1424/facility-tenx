import { ApiProperty } from '@nestjs/swagger';

export class DashboardStatsDto {
  @ApiProperty({ description: 'Number of open tickets' })
  openRequests!: number;

  @ApiProperty({ description: 'Number of tickets in progress' })
  inProgress!: number;

  @ApiProperty({ description: 'Number of resolved tickets' })
  resolved!: number;

  @ApiProperty({ description: 'Total number of tickets' })
  totalRequests!: number;

  @ApiProperty({ description: 'Number of active users' })
  activeUsers!: number;

  @ApiProperty({ description: 'Number of pending approvals' })
  pendingApproval!: number;

  @ApiProperty({ description: 'Number of tickets completed today' })
  completedToday!: number;

  @ApiProperty({ description: 'Number of assigned tickets' })
  assigned!: number;

  @ApiProperty({ description: 'Number of completed tickets' })
  completed!: number;

  @ApiProperty({ description: 'Number of pending tickets' })
  pending!: number;

  @ApiProperty({ description: 'Number of acknowledged tickets' })
  acknowledged!: number;

  @ApiProperty({ description: 'Number of tickets on hold' })
  onHold!: number;

  @ApiProperty({ description: 'Number of escalated tickets', required: false })
  escalated?: number;

  @ApiProperty({ description: 'Number of overdue tickets', required: false })
  overdue?: number;
}

