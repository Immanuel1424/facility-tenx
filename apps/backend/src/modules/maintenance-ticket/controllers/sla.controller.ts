import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  UseGuards,
  HttpCode,
  HttpStatus,
  Version,
} from '@nestjs/common';
import { SlaService } from '../services/sla.service';
import { SystemConfigService } from '../services/system-config.service';
import { CreateSlaConfigurationDto } from '../dto/create-sla-configuration.dto';
import { UpdateSlaConfigurationDto } from '../dto/update-sla-configuration.dto';
import { UpdateEscalationSchedulerConfigDto } from '../dto/update-escalation-scheduler-config.dto';
import { CurrentUser, CurrentUserData } from '../../iam/decorators/current-user.decorator';
import { RolesGuard, RequireRoles } from '../guards/roles.guard';
import { UserRole } from '../enums/user-role.enum';
import { ApiResponseUtil } from '../../../shared/utils/api-response.util';

@Controller('sla')
@UseGuards(RolesGuard)
export class SlaController {
  constructor(
    private readonly slaService: SlaService,
    private readonly systemConfigService: SystemConfigService,
  ) {}

  // SLA Configuration Endpoints
  @Post('configurations')
  @Version('1')
  @RequireRoles(UserRole.ADMIN)
  async createConfiguration(
    @CurrentUser() user: CurrentUserData,
    @Body() createDto: CreateSlaConfigurationDto,
  ) {
    const config = await this.slaService.createConfiguration(
      user.companyId,
      user.userId,
      createDto,
    );
    return ApiResponseUtil.created(config, 'SLA configuration created successfully');
  }

  @Get('configurations')
  @Version('1')
  @RequireRoles(UserRole.ADMIN, UserRole.SITE_COORDINATOR)
  async findAllConfigurations(@CurrentUser() user: CurrentUserData) {
    const configs = await this.slaService.findAllConfigurations(user.companyId);
    return ApiResponseUtil.success(configs, 'SLA configurations retrieved successfully');
  }

  @Get('configurations/active')
  @Version('1')
  @RequireRoles(UserRole.ADMIN, UserRole.SITE_COORDINATOR)
  async findActiveConfigurations(@CurrentUser() user: CurrentUserData) {
    const configs = await this.slaService.findActiveConfigurations(user.companyId);
    return ApiResponseUtil.success(configs, 'Active SLA configurations retrieved successfully');
  }

  @Get('configurations/:id')
  @Version('1')
  @RequireRoles(UserRole.ADMIN, UserRole.SITE_COORDINATOR)
  async findConfigurationById(
    @CurrentUser() user: CurrentUserData,
    @Param('id') id: string,
  ) {
    const config = await this.slaService.findConfigurationById(user.companyId, id);
    return ApiResponseUtil.success(config, 'SLA configuration retrieved successfully');
  }

  @Put('configurations/:id')
  @Version('1')
  @RequireRoles(UserRole.ADMIN)
  async updateConfiguration(
    @CurrentUser() user: CurrentUserData,
    @Param('id') id: string,
    @Body() updateDto: UpdateSlaConfigurationDto,
  ) {
    const config = await this.slaService.updateConfiguration(
      user.companyId,
      id,
      updateDto,
    );
    return ApiResponseUtil.success(config, 'SLA configuration updated successfully');
  }

  @Delete('configurations/:id')
  @Version('1')
  @RequireRoles(UserRole.ADMIN)
  @HttpCode(HttpStatus.OK)
  async deleteConfiguration(
    @CurrentUser() user: CurrentUserData,
    @Param('id') id: string,
  ) {
    await this.slaService.deleteConfiguration(user.companyId, id);
    return ApiResponseUtil.noContent('SLA configuration deleted successfully');
  }

  // SLA Metrics Endpoints
  @Get('metrics')
  @Version('1')
  @RequireRoles(UserRole.ADMIN, UserRole.SITE_COORDINATOR)
  async getMetrics(@CurrentUser() user: CurrentUserData) {
    const metrics = await this.slaService.getSlaMetrics(user.companyId);
    return ApiResponseUtil.success(metrics, 'SLA metrics retrieved successfully');
  }

  @Get('breached')
  @Version('1')
  @RequireRoles(UserRole.ADMIN, UserRole.SITE_COORDINATOR, UserRole.SUPERVISOR)
  async getBreachedTickets(@CurrentUser() user: CurrentUserData) {
    const tickets = await this.slaService.getBreachedTickets(user.companyId);
    return ApiResponseUtil.success(tickets, 'Breached tickets retrieved successfully');
  }

  @Get('at-risk')
  @Version('1')
  @RequireRoles(UserRole.ADMIN, UserRole.SITE_COORDINATOR, UserRole.SUPERVISOR)
  async getAtRiskTickets(@CurrentUser() user: CurrentUserData) {
    const tickets = await this.slaService.getAtRiskTickets(user.companyId);
    return ApiResponseUtil.success(tickets, 'At-risk tickets retrieved successfully');
  }

  // Ticket-specific SLA Endpoints
  @Get('tickets/:ticketId')
  @Version('1')
  async getTicketSla(
    @CurrentUser() user: CurrentUserData,
    @Param('ticketId') ticketId: string,
  ) {
    const sla = await this.slaService.getTicketSla(user.companyId, ticketId);
    return ApiResponseUtil.success(sla, 'Ticket SLA retrieved successfully');
  }

  // Escalation Scheduler Configuration Endpoints
  @Get('escalation-scheduler/config')
  @Version('1')
  @RequireRoles(UserRole.ADMIN)
  async getEscalationSchedulerConfig(@CurrentUser() user: CurrentUserData) {
    const config = await this.systemConfigService.getEscalationSchedulerConfig(
      user.companyId,
    );
    return ApiResponseUtil.success(
      config,
      'Escalation scheduler configuration retrieved successfully',
    );
  }

  @Put('escalation-scheduler/config')
  @Version('1')
  @RequireRoles(UserRole.ADMIN)
  async updateEscalationSchedulerConfig(
    @CurrentUser() user: CurrentUserData,
    @Body() dto: UpdateEscalationSchedulerConfigDto,
  ) {
    const config = await this.systemConfigService.updateEscalationSchedulerConfig(
      user.companyId,
      dto,
    );
    return ApiResponseUtil.success(
      { intervalMinutes: parseInt(config.value, 10) },
      'Escalation scheduler configuration updated successfully. Note: Changes will take effect after server restart.',
    );
  }
}

