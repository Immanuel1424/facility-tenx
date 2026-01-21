import {
  Controller,
  Get,
  Post,
  Put,
  Patch,
  Body,
  Param,
  Query,
  UseGuards,
  HttpCode,
  HttpStatus,
  Version,
} from '@nestjs/common';
import { ApiOperation, ApiTags, ApiOkResponse } from '@nestjs/swagger';
import { plainToInstance } from 'class-transformer';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, SelectQueryBuilder } from 'typeorm';
import { MaintenanceTicketService } from '../services/maintenance-ticket.service';
import { EscalationService } from '../services/escalation.service';
import { CreateTicketDto } from '../dto/create-ticket.dto';
import { UpdateTicketDto } from '../dto/update-ticket.dto';
import { ChangeStatusDto } from '../dto/change-status.dto';
import { AssignSupervisorDto } from '../dto/assign-supervisor.dto';
import { AssignTechnicianDto } from '../dto/assign-technician.dto';
import { AssignTeamDto } from '../dto/assign-team.dto';
import { QueryTicketDto } from '../dto/query-ticket.dto';
import { AddNotesDto } from '../dto/add-notes.dto';
import { SubmitRatingDto } from '../dto/submit-rating.dto';
import { AnalyzeTicketDescriptionDto } from '../dto/analyze-ticket-description.dto';
import { AiTicketAnalysisResponseDto } from '../dto/ai-ticket-analysis-response.dto';
import { EscalateTicketDto } from '../dto/escalate-ticket.dto';
import { GeminiAiService } from '../services/gemini-ai.service';
import { CurrentUser, CurrentUserData } from '../../iam/decorators/current-user.decorator';
import { RolesGuard, RequireRoles } from '../guards/roles.guard';
import { TicketOwnershipGuard } from '../guards/ticket-ownership.guard';
import { UserRole } from '../enums/user-role.enum';
import { ApiResponseUtil } from '../../../shared/utils/api-response.util';
import { Team } from '../entities/team.entity';

@ApiTags('maintenance-tickets')
@Controller('maintenance-tickets')
@UseGuards(RolesGuard)
export class MaintenanceTicketController {
  constructor(
    private readonly ticketService: MaintenanceTicketService,
    private readonly escalationService: EscalationService,
    private readonly geminiAiService: GeminiAiService,
    @InjectRepository(Team)
    private readonly teamRepository: Repository<Team>,
  ) {}

  @Post('analyze-description')
  @Version('1')
  @RequireRoles(UserRole.TENANT, UserRole.ADMIN)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Analyze ticket description using AI' })
  @ApiOkResponse({
    description: 'Ticket analysis completed successfully',
    type: AiTicketAnalysisResponseDto,
  })
  async analyzeDescription(
    @Body() dto: AnalyzeTicketDescriptionDto,
  ): Promise<AiTicketAnalysisResponseDto> {
    const analysis = await this.geminiAiService.analyzeTicketDescription(
      dto.description,
    );
    // Ensure proper serialization to match frontend DTO format
    return plainToInstance(AiTicketAnalysisResponseDto, analysis, {
      excludeExtraneousValues: false,
    });
  }

  @Post()
  @Version('1')
  @RequireRoles(UserRole.TENANT, UserRole.ADMIN)
  async create(
    @CurrentUser() user: CurrentUserData,
    @Body() createDto: CreateTicketDto,
  ) {
    return this.ticketService.create(
      user.companyId,
      user.userId,
      createDto,
    );
  }

  @Get('tenant/villas')
  @Version('1')
  @RequireRoles(UserRole.TENANT)
  async getTenantVillas(@CurrentUser() user: CurrentUserData) {
    const villas = await this.ticketService.getTenantVillas(
      user.companyId,
      user.userId,
    );
    return ApiResponseUtil.success(
      villas,
      'Tenant villas retrieved successfully',
    );
  }

