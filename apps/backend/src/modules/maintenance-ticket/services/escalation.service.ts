import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In } from 'typeorm';
import { MaintenanceTicket } from '../entities/maintenance-ticket.entity';
import { TicketSla } from '../entities/ticket-sla.entity';
import { EscalationHistory } from '../entities/escalation-history.entity';
import { SlaConfiguration } from '../entities/sla-configuration.entity';
import { User } from '../../iam/entities/user.entity';
import { UserRole } from '../../iam/entities/user-role.entity';
import { Role } from '../../iam/entities/role.entity';
import { TicketStatus } from '../enums/ticket-status.enum';
import { UserStatus } from '../../iam/entities/user.entity';
import { SlaService } from './sla.service';
import { NotificationService } from '../../notification/notification.service';
import { NotificationSeverity } from '../../notification/enums/notification-severity.enum';
import { NotificationChannel } from '../../notification/enums/notification-channel.enum';

@Injectable()
export class EscalationService {
  private readonly logger = new Logger(EscalationService.name);

  // Role hierarchy mapping
  private readonly ESCALATION_ROLE_MAP: Record<number, string> = {
    1: 'SUPERVISOR',
    2: 'SITE_COORDINATOR',
    3: 'ADMIN',
  };

  constructor(
    @InjectRepository(MaintenanceTicket)
    private readonly ticketRepository: Repository<MaintenanceTicket>,
    @InjectRepository(TicketSla)
    private readonly ticketSlaRepository: Repository<TicketSla>,
    @InjectRepository(EscalationHistory)
    private readonly escalationHistoryRepository: Repository<EscalationHistory>,
    @InjectRepository(SlaConfiguration)
    private readonly slaConfigRepository: Repository<SlaConfiguration>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(UserRole)
    private readonly userRoleRepository: Repository<UserRole>,
    @InjectRepository(Role)
    private readonly roleRepository: Repository<Role>,
    private readonly slaService: SlaService,
    private readonly notificationService: NotificationService,
  ) {}

  /**
   * Main method to check and escalate tickets based on SLA thresholds
   */
  async checkAndEscalateTickets(companyId: string): Promise<void> {
    try {
      const now = new Date();
      
      // Find all active tickets with SLA that haven't been resolved
      // Query from TicketSla and join with MaintenanceTicket
      const activeTicketsWithSla = await this.ticketSlaRepository
        .createQueryBuilder('sla')
        .leftJoinAndSelect('sla.ticket', 'ticket')
        .leftJoinAndSelect('sla.slaConfiguration', 'config')
        .where('sla.companyId = :companyId', { companyId })
        .andWhere('ticket.status NOT IN (:...resolvedStatuses)', {
          resolvedStatuses: [TicketStatus.COMPLETED, TicketStatus.CANCELLED],
        })
        .getMany();

      const activeTickets = activeTicketsWithSla.map((sla) => sla.ticket);

      this.logger.log(
        `Checking ${activeTicketsWithSla.length} active tickets for escalation in company ${companyId}`,
      );

      for (const ticketSla of activeTicketsWithSla) {
        try {
          await this.checkAndEscalateTicket(ticketSla.ticket, ticketSla, now);
        } catch (error) {
          const errorMessage = error instanceof Error ? error.message : String(error);
          this.logger.error(
            `Error checking escalation for ticket ${ticketSla.ticket.id}: ${errorMessage}`,
          );
          // Continue with other tickets
        }
      }
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      this.logger.error(
        `Error in checkAndEscalateTickets for company ${companyId}: ${errorMessage}`,
      );
      throw error;
    }
  }

