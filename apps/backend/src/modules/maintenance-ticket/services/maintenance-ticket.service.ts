import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
  Logger,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, FindOptionsWhere, ILike } from 'typeorm';
import { MaintenanceTicket } from '../entities/maintenance-ticket.entity';
import { TicketStatusHistory } from '../entities/ticket-status-history.entity';
import { Department } from '../entities/department.entity';
import { TicketCategory } from '../entities/ticket-category.entity';
import { Team } from '../entities/team.entity';
import { User } from '../../iam/entities/user.entity';
import { TicketStatus } from '../enums/ticket-status.enum';
import { TicketPriority } from '../enums/ticket-priority.enum';
import { UserRole } from '../enums/user-role.enum';
import { CreateTicketDto } from '../dto/create-ticket.dto';
import { UpdateTicketDto } from '../dto/update-ticket.dto';
import { ChangeStatusDto } from '../dto/change-status.dto';
import { QueryTicketDto } from '../dto/query-ticket.dto';
import { AddNotesDto } from '../dto/add-notes.dto';
import { StatusTransitionService } from './status-transition.service';
import {
  PRIORITY_METADATA,
  PriorityDetails,
} from '../constants/priority-metadata.constant';
import { EmailService } from '../../auth/services/email.service';
import { UserService } from '../../iam/services/user.service';
import { TicketAttachmentService } from './ticket-attachment.service';
import { TicketAttachment, AttachmentContext } from '../entities/ticket-attachment.entity';
import { ConfigService } from '@nestjs/config';
import { UserStatus } from '../../iam/entities/user.entity';
import { NotificationService } from '../../notification/notification.service';
import { TemplateSeedService } from '../../notification/services/template-seed.service';
import { NotificationSeverity } from '../../notification/enums/notification-severity.enum';
import { NotificationTemplate } from '../../notification/entities/notification-template.entity';
import { NotificationChannel } from '../../notification/enums/notification-channel.enum';
import { SlaService } from './sla.service';
import * as path from 'path';

@Injectable()
export class MaintenanceTicketService {
  private readonly logger = new Logger(MaintenanceTicketService.name);

  constructor(
    @InjectRepository(MaintenanceTicket)
    private readonly ticketRepository: Repository<MaintenanceTicket>,
    @InjectRepository(TicketStatusHistory)
    private readonly statusHistoryRepository: Repository<TicketStatusHistory>,
    @InjectRepository(Department)
    private readonly departmentRepository: Repository<Department>,
    @InjectRepository(TicketCategory)
    private readonly categoryRepository: Repository<TicketCategory>,
    @InjectRepository(Team)
    private readonly teamRepository: Repository<Team>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(TicketAttachment)
    private readonly attachmentRepository: Repository<TicketAttachment>,
    @InjectRepository(NotificationTemplate)
    private readonly notificationTemplateRepository: Repository<NotificationTemplate>,
    private readonly statusTransitionService: StatusTransitionService,
    private readonly emailService: EmailService,
    private readonly userService: UserService,
    private readonly ticketAttachmentService: TicketAttachmentService,
    private readonly configService: ConfigService,
    private readonly notificationService: NotificationService,
    private readonly templateSeedService: TemplateSeedService,
    private readonly slaService: SlaService,
  ) {}

  async generateTicketNumber(companyId: string): Promise<string> {
    const year = new Date().getFullYear();
    const prefix = `TKT-${year}-`;

    const lastTicket = await this.ticketRepository.findOne({
      where: {
        companyId,
        ticketNumber: ILike(`${prefix}%`),
      } as FindOptionsWhere<MaintenanceTicket>,
      order: { createdAt: 'DESC' },
    });

    if (!lastTicket) {
      return `${prefix}0001`;
    }

    const lastNumber = parseInt(
      lastTicket.ticketNumber.replace(prefix, ''),
      10,
    );
    const nextNumber = (lastNumber + 1).toString().padStart(4, '0');

    return `${prefix}${nextNumber}`;
  }