  @Get()
  @Version('1')
  @RequireRoles(
    UserRole.TENANT,
    UserRole.ADMIN,
    UserRole.SITE_COORDINATOR,
    UserRole.SUPERVISOR,
    UserRole.TECHNICIAN,
  )
  async findAll(
    @CurrentUser() user: CurrentUserData,
    @Query() queryDto: QueryTicketDto,
  ) {
    const { tickets, total } = await this.ticketService.findAll(
      user.companyId,
      user.userId,
      user.roles || [],
      queryDto,
    );
    
    // Return custom structure with 'tickets' key to match Flutter DTO expectations
    const page = queryDto.page || 1;
    const limit = queryDto.limit || 20;
    const totalPages = Math.ceil(total / limit);
    
    return ApiResponseUtil.success(
      {
        tickets,
        total,
        page,
        limit,
        total_pages: totalPages,
        has_next: page < totalPages,
        has_previous: page > 1,
      },
      'Maintenance tickets retrieved successfully',
    );
  }

  @Get(':id/children')
  @Version('1')
  @UseGuards(TicketOwnershipGuard)
  @RequireRoles(
    UserRole.TENANT,
    UserRole.ADMIN,
    UserRole.SITE_COORDINATOR,
    UserRole.SUPERVISOR,
    UserRole.TECHNICIAN,
  )
  async getChildTickets(
    @CurrentUser() user: CurrentUserData,
    @Param('id') id: string,
  ) {
    const childTickets = await this.ticketService.getChildTickets(
      user.companyId,
      id,
      user.userId,
    );
    return ApiResponseUtil.success(
      childTickets,
      'Child tickets retrieved successfully',
    );
  }

  @Get(':id')
  @Version('1')
  @UseGuards(TicketOwnershipGuard)
  async findOne(
    @CurrentUser() user: CurrentUserData,
    @Param('id') id: string,
  ) {
    const ticket = await this.ticketService.findOne(user.companyId, id, user.userId);
    return ApiResponseUtil.success(ticket, 'Ticket retrieved successfully');
  }

  @Put(':id')
  @Version('1')
  @UseGuards(TicketOwnershipGuard)
  async update(
    @CurrentUser() user: CurrentUserData,
    @Param('id') id: string,
    @Body() updateDto: UpdateTicketDto,
  ) {
    return this.ticketService.update(
      user.companyId,
      id,
      user.userId,
      updateDto,
    );
  }

  @Patch(':id/status')
  @Version('1')
  @RequireRoles(
    UserRole.ADMIN,
    UserRole.SITE_COORDINATOR,
    UserRole.SUPERVISOR,
    UserRole.TECHNICIAN,
    UserRole.TENANT,
  )
  async changeStatus(
    @CurrentUser() user: CurrentUserData,
    @Param('id') id: string,
    @Body() changeStatusDto: ChangeStatusDto,
  ) {
    return this.ticketService.changeStatus(
      user.companyId,
      id,
      user.userId,
      changeStatusDto,
    );
  }


  @Post(':id/acknowledge')
  @Version('1')
  @RequireRoles(UserRole.ADMIN, UserRole.SITE_COORDINATOR)
  @HttpCode(HttpStatus.OK)
  async acknowledge(
    @CurrentUser() user: CurrentUserData,
    @Param('id') id: string,
  ) {
    return this.ticketService.acknowledge(
      user.companyId,
      id,
      user.userId,
    );
  }

  @Post(':id/cancel')
  @Version('1')
  @RequireRoles(UserRole.ADMIN, UserRole.TENANT)
  @HttpCode(HttpStatus.OK)
  async cancel(
    @CurrentUser() user: CurrentUserData,
    @Param('id') id: string,
  ) {
    return this.ticketService.cancel(
      user.companyId,
      id,
      user.userId,
    );
  }

  @Post(':id/technician-notes')
  @Version('1')
  @RequireRoles(
    UserRole.ADMIN,
    UserRole.SUPERVISOR,
    UserRole.TECHNICIAN,
  )
  async addTechnicianNotes(
    @CurrentUser() user: CurrentUserData,
    @Param('id') id: string,
    @Body() notesDto: AddNotesDto,
  ) {
    return this.ticketService.addTechnicianNotes(
      user.companyId,
      id,
      user.userId,
      notesDto,
    );
  }

  @Post(':id/resolution-notes')
  @Version('1')
  @RequireRoles(
    UserRole.ADMIN,
    UserRole.SUPERVISOR,
    UserRole.TECHNICIAN,
  )
  async addResolutionNotes(
    @CurrentUser() user: CurrentUserData,
    @Param('id') id: string,
    @Body() notesDto: AddNotesDto,
  ) {
    return this.ticketService.addResolutionNotes(
      user.companyId,
      id,
      user.userId,
      notesDto,
    );
  }