  /**
   * Check a single ticket and escalate if thresholds are met
   */
  private async checkAndEscalateTicket(
    ticket: MaintenanceTicket,
    sla: TicketSla,
    now: Date,
  ): Promise<void> {
    if (!sla || !sla.slaConfiguration) {
      return;
    }

    const config = sla.slaConfiguration;
    const currentLevel = sla.currentEscalationLevel || 0;

    // Determine the base time for escalation calculation
    // If ticket is assigned, use assignment time; otherwise use creation time
    const baseTime = ticket.assignedAt || ticket.createdAt;
    
    // Calculate elapsed time since base time (excluding paused time)
    const elapsedMinutes =
      (now.getTime() - baseTime.getTime()) / (1000 * 60) -
      (sla.totalPausedMinutes || 0);

    // Check if ticket is assigned but not acknowledged
    const isAssigned = !!ticket.assignedTechnicianId || !!ticket.assignedSupervisorId;
    const isAcknowledged = !!(ticket.acknowledgedAt || sla.acknowledgedAt);
    
    // If ticket is assigned but not acknowledged, check acknowledgment deadline
    if (isAssigned && !isAcknowledged && config.acknowledgementTimeMinutes) {
      const acknowledgmentElapsed = elapsedMinutes;
      if (acknowledgmentElapsed >= config.acknowledgementTimeMinutes) {
        // Escalate for non-acknowledgment - this is a critical issue
        // Escalate to Level 1 (SUPERVISOR) immediately if not already escalated
        if (currentLevel < 1) {
          await this.escalateTicket(
            ticket.companyId,
            ticket.id,
            1,
            `Automatic escalation: Ticket assigned but not acknowledged after ${Math.round(acknowledgmentElapsed)} minutes (deadline: ${config.acknowledgementTimeMinutes} minutes)`,
            undefined, // automatic escalation
          );
          return; // Don't check other escalation levels in this cycle
        }
      }
    }

    // Check if ticket is assigned but work hasn't started (status is still ASSIGNED)
    // This is a critical check: technician must start work within the deadline
    if (
      isAssigned &&
      ticket.status === TicketStatus.ASSIGNED &&
      ticket.assignedAt &&
      config.startWorkTimeMinutes
    ) {
      // Calculate time since assignment
      const timeSinceAssignment =
        (now.getTime() - ticket.assignedAt.getTime()) / (1000 * 60) -
        (sla.totalPausedMinutes || 0);

      if (timeSinceAssignment >= config.startWorkTimeMinutes) {
        // Escalate for not starting work - this is a critical issue
        // Escalate to Level 1 (SUPERVISOR) immediately if not already escalated
        if (currentLevel < 1) {
          await this.escalateTicket(
            ticket.companyId,
            ticket.id,
            1,
            `Automatic escalation: Ticket assigned but work not started after ${Math.round(timeSinceAssignment)} minutes (deadline: ${config.startWorkTimeMinutes} minutes). Status is still ASSIGNED.`,
            undefined, // automatic escalation
          );
          return; // Don't check other escalation levels in this cycle
        } else if (currentLevel < 2) {
          // If already at level 1, escalate to level 2
          await this.escalateTicket(
            ticket.companyId,
            ticket.id,
            2,
            `Automatic escalation: Ticket assigned but work not started after ${Math.round(timeSinceAssignment)} minutes (deadline: ${config.startWorkTimeMinutes} minutes). Status is still ASSIGNED.`,
            undefined, // automatic escalation
          );
          return;
        } else if (currentLevel < 3) {
          // If already at level 2, escalate to level 3
          await this.escalateTicket(
            ticket.companyId,
            ticket.id,
            3,
            `Automatic escalation: Ticket assigned but work not started after ${Math.round(timeSinceAssignment)} minutes (deadline: ${config.startWorkTimeMinutes} minutes). Status is still ASSIGNED.`,
            undefined, // automatic escalation
          );
          return;
        }
      }
    }

    // Check escalation levels based on total elapsed time
    // These escalations apply regardless of acknowledgment status
    let newEscalationLevel = currentLevel;

    // Level 3: ADMIN
    if (
      config.escalationLevel3Minutes &&
      elapsedMinutes >= config.escalationLevel3Minutes &&
      currentLevel < 3
    ) {
      newEscalationLevel = 3;
    }
    // Level 2: SITE_COORDINATOR
    else if (
      config.escalationLevel2Minutes &&
      elapsedMinutes >= config.escalationLevel2Minutes &&
      currentLevel < 2
    ) {
      newEscalationLevel = 2;
    }
    // Level 1: SUPERVISOR
    else if (
      config.escalationLevel1Minutes &&
      elapsedMinutes >= config.escalationLevel1Minutes &&
      currentLevel < 1
    ) {
      newEscalationLevel = 1;
    }

    // Escalate if needed
    if (newEscalationLevel > currentLevel) {
      const reason = isAssigned && !isAcknowledged
        ? `Automatic escalation: Ticket assigned but not acknowledged after ${Math.round(elapsedMinutes)} minutes`
        : `Automatic escalation after ${Math.round(elapsedMinutes)} minutes`;
      
      await this.escalateTicket(
        ticket.companyId,
        ticket.id,
        newEscalationLevel,
        reason,
        undefined, // automatic escalation
      );
    }
  }