  async create(
    companyId: string,
    userId: string,
    createDto: CreateTicketDto,
  ): Promise<MaintenanceTicket> {
    const user = await this.userRepository.findOne({
      where: { id: userId, companyId },
      relations: ['userRoles', 'userRoles.role'],
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Enforce villa scoping for tenant users (multi-villa aware)
    const userRoles = user.userRoles?.map((ur) => ur.role.name) ?? [];
    const isTenantOnly =
      userRoles.includes(UserRole.TENANT) &&
      !userRoles.includes(UserRole.ADMIN) &&
      !userRoles.includes(UserRole.SITE_COORDINATOR) &&
      !userRoles.includes(UserRole.SUPERVISOR) &&
      !userRoles.includes(UserRole.TECHNICIAN);

    if (isTenantOnly) {
      const allowedVillaNumbers = await this.getTenantVillaNumbers(
        companyId,
        userId,
        user.villaNumber,
      );

      if (!allowedVillaNumbers.length) {
        throw new ForbiddenException(
          'You do not have any villas assigned. Please contact support.',
        );
      }

      // If tenant has multiple villas, require explicit villa_number selection
      if (allowedVillaNumbers.length > 1 && !createDto.villa_number) {
        throw new BadRequestException(
          'Please select a villa for this ticket.',
        );
      }

      // If no villa_number is provided but there is exactly one allowed villa,
      // default to that villa for convenience.
      if (!createDto.villa_number && allowedVillaNumbers.length === 1) {
        // eslint-disable-next-line no-param-reassign
        createDto.villa_number = allowedVillaNumbers[0];
      }

      if (
        createDto.villa_number != null &&
        !allowedVillaNumbers.includes(createDto.villa_number)
      ) {
        throw new ForbiddenException(
          'You can only create tickets for your own villas.',
        );
      }
    }

    const ticketNumber = await this.generateTicketNumber(companyId);

    // Look up or create category if provided
    let categoryId: string | undefined = createDto.category_id;
    if (!categoryId && createDto.category) {
      // Normalize category string: trim and prepare for code/name
      const categoryString = createDto.category.trim();
      const categoryCode = categoryString.toUpperCase().replace(/\s+/g, '_');
      const categoryName = categoryString
        .split(/\s+/)
        .map((word) => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase())
        .join(' ');

      // Try to find category by code (case-insensitive) or name (case-insensitive)
      let category = await this.categoryRepository.findOne({
        where: [
          { companyId, code: ILike(categoryCode) },
          { companyId, name: ILike(categoryName) },
          { companyId, code: ILike(categoryString) },
          { companyId, name: ILike(categoryString) },
        ],
      });

      if (!category) {
        // Category doesn't exist - create it automatically
        // Get the next display order
        const maxOrder = await this.categoryRepository
          .createQueryBuilder('category')
          .where('category.companyId = :companyId', { companyId })
          .select('MAX(category.displayOrder)', 'maxOrder')
          .getRawOne();

        const nextDisplayOrder = (maxOrder?.maxOrder ?? 0) + 1;

        category = this.categoryRepository.create({
          companyId,
          code: categoryCode,
          name: categoryName,
          description: `${categoryName} related issues`,
          displayOrder: nextDisplayOrder,
          isActive: true,
          createdById: userId,
        });

        category = await this.categoryRepository.save(category);
      }

      if (category) {
        categoryId = category.id;
      }
    }

    const ticket = this.ticketRepository.create({
      companyId,
      ticketNumber,
      villaNumber: createDto.villa_number,
      createdBy: userId,
      title: createDto.title,
      description: createDto.description,
      priority: createDto.priority ?? TicketPriority.MEDIUM,
      status: TicketStatus.NEW,
      contactNumber: createDto.contact_number,
      alternateContact: createDto.alternate_contact,
      preferredTime: createDto.preferred_time,
      locationDetail: createDto.location_detail,
      categoryId,
    });

    const savedTicket = await this.ticketRepository.save(ticket);

    await this.createStatusHistory(
      companyId,
      savedTicket.id,
      userId,
      undefined,
      TicketStatus.NEW,
      'Ticket created',
    );

    // Send email notification to admins/supervisor (non-blocking)
    // Send combined notification to admins/supervisor (email, push, and in-app) - single notification
    this.sendTicketCreationNotification(companyId, savedTicket.id, userId).catch(
      (error) => {
        this.logger.error(
          `Failed to send ticket creation notification for ticket ${savedTicket.id}:`,
          error,
        );
      },
    );

    // Send combined notification to tenant (email, push, and in-app) - single notification
    this.sendTenantTicketUpdateNotification(
      companyId,
      savedTicket.id,
      'TICKET_CREATED',
      'Your ticket has been created successfully',
    ).catch((error) => {
      this.logger.error(
        `Failed to send tenant notification for ticket ${savedTicket.id}:`,
        error,
      );
    });

    return this.findOne(companyId, savedTicket.id, userId);
  }

  async findAll(
    companyId: string,
    userId: string,
    userRoles: string[],
    queryDto: QueryTicketDto,
  ): Promise<{
    tickets: Array<MaintenanceTicket & { priority_details: PriorityDetails }>;
    total: number;
  }> {
    const user = await this.userRepository.findOne({
      where: { id: userId, companyId },
      relations: ['userRoles', 'userRoles.role'],
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const isTenant = userRoles.includes(UserRole.TENANT);
    const isAdmin = userRoles.includes(UserRole.ADMIN);
    const isSiteCoordinator = userRoles.includes(UserRole.SITE_COORDINATOR);
    const isSupervisor = userRoles.includes(UserRole.SUPERVISOR);
    const isTechnician = userRoles.includes(UserRole.TECHNICIAN);

    // Build base query for counting (without joins to avoid duplicate counts)
    const countQueryBuilder = this.ticketRepository
      .createQueryBuilder('ticket')
      .where('ticket.companyId = :companyId', { companyId });

    // Build query for fetching data (with joins)
    // Note: Using getRawAndEntities() approach to avoid loading non-existent columns
    const queryBuilder = this.ticketRepository
      .createQueryBuilder('ticket')
      .leftJoinAndSelect('ticket.creator', 'creator')
      .leftJoinAndSelect('ticket.department', 'department')
      .leftJoinAndSelect('ticket.category', 'category')
      .leftJoinAndSelect('ticket.assignedSupervisor', 'assignedSupervisor')
      .leftJoinAndSelect('ticket.assignedTechnician', 'assignedTechnician')
      .leftJoinAndSelect('ticket.assigner', 'assigner')
      .leftJoinAndSelect('ticket.acknowledger', 'acknowledger')
      .where('ticket.companyId = :companyId', { companyId });

    // Role-based filtering (strict data scoping)
    if (isTenant && !isAdmin) {
      // Tenants can ONLY see tickets for villas they are linked to.
      // Multi-villa support:
      //  - If queryDto.villa_number is provided, restrict to that villa and
      //    ensure it belongs to the tenant's allowed villas.
      //  - If not provided, show tickets for ALL of the tenant's villas.
      const allowedVillaNumbers = await this.getTenantVillaNumbers(
        companyId,
        userId,
        user.villaNumber,
        user.villaNumbers,
      );

      if (!allowedVillaNumbers.length) {
        // Tenant has no villas linked; return empty result by forcing false condition
        queryBuilder.andWhere('1 = 0');
        countQueryBuilder.andWhere('1 = 0');
      } else if (queryDto.villa_numbers && queryDto.villa_numbers.length > 0) {
        const requestedVillas = queryDto.villa_numbers;
        
        // Ensure all requested villas are allowed for this tenant
        const invalidVillas = requestedVillas.filter(v => !allowedVillaNumbers.includes(v));
        if (invalidVillas.length > 0) {
          throw new ForbiddenException(
            'You can only view tickets for your own villas',
          );
        }
        
        queryBuilder.andWhere('ticket.villaNumber IN (:...villaNumbers)', {
          villaNumbers: requestedVillas,
        });
        countQueryBuilder.andWhere('ticket.villaNumber IN (:...villaNumbers)', {
          villaNumbers: requestedVillas,
        });
      } else {
        // All-my-villas combined view
        queryBuilder.andWhere('ticket.villaNumber IN (:...villaNumbers)', {
          villaNumbers: allowedVillaNumbers,
        });
        countQueryBuilder.andWhere('ticket.villaNumber IN (:...villaNumbers)', {
          villaNumbers: allowedVillaNumbers,
        });
      }
    } else if (isTechnician && !isAdmin && !isSiteCoordinator && !isSupervisor) {
      // Technicians can ONLY see tickets assigned to them
      queryBuilder.andWhere('ticket.assignedTechnicianId = :userId', { userId });
      countQueryBuilder.andWhere('ticket.assignedTechnicianId = :userId', { userId });
    } else if (isSupervisor && !isAdmin && !isSiteCoordinator) {
      // Supervisors can see tickets assigned to them as supervisor
      // OR tickets assigned to technicians in their team (handled by department)
      queryBuilder.andWhere(
        '(ticket.assignedSupervisorId = :userId OR ticket.assignedTechnicianId = :userId)',
        { userId },
      );
      countQueryBuilder.andWhere(
        '(ticket.assignedSupervisorId = :userId OR ticket.assignedTechnicianId = :userId)',
        { userId },
      );
    }
    // Admin and Site Coordinator can see ALL tickets (no additional filter)

    // Apply query filters
    if (queryDto.status) {
      queryBuilder.andWhere('ticket.status = :status', { status: queryDto.status });
      countQueryBuilder.andWhere('ticket.status = :status', { status: queryDto.status });
    }

    if (queryDto.priority) {
      queryBuilder.andWhere('ticket.priority = :priority', { priority: queryDto.priority });
      countQueryBuilder.andWhere('ticket.priority = :priority', { priority: queryDto.priority });
    }

    // Non-tenant villa filter (e.g. ADMIN, SITE_COORDINATOR)
    if (queryDto.villa_numbers && queryDto.villa_numbers.length > 0 && (!isTenant || isAdmin)) {
      queryBuilder.andWhere('ticket.villaNumber IN (:...villaNumbers)', {
        villaNumbers: queryDto.villa_numbers,
      });
      countQueryBuilder.andWhere('ticket.villaNumber IN (:...villaNumbers)', {
        villaNumbers: queryDto.villa_numbers,
      });
    }

    if (queryDto.department_id) {
      queryBuilder.andWhere('ticket.departmentId = :departmentId', {
        departmentId: queryDto.department_id,
      });
      countQueryBuilder.andWhere('ticket.departmentId = :departmentId', {
        departmentId: queryDto.department_id,
      });
    }

    if (queryDto.assigned_technician_id) {
      queryBuilder.andWhere('ticket.assignedTechnicianId = :assignedTechnicianId', {
        assignedTechnicianId: queryDto.assigned_technician_id,
      });
      countQueryBuilder.andWhere('ticket.assignedTechnicianId = :assignedTechnicianId', {
        assignedTechnicianId: queryDto.assigned_technician_id,
      });
    }

    if (queryDto.assigned_supervisor_id) {
      queryBuilder.andWhere('ticket.assignedSupervisorId = :assignedSupervisorId', {
        assignedSupervisorId: queryDto.assigned_supervisor_id,
      });
      countQueryBuilder.andWhere('ticket.assignedSupervisorId = :assignedSupervisorId', {
        assignedSupervisorId: queryDto.assigned_supervisor_id,
      });
    }

    if (queryDto.category_id) {
      queryBuilder.andWhere('ticket.categoryId = :categoryId', {
        categoryId: queryDto.category_id,
      });
      countQueryBuilder.andWhere('ticket.categoryId = :categoryId', {
        categoryId: queryDto.category_id,
      });
    }

    if (queryDto.search) {
      const searchPattern = `%${queryDto.search}%`;
      queryBuilder.andWhere(
        '(ticket.title ILIKE :search OR ticket.description ILIKE :search OR ticket.ticketNumber ILIKE :search)',
        { search: searchPattern },
      );
      countQueryBuilder.andWhere(
        '(ticket.title ILIKE :search OR ticket.description ILIKE :search OR ticket.ticketNumber ILIKE :search)',
        { search: searchPattern },
      );
    }

    if (queryDto.is_escalated !== undefined) {
      queryBuilder.andWhere('ticket.isEscalated = :isEscalated', {
        isEscalated: queryDto.is_escalated,
      });
      countQueryBuilder.andWhere('ticket.isEscalated = :isEscalated', {
        isEscalated: queryDto.is_escalated,
      });
    }

    const total = await countQueryBuilder.getCount();

    const page = queryDto.page ?? 1;
    const limit = queryDto.limit ?? 20;

    const tickets = await queryBuilder
      .orderBy('ticket.createdAt', 'DESC')
      .skip((page - 1) * limit)
      .take(limit)
      .getMany();
    const ticketsWithPriorityDetails = tickets.map((ticket) => ({
      ...ticket,
      priority_details: PRIORITY_METADATA[ticket.priority],
    }));

    return { tickets: ticketsWithPriorityDetails, total };
  }

  async findOne(
    companyId: string,
    ticketId: string,
    userId: string,
  ): Promise<MaintenanceTicket & { priority_details: PriorityDetails; slaDueAt?: Date; slaStatus?: string }> {
    const ticket = await this.ticketRepository.findOne({
      where: { id: ticketId, companyId },
      relations: [
        'creator',
        'department',
        'category',
        'assignedTechnician',
        'assigner',
        'ratedByUser',
        'statusHistory',
        'statusHistory.changer',
      ],
    });

    if (!ticket) {
      throw new NotFoundException('Ticket not found');
    }

    const user = await this.userRepository.findOne({
      where: { id: userId, companyId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const userRoles = await this.getUserRoles(companyId, userId);
    const isTenant = userRoles.includes(UserRole.TENANT);
    const isAdmin = userRoles.includes(UserRole.ADMIN);

    if (isTenant && !isAdmin) {
      const allowedVillaNumbers = await this.getTenantVillaNumbers(
        companyId,
        userId,
        user.villaNumber,
        user.villaNumbers,
      );

      // If the ticket has no villa number, we assume it's general or allow access if strict mode isn't required. 
      // However, usually tickets must belong to a villa.
      if (
        ticket.villaNumber != null &&
        !allowedVillaNumbers.includes(String(ticket.villaNumber))
      ) {
        throw new ForbiddenException(
          'You can only access tickets for your own villa',
        );
      }
    }

    // Fetch SLA information if available
    const ticketSla = await this.slaService.getTicketSla(companyId, ticketId);
    const slaDueAt = ticketSla?.resolutionDeadline;
    const slaStatus = ticketSla?.slaStatus;

    return {
      ...ticket,
      priority_details: PRIORITY_METADATA[ticket.priority],
      slaDueAt,
      slaStatus,
    };
  }

  async getChildTickets(
    companyId: string,
    parentTicketId: string,
    userId: string,
  ): Promise<Array<MaintenanceTicket & { priority_details: PriorityDetails }>> {
    // First verify the parent ticket exists and user has access
    const parentTicket = await this.findOne(companyId, parentTicketId, userId);

    if (!parentTicket) {
      throw new NotFoundException('Parent ticket not found');
    }

    // Get child tickets
    const childTickets = await this.ticketRepository.find({
      where: { 
        companyId, 
        parentTicketId,
      },
      relations: [
        'creator',
        'department',
        'category',
        'assignedTechnician',
        'assigner',
        'statusHistory',
        'statusHistory.changer',
      ],
      order: { createdAt: 'ASC' },
    });

    // Add priority details to each ticket
    return childTickets.map((ticket) => ({
      ...ticket,
      priority_details: PRIORITY_METADATA[ticket.priority],
    }));
  }

  async update(
    companyId: string,
    ticketId: string,
    userId: string,
    updateDto: UpdateTicketDto,
  ): Promise<MaintenanceTicket> {
    const ticket = await this.findOne(companyId, ticketId, userId);
    const userRoles = await this.getUserRoles(companyId, userId);

    const isTenant = userRoles.includes(UserRole.TENANT);
    const isAdmin = userRoles.includes(UserRole.ADMIN);

    if (isTenant && !isAdmin) {
      if (ticket.status === TicketStatus.CANCELLED || ticket.status === TicketStatus.COMPLETED) {
        throw new ForbiddenException('Cannot update cancelled or completed tickets');
      }
      if (ticket.createdBy !== userId) {
        throw new ForbiddenException('You can only update your own tickets');
      }
    }

    if (updateDto.title) {
      ticket.title = updateDto.title;
    }
    if (updateDto.description !== undefined) {
      ticket.description = updateDto.description;
    }
    if (updateDto.priority) {
      ticket.priority = updateDto.priority;
    }

    return this.ticketRepository.save(ticket);
  }

  async changeStatus(
    companyId: string,
    ticketId: string,
    userId: string,
    changeStatusDto: ChangeStatusDto,
  ): Promise<MaintenanceTicket> {
    const ticket = await this.findOne(companyId, ticketId, userId);
    const userRoles = await this.getUserRoles(companyId, userId);

    const primaryRole = this.getPrimaryRole(userRoles);
    this.statusTransitionService.validateTransition(
      ticket.status,
      changeStatusDto.status,
      primaryRole,
    );

    const previousStatus = ticket.status;
    ticket.status = changeStatusDto.status;

    if (changeStatusDto.status === TicketStatus.COMPLETED) {
      ticket.completedAt = new Date();
    }

    await this.ticketRepository.save(ticket);

    await this.createStatusHistory(
      companyId,
      ticketId,
      userId,
      previousStatus,
      changeStatusDto.status,
      changeStatusDto.notes,
    );

    // Send combined notification to tenant (email, push, and in-app) - single notification
    const statusLabel = this.getStatusLabel(changeStatusDto.status);
    this.sendTenantTicketUpdateNotification(
      companyId,
      ticketId,
      'STATUS_CHANGED',
      `Ticket status updated to: ${statusLabel}`,
      { previousStatus, newStatus: changeStatusDto.status, notes: changeStatusDto.notes },
    ).catch((error) => {
      this.logger.error(
        `Failed to send tenant status update notification for ticket ${ticketId}:`,
        error,
      );
    });

    return this.findOne(companyId, ticketId, userId);
  }


  async addTechnicianNotes(
    companyId: string,
    ticketId: string,
    userId: string,
    notesDto: AddNotesDto,
  ): Promise<MaintenanceTicket> {
    const ticket = await this.findOne(companyId, ticketId, userId);
    const userRoles = await this.getUserRoles(companyId, userId);

    const isTechnician = userRoles.includes(UserRole.TECHNICIAN);
    const isAdmin = userRoles.includes(UserRole.ADMIN);
    const isSupervisor = userRoles.includes(UserRole.SUPERVISOR);

    if (!isAdmin && !isSupervisor && !isTechnician) {
      throw new ForbiddenException(
        'Only technicians, supervisors, or admins can add technician notes',
      );
    }

    if (isTechnician && !isAdmin && ticket.assignedTechnicianId !== userId) {
      throw new ForbiddenException(
        'You can only add notes to tickets assigned to you',
      );
    }

    ticket.technicianNotes = notesDto.notes;
    await this.ticketRepository.save(ticket);

    return this.findOne(companyId, ticketId, userId);
  }

  async addResolutionNotes(
    companyId: string,
    ticketId: string,
    userId: string,
    notesDto: AddNotesDto,
  ): Promise<MaintenanceTicket> {
    const ticket = await this.findOne(companyId, ticketId, userId);
    const userRoles = await this.getUserRoles(companyId, userId);

    const isTechnician = userRoles.includes(UserRole.TECHNICIAN);
    const isAdmin = userRoles.includes(UserRole.ADMIN);
    const isSupervisor = userRoles.includes(UserRole.SUPERVISOR);

    if (!isAdmin && !isSupervisor && !isTechnician) {
      throw new ForbiddenException(
        'Only technicians, supervisors, or admins can add resolution notes',
      );
    }

    if (isTechnician && !isAdmin && ticket.assignedTechnicianId !== userId) {
      throw new ForbiddenException(
        'You can only add resolution notes to tickets assigned to you',
      );
    }

    ticket.resolutionNotes = notesDto.notes;
    await this.ticketRepository.save(ticket);

    return this.findOne(companyId, ticketId, userId);
  }

  async confirmCompletion(
    companyId: string,
    ticketId: string,
    userId: string,
  ): Promise<MaintenanceTicket> {
    const ticket = await this.findOne(companyId, ticketId, userId);
    const userRoles = await this.getUserRoles(companyId, userId);

    const isTenant = userRoles.includes(UserRole.TENANT);
    const isAdmin = userRoles.includes(UserRole.ADMIN);

    if (!isTenant && !isAdmin) {
      throw new ForbiddenException(
        'Only tenants or admins can confirm completion',
      );
    }

    if (isTenant && !isAdmin) {
      const user = await this.userRepository.findOne({
        where: { id: userId, companyId },
      });
      const allowedVillaNumbers = await this.getTenantVillaNumbers(
        companyId,
        userId,
        user?.villaNumber,
      );
      if (
        !user ||
        !ticket.villaNumber ||
        !allowedVillaNumbers.includes(String(ticket.villaNumber))
      ) {
        throw new ForbiddenException(
          'You can only confirm completion for your own villa tickets',
        );
      }
    }

    if (ticket.status !== TicketStatus.COMPLETED) {
      throw new BadRequestException(
        'Ticket must be in COMPLETED status to confirm',
      );
    }

    ticket.tenantConfirmed = true;
    // Status remains COMPLETED, just mark as tenant confirmed
    ticket.closedAt = new Date();

    await this.ticketRepository.save(ticket);

    await this.createStatusHistory(
      companyId,
      ticketId,
      userId,
      TicketStatus.COMPLETED,
      TicketStatus.COMPLETED,
      'Tenant confirmed completion',
    );

    return this.findOne(companyId, ticketId, userId);
  }

  async submitRating(
    companyId: string,
    ticketId: string,
    userId: string,
    rating: number,
    comment?: string,
  ): Promise<MaintenanceTicket> {
    const ticket = await this.findOne(companyId, ticketId, userId);
    const userRoles = await this.getUserRoles(companyId, userId);

    const isTenant = userRoles.includes(UserRole.TENANT);
    const isAdmin = userRoles.includes(UserRole.ADMIN);

    if (!isTenant && !isAdmin) {
      throw new ForbiddenException(
        'Only tenants or admins can submit ratings',
      );
    }

    // Validate ticket is closed
    if (!ticket.tenantConfirmed) {
      throw new BadRequestException(
        'Rating can only be submitted for closed tickets',
      );
    }

    // Validate rating not already submitted
    if (ticket.rating !== null && ticket.rating !== undefined) {
      throw new BadRequestException('You have already rated this ticket');
    }

    // Validate rating value
    if (rating < 1 || rating > 5) {
      throw new BadRequestException('Rating must be between 1 and 5');
    }

    // Validate tenant owns the ticket (if tenant, not admin)
    if (isTenant && !isAdmin) {
      const user = await this.userRepository.findOne({
        where: { id: userId, companyId },
      });
      const allowedVillaNumbers = await this.getTenantVillaNumbers(
        companyId,
        userId,
        user?.villaNumber,
      );
      if (
        !user ||
        !ticket.villaNumber ||
        !allowedVillaNumbers.includes(String(ticket.villaNumber))
      ) {
        throw new ForbiddenException(
          'You can only rate tickets for your own villa',
        );
      }
    }

    // Save rating
    ticket.rating = rating;
    ticket.ratingComment = comment || undefined;
    ticket.ratedAt = new Date();
    ticket.ratedBy = userId;

    await this.ticketRepository.save(ticket);

    // Create status history entry
    await this.createStatusHistory(
      companyId,
      ticketId,
      userId,
      TicketStatus.COMPLETED,
      TicketStatus.COMPLETED,
      `Tenant rated ticket: ${rating} stars${comment ? ` - ${comment}` : ''}`,
    );

    // Send email notification to admins/supervisor (non-blocking, mandatory)
    this.sendRatingNotificationEmail(companyId, ticketId, userId, rating, comment).catch(
      (error) => {
        this.logger.error(
          `Failed to send rating notification email for ticket ${ticketId}:`,
          error,
        );
      },
    );

    // Send push notification to admins/supervisor (non-blocking, mandatory alongside email)
    this.sendRatingNotificationPushNotification(companyId, ticketId, userId, rating, comment).catch(
      (error) => {
        this.logger.error(
          `Failed to send rating notification push notification for ticket ${ticketId}:`,
          error,
        );
      },
    );

    return this.findOne(companyId, ticketId, userId);
  }

  async acknowledge(
    companyId: string,
    ticketId: string,
    userId: string,
  ): Promise<MaintenanceTicket> {
    const ticket = await this.findOne(companyId, ticketId, userId);
    const userRoles = await this.getUserRoles(companyId, userId);

    const isAdmin = userRoles.includes(UserRole.ADMIN);
    const isSiteCoordinator = userRoles.includes(UserRole.SITE_COORDINATOR);

    if (!isAdmin && !isSiteCoordinator) {
      throw new ForbiddenException(
        'Only ADMIN or SITE_COORDINATOR can acknowledge tickets',
      );
    }

    if (ticket.status !== TicketStatus.NEW) {
      throw new BadRequestException(
        'Only NEW tickets can be acknowledged',
      );
    }

    // Record who acknowledged the ticket
    ticket.acknowledgedBy = userId;
    ticket.acknowledgedAt = new Date();
    await this.ticketRepository.save(ticket);

    const result = await this.changeStatus(companyId, ticketId, userId, {
      status: TicketStatus.ACKNOWLEDGED,
      notes: 'Ticket acknowledged',
    });

    // Send combined notification to tenant (email, push, and in-app) - single notification
    const acknowledger = await this.userRepository.findOne({
      where: { id: userId, companyId },
    });
    const acknowledgerName = acknowledger
      ? `${acknowledger.firstName || ''} ${acknowledger.lastName || ''}`.trim() || acknowledger.email
      : 'Support Team';

    this.sendTenantTicketUpdateNotification(
      companyId,
      ticketId,
      'ACKNOWLEDGED',
      'Your ticket has been acknowledged',
      { acknowledgerName },
    ).catch((error) => {
      this.logger.error(
        `Failed to send tenant acknowledgment notification for ticket ${ticketId}:`,
        error,
      );
    });

    return result;
  }

  async assignToSupervisor(
    companyId: string,
    ticketId: string,
    userId: string,
    supervisorId: string,
    departmentId?: string,
    priority?: string,
  ): Promise<MaintenanceTicket> {
    const ticket = await this.findOne(companyId, ticketId, userId);
    const userRoles = await this.getUserRoles(companyId, userId);

    const isAdmin = userRoles.includes(UserRole.ADMIN);
    const isSiteCoordinator = userRoles.includes(UserRole.SITE_COORDINATOR);

    if (!isAdmin && !isSiteCoordinator) {
      throw new ForbiddenException(
        'Only ADMIN or SITE_COORDINATOR can assign tickets to supervisors',
      );
    }

    // Validate supervisor
    const supervisor = await this.userRepository.findOne({
      where: { id: supervisorId, companyId },
      relations: ['userRoles', 'userRoles.role'],
    });

    if (!supervisor) {
      throw new NotFoundException('Supervisor not found');
    }

    const supervisorRoles = supervisor.userRoles.map((ur) => ur.role.name);
    if (!supervisorRoles.includes(UserRole.SUPERVISOR)) {
      throw new BadRequestException('User is not a supervisor');
    }

    // Update ticket
    ticket.assignedSupervisorId = supervisorId;
    ticket.supervisorAssignedAt = new Date();
    ticket.assignedBy = userId;

    if (departmentId) {
      const department = await this.departmentRepository.findOne({
        where: { id: departmentId, companyId },
      });
      if (!department) {
        throw new NotFoundException('Department not found');
      }
      ticket.departmentId = departmentId;
    }

    if (priority) {
      ticket.priority = priority as any;
    }

    await this.ticketRepository.save(ticket);

    await this.createStatusHistory(
      companyId,
      ticketId,
      userId,
      ticket.status,
      ticket.status,
      `Assigned to supervisor ${supervisor.email}`,
    );

    // Send combined notification to tenant (email, push, and in-app) - single notification
    const supervisorName = `${supervisor.firstName || ''} ${supervisor.lastName || ''}`.trim() || supervisor.email;
    this.sendTenantTicketUpdateNotification(
      companyId,
      ticketId,
      'SUPERVISOR_ASSIGNED',
      'A supervisor has been assigned to your ticket',
      { supervisorName, supervisorEmail: supervisor.email },
    ).catch((error) => {
      this.logger.error(
        `Failed to send tenant supervisor assignment notification for ticket ${ticketId}:`,
        error,
      );
    });

    return this.findOne(companyId, ticketId, userId);
  }

  async assignToTechnician(
    companyId: string,
    ticketId: string,
    userId: string,
    technicianId: string,
    scheduledAt?: string,
  ): Promise<MaintenanceTicket> {
    const ticket = await this.findOne(companyId, ticketId, userId);
    const userRoles = await this.getUserRoles(companyId, userId);

    const isAdmin = userRoles.includes(UserRole.ADMIN);
    const isSiteCoordinator = userRoles.includes(UserRole.SITE_COORDINATOR);
    const isSupervisor = userRoles.includes(UserRole.SUPERVISOR);

    if (!isAdmin && !isSiteCoordinator && !isSupervisor) {
      throw new ForbiddenException(
        'Only ADMIN, SITE_COORDINATOR, or SUPERVISOR can assign tickets to technicians',
      );
    }

    // Supervisors can only assign tickets assigned to them
    if (isSupervisor && !isAdmin && !isSiteCoordinator) {
      if (ticket.assignedSupervisorId !== userId) {
        throw new ForbiddenException(
          'You can only assign tickets that are assigned to you as supervisor',
        );
      }
    }

    // Validate technician
    const technician = await this.userRepository.findOne({
      where: { id: technicianId, companyId },
      relations: ['userRoles', 'userRoles.role'],
    });

    if (!technician) {
      throw new NotFoundException('Technician not found');
    }

    const technicianRoles = technician.userRoles.map((ur) => ur.role.name);
    const isValidTechnician = technicianRoles.includes(UserRole.TECHNICIAN);

    if (!isValidTechnician) {
      throw new BadRequestException('User is not a technician');
    }

    // Update ticket
    const previousStatus = ticket.status;
    ticket.assignedTechnicianId = technicianId;
    ticket.assignedBy = userId;
    ticket.assignedAt = new Date();

    if (scheduledAt) {
      ticket.scheduledAt = new Date(scheduledAt);
    }

    // Transition to ASSIGNED status if acknowledged
    if (ticket.status === TicketStatus.ACKNOWLEDGED) {
      ticket.status = TicketStatus.ASSIGNED;
    }

    await this.ticketRepository.save(ticket);

    // Initialize SLA if not already initialized
    // This ensures escalation emails are sent when technician doesn't start work
    try {
      const existingSla = await this.slaService.getTicketSla(companyId, ticketId);
      if (!existingSla) {
        await this.slaService.initializeTicketSla(
          companyId,
          ticketId,
          ticket.priority,
        );
        this.logger.log(
          `Initialized SLA for ticket ${ticket.ticketNumber} (priority: ${ticket.priority})`,
        );
      }
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      this.logger.warn(
        `Failed to initialize SLA for ticket ${ticketId}: ${errorMessage}. Escalation emails may not be sent.`,
      );
      // Don't throw - SLA initialization failure shouldn't block assignment
    }

    await this.createStatusHistory(
      companyId,
      ticketId,
      userId,
      previousStatus,
      ticket.status,
      `Assigned to technician ${technician.email}`,
    );

    // Send combined notification to tenant (email, push, and in-app) - single notification
    const technicianName = `${technician.firstName || ''} ${technician.lastName || ''}`.trim() || technician.email;
    this.sendTenantTicketUpdateNotification(
      companyId,
      ticketId,
      'TECHNICIAN_ASSIGNED',
      'A technician has been assigned to your ticket',
      { technicianName, technicianEmail: technician.email, scheduledAt: ticket.scheduledAt },
    ).catch((error) => {
      this.logger.error(
        `Failed to send tenant technician assignment notification for ticket ${ticketId}:`,
        error,
      );
    });

    return this.findOne(companyId, ticketId, userId);
  }

  async assignToTeam(
    companyId: string,
    ticketId: string,
    userId: string,
    teamId: string,
  ): Promise<MaintenanceTicket> {
    const ticket = await this.findOne(companyId, ticketId, userId);
    const userRoles = await this.getUserRoles(companyId, userId);

    const isAdmin = userRoles.includes(UserRole.ADMIN);
    const isSiteCoordinator = userRoles.includes(UserRole.SITE_COORDINATOR);
    const isSupervisor = userRoles.includes(UserRole.SUPERVISOR);

    if (!isAdmin && !isSiteCoordinator && !isSupervisor) {
      throw new ForbiddenException(
        'Only ADMIN, SITE_COORDINATOR, or SUPERVISOR can assign tickets to teams',
      );
    }

    // Supervisors can only assign tickets assigned to them
    if (isSupervisor && !isAdmin && !isSiteCoordinator) {
      if (ticket.assignedSupervisorId !== userId) {
        throw new ForbiddenException(
          'You can only assign tickets that are assigned to you as supervisor',
        );
      }
    }

    // Validate team using query builder to exclude color_code column that doesn't exist yet
    const team = await this.teamRepository
      .createQueryBuilder('team')
      .leftJoinAndSelect('team.department', 'department')
      .where('team.id = :teamId', { teamId })
      .andWhere('team.companyId = :companyId', { companyId })
      .select([
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
      ])
      .getOne();

    if (!team) {
      throw new NotFoundException('Team not found');
    }

    if (!team.isActive) {
      throw new BadRequestException('Team is not active');
    }

    // Update ticket
    const previousStatus = ticket.status;
    ticket.assignedTeamId = teamId;
    ticket.assignedBy = userId;
    ticket.assignedAt = new Date();

    // If team has a department, assign to that department
    if (team.department) {
      ticket.departmentId = team.department.id;
    }

    // Transition to ASSIGNED status if acknowledged
    if (ticket.status === TicketStatus.ACKNOWLEDGED) {
      ticket.status = TicketStatus.ASSIGNED;
    }

    await this.ticketRepository.save(ticket);

    await this.createStatusHistory(
      companyId,
      ticketId,
      userId,
      previousStatus,
      ticket.status,
      `Assigned to team ${team.name}`,
    );

    // Send combined notification to tenant (email, push, and in-app) - single notification
    this.sendTenantTicketUpdateNotification(
      companyId,
      ticketId,
      'TEAM_ASSIGNED',
      'A team has been assigned to your ticket',
      { teamName: team.name },
    ).catch((error) => {
      this.logger.error(
        `Failed to send tenant team assignment notification for ticket ${ticketId}:`,
        error,
      );
    });

    return this.findOne(companyId, ticketId, userId);
  }

  async cancel(
    companyId: string,
    ticketId: string,
    userId: string,
  ): Promise<MaintenanceTicket> {
    const ticket = await this.findOne(companyId, ticketId, userId);
    const userRoles = await this.getUserRoles(companyId, userId);

    const isTenant = userRoles.includes(UserRole.TENANT);
    const isAdmin = userRoles.includes(UserRole.ADMIN);

    if (!isTenant && !isAdmin) {
      throw new ForbiddenException('Only tenants or admins can cancel tickets');
    }

    if (isTenant && !isAdmin) {
      const user = await this.userRepository.findOne({
        where: { id: userId, companyId },
      });
      const allowedVillaNumbers = await this.getTenantVillaNumbers(
        companyId,
        userId,
        user?.villaNumber,
      );
      if (
        !user ||
        !ticket.villaNumber ||
        !allowedVillaNumbers.includes(String(ticket.villaNumber))
      ) {
        throw new ForbiddenException(
          'You can only cancel tickets for your own villas',
        );
      }
      if (ticket.status === TicketStatus.COMPLETED) {
        throw new BadRequestException('Cannot cancel completed tickets');
      }
    }

    return this.changeStatus(companyId, ticketId, userId, {
      status: TicketStatus.CANCELLED,
      notes: 'Ticket cancelled',
    });
  }

  private async createStatusHistory(
    companyId: string,
    ticketId: string,
    userId: string,
    previousStatus: TicketStatus | undefined,
    newStatus: TicketStatus,
    notes?: string,
  ): Promise<TicketStatusHistory> {
    const history = this.statusHistoryRepository.create({
      companyId,
      ticketId,
      changedBy: userId,
      previousStatus,
      newStatus,
      notes,
    });

    return this.statusHistoryRepository.save(history);
  }

  private async getUserRoles(
    companyId: string,
    userId: string,
  ): Promise<string[]> {
    const user = await this.userRepository.findOne({
      where: { id: userId, companyId },
      relations: ['userRoles', 'userRoles.role'],
    });

    if (!user) {
      return [];
    }

    return user.userRoles.map((ur) => ur.role.name);
  }

    /**
   * Resolve the list of villa numbers a tenant user is allowed to access.
   * Checks:
   * 1. users.villa_numbers (JSONB array)
   * 2. user_villas mapping table (legacy/alt)
   * 3. users.villa_number (legacy single)
   */
  private async getTenantVillaNumbers(
    companyId: string,
    userId: string,
    fallbackVillaNumber?: string | null,
    villaNumbers?: string[] | null,
  ): Promise<string[]> {
    const rows: Array<{ villaNumber: string | null }> =
      await this.userRepository.query(
        `
        SELECT DISTINCT v.villa_number AS "villaNumber"
        FROM user_villas uv
        JOIN villas v
          ON v.id = uv.villa_id
         AND v.company_id = uv.company_id
        WHERE uv.company_id = $1
          AND uv.user_id = $2
      `,
        [companyId, userId],
      );

    const dbNumbers = rows
      .map((row) => row.villaNumber)
      .filter((value): value is string => value !== null && value !== undefined);

    const allNumbers = new Set<string>(dbNumbers);

    if (villaNumbers && Array.isArray(villaNumbers)) {
      villaNumbers.forEach((n) => {
        if (n != null && n !== '') {
          allNumbers.add(String(n));
        }
      });
    }

    if (fallbackVillaNumber != null && fallbackVillaNumber !== '') {
      allNumbers.add(String(fallbackVillaNumber));
    }

    return Array.from(allNumbers);
  }

  /**
   * Return the list of villas (id + metadata) the current tenant user
   * is allowed to access. This is used by the frontend to present a
   * villa selector when a tenant is linked to multiple villas.
   */
  async getTenantVillas(
    companyId: string,
    userId: string,
  ): Promise<
    Array<{
      id: string;
      villaNumber: string | null;
      villaCode: string | null;
      siteId: string | null;
      ownerName: string | null;
      tenantName: string | null;
      contactPhone: string | null;
      contactEmail: string | null;
      isActive: boolean;
      isOccupied: boolean;
    }>
  > {
    const rows: Array<{
      id: string;
      villaNumber: string | null;
      villaCode: string | null;
      siteId: string | null;
      ownerName: string | null;
      tenantName: string | null;
      contactPhone: string | null;
      contactEmail: string | null;
      isActive: boolean | null;
      isOccupied: boolean | null;
    }> = await this.userRepository.query(
      `
        SELECT
          v.id,
          v.villa_number AS "villaNumber",
          v.villa_code AS "villaCode",
          v.site_id AS "siteId",
          v.owner_name AS "ownerName",
          v.tenant_name AS "tenantName",
          v.contact_phone AS "contactPhone",
          v.contact_email AS "contactEmail",
          v.is_active AS "isActive",
          v.is_occupied AS "isOccupied"
        FROM user_villas uv
        JOIN villas v
          ON v.id = uv.villa_id
         AND v.company_id = uv.company_id
        WHERE uv.company_id = $1
          AND uv.user_id = $2
        ORDER BY v.villa_number ASC NULLS LAST
      `,
      [companyId, userId],
    );

    return rows.map((row) => ({
      id: row.id,
      villaNumber: row.villaNumber ?? null,
      villaCode: row.villaCode,
      siteId: row.siteId,
      ownerName: row.ownerName,
      tenantName: row.tenantName,
      contactPhone: row.contactPhone,
      contactEmail: row.contactEmail,
      isActive: row.isActive ?? true,
      isOccupied: row.isOccupied ?? true,
    }));
  }

  private getPrimaryRole(userRoles: string[]): UserRole {
    const rolePriority = [
      UserRole.ADMIN,
      UserRole.SITE_COORDINATOR,
      UserRole.SUPERVISOR,
      UserRole.TECHNICIAN,
      UserRole.TENANT,
    ];

    for (const role of rolePriority) {
      if (userRoles.includes(role)) {
        return role as UserRole;
      }
    }

    return UserRole.TENANT;
  }

  /**
   * Send email notification when ticket is created
   * Now uses NotificationService with templates
   */
  private async sendTicketCreationEmail(
    companyId: string,
    ticketId: string,
    userId: string,
  ): Promise<void> {
    try {
      const ticket = await this.findOne(companyId, ticketId, userId);
      const creator = await this.userRepository.findOne({
        where: { id: userId, companyId },
      });

      if (!ticket || !creator) {
        this.logger.warn(
          `Ticket or creator not found for email notification: ticketId=${ticketId}, userId=${userId}`,
        );
        return;
      }

      // Ensure email template exists
      await this.templateSeedService.seedEmailTemplates(companyId);

      // Get recipients (admins and supervisor only - tenant gets separate confirmation)
      const recipients: User[] = [];

      // Add assigned supervisor if exists
      if (ticket.assignedSupervisorId) {
        const supervisor = await this.userRepository.findOne({
          where: { id: ticket.assignedSupervisorId, companyId },
        });
        if (supervisor && supervisor.status === UserStatus.ACTIVE) {
          recipients.push(supervisor);
        }
      }

      // Add all admin users
      const admins = await this.userService.findAdmins(companyId);
      recipients.push(...admins);

      // Remove duplicates based on email
      const uniqueRecipients = recipients.filter(
        (user, index, self) =>
          index === self.findIndex((u) => u.email === user.email),
      );

      if (uniqueRecipients.length === 0) {
        this.logger.warn(`No recipients found for ticket creation email: ticketId=${ticketId}`);
        return;
      }

      // Prepare email content
      const creatorName = creator.firstName
        ? `${creator.firstName} ${creator.lastName || ''}`.trim()
        : creator.email;
      const priorityLabel = ticket.priority.charAt(0) + ticket.priority.slice(1).toLowerCase();

      // Send email notification using template system
      for (const recipient of uniqueRecipients) {
        try {
          await this.notificationService.publishEvent({
            type: 'ticket_created',
            companyId,
            recipientUserId: recipient.id,
            severity: NotificationSeverity.INFO,
            templateCode: 'ticket_created',
            variables: {
              title: `New Ticket: ${ticket.ticketNumber}`,
              ticketNumber: ticket.ticketNumber,
              ticketTitle: ticket.title,
              priority: priorityLabel,
              creatorName,
              villaNumber: ticket.villaNumber || null,
              description: ticket.description || null,
              ticketId: ticket.id,
              body: `Ticket ${ticket.ticketNumber}: ${ticket.title} (${priorityLabel})`,
              recipient: {
                email: recipient.email,
                firstName: recipient.firstName,
                lastName: recipient.lastName,
              },
            },
            channels: ['email'], // Only email - push/in-app handled by sendTicketCreationPushNotification
          });

          this.logger.log(
            `Ticket creation email sent to ${recipient.email} for ticket ${ticket.ticketNumber}`,
          );
        } catch (error: unknown) {
          const errorMessage = error instanceof Error ? error.message : 'Unknown error';
          this.logger.error(
            `Failed to send ticket creation email to ${recipient.email}: ${errorMessage}`,
          );
        }
      }
    } catch (error: unknown) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error(
        `Error in sendTicketCreationEmail for ticket ${ticketId}: ${errorMessage}`,
      );
      // Don't throw - email failure shouldn't block ticket creation
    }
  }

  /**
   * Ensure notification templates exist for ticket creation notifications
   * Uses 'ticket_created' as the template code for all channels (email, push, in-app)
   */
  private async ensureNotificationTemplates(companyId: string): Promise<void> {
    const templateCode = 'ticket_created'; // Use same code as email template for consistency

    // Check if push template exists
    let pushTemplate = await this.notificationTemplateRepository.findOne({
      where: {
        companyId,
        code: templateCode,
        channel: NotificationChannel.PUSH,
      },
    });

    if (!pushTemplate) {
      pushTemplate = this.notificationTemplateRepository.create({
        companyId,
        code: templateCode,
        channel: NotificationChannel.PUSH,
        subject: 'New Ticket Created',
        body: '{{message}}',
        defaultVariables: {
          message: 'A new ticket has been created',
        },
      });
      await this.notificationTemplateRepository.save(pushTemplate);
      this.logger.log(`Created push notification template: ${templateCode}`);
    }

    // Check if in-app template exists
    let inAppTemplate = await this.notificationTemplateRepository.findOne({
      where: {
        companyId,
        code: templateCode,
        channel: NotificationChannel.IN_APP,
      },
    });

    if (!inAppTemplate) {
      inAppTemplate = this.notificationTemplateRepository.create({
        companyId,
        code: templateCode,
        channel: NotificationChannel.IN_APP,
        subject: null,
        body: '{{message}}',
        defaultVariables: {
          message: 'A new ticket has been created',
        },
      });
      await this.notificationTemplateRepository.save(inAppTemplate);
      this.logger.log(`Created in-app notification template: ${templateCode}`);
    }
  }

  /**
   * Send push notification to admins and assigned supervisor when ticket is created
   * This is mandatory alongside email notification - both must be sent
   */
  private async sendTicketCreationPushNotification(
    companyId: string,
    ticketId: string,
    userId: string,
  ): Promise<void> {
    try {
      const ticket = await this.findOne(companyId, ticketId, userId);
      const creator = await this.userRepository.findOne({
        where: { id: userId, companyId },
      });

      if (!ticket || !creator) {
        this.logger.warn(
          `Ticket or creator not found for push notification: ticketId=${ticketId}, userId=${userId}`,
        );
        return;
      }

      // Get recipients (admins and supervisor - same as email notification)
      const recipients: User[] = [];

      // Add assigned supervisor if exists
      if (ticket.assignedSupervisorId) {
        const supervisor = await this.userRepository.findOne({
          where: { id: ticket.assignedSupervisorId, companyId },
        });
        if (supervisor && supervisor.status === UserStatus.ACTIVE) {
          recipients.push(supervisor);
        }
      }

      // Add all admin users
      const admins = await this.userService.findAdmins(companyId);
      recipients.push(...admins);

      // Remove duplicates based on email
      const uniqueRecipients = recipients.filter(
        (user, index, self) =>
          index === self.findIndex((u) => u.email === user.email),
      );

      if (uniqueRecipients.length === 0) {
        this.logger.warn(`No recipients found for push notification: ticketId=${ticketId}`);
        return;
      }

      // Prepare notification content
      const creatorName = creator.firstName
        ? `${creator.firstName} ${creator.lastName || ''}`.trim()
        : creator.email;
      const priorityLabel = ticket.priority.charAt(0) + ticket.priority.slice(1).toLowerCase();
      const title = `New Ticket: ${ticket.ticketNumber}`;
      const message = `${creatorName} created a ${priorityLabel} priority ticket: ${ticket.title}${ticket.villaNumber ? ` (Villa ${ticket.villaNumber})` : ''}`;

      // Ensure notification templates exist (create if missing)
      await this.ensureNotificationTemplates(companyId);

      // Send push notification to each recipient (admins and supervisor)
      for (const recipient of uniqueRecipients) {
        try {
          await this.notificationService.publishEvent({
            type: 'ticket_created',
            companyId,
            recipientUserId: recipient.id,
            severity: NotificationSeverity.INFO,
            templateCode: 'ticket_created_push',
            variables: {
              title,
              message,
              ticketId: ticket.id,
              ticketNumber: ticket.ticketNumber,
              creatorName,
              priority: priorityLabel,
              villaNumber: ticket.villaNumber || null,
            },
            channels: ['push', 'in_app'], // Send both push and in-app notification
          });

          this.logger.log(
            `Ticket creation push notification sent to ${recipient.email} for ticket ${ticket.ticketNumber}`,
          );
        } catch (error: unknown) {
          const errorMessage = error instanceof Error ? error.message : 'Unknown error';
          this.logger.error(
            `Failed to send push notification to ${recipient.email}: ${errorMessage}`,
          );
          // Continue with other admins even if one fails
        }
      }
    } catch (error: unknown) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error(
        `Error in sendTicketCreationPushNotification for ticket ${ticketId}: ${errorMessage}`,
      );
      // Don't throw - push notification failure shouldn't block ticket creation
    }
  }

  /**
   * Send combined notification to admins and supervisor when ticket is created
   * This creates a single notification with all channels (email, push, in-app)
   */
  private async sendTicketCreationNotification(
    companyId: string,
    ticketId: string,
    userId: string,
  ): Promise<void> {
    try {
      const ticket = await this.findOne(companyId, ticketId, userId);
      const creator = await this.userRepository.findOne({
        where: { id: userId, companyId },
      });

      if (!ticket || !creator) {
        this.logger.warn(
          `Ticket or creator not found for notification: ticketId=${ticketId}, userId=${userId}`,
        );
        return;
      }

      // Ensure templates exist
      await this.templateSeedService.seedEmailTemplates(companyId);
      await this.ensureNotificationTemplates(companyId);

      // Get recipients (admins and supervisor)
      const recipients: User[] = [];

      // Add assigned supervisor if exists
      if (ticket.assignedSupervisorId) {
        const supervisor = await this.userRepository.findOne({
          where: { id: ticket.assignedSupervisorId, companyId },
        });
        if (supervisor && supervisor.status === UserStatus.ACTIVE) {
          recipients.push(supervisor);
        }
      }

      // Add all admin users
      const admins = await this.userService.findAdmins(companyId);
      recipients.push(...admins);

      // Remove duplicates based on email
      const uniqueRecipients = recipients.filter(
        (user, index, self) =>
          index === self.findIndex((u) => u.email === user.email),
      );

      if (uniqueRecipients.length === 0) {
        this.logger.warn(`No recipients found for ticket creation notification: ticketId=${ticketId}`);
        return;
      }

      // Prepare notification content
      const creatorName = creator.firstName
        ? `${creator.firstName} ${creator.lastName || ''}`.trim()
        : creator.email;
      const priorityLabel = ticket.priority.charAt(0) + ticket.priority.slice(1).toLowerCase();
      const title = `New Ticket: ${ticket.ticketNumber}`;
      const message = `${creatorName} created a ${priorityLabel} priority ticket: ${ticket.title}${ticket.villaNumber ? ` (Villa ${ticket.villaNumber})` : ''}`;

      // Send combined notification to each recipient (admins and supervisor)
      // This creates ONE notification record per recipient with all channels
      // Note: Email template uses 'ticket_created', push/in-app use 'ticket_created_push'
      // The notification service will load templates for each channel, so we use 'ticket_created' 
      // as the primary code and ensure push/in-app templates also exist with that code
      for (const recipient of uniqueRecipients) {
        try {
          await this.notificationService.publishEvent({
            type: 'ticket_created',
            companyId,
            recipientUserId: recipient.id,
            severity: NotificationSeverity.INFO,
            templateCode: 'ticket_created', // Use email template code - push/in-app templates should also exist with this code
            variables: {
              title,
              message,
              ticketId: ticket.id,
              ticketNumber: ticket.ticketNumber,
              ticketTitle: ticket.title,
              creatorName,
              priority: priorityLabel,
              villaNumber: ticket.villaNumber || null,
              description: ticket.description || null,
              body: `Ticket ${ticket.ticketNumber}: ${ticket.title} (${priorityLabel})`,
              recipient: {
                email: recipient.email,
                firstName: recipient.firstName,
                lastName: recipient.lastName,
              },
            },
            channels: ['email', 'push', 'in_app'], // All channels in one notification
          });

          this.logger.log(
            `Ticket creation notification sent to ${recipient.email} for ticket ${ticket.ticketNumber} - email, push, and in-app`,
          );
        } catch (error: unknown) {
          const errorMessage = error instanceof Error ? error.message : 'Unknown error';
          this.logger.error(
            `Failed to send ticket creation notification to ${recipient.email}: ${errorMessage}`,
          );
          // Continue with other admins even if one fails
        }
      }
    } catch (error: unknown) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error(
        `Error in sendTicketCreationNotification for ticket ${ticketId}: ${errorMessage}`,
      );
      // Don't throw - notification failure shouldn't block ticket creation
    }
  }

  /**
   * Send push notification to admins/supervisor when rating is submitted
   * This is mandatory alongside email notification - both must be sent
   */
  private async sendRatingNotificationPushNotification(
    companyId: string,
    ticketId: string,
    userId: string,
    rating: number,
    comment?: string,
  ): Promise<void> {
    try {
      const ticket = await this.findOne(companyId, ticketId, userId);
      const rater = await this.userRepository.findOne({
        where: { id: userId, companyId },
      });

      if (!ticket || !rater) {
        this.logger.warn(
          `Ticket or rater not found for push notification: ticketId=${ticketId}, userId=${userId}`,
        );
        return;
      }

      // Get recipients (admins and supervisor - same as email)
      const recipients: User[] = [];

      // Add assigned supervisor if exists
      if (ticket.assignedSupervisorId) {
        const supervisor = await this.userRepository.findOne({
          where: { id: ticket.assignedSupervisorId, companyId },
        });
        if (supervisor && supervisor.status === UserStatus.ACTIVE) {
          recipients.push(supervisor);
        }
      }

      // Add all admin users
      const admins = await this.userService.findAdmins(companyId);
      recipients.push(...admins);

      // Remove duplicates based on email
      const uniqueRecipients = recipients.filter(
        (user, index, self) =>
          index === self.findIndex((u) => u.email === user.email),
      );

      if (uniqueRecipients.length === 0) {
        this.logger.warn(`No recipients found for rating push notification: ticketId=${ticketId}`);
        return;
      }

      // Prepare notification content
      const raterName = rater.firstName
        ? `${rater.firstName} ${rater.lastName || ''}`.trim()
        : rater.email;
      const stars = '⭐'.repeat(rating);
      const title = `Ticket Rated: ${ticket.ticketNumber}`;
      const message = `${raterName} rated ticket ${ticket.ticketNumber} with ${stars} (${rating}/5)${comment ? ` - ${comment}` : ''}`;

      // Ensure notification templates exist
      await this.ensureRatingNotificationTemplates(companyId);

      // Send push notification to each recipient
      for (const recipient of uniqueRecipients) {
        try {
          await this.notificationService.publishEvent({
            type: 'ticket_rated',
            companyId,
            recipientUserId: recipient.id,
            severity: NotificationSeverity.INFO,
            templateCode: 'ticket_rated_push',
            variables: {
              title,
              message,
              ticketId: ticket.id,
              ticketNumber: ticket.ticketNumber,
              raterName,
              rating,
              stars,
              comment: comment || null,
            },
            channels: ['push', 'in_app'], // Send both push and in-app notification
          });

          this.logger.log(
            `Rating push notification sent to ${recipient.email} for ticket ${ticket.ticketNumber}`,
          );
        } catch (error: unknown) {
          const errorMessage = error instanceof Error ? error.message : 'Unknown error';
          this.logger.error(
            `Failed to send push notification to ${recipient.email}: ${errorMessage}`,
          );
          // Continue with other recipients even if one fails
        }
      }
    } catch (error: unknown) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error(
        `Error in sendRatingNotificationPushNotification for ticket ${ticketId}: ${errorMessage}`,
      );
      // Don't throw - push notification failure shouldn't block rating submission
    }
  }

  /**
   * Ensure notification templates exist for rating notifications
   */
  private async ensureRatingNotificationTemplates(companyId: string): Promise<void> {
    const templateCode = 'ticket_rated_push';

    // Check if push template exists
    let pushTemplate = await this.notificationTemplateRepository.findOne({
      where: {
        companyId,
        code: templateCode,
        channel: NotificationChannel.PUSH,
      },
    });

    if (!pushTemplate) {
      pushTemplate = this.notificationTemplateRepository.create({
        companyId,
        code: templateCode,
        channel: NotificationChannel.PUSH,
        subject: 'Ticket Rating Submitted',
        body: '{{message}}',
        defaultVariables: {
          message: 'A ticket has been rated',
        },
      });
      await this.notificationTemplateRepository.save(pushTemplate);
      this.logger.log(`Created rating push notification template: ${templateCode}`);
    }

    // Check if in-app template exists
    let inAppTemplate = await this.notificationTemplateRepository.findOne({
      where: {
        companyId,
        code: templateCode,
        channel: NotificationChannel.IN_APP,
      },
    });

    if (!inAppTemplate) {
      inAppTemplate = this.notificationTemplateRepository.create({
        companyId,
        code: templateCode,
        channel: NotificationChannel.IN_APP,
        subject: null,
        body: '{{message}}',
        defaultVariables: {
          message: 'A ticket has been rated',
        },
      });
      await this.notificationTemplateRepository.save(inAppTemplate);
      this.logger.log(`Created rating in-app notification template: ${templateCode}`);
    }
  }

  /**
   * Send email notification when rating is submitted
   */
  private async sendRatingNotificationEmail(
    companyId: string,
    ticketId: string,
    userId: string,
    rating: number,
    comment?: string,
  ): Promise<void> {
    try {
      const ticket = await this.findOne(companyId, ticketId, userId);
      const rater = await this.userRepository.findOne({
        where: { id: userId, companyId },
      });

      if (!ticket || !rater) {
        this.logger.warn(
          `Ticket or rater not found for email notification: ticketId=${ticketId}, userId=${userId}`,
        );
        return;
      }

      // Get recipients
      const recipients: User[] = [];

      // Add assigned supervisor if exists
      if (ticket.assignedSupervisorId) {
        const supervisor = await this.userRepository.findOne({
          where: { id: ticket.assignedSupervisorId, companyId },
        });
        if (supervisor && supervisor.status === UserStatus.ACTIVE) {
          recipients.push(supervisor);
        }
      }

      // Add all admin users
      const admins = await this.userService.findAdmins(companyId);
      recipients.push(...admins);

      // Remove duplicates based on email
      const uniqueRecipients = recipients.filter(
        (user, index, self) =>
          index === self.findIndex((u) => u.email === user.email),
      );

      if (uniqueRecipients.length === 0) {
        this.logger.warn(`No recipients found for rating email: ticketId=${ticketId}`);
        return;
      }

      // Prepare email content
      const raterName = rater.firstName
        ? `${rater.firstName} ${rater.lastName || ''}`.trim()
        : rater.email;
      const stars = '⭐'.repeat(rating);
      const subject = `Ticket Rating Submitted - ${ticket.ticketNumber}`;
      const htmlBody = this.getRatingEmailHtml(ticket, raterName, rating, stars, comment);
      const textBody = this.getRatingEmailText(ticket, raterName, rating, comment);

      // Send email to each recipient
      for (const recipient of uniqueRecipients) {
        try {
          await this.emailService.sendEmail(recipient.email, subject, htmlBody, textBody);

          this.logger.log(
            `Rating email sent to ${recipient.email} for ticket ${ticket.ticketNumber}`,
          );
        } catch (error: unknown) {
          const errorMessage = error instanceof Error ? error.message : 'Unknown error';
          this.logger.error(
            `Failed to send rating email to ${recipient.email}: ${errorMessage}`,
          );
        }
      }
    } catch (error: unknown) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error(
        `Error in sendRatingNotificationEmail for ticket ${ticketId}: ${errorMessage}`,
      );
      // Don't throw - email failure shouldn't block rating submission
    }
  }

  /**
   * Get HTML email body for ticket creation
   */
  private getTicketCreationEmailHtml(
    ticket: MaintenanceTicket,
    creatorName: string,
    priorityLabel: string,
    hasAttachments: boolean,
  ): string {
    const appName = this.configService.get<string>('APP_NAME') || 'TENX';
    const attachmentNote = hasAttachments
      ? '<p><strong>Attachments:</strong> Images are attached to this email.</p>'
      : '';

    return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>New Ticket Created</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
  <div style="background-color: #FCB447; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0;">
    <h1 style="margin: 0;">${appName}</h1>
    <p style="margin: 10px 0 0 0; font-size: 18px; opacity: 0.9;">New Ticket Created</p>
  </div>
  <div style="background-color: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px;">
    <p>A new maintenance ticket has been created:</p>
    
    <div style="background-color: #fff; border: 2px solid #FCB447; border-radius: 8px; padding: 20px; margin: 20px 0;">
      <table style="width: 100%; border-collapse: collapse;">
        <tr>
          <td style="padding: 8px 0; font-weight: bold; width: 150px;">Ticket Number:</td>
          <td style="padding: 8px 0;"><strong>${ticket.ticketNumber}</strong></td>
        </tr>
        <tr>
          <td style="padding: 8px 0; font-weight: bold;">Title:</td>
          <td style="padding: 8px 0;">${ticket.title}</td>
        </tr>
        ${ticket.villaNumber ? `<tr>
          <td style="padding: 8px 0; font-weight: bold;">Villa Number:</td>
          <td style="padding: 8px 0;">${ticket.villaNumber}</td>
        </tr>` : ''}
        ${ticket.description ? `<tr>
          <td style="padding: 8px 0; font-weight: bold;">Description:</td>
          <td style="padding: 8px 0;">${ticket.description}</td>
        </tr>` : ''}
        <tr>
          <td style="padding: 8px 0; font-weight: bold;">Priority:</td>
          <td style="padding: 8px 0;">${priorityLabel}</td>
        </tr>
        ${ticket.contactNumber ? `<tr>
          <td style="padding: 8px 0; font-weight: bold;">Contact:</td>
          <td style="padding: 8px 0;">${ticket.contactNumber}${ticket.alternateContact ? ` / ${ticket.alternateContact}` : ''}</td>
        </tr>` : ''}
        ${ticket.preferredTime ? `<tr>
          <td style="padding: 8px 0; font-weight: bold;">Preferred Time:</td>
          <td style="padding: 8px 0;">${ticket.preferredTime}</td>
        </tr>` : ''}
        ${ticket.locationDetail ? `<tr>
          <td style="padding: 8px 0; font-weight: bold;">Location:</td>
          <td style="padding: 8px 0;">${ticket.locationDetail}</td>
        </tr>` : ''}
        <tr>
          <td style="padding: 8px 0; font-weight: bold;">Created by:</td>
          <td style="padding: 8px 0;">${creatorName}</td>
        </tr>
        <tr>
          <td style="padding: 8px 0; font-weight: bold;">Created on:</td>
          <td style="padding: 8px 0;">${ticket.createdAt.toLocaleString()}</td>
        </tr>
      </table>
    </div>

    ${attachmentNote}

    <hr style="border: none; border-top: 1px solid #ddd; margin: 30px 0;">
    <p style="color: #999; font-size: 12px; text-align: center;">This is an automated message from ${appName}. Please do not reply to this email.</p>
  </div>
</body>
</html>
    `.trim();
  }

  /**
   * Get plain text email body for ticket creation
   */
  private getTicketCreationEmailText(
    ticket: MaintenanceTicket,
    creatorName: string,
    priorityLabel: string,
    hasAttachments: boolean,
  ): string {
    const attachmentNote = hasAttachments
      ? '\n\nAttachments: Images are attached to this email.'
      : '';

    return `
A new maintenance ticket has been created:

Ticket Number: ${ticket.ticketNumber}
Title: ${ticket.title}
${ticket.villaNumber ? `Villa Number: ${ticket.villaNumber}\n` : ''}${ticket.description ? `Description: ${ticket.description}\n` : ''}Priority: ${priorityLabel}
${ticket.contactNumber ? `Contact: ${ticket.contactNumber}${ticket.alternateContact ? ` / ${ticket.alternateContact}` : ''}\n` : ''}${ticket.preferredTime ? `Preferred Time: ${ticket.preferredTime}\n` : ''}${ticket.locationDetail ? `Location: ${ticket.locationDetail}\n` : ''}Created by: ${creatorName}
Created on: ${ticket.createdAt.toLocaleString()}${attachmentNote}

This is an automated message. Please do not reply to this email.
    `.trim();
  }

  /**
   * Get HTML email body for rating notification
   */
  private getRatingEmailHtml(
    ticket: MaintenanceTicket,
    raterName: string,
    rating: number,
    stars: string,
    comment?: string,
  ): string {
    const appName = this.configService.get<string>('APP_NAME') || 'TENX';

    return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Ticket Rating Submitted</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
  <div style="background-color: #FCB447; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0;">
    <h1 style="margin: 0;">${appName}</h1>
    <p style="margin: 10px 0 0 0; font-size: 18px; opacity: 0.9;">Ticket Rating Submitted</p>
  </div>
  <div style="background-color: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px;">
    <p>A tenant has submitted a rating for a closed ticket:</p>
    
    <div style="background-color: #fff; border: 2px solid #FCB447; border-radius: 8px; padding: 20px; margin: 20px 0;">
      <table style="width: 100%; border-collapse: collapse;">
        <tr>
          <td style="padding: 8px 0; font-weight: bold; width: 150px;">Ticket Number:</td>
          <td style="padding: 8px 0;"><strong>${ticket.ticketNumber}</strong></td>
        </tr>
        <tr>
          <td style="padding: 8px 0; font-weight: bold;">Title:</td>
          <td style="padding: 8px 0;">${ticket.title}</td>
        </tr>
        ${ticket.villaNumber ? `<tr>
          <td style="padding: 8px 0; font-weight: bold;">Villa Number:</td>
          <td style="padding: 8px 0;">${ticket.villaNumber}</td>
        </tr>` : ''}
        <tr>
          <td style="padding: 8px 0; font-weight: bold;">Rating:</td>
          <td style="padding: 8px 0; font-size: 24px;">${stars} (${rating}/5)</td>
        </tr>
        ${comment ? `<tr>
          <td style="padding: 8px 0; font-weight: bold;">Comment:</td>
          <td style="padding: 8px 0;">${comment}</td>
        </tr>` : ''}
        <tr>
          <td style="padding: 8px 0; font-weight: bold;">Submitted by:</td>
          <td style="padding: 8px 0;">${raterName}</td>
        </tr>
        <tr>
          <td style="padding: 8px 0; font-weight: bold;">Submitted on:</td>
          <td style="padding: 8px 0;">${ticket.ratedAt?.toLocaleString() || new Date().toLocaleString()}</td>
        </tr>
      </table>
    </div>

    <hr style="border: none; border-top: 1px solid #ddd; margin: 30px 0;">
    <p style="color: #999; font-size: 12px; text-align: center;">This is an automated message from ${appName}. Please do not reply to this email.</p>
  </div>
</body>
</html>
    `.trim();
  }

  /**
   * Get plain text email body for rating notification
   */
  private getRatingEmailText(
    ticket: MaintenanceTicket,
    raterName: string,
    rating: number,
    comment?: string,
  ): string {
    return `
A tenant has submitted a rating for a closed ticket:

Ticket Number: ${ticket.ticketNumber}
Title: ${ticket.title}
${ticket.villaNumber ? `Villa Number: ${ticket.villaNumber}\n` : ''}Rating: ${rating}/5 stars
${comment ? `Comment: ${comment}\n` : ''}Submitted by: ${raterName}
Submitted on: ${ticket.ratedAt?.toLocaleString() || new Date().toLocaleString()}

This is an automated message. Please do not reply to this email.
    `.trim();
  }

  /**
   * Send push notification to tenant for ticket updates
   * This is mandatory alongside email notification - both must be sent
   */
  private async sendTenantTicketUpdatePushNotification(
    companyId: string,
    ticketId: string,
    updateType: 'TICKET_CREATED' | 'STATUS_CHANGED' | 'ACKNOWLEDGED' | 'TECHNICIAN_ASSIGNED' | 'SUPERVISOR_ASSIGNED' | 'TEAM_ASSIGNED',
    message: string,
    additionalData?: Record<string, unknown>,
  ): Promise<void> {
    try {
      const ticket = await this.ticketRepository.findOne({
        where: { id: ticketId, companyId },
        relations: ['creator'],
      });

      if (!ticket || !ticket.createdBy) {
        this.logger.warn(
          `Ticket or creator not found for tenant push notification: ticketId=${ticketId}`,
        );
        return;
      }

      const tenant = await this.userRepository.findOne({
        where: { id: ticket.createdBy, companyId },
      });

      if (!ticket || !tenant) {
        this.logger.warn(
          `Ticket or tenant not found for push notification: ticketId=${ticketId}`,
        );
        return;
      }

      if (tenant.status !== UserStatus.ACTIVE) {
        this.logger.warn(`Tenant ${tenant.id} is not active, skipping push notification`);
        return;
      }

      // Prepare notification content based on update type
      let title: string;
      let notificationMessage: string;
      const templateCode = this.getTenantTicketTemplateCode(updateType);

      switch (updateType) {
        case 'TICKET_CREATED':
          title = `Ticket Created: ${ticket.ticketNumber}`;
          notificationMessage = `Your ticket "${ticket.title}" has been created successfully.`;
          break;
        case 'STATUS_CHANGED':
          const newStatusLabel = this.getStatusLabel(additionalData?.newStatus as TicketStatus || ticket.status);
          title = `Status Updated: ${ticket.ticketNumber}`;
          notificationMessage = `Your ticket status has been updated to: ${newStatusLabel}${additionalData?.notes ? ` - ${additionalData.notes as string}` : ''}`;
          break;
        case 'ACKNOWLEDGED':
          const acknowledgerName = additionalData?.acknowledgerName as string || 'Support Team';
          title = `Ticket Acknowledged: ${ticket.ticketNumber}`;
          notificationMessage = `Your ticket has been acknowledged by ${acknowledgerName}.`;
          break;
        case 'TECHNICIAN_ASSIGNED':
          const technicianName = additionalData?.technicianName as string || 'Technician';
          const scheduledAt = additionalData?.scheduledAt as Date;
          title = `Technician Assigned: ${ticket.ticketNumber}`;
          notificationMessage = `Technician ${technicianName} has been assigned to your ticket${scheduledAt ? `. Scheduled visit: ${scheduledAt.toLocaleString()}` : ''}.`;
          break;
        case 'SUPERVISOR_ASSIGNED':
          const supervisorName = additionalData?.supervisorName as string || 'Supervisor';
          title = `Supervisor Assigned: ${ticket.ticketNumber}`;
          notificationMessage = `Supervisor ${supervisorName} has been assigned to review your ticket.`;
          break;
        case 'TEAM_ASSIGNED':
          const teamName = additionalData?.teamName as string || 'Team';
          title = `Team Assigned: ${ticket.ticketNumber}`;
          notificationMessage = `Team ${teamName} has been assigned to work on your ticket.`;
          break;
        default:
          this.logger.warn(`Unknown update type: ${updateType}`);
          return;
      }

      // Ensure notification templates exist
      await this.ensureTenantNotificationTemplates(companyId, updateType);

      // Send push notification to tenant
      await this.notificationService.publishEvent({
        type: `tenant_ticket_${updateType.toLowerCase()}`,
        companyId,
        recipientUserId: tenant.id,
        severity: NotificationSeverity.INFO,
        templateCode,
        variables: {
          title,
          message: notificationMessage,
          ticketId: ticket.id,
          ticketNumber: ticket.ticketNumber,
          ...additionalData,
        },
        channels: ['push', 'in_app'], // Send both push and in-app notification
      });

      this.logger.log(
        `Tenant push notification sent to ${tenant.email} for ticket ${ticket.ticketNumber} (${updateType})`,
      );
    } catch (error: unknown) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error(
        `Error in sendTenantTicketUpdatePushNotification for ticket ${ticketId}: ${errorMessage}`,
      );
      // Don't throw - push notification failure shouldn't block operations
    }
  }

  /**
   * Get the correct template code for tenant ticket notifications
   * Maps updateType to template code, avoiding duplicate "ticket_" in TICKET_CREATED
   */
  private getTenantTicketTemplateCode(
    updateType: 'TICKET_CREATED' | 'STATUS_CHANGED' | 'ACKNOWLEDGED' | 'TECHNICIAN_ASSIGNED' | 'SUPERVISOR_ASSIGNED' | 'TEAM_ASSIGNED',
  ): string {
    const templateCodeMap: Record<string, string> = {
      'TICKET_CREATED': 'tenant_ticket_created',
      'STATUS_CHANGED': 'tenant_ticket_status_changed',
      'ACKNOWLEDGED': 'tenant_ticket_acknowledged',
      'TECHNICIAN_ASSIGNED': 'tenant_ticket_technician_assigned',
      'SUPERVISOR_ASSIGNED': 'tenant_ticket_supervisor_assigned',
      'TEAM_ASSIGNED': 'tenant_ticket_team_assigned',
    };
    return templateCodeMap[updateType] || `tenant_ticket_${updateType.toLowerCase()}`;
  }

  /**
   * Ensure notification templates exist for tenant push notifications
   */
  private async ensureTenantNotificationTemplates(
    companyId: string,
    updateType: 'TICKET_CREATED' | 'STATUS_CHANGED' | 'ACKNOWLEDGED' | 'TECHNICIAN_ASSIGNED' | 'SUPERVISOR_ASSIGNED' | 'TEAM_ASSIGNED',
  ): Promise<void> {
    const templateCode = this.getTenantTicketTemplateCode(updateType);

    // Check if push template exists
    let pushTemplate = await this.notificationTemplateRepository.findOne({
      where: {
        companyId,
        code: templateCode,
        channel: NotificationChannel.PUSH,
      },
    });

    if (!pushTemplate) {
      pushTemplate = this.notificationTemplateRepository.create({
        companyId,
        code: templateCode,
        channel: NotificationChannel.PUSH,
        subject: 'Ticket Update',
        body: '{{message}}',
        defaultVariables: {
          message: 'Your ticket has been updated',
        },
      });
      await this.notificationTemplateRepository.save(pushTemplate);
      this.logger.log(`Created tenant push notification template: ${templateCode}`);
    }

    // Check if in-app template exists
    let inAppTemplate = await this.notificationTemplateRepository.findOne({
      where: {
        companyId,
        code: templateCode,
        channel: NotificationChannel.IN_APP,
      },
    });

    if (!inAppTemplate) {
      inAppTemplate = this.notificationTemplateRepository.create({
        companyId,
        code: templateCode,
        channel: NotificationChannel.IN_APP,
        subject: null,
        body: '{{message}}',
        defaultVariables: {
          message: 'Your ticket has been updated',
        },
      });
      await this.notificationTemplateRepository.save(inAppTemplate);
      this.logger.log(`Created tenant in-app notification template: ${templateCode}`);
    }
  }

  /**
   * Send email notification to tenant for ticket updates
   */
  private async sendTenantTicketUpdateEmail(
    companyId: string,
    ticketId: string,
    updateType: 'TICKET_CREATED' | 'STATUS_CHANGED' | 'ACKNOWLEDGED' | 'TECHNICIAN_ASSIGNED' | 'SUPERVISOR_ASSIGNED' | 'TEAM_ASSIGNED',
    message: string,
    additionalData?: Record<string, unknown>,
  ): Promise<void> {
    try {
      // First get the ticket without access control (we're sending to the creator)
      const ticket = await this.ticketRepository.findOne({
        where: { id: ticketId, companyId },
        relations: ['creator'],
      });

      if (!ticket || !ticket.createdBy) {
        this.logger.warn(
          `Ticket or creator not found for tenant email notification: ticketId=${ticketId}`,
        );
        return;
      }

      const tenant = await this.userRepository.findOne({
        where: { id: ticket.createdBy, companyId },
      });

      if (!ticket || !tenant) {
        this.logger.warn(
          `Ticket or tenant not found for email notification: ticketId=${ticketId}`,
        );
        return;
      }

      if (tenant.status !== UserStatus.ACTIVE) {
        this.logger.warn(`Tenant ${tenant.id} is not active, skipping email notification`);
        return;
      }

      // Ensure email template exists
      await this.templateSeedService.seedEmailTemplates(companyId);

      // Map updateType to template code
      let templateCode: string;
      let templateVariables: Record<string, unknown> = {
        ticketNumber: ticket.ticketNumber,
        title: ticket.title,
        recipient: {
          email: tenant.email,
          firstName: tenant.firstName,
          lastName: tenant.lastName,
        },
      };

      switch (updateType) {
        case 'TICKET_CREATED':
          templateCode = 'tenant_ticket_created';
          templateVariables = {
            ...templateVariables,
            priority: ticket.priority.charAt(0) + ticket.priority.slice(1).toLowerCase(),
            villaNumber: ticket.villaNumber || '',
          };
          break;
        case 'STATUS_CHANGED':
          templateCode = 'ticket_status_changed';
          const newStatusLabel = this.getStatusLabel(additionalData?.newStatus as TicketStatus || ticket.status);
          const previousStatusLabel = additionalData?.previousStatus
            ? this.getStatusLabel(additionalData.previousStatus as TicketStatus)
            : '';
          templateVariables = {
            ...templateVariables,
            previousStatus: previousStatusLabel,
            newStatus: newStatusLabel,
            assignedTo: additionalData?.assignedTo as string || '',
            notes: additionalData?.notes as string || '',
          };
          break;
        case 'ACKNOWLEDGED':
        case 'TECHNICIAN_ASSIGNED':
        case 'SUPERVISOR_ASSIGNED':
        case 'TEAM_ASSIGNED':
          // For now, use ticket_updated template for these
          templateCode = 'ticket_updated';
          templateVariables = {
            ...templateVariables,
            status: this.getStatusLabel(ticket.status),
            updatedBy: additionalData?.acknowledgerName as string || 
                      additionalData?.technicianName as string || 
                      additionalData?.supervisorName as string || 
                      additionalData?.teamName as string || 
                      'Support Team',
            notes: additionalData?.notes as string || '',
          };
          break;
        default:
          this.logger.warn(`Unknown update type: ${updateType}`);
          return;
      }

      // Send email notification using template system
      await this.notificationService.publishEvent({
        type: `tenant_ticket_${updateType.toLowerCase()}`,
        companyId,
        recipientUserId: tenant.id,
        severity: NotificationSeverity.INFO,
        templateCode,
        variables: templateVariables,
        channels: ['email'],
      });

      this.logger.log(
        `Tenant notification email sent to ${tenant.email} for ticket ${ticket.ticketNumber} (${updateType})`,
      );
    } catch (error: unknown) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error(
        `Error in sendTenantTicketUpdateEmail for ticket ${ticketId}: ${errorMessage}`,
      );
      // Don't throw - email failure shouldn't block operations
    }
  }