  @Post(':id/confirm-completion')
  @Version('1')
  @RequireRoles(UserRole.ADMIN, UserRole.TENANT)
  @HttpCode(HttpStatus.OK)
  async confirmCompletion(
    @CurrentUser() user: CurrentUserData,
    @Param('id') id: string,
  ) {
    const ticket = await this.ticketService.confirmCompletion(
      user.companyId,
      id,
      user.userId,
    );
    return ApiResponseUtil.success(ticket, 'Ticket completion confirmed');
  }

  @Post(':id/rating')
  @Version('1')
  @RequireRoles(UserRole.ADMIN, UserRole.TENANT)
  @HttpCode(HttpStatus.OK)
  async submitRating(
    @CurrentUser() user: CurrentUserData,
    @Param('id') id: string,
    @Body() submitRatingDto: SubmitRatingDto,
  ) {
    const ticket = await this.ticketService.submitRating(
      user.companyId,
      id,
      user.userId,
      submitRatingDto.rating,
      submitRatingDto.comment,
    );
    return ApiResponseUtil.success(ticket, 'Rating submitted successfully');
  }

  @Post(':id/assign-supervisor')
  @Version('1')
  @RequireRoles(UserRole.ADMIN, UserRole.SITE_COORDINATOR)
  @HttpCode(HttpStatus.OK)
  async assignToSupervisor(
    @CurrentUser() user: CurrentUserData,
    @Param('id') id: string,
    @Body() assignDto: AssignSupervisorDto,
  ) {
    const ticket = await this.ticketService.assignToSupervisor(
      user.companyId,
      id,
      user.userId,
      assignDto.supervisor_id,
      assignDto.department_id,
      assignDto.priority,
    );
    return ApiResponseUtil.success(ticket, 'Ticket assigned to supervisor');
  }

  @Post(':id/assign-technician')
  @Version('1')
  @RequireRoles(UserRole.ADMIN, UserRole.SITE_COORDINATOR, UserRole.SUPERVISOR)
  @HttpCode(HttpStatus.OK)
  async assignToTechnician(
    @CurrentUser() user: CurrentUserData,
    @Param('id') id: string,
    @Body() assignDto: AssignTechnicianDto,
  ) {
    const ticket = await this.ticketService.assignToTechnician(
      user.companyId,
      id,
      user.userId,
      assignDto.technician_id,
      assignDto.scheduled_at,
    );
    return ApiResponseUtil.success(ticket, 'Ticket assigned to technician');
  }

  @Post(':id/assign-team')
  @Version('1')
  @RequireRoles(UserRole.ADMIN, UserRole.SITE_COORDINATOR, UserRole.SUPERVISOR)
  @HttpCode(HttpStatus.OK)
  async assignToTeam(
    @CurrentUser() user: CurrentUserData,
    @Param('id') id: string,
    @Body() assignDto: AssignTeamDto,
  ) {
    const ticket = await this.ticketService.assignToTeam(
      user.companyId,
      id,
      user.userId,
      assignDto.team_id,
    );
    return ApiResponseUtil.success(ticket, 'Ticket assigned to team');
  }