  /**
   * Manually escalate a ticket
   */
  async escalateTicketManually(
    companyId: string,
    ticketId: string,
    escalationLevel: number,
    reason: string | undefined,
    escalatedBy: string,
  ): Promise<EscalationHistory> {
    return this.escalateTicket(
      companyId,
      ticketId,
      escalationLevel,
      reason,
      escalatedBy,
    );
  }

  /**
   * Internal method to escalate a ticket
   */
  private async escalateTicket(
    companyId: string,
    ticketId: string,
    escalationLevel: number,
    reason: string | undefined,
    escalatedBy: string | undefined,
  ): Promise<EscalationHistory> {
    // Validate escalation level
    if (escalationLevel < 1 || escalationLevel > 3) {
      throw new Error(`Invalid escalation level: ${escalationLevel}. Must be 1, 2, or 3.`);
    }

    // Get ticket
    const ticket = await this.ticketRepository.findOne({
      where: { id: ticketId, companyId },
    });

    if (!ticket) {
      throw new Error(`Ticket not found: ${ticketId}`);
    }

    const targetRole = this.ESCALATION_ROLE_MAP[escalationLevel];
    if (!targetRole) {
      throw new Error(`Invalid escalation level: ${escalationLevel}`);
    }

    // Get current escalation level from SLA
    const sla = await this.ticketSlaRepository.findOne({
      where: { companyId, ticketId },
    });
    const previousLevel = sla?.currentEscalationLevel || 0;

    // Don't escalate if already at or beyond this level
    if (previousLevel >= escalationLevel) {
      this.logger.warn(
        `Ticket ${ticketId} already at escalation level ${previousLevel}, skipping escalation to level ${escalationLevel}`,
      );
      // Return existing history entry if any
      const existing = await this.escalationHistoryRepository.findOne({
        where: { companyId, ticketId, escalationLevel },
        order: { escalatedAt: 'DESC' },
      });
      if (existing) {
        return existing;
      }
    }

    // Update ticket escalation fields
    ticket.isEscalated = true;
    ticket.escalationLevel = escalationLevel;
    ticket.escalatedAt = new Date();

    // Update SLA escalation tracking
    if (sla) {
      sla.currentEscalationLevel = escalationLevel;
      sla.lastEscalationAt = new Date();
      await this.ticketSlaRepository.save(sla);
    }

    await this.ticketRepository.save(ticket);

    // Create escalation history entry
    const escalationHistory = this.escalationHistoryRepository.create({
      companyId,
      ticketId,
      escalationLevel,
      escalatedFromRole:
        previousLevel > 0 ? this.ESCALATION_ROLE_MAP[previousLevel] : undefined,
      escalatedToRole: targetRole,
      reason: reason || `Automatic escalation to level ${escalationLevel}`,
      escalatedBy,
      escalatedAt: new Date(),
      isAutomatic: !escalatedBy,
    });

    const savedHistory = await this.escalationHistoryRepository.save(escalationHistory);

    // Send notifications to all users with target role
    await this.sendEscalationNotifications(
      companyId,
      ticket,
      escalationLevel,
      targetRole,
      savedHistory,
    );

    this.logger.log(
      `Ticket ${ticket.ticketNumber} escalated to level ${escalationLevel} (${targetRole})`,
    );

    return savedHistory;
  }