  /**
   * Send combined notification to tenant (email, push, and in-app) - creates single notification
   */
  private async sendTenantTicketUpdateNotification(
    companyId: string,
    ticketId: string,
    updateType: 'TICKET_CREATED' | 'STATUS_CHANGED' | 'ACKNOWLEDGED' | 'TECHNICIAN_ASSIGNED' | 'SUPERVISOR_ASSIGNED' | 'TEAM_ASSIGNED',
    message: string,
    additionalData?: Record<string, unknown>,
  ): Promise<void> {
    try {
      const ticket = await this.ticketRepository.findOne({
        where: { id: ticketId, companyId },
        relations: ['creator'],
      });

      if (!ticket || !ticket.createdBy) {
        this.logger.warn(
          `Ticket or creator not found for tenant notification: ticketId=${ticketId}`,
        );
        return;
      }

      const tenant = await this.userRepository.findOne({
        where: { id: ticket.createdBy, companyId },
      });

      if (!ticket || !tenant) {
        this.logger.warn(
          `Ticket or tenant not found for notification: ticketId=${ticketId}`,
        );
        return;
      }

      if (tenant.status !== UserStatus.ACTIVE) {
        this.logger.warn(`Tenant ${tenant.id} is not active, skipping notification`);
        return;
      }

      // Ensure templates exist
      await this.templateSeedService.seedEmailTemplates(companyId);
      await this.ensureTenantNotificationTemplates(companyId, updateType);

      // Prepare notification content based on update type
      let title: string;
      let notificationMessage: string;
      const templateCode = this.getTenantTicketTemplateCode(updateType);
      let templateVariables: Record<string, unknown> = {
        ticketNumber: ticket.ticketNumber,
        title: ticket.title,
        ticketId: ticket.id,
        recipient: {
          email: tenant.email,
          firstName: tenant.firstName,
          lastName: tenant.lastName,
        },
        ...additionalData,
      };

      switch (updateType) {
        case 'TICKET_CREATED':
          title = `Ticket Created: ${ticket.ticketNumber}`;
          notificationMessage = `Your ticket "${ticket.title}" has been created successfully.`;
          templateVariables = {
            ...templateVariables,
            priority: ticket.priority.charAt(0) + ticket.priority.slice(1).toLowerCase(),
            villaNumber: ticket.villaNumber || '',
            message: notificationMessage,
          };
          break;
        case 'STATUS_CHANGED':
          const newStatusLabel = this.getStatusLabel(additionalData?.newStatus as TicketStatus || ticket.status);
          const previousStatusLabel = additionalData?.previousStatus
            ? this.getStatusLabel(additionalData.previousStatus as TicketStatus)
            : '';
          title = `Status Updated: ${ticket.ticketNumber}`;
          notificationMessage = `Your ticket status has been updated to: ${newStatusLabel}${additionalData?.notes ? ` - ${additionalData.notes as string}` : ''}`;
          templateVariables = {
            ...templateVariables,
            previousStatus: previousStatusLabel,
            newStatus: newStatusLabel,
            assignedTo: additionalData?.assignedTo as string || '',
            notes: additionalData?.notes as string || '',
            message: notificationMessage,
          };
          break;
        case 'ACKNOWLEDGED':
          const acknowledgerName = additionalData?.acknowledgerName as string || 'Support Team';
          title = `Ticket Acknowledged: ${ticket.ticketNumber}`;
          notificationMessage = `Your ticket has been acknowledged by ${acknowledgerName}.`;
          templateVariables = {
            ...templateVariables,
            status: this.getStatusLabel(ticket.status),
            updatedBy: acknowledgerName,
            notes: additionalData?.notes as string || '',
            message: notificationMessage,
          };
          break;
        case 'TECHNICIAN_ASSIGNED':
          const technicianName = additionalData?.technicianName as string || 'Technician';
          const scheduledAt = additionalData?.scheduledAt as Date;
          title = `Technician Assigned: ${ticket.ticketNumber}`;
          notificationMessage = `Technician ${technicianName} has been assigned to your ticket${scheduledAt ? `. Scheduled visit: ${scheduledAt.toLocaleString()}` : ''}.`;
          templateVariables = {
            ...templateVariables,
            status: this.getStatusLabel(ticket.status),
            updatedBy: technicianName,
            notes: additionalData?.notes as string || '',
            message: notificationMessage,
          };
          break;
        case 'SUPERVISOR_ASSIGNED':
          const supervisorName = additionalData?.supervisorName as string || 'Supervisor';
          title = `Supervisor Assigned: ${ticket.ticketNumber}`;
          notificationMessage = `Supervisor ${supervisorName} has been assigned to review your ticket.`;
          templateVariables = {
            ...templateVariables,
            status: this.getStatusLabel(ticket.status),
            updatedBy: supervisorName,
            notes: additionalData?.notes as string || '',
            message: notificationMessage,
          };
          break;
        case 'TEAM_ASSIGNED':
          const teamName = additionalData?.teamName as string || 'Team';
          title = `Team Assigned: ${ticket.ticketNumber}`;
          notificationMessage = `Team ${teamName} has been assigned to work on your ticket.`;
          templateVariables = {
            ...templateVariables,
            status: this.getStatusLabel(ticket.status),
            updatedBy: teamName,
            notes: additionalData?.notes as string || '',
            message: notificationMessage,
          };
          break;
        default:
          this.logger.warn(`Unknown update type: ${updateType}`);
          return;
      }

      // Send single notification with all channels (email, push, in-app)
      // This creates ONE notification record instead of multiple
      // Use the same helper to get correct notification type (avoid duplicate "ticket_" in TICKET_CREATED)
      const notificationType = this.getTenantTicketTemplateCode(updateType);
      
      this.logger.log(
        `Sending tenant notification: type=${notificationType}, ticketId=${ticket.id}, recipient=${tenant.id}`,
      );
      
      await this.notificationService.publishEvent({
        type: notificationType,
        companyId,
        recipientUserId: tenant.id,
        severity: NotificationSeverity.INFO,
        templateCode, // Use same template code for all channels (email, push, in-app)
        variables: {
          ...templateVariables,
          title,
          message: notificationMessage,
          ticketId: ticket.id, // Ensure ticketId is in variables for duplicate detection
        },
        channels: ['email', 'push', 'in_app'], // All channels in one notification
      });

      this.logger.log(
        `Tenant notification sent to ${tenant.email} for ticket ${ticket.ticketNumber} (${updateType}) - email, push, and in-app`,
      );
    } catch (error: unknown) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error(
        `Error in sendTenantTicketUpdateNotification for ticket ${ticketId}: ${errorMessage}`,
      );
      // Don't throw - notification failure shouldn't block operations
    }
  }

  /**
   * Get status label for display
   */
  private getStatusLabel(status: TicketStatus): string {
    const statusLabels: Record<TicketStatus, string> = {
      [TicketStatus.NEW]: 'New',
      [TicketStatus.ACKNOWLEDGED]: 'Acknowledged',
      [TicketStatus.ASSIGNED]: 'Assigned',
      [TicketStatus.IN_PROGRESS]: 'In Progress',
      [TicketStatus.ON_HOLD]: 'On Hold',
      [TicketStatus.COMPLETED]: 'Completed',
      [TicketStatus.CANCELLED]: 'Cancelled',
    };
    return statusLabels[status] || status;
  }

  /**
   * Get HTML email body for tenant ticket creation confirmation
   */
  private getTenantTicketCreatedEmailHtml(
    ticket: MaintenanceTicket,
    tenant: User,
  ): string {
    const appName = this.configService.get<string>('APP_NAME') || 'TENX';
    const tenantName = tenant.firstName
      ? `${tenant.firstName} ${tenant.lastName || ''}`.trim()
      : tenant.email;

    return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Ticket Created</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
  <div style="background-color: #FCB447; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0;">
    <h1 style="margin: 0;">${appName}</h1>
    <p style="margin: 10px 0 0 0; font-size: 18px; opacity: 0.9;">Ticket Created Successfully</p>
  </div>
  <div style="background-color: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px;">
    <p>Dear ${tenantName},</p>
    <p>Your maintenance ticket has been created successfully. We will review it and get back to you soon.</p>
    
    <div style="background-color: #fff; border: 2px solid #FCB447; border-radius: 8px; padding: 20px; margin: 20px 0;">
      <table style="width: 100%; border-collapse: collapse;">
        <tr>
          <td style="padding: 8px 0; font-weight: bold; width: 150px;">Ticket Number:</td>
          <td style="padding: 8px 0;"><strong>${ticket.ticketNumber}</strong></td>
        </tr>
        <tr>
          <td style="padding: 8px 0; font-weight: bold;">Title:</td>
          <td style="padding: 8px 0;">${ticket.title}</td>
        </tr>
        ${ticket.villaNumber ? `<tr>
          <td style="padding: 8px 0; font-weight: bold;">Villa Number:</td>
          <td style="padding: 8px 0;">${ticket.villaNumber}</td>
        </tr>` : ''}
        <tr>
          <td style="padding: 8px 0; font-weight: bold;">Status:</td>
          <td style="padding: 8px 0;">New</td>
        </tr>
        <tr>
          <td style="padding: 8px 0; font-weight: bold;">Created on:</td>
          <td style="padding: 8px 0;">${ticket.createdAt.toLocaleString()}</td>
        </tr>
      </table>
    </div>

    <p>You will receive email notifications when your ticket status is updated.</p>

    <hr style="border: none; border-top: 1px solid #ddd; margin: 30px 0;">
    <p style="color: #999; font-size: 12px; text-align: center;">This is an automated message from ${appName}. Please do not reply to this email.</p>
  </div>
</body>
</html>
    `.trim();
  }

  /**
   * Get plain text email body for tenant ticket creation confirmation
   */
  private getTenantTicketCreatedEmailText(
    ticket: MaintenanceTicket,
    tenant: User,
  ): string {
    const tenantName = tenant.firstName
      ? `${tenant.firstName} ${tenant.lastName || ''}`.trim()
      : tenant.email;

    return `
Dear ${tenantName},

Your maintenance ticket has been created successfully. We will review it and get back to you soon.

Ticket Number: ${ticket.ticketNumber}
Title: ${ticket.title}
${ticket.villaNumber ? `Villa Number: ${ticket.villaNumber}\n` : ''}Status: New
Created on: ${ticket.createdAt.toLocaleString()}

You will receive email notifications when your ticket status is updated.

This is an automated message. Please do not reply to this email.
    `.trim();
  }

  /**
   * Get HTML email body for tenant status update
   */
  private getTenantStatusUpdateEmailHtml(
    ticket: MaintenanceTicket,
    newStatus: string,
    previousStatus: string,
    notes?: string,
  ): string {
    const appName = this.configService.get<string>('APP_NAME') || 'TENX';

    return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Ticket Status Updated</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
  <div style="background-color: #FCB447; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0;">
    <h1 style="margin: 0;">${appName}</h1>
    <p style="margin: 10px 0 0 0; font-size: 18px; opacity: 0.9;">Ticket Status Updated</p>
  </div>
  <div style="background-color: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px;">
    <p>Your ticket status has been updated:</p>
    
    <div style="background-color: #fff; border: 2px solid #FCB447; border-radius: 8px; padding: 20px; margin: 20px 0;">
      <table style="width: 100%; border-collapse: collapse;">
        <tr>
          <td style="padding: 8px 0; font-weight: bold; width: 150px;">Ticket Number:</td>
          <td style="padding: 8px 0;"><strong>${ticket.ticketNumber}</strong></td>
        </tr>
        <tr>
          <td style="padding: 8px 0; font-weight: bold;">Title:</td>
          <td style="padding: 8px 0;">${ticket.title}</td>
        </tr>
        ${previousStatus ? `<tr>
          <td style="padding: 8px 0; font-weight: bold;">Previous Status:</td>
          <td style="padding: 8px 0;">${previousStatus}</td>
        </tr>` : ''}
        <tr>
          <td style="padding: 8px 0; font-weight: bold;">New Status:</td>
          <td style="padding: 8px 0;"><strong>${newStatus}</strong></td>
        </tr>
        ${notes ? `<tr>
          <td style="padding: 8px 0; font-weight: bold;">Notes:</td>
          <td style="padding: 8px 0;">${notes}</td>
        </tr>` : ''}
      </table>
    </div>

    <hr style="border: none; border-top: 1px solid #ddd; margin: 30px 0;">
    <p style="color: #999; font-size: 12px; text-align: center;">This is an automated message from ${appName}. Please do not reply to this email.</p>
  </div>
</body>
</html>
    `.trim();
  }

  /**
   * Get plain text email body for tenant status update
   */
  private getTenantStatusUpdateEmailText(
    ticket: MaintenanceTicket,
    newStatus: string,
    previousStatus: string,
    notes?: string,
  ): string {
    return `
Your ticket status has been updated:

Ticket Number: ${ticket.ticketNumber}
Title: ${ticket.title}
${previousStatus ? `Previous Status: ${previousStatus}\n` : ''}New Status: ${newStatus}
${notes ? `Notes: ${notes}\n` : ''}This is an automated message. Please do not reply to this email.
    `.trim();
  }

  /**
   * Get HTML email body for tenant acknowledgment notification
   */
  private getTenantAcknowledgmentEmailHtml(
    ticket: MaintenanceTicket,
    acknowledgerName: string,
  ): string {
    const appName = this.configService.get<string>('APP_NAME') || 'TENX';

    return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Ticket Acknowledged</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
  <div style="background-color: #FCB447; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0;">
    <h1 style="margin: 0;">${appName}</h1>
    <p style="margin: 10px 0 0 0; font-size: 18px; opacity: 0.9;">Ticket Acknowledged</p>
  </div>
  <div style="background-color: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px;">
    <p>Your ticket has been acknowledged by our support team.</p>
    
    <div style="background-color: #fff; border: 2px solid #FCB447; border-radius: 8px; padding: 20px; margin: 20px 0;">
      <table style="width: 100%; border-collapse: collapse;">
        <tr>
          <td style="padding: 8px 0; font-weight: bold; width: 150px;">Ticket Number:</td>
          <td style="padding: 8px 0;"><strong>${ticket.ticketNumber}</strong></td>
        </tr>
        <tr>
          <td style="padding: 8px 0; font-weight: bold;">Title:</td>
          <td style="padding: 8px 0;">${ticket.title}</td>
        </tr>
        <tr>
          <td style="padding: 8px 0; font-weight: bold;">Acknowledged by:</td>
          <td style="padding: 8px 0;">${acknowledgerName}</td>
        </tr>
        <tr>
          <td style="padding: 8px 0; font-weight: bold;">Acknowledged on:</td>
          <td style="padding: 8px 0;">${ticket.acknowledgedAt?.toLocaleString() || new Date().toLocaleString()}</td>
        </tr>
      </table>
    </div>

    <p>We are reviewing your ticket and will assign it to the appropriate team shortly.</p>

    <hr style="border: none; border-top: 1px solid #ddd; margin: 30px 0;">
    <p style="color: #999; font-size: 12px; text-align: center;">This is an automated message from ${appName}. Please do not reply to this email.</p>
  </div>
</body>
</html>
    `.trim();
  }

  /**
   * Get plain text email body for tenant acknowledgment notification
   */
  private getTenantAcknowledgmentEmailText(
    ticket: MaintenanceTicket,
    acknowledgerName: string,
  ): string {
    return `
Your ticket has been acknowledged by our support team.

Ticket Number: ${ticket.ticketNumber}
Title: ${ticket.title}
Acknowledged by: ${acknowledgerName}
Acknowledged on: ${ticket.acknowledgedAt?.toLocaleString() || new Date().toLocaleString()}

We are reviewing your ticket and will assign it to the appropriate team shortly.

This is an automated message. Please do not reply to this email.
    `.trim();
  }

  /**
   * Get HTML email body for tenant technician assignment notification
   */
  private getTenantTechnicianAssignedEmailHtml(
    ticket: MaintenanceTicket,
    technicianName: string,
    technicianEmail?: string,
    scheduledAt?: Date,
  ): string {
    const appName = this.configService.get<string>('APP_NAME') || 'TENX';

    return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Technician Assigned</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
  <div style="background-color: #FCB447; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0;">
    <h1 style="margin: 0;">${appName}</h1>
    <p style="margin: 10px 0 0 0; font-size: 18px; opacity: 0.9;">Technician Assigned</p>
  </div>
  <div style="background-color: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px;">
    <p>A technician has been assigned to your ticket and will be in touch with you soon.</p>
    
    <div style="background-color: #fff; border: 2px solid #FCB447; border-radius: 8px; padding: 20px; margin: 20px 0;">
      <table style="width: 100%; border-collapse: collapse;">
        <tr>
          <td style="padding: 8px 0; font-weight: bold; width: 150px;">Ticket Number:</td>
          <td style="padding: 8px 0;"><strong>${ticket.ticketNumber}</strong></td>
        </tr>
        <tr>
          <td style="padding: 8px 0; font-weight: bold;">Title:</td>
          <td style="padding: 8px 0;">${ticket.title}</td>
        </tr>
        <tr>
          <td style="padding: 8px 0; font-weight: bold;">Technician:</td>
          <td style="padding: 8px 0;">${technicianName}${technicianEmail ? ` (${technicianEmail})` : ''}</td>
        </tr>
        ${scheduledAt ? `<tr>
          <td style="padding: 8px 0; font-weight: bold;">Scheduled Visit:</td>
          <td style="padding: 8px 0;">${scheduledAt.toLocaleString()}</td>
        </tr>` : ''}
        <tr>
          <td style="padding: 8px 0; font-weight: bold;">Assigned on:</td>
          <td style="padding: 8px 0;">${ticket.assignedAt?.toLocaleString() || new Date().toLocaleString()}</td>
        </tr>
      </table>
    </div>

    <p>You can track the progress of your ticket and communicate with the technician through the app.</p>

    <hr style="border: none; border-top: 1px solid #ddd; margin: 30px 0;">
    <p style="color: #999; font-size: 12px; text-align: center;">This is an automated message from ${appName}. Please do not reply to this email.</p>
  </div>
</body>
</html>
    `.trim();
  }

  /**
   * Get plain text email body for tenant technician assignment notification
   */
  private getTenantTechnicianAssignedEmailText(
    ticket: MaintenanceTicket,
    technicianName: string,
    technicianEmail?: string,
    scheduledAt?: Date,
  ): string {
    return `
A technician has been assigned to your ticket and will be in touch with you soon.

Ticket Number: ${ticket.ticketNumber}
Title: ${ticket.title}
Technician: ${technicianName}${technicianEmail ? ` (${technicianEmail})` : ''}
${scheduledAt ? `Scheduled Visit: ${scheduledAt.toLocaleString()}\n` : ''}Assigned on: ${ticket.assignedAt?.toLocaleString() || new Date().toLocaleString()}

You can track the progress of your ticket and communicate with the technician through the app.

This is an automated message. Please do not reply to this email.
    `.trim();
  }

  /**
   * Get HTML email body for tenant supervisor assignment notification
   */
  private getTenantSupervisorAssignedEmailHtml(
    ticket: MaintenanceTicket,
    supervisorName: string,
    supervisorEmail?: string,
  ): string {
    const appName = this.configService.get<string>('APP_NAME') || 'TENX';

    return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Supervisor Assigned</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
  <div style="background-color: #FCB447; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0;">
    <h1 style="margin: 0;">${appName}</h1>
    <p style="margin: 10px 0 0 0; font-size: 18px; opacity: 0.9;">Supervisor Assigned</p>
  </div>
  <div style="background-color: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px;">
    <p>A supervisor has been assigned to review and coordinate your ticket.</p>
    
    <div style="background-color: #fff; border: 2px solid #FCB447; border-radius: 8px; padding: 20px; margin: 20px 0;">
      <table style="width: 100%; border-collapse: collapse;">
        <tr>
          <td style="padding: 8px 0; font-weight: bold; width: 150px;">Ticket Number:</td>
          <td style="padding: 8px 0;"><strong>${ticket.ticketNumber}</strong></td>
        </tr>
        <tr>
          <td style="padding: 8px 0; font-weight: bold;">Title:</td>
          <td style="padding: 8px 0;">${ticket.title}</td>
        </tr>
        <tr>
          <td style="padding: 8px 0; font-weight: bold;">Supervisor:</td>
          <td style="padding: 8px 0;">${supervisorName}${supervisorEmail ? ` (${supervisorEmail})` : ''}</td>
        </tr>
        <tr>
          <td style="padding: 8px 0; font-weight: bold;">Assigned on:</td>
          <td style="padding: 8px 0;">${ticket.supervisorAssignedAt?.toLocaleString() || new Date().toLocaleString()}</td>
        </tr>
      </table>
    </div>

    <p>The supervisor will review your ticket and coordinate the appropriate resources to resolve it.</p>

    <hr style="border: none; border-top: 1px solid #ddd; margin: 30px 0;">
    <p style="color: #999; font-size: 12px; text-align: center;">This is an automated message from ${appName}. Please do not reply to this email.</p>
  </div>
</body>
</html>
    `.trim();
  }

  /**
   * Get plain text email body for tenant supervisor assignment notification
   */
  private getTenantSupervisorAssignedEmailText(
    ticket: MaintenanceTicket,
    supervisorName: string,
    supervisorEmail?: string,
  ): string {
    return `
A supervisor has been assigned to review and coordinate your ticket.

Ticket Number: ${ticket.ticketNumber}
Title: ${ticket.title}
Supervisor: ${supervisorName}${supervisorEmail ? ` (${supervisorEmail})` : ''}
Assigned on: ${ticket.supervisorAssignedAt?.toLocaleString() || new Date().toLocaleString()}

The supervisor will review your ticket and coordinate the appropriate resources to resolve it.

This is an automated message. Please do not reply to this email.
    `.trim();
  }

  /**
   * Get HTML email body for tenant team assignment notification
   */
  private getTenantTeamAssignedEmailHtml(
    ticket: MaintenanceTicket,
    teamName: string,
  ): string {
    const appName = this.configService.get<string>('APP_NAME') || 'TENX';

    return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Team Assigned</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
  <div style="background-color: #FCB447; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0;">
    <h1 style="margin: 0;">${appName}</h1>
    <p style="margin: 10px 0 0 0; font-size: 18px; opacity: 0.9;">Team Assigned</p>
  </div>
  <div style="background-color: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px;">
    <p>A team has been assigned to work on your ticket.</p>
    
    <div style="background-color: #fff; border: 2px solid #FCB447; border-radius: 8px; padding: 20px; margin: 20px 0;">
      <table style="width: 100%; border-collapse: collapse;">
        <tr>
          <td style="padding: 8px 0; font-weight: bold; width: 150px;">Ticket Number:</td>
          <td style="padding: 8px 0;"><strong>${ticket.ticketNumber}</strong></td>
        </tr>
        <tr>
          <td style="padding: 8px 0; font-weight: bold;">Title:</td>
          <td style="padding: 8px 0;">${ticket.title}</td>
        </tr>
        <tr>
          <td style="padding: 8px 0; font-weight: bold;">Team:</td>
          <td style="padding: 8px 0;">${teamName}</td>
        </tr>
        <tr>
          <td style="padding: 8px 0; font-weight: bold;">Assigned on:</td>
          <td style="padding: 8px 0;">${ticket.assignedAt?.toLocaleString() || new Date().toLocaleString()}</td>
        </tr>
      </table>
    </div>

    <p>The team will coordinate to resolve your ticket efficiently.</p>

    <hr style="border: none; border-top: 1px solid #ddd; margin: 30px 0;">
    <p style="color: #999; font-size: 12px; text-align: center;">This is an automated message from ${appName}. Please do not reply to this email.</p>
  </div>
</body>
</html>
    `.trim();
  }

  /**
   * Get plain text email body for tenant team assignment notification
   */
  private getTenantTeamAssignedEmailText(
    ticket: MaintenanceTicket,
    teamName: string,
  ): string {
    return `
A team has been assigned to work on your ticket.

Ticket Number: ${ticket.ticketNumber}
Title: ${ticket.title}
Team: ${teamName}
Assigned on: ${ticket.assignedAt?.toLocaleString() || new Date().toLocaleString()}

The team will coordinate to resolve your ticket efficiently.

This is an automated message. Please do not reply to this email.
    `.trim();
  }
}