  @Get('lookup/teams')
  @Version('1')
  @RequireRoles(
    UserRole.ADMIN,
    UserRole.SITE_COORDINATOR,
    UserRole.SUPERVISOR,
    UserRole.TECHNICIAN,
  )
  async getTeams(
    @CurrentUser() user: CurrentUserData,
    @Query('department_id') departmentId?: string,
    @Query('is_active') isActive?: string,
  ) {
    // Use query builder to select only columns that exist in database
    const queryBuilder = this.teamRepository
      .createQueryBuilder('team')
      .leftJoinAndSelect('team.department', 'department')
      .leftJoinAndSelect('team.leadUser', 'leadUser')
      .where('team.companyId = :companyId', { companyId: user.companyId })
      .orderBy('team.name', 'ASC');

    if (departmentId) {
      queryBuilder.andWhere('team.departmentId = :departmentId', {
        departmentId,
      });
    }

    if (isActive !== undefined) {
      queryBuilder.andWhere('team.isActive = :isActive', {
        isActive: isActive === 'true',
      });
    }

    // Select only columns that exist (excluding colorCode)
    queryBuilder.select([
      'team.id',
      'team.name',
      'team.description',
      'team.departmentId',
      'team.leadUserId',
      'team.isActive',
      'team.createdAt',
      'team.updatedAt',
      'department.id',
      'department.name',
      'leadUser.id',
      'leadUser.email',
      'leadUser.firstName',
      'leadUser.lastName',
    ]);

    const teams = await queryBuilder.getMany();

    return teams.map((team) => ({
      id: team.id,
      name: team.name,
      display_name: team.name, // For compatibility with frontend
      description: team.description,
      department_id: team.departmentId,
      department: team.department
        ? {
            id: team.department.id,
            name: team.department.name,
          }
        : null,
      lead_user_id: team.leadUserId,
      lead_user: team.leadUser
        ? {
            id: team.leadUser.id,
            email: team.leadUser.email,
            firstName: team.leadUser.firstName,
            lastName: team.leadUser.lastName,
          }
        : null,
      is_active: team.isActive,
      // color_code: team.colorCode, // Removed - column doesn't exist in database yet
      created_at: team.createdAt,
      updated_at: team.updatedAt,
    }));
  }

  @Post(':id/escalate')
  @Version('1')
  @RequireRoles(UserRole.ADMIN, UserRole.SITE_COORDINATOR, UserRole.SUPERVISOR)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Manually escalate a ticket' })
  @ApiOkResponse({ description: 'Ticket escalated successfully' })
  async escalateTicket(
    @CurrentUser() user: CurrentUserData,
    @Param('id') id: string,
    @Body() dto: EscalateTicketDto,
  ) {
    const escalationHistory = await this.escalationService.escalateTicketManually(
      user.companyId,
      id,
      dto.escalation_level,
      dto.reason,
      user.userId,
    );
    return ApiResponseUtil.success(
      escalationHistory,
      'Ticket escalated successfully',
    );
  }

  @Get('escalated')
  @Version('1')
  @RequireRoles(
    UserRole.ADMIN,
    UserRole.SITE_COORDINATOR,
    UserRole.SUPERVISOR,
  )
  @ApiOperation({ summary: 'Get all escalated tickets' })
  @ApiOkResponse({ description: 'Escalated tickets retrieved successfully' })
  async getEscalatedTickets(
    @CurrentUser() user: CurrentUserData,
    @Query() queryDto: QueryTicketDto,
  ) {
    const tickets = await this.ticketService.findAll(
      user.companyId,
      user.userId,
      user.roles || [],
      {
        ...queryDto,
        is_escalated: true,
      },
    );
    return ApiResponseUtil.success(
      tickets,
      'Escalated tickets retrieved successfully',
    );
  }

  @Get(':id/escalation-history')
  @Version('1')
  @RequireRoles(
    UserRole.ADMIN,
    UserRole.SITE_COORDINATOR,
    UserRole.SUPERVISOR,
  )
  @ApiOperation({ summary: 'Get escalation history for a ticket' })
  @ApiOkResponse({ description: 'Escalation history retrieved successfully' })
  async getEscalationHistory(
    @CurrentUser() user: CurrentUserData,
    @Param('id') id: string,
  ) {
    const history = await this.escalationService.getEscalationHistory(
      user.companyId,
      id,
    );
    return ApiResponseUtil.success(
      history,
      'Escalation history retrieved successfully',
    );
  }

  @Get('escalation-matrix')
  @Version('1')
  @RequireRoles(UserRole.ADMIN, UserRole.SITE_COORDINATOR)
  @ApiOperation({ summary: 'Get escalation matrix configuration' })
  @ApiOkResponse({
    description: 'Escalation matrix configuration retrieved successfully',
  })
  async getEscalationMatrix(@CurrentUser() user: CurrentUserData) {
    const matrix = await this.escalationService.getEscalationMatrix(
      user.companyId,
    );
    return ApiResponseUtil.success(
      matrix,
      'Escalation matrix configuration retrieved successfully',
    );
  }
}

