import {
  Controller,
  Get,
  Query,
  Param,
  UseGuards,
  Version,
} from '@nestjs/common';
import { AuditService } from './audit.service';
import { QueryAuditLogDto } from './dto/query-audit-log.dto';
import { CurrentUser, CurrentUserData } from '../iam/decorators/current-user.decorator';
import { RolesGuard, RequireRoles } from '../maintenance-ticket/guards/roles.guard';
import { UserRole } from '../maintenance-ticket/enums/user-role.enum';
import { ApiResponseUtil } from '../../shared/utils/api-response.util';
import { AuditResourceType } from './entities/audit-log.entity';

@Controller('audit-logs')
@UseGuards(RolesGuard)
@RequireRoles(UserRole.ADMIN)
export class AuditController {
  constructor(private readonly auditService: AuditService) {}

  @Get()
  @Version('1')
  async findAll(
    @CurrentUser() user: CurrentUserData,
    @Query() queryDto: QueryAuditLogDto,
  ) {
    const { logs, total } = await this.auditService.findAll(
      user.companyId,
      queryDto,
    );
    return ApiResponseUtil.paginated(
      logs,
      total,
      queryDto.page || 1,
      queryDto.limit || 20,
      'Audit logs retrieved successfully',
    );
  }

  @Get('recent')
  @Version('1')
  async getRecentActivity(
    @CurrentUser() user: CurrentUserData,
    @Query('limit') limit?: string,
  ) {
    const logs = await this.auditService.getRecentActivity(
      user.companyId,
      limit ? parseInt(limit, 10) : 10,
    );
    return ApiResponseUtil.success(logs, 'Recent activity retrieved successfully');
  }

  @Get('summary')
  @Version('1')
  async getSummary(
    @CurrentUser() user: CurrentUserData,
    @Query('start_date') startDate: string,
    @Query('end_date') endDate: string,
  ) {
    const start = startDate ? new Date(startDate) : new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
    const end = endDate ? new Date(endDate) : new Date();

    const summary = await this.auditService.getAuditSummary(
      user.companyId,
      start,
      end,
    );
    return ApiResponseUtil.success(summary, 'Audit summary retrieved successfully');
  }

  @Get('user/:userId')
  @Version('1')
  async findByUserId(
    @CurrentUser() user: CurrentUserData,
    @Param('userId') userId: string,
    @Query('limit') limit?: string,
  ) {
    const logs = await this.auditService.findByUserId(
      user.companyId,
      userId,
      limit ? parseInt(limit, 10) : 50,
    );
    return ApiResponseUtil.success(logs, 'User audit logs retrieved successfully');
  }

  @Get('resource/:resourceType/:resourceId')
  @Version('1')
  async findByResource(
    @CurrentUser() user: CurrentUserData,
    @Param('resourceType') resourceType: AuditResourceType,
    @Param('resourceId') resourceId: string,
  ) {
    const logs = await this.auditService.findByResourceId(
      user.companyId,
      resourceType,
      resourceId,
    );
    return ApiResponseUtil.success(logs, 'Resource audit logs retrieved successfully');
  }
}