  /**
   * Send email and push notifications to users with target role
   */
  private async sendEscalationNotifications(
    companyId: string,
    ticket: MaintenanceTicket,
    escalationLevel: number,
    targetRole: string,
    escalationHistory: EscalationHistory,
  ): Promise<void> {
    try {
      // Find all users with the target role
      const targetUsers = await this.userRepository
        .createQueryBuilder('user')
        .leftJoinAndSelect('user.userRoles', 'userRole')
        .leftJoinAndSelect('userRole.role', 'role')
        .where('user.companyId = :companyId', { companyId })
        .andWhere('user.status = :status', { status: UserStatus.ACTIVE })
        .andWhere('user.deleted_at IS NULL')
        .andWhere('role.name = :roleName', { roleName: targetRole })
        .getMany();

      if (targetUsers.length === 0) {
        this.logger.warn(
          `No active users found with role ${targetRole} for escalation notifications`,
        );
        return;
      }

      const priorityLabel =
        ticket.priority.charAt(0) + ticket.priority.slice(1).toLowerCase();

      // Template codes based on escalation level
      // Map role names to template code suffixes
      const roleTemplateMap: Record<string, { email: string; push: string }> = {
        SUPERVISOR: {
          email: 'TICKET_ESCALATED_TO_SUPERVISOR_EMAIL',
          push: 'TICKET_ESCALATED_TO_SUPERVISOR_PUSH',
        },
        SITE_COORDINATOR: {
          email: 'TICKET_ESCALATED_TO_COORDINATOR_EMAIL',
          push: 'TICKET_ESCALATED_TO_COORDINATOR_PUSH',
        },
        ADMIN: {
          email: 'TICKET_ESCALATED_TO_ADMIN_EMAIL',
          push: 'TICKET_ESCALATED_TO_ADMIN_PUSH',
        },
      };

      const templateCodes = roleTemplateMap[targetRole];
      if (!templateCodes) {
        this.logger.warn(
          `No template codes found for role ${targetRole}, skipping notifications`,
        );
        return;
      }

      const emailTemplateCode = templateCodes.email;
      const pushTemplateCode = templateCodes.push;

      // Send notifications to each user
      for (const user of targetUsers) {
        try {
          // Send Email notification
          await this.notificationService.publishEvent({
            type: 'ticket_escalated',
            companyId,
            recipientUserId: user.id,
            severity: NotificationSeverity.WARNING,
            templateCode: emailTemplateCode,
            channels: [NotificationChannel.EMAIL as string],
            variables: {
              title: `Ticket Escalated: ${ticket.ticketNumber}`,
              ticketNumber: ticket.ticketNumber,
              ticketTitle: ticket.title,
              priority: priorityLabel,
              escalationLevel: escalationLevel.toString(),
              escalationRole: targetRole,
              reason: escalationHistory.reason || 'Automatic escalation',
              escalatedAt: escalationHistory.escalatedAt.toISOString(),
              ticketId: ticket.id,
              body: `Ticket ${ticket.ticketNumber} has been escalated to ${targetRole}`,
            },
          });

          // Send Push notification
          await this.notificationService.publishEvent({
            type: 'ticket_escalated',
            companyId,
            recipientUserId: user.id,
            severity: NotificationSeverity.WARNING,
            templateCode: pushTemplateCode,
            channels: [NotificationChannel.PUSH as string],
            variables: {
              title: `Ticket Escalated: ${ticket.ticketNumber}`,
              ticketNumber: ticket.ticketNumber,
              ticketTitle: ticket.title,
              priority: priorityLabel,
              escalationLevel: escalationLevel.toString(),
              escalationRole: targetRole,
              reason: escalationHistory.reason || 'Automatic escalation',
              escalatedAt: escalationHistory.escalatedAt.toISOString(),
              ticketId: ticket.id,
              body: `Ticket ${ticket.ticketNumber} escalated to ${targetRole}`,
            },
          });
        } catch (error) {
          const errorMessage = error instanceof Error ? error.message : String(error);
          this.logger.error(
            `Error sending escalation notification to user ${user.id}: ${errorMessage}`,
          );
          // Continue with other users
        }
      }
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      this.logger.error(
        `Error in sendEscalationNotifications: ${errorMessage}`,
      );
      // Don't throw - notification failures shouldn't block escalation
    }
  }

  /**
   * Get escalation history for a ticket
   */
  async getEscalationHistory(
    companyId: string,
    ticketId: string,
  ): Promise<EscalationHistory[]> {
    return this.escalationHistoryRepository.find({
      where: { companyId, ticketId },
      relations: ['escalator'],
      order: { escalatedAt: 'DESC' },
    });
  }

  /**
   * Get escalation matrix configuration for a company
   */
  async getEscalationMatrix(companyId: string): Promise<{
    priority: string;
    level1Minutes?: number;
    level2Minutes?: number;
    level3Minutes?: number;
  }[]> {
    const configs = await this.slaConfigRepository.find({
      where: { companyId, isActive: true },
      order: { priority: 'ASC' },
    });

    return configs.map((config) => ({
      priority: config.priority,
      level1Minutes: config.escalationLevel1Minutes,
      level2Minutes: config.escalationLevel2Minutes,
      level3Minutes: config.escalationLevel3Minutes,
    }));
  }
}
