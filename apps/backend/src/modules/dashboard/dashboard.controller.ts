import { Controller, Get, Query, UseGuards, Version } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOkResponse,
  ApiOperation,
  ApiQuery,
  ApiTags,
} from '@nestjs/swagger';
import { DashboardService } from './dashboard.service';
import { DashboardStatsDto } from './dto/dashboard-stats.dto';
import { DashboardAnalyticsDto } from './dto/dashboard-analytics.dto';
import { CurrentUser, CurrentUserData } from '../iam/decorators/current-user.decorator';
import { ApiResponseUtil } from '../../shared/utils/api-response.util';

@ApiTags('dashboard')
@ApiBearerAuth('access-token')
@Controller('dashboard')
export class DashboardController {
  constructor(private readonly dashboardService: DashboardService) {}

  @Get('stats')
  @Version('1')
  @ApiOperation({
    summary: 'Get dashboard statistics',
    description:
      'Returns aggregated statistics for the dashboard including service request counts, user counts, and completion metrics.',
  })
  @ApiOkResponse({
    description: 'Dashboard statistics',
    type: DashboardStatsDto,
  })
  @ApiQuery({
    name: 'role',
    required: false,
    description: 'Optional role filter for role-specific statistics',
  })
  async getStats(
    @CurrentUser() user: CurrentUserData,
    @Query('role') role?: string,
  ) {
    if (!user || !user.companyId) {
      throw new Error('User or company ID is missing');
    }
    
    const stats = await this.dashboardService.getStats(
      user.companyId,
      role,
      user.userId,
    );
    return ApiResponseUtil.success(stats, 'Dashboard statistics retrieved successfully');
  }

  @Get('analytics')
  @Version('1')
  @ApiOperation({
    summary: 'Get dashboard analytics',
    description:
      'Returns detailed analytics including distributions, trends, performance metrics, and predictions.',
  })
  @ApiOkResponse({
    description: 'Dashboard analytics',
    type: DashboardAnalyticsDto,
  })
  @ApiQuery({
    name: 'role',
    required: false,
    description: 'Optional role filter for role-specific analytics',
  })
  @ApiQuery({
    name: 'period',
    required: false,
    enum: ['daily', 'weekly', 'monthly'],
    description: 'Time period for trend analysis',
  })
  async getAnalytics(
    @CurrentUser() user: CurrentUserData,
    @Query('role') role?: string,
    @Query('period') period: 'daily' | 'weekly' | 'monthly' = 'weekly',
  ) {
    if (!user || !user.companyId) {
      throw new Error('User or company ID is missing');
    }
    
    const analytics = await this.dashboardService.getAnalytics(
      user.companyId,
      role,
      user.userId,
      period,
    );
    return ApiResponseUtil.success(analytics, 'Dashboard analytics retrieved successfully');
  }
}

