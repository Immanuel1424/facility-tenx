import { ApiProperty } from '@nestjs/swagger';

export class StatusDistributionDto {
  @ApiProperty({ description: 'Status name' })
  status!: string;

  @ApiProperty({ description: 'Count of tickets with this status' })
  count!: number;

  @ApiProperty({ description: 'Percentage of total tickets' })
  percentage!: number;
}

export class PriorityDistributionDto {
  @ApiProperty({ description: 'Priority level' })
  priority!: string;

  @ApiProperty({ description: 'Count of tickets with this priority' })
  count!: number;

  @ApiProperty({ description: 'Percentage of total tickets' })
  percentage!: number;
}

export class DepartmentDistributionDto {
  @ApiProperty({ description: 'Department name' })
  departmentName!: string;

  @ApiProperty({ description: 'Count of tickets for this department' })
  count!: number;

  @ApiProperty({ description: 'Percentage of total tickets' })
  percentage!: number;
}

export class TrendDataPointDto {
  @ApiProperty({ description: 'Date in ISO format' })
  date!: string;

  @ApiProperty({ description: 'Number of tickets created' })
  created!: number;

  @ApiProperty({ description: 'Number of tickets resolved' })
  resolved!: number;

  @ApiProperty({ description: 'Number of tickets in progress' })
  inProgress!: number;
}

export class PerformanceMetricsDto {
  @ApiProperty({ description: 'Average resolution time in hours' })
  averageResolutionTime!: number;

  @ApiProperty({ description: 'Average first response time in hours' })
  averageFirstResponseTime!: number;

  @ApiProperty({ description: 'SLA compliance percentage' })
  slaCompliance!: number;

  @ApiProperty({ description: 'Total tickets resolved this period' })
  ticketsResolved!: number;
}

export class PredictionDto {
  @ApiProperty({ description: 'Predicted ticket volume for next period' })
  predictedVolume!: number;

  @ApiProperty({ description: 'Confidence level (0-100)' })
  confidence!: number;

  @ApiProperty({ description: 'Trend direction (increasing, decreasing, stable)' })
  trend!: string;

  @ApiProperty({ description: 'Expected resolution time in hours' })
  expectedResolutionTime!: number;
}

export class VillaDistributionDto {
  @ApiProperty({ description: 'Villa number' })
  villaNumber!: string;

  @ApiProperty({ description: 'Count of tickets for this villa' })
  count!: number;

  @ApiProperty({ description: 'Percentage of total tickets' })
  percentage!: number;
}

export class TechnicianPerformanceDto {
  @ApiProperty({ description: 'Technician ID' })
  technicianId!: string;

  @ApiProperty({ description: 'Technician name' })
  technicianName!: string;

  @ApiProperty({ description: 'Total tickets assigned' })
  totalTickets!: number;

  @ApiProperty({ description: 'Tickets completed' })
  completedTickets!: number;

  @ApiProperty({ description: 'Average resolution time in hours' })
  averageResolutionTime!: number;

  @ApiProperty({ description: 'Completion rate percentage' })
  completionRate!: number;
}

export class DashboardAnalyticsDto {
  @ApiProperty({ description: 'Status distribution', type: [StatusDistributionDto] })
  statusDistribution!: StatusDistributionDto[];

  @ApiProperty({ description: 'Priority distribution', type: [PriorityDistributionDto] })
  priorityDistribution!: PriorityDistributionDto[];

  @ApiProperty({ description: 'Department distribution', type: [DepartmentDistributionDto] })
  departmentDistribution!: DepartmentDistributionDto[];

  @ApiProperty({ description: 'Villa distribution', type: [VillaDistributionDto] })
  villaDistribution!: VillaDistributionDto[];

  @ApiProperty({ description: 'Technician performance', type: [TechnicianPerformanceDto] })
  technicianPerformance!: TechnicianPerformanceDto[];

  @ApiProperty({ description: 'Trend data over time', type: [TrendDataPointDto] })
  trends!: TrendDataPointDto[];

  @ApiProperty({ description: 'Performance metrics', type: PerformanceMetricsDto })
  performance!: PerformanceMetricsDto;

  @ApiProperty({ description: 'Predictions', type: PredictionDto })
  predictions!: PredictionDto;
}

