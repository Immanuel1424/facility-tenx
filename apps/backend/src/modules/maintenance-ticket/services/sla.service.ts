import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThan } from 'typeorm';
import { SlaConfiguration } from '../entities/sla-configuration.entity';
import { TicketSla, SlaStatus } from '../entities/ticket-sla.entity';
import { MaintenanceTicket } from '../entities/maintenance-ticket.entity';
import { TicketPriority } from '../enums/ticket-priority.enum';
import { TicketStatus } from '../enums/ticket-status.enum';
import { CreateSlaConfigurationDto } from '../dto/create-sla-configuration.dto';
import { UpdateSlaConfigurationDto } from '../dto/update-sla-configuration.dto';
import {
  ResourceNotFoundException,
  DuplicateResourceException,
} from '../../../shared/exceptions/business.exception';
import { NotificationService } from '../../notification/notification.service';
import { NotificationSeverity } from '../../notification/enums/notification-severity.enum';
import { UserService } from '../../iam/services/user.service';
import { User } from '../../iam/entities/user.entity';
import { UserStatus } from '../../iam/entities/user.entity';

@Injectable()
export class SlaService {
  private readonly logger = new Logger(SlaService.name);

  constructor(
    @InjectRepository(SlaConfiguration)
    private readonly slaConfigRepository: Repository<SlaConfiguration>,
    @InjectRepository(TicketSla)
    private readonly ticketSlaRepository: Repository<TicketSla>,
    @InjectRepository(MaintenanceTicket)
    private readonly ticketRepository: Repository<MaintenanceTicket>,
    private readonly notificationService: NotificationService,
    private readonly userService: UserService,
  ) {}

  // SLA Configuration Management
  async createConfiguration(
    companyId: string,
    userId: string,
    createDto: CreateSlaConfigurationDto,
  ): Promise<SlaConfiguration> {
    // Check for existing configuration with same priority
    const existing = await this.slaConfigRepository.findOne({
      where: { companyId, priority: createDto.priority },
    });

    if (existing) {
      throw new DuplicateResourceException(
        'SLA Configuration',
        'priority',
        createDto.priority,
      );
    }

    const config = this.slaConfigRepository.create({
      companyId,
      name: createDto.name,
      description: createDto.description,
      priority: createDto.priority,
      firstResponseTimeMinutes: createDto.first_response_time_minutes,
      acknowledgementTimeMinutes: createDto.acknowledgement_time_minutes,
      startWorkTimeMinutes: createDto.start_work_time_minutes,
      resolutionTimeMinutes: createDto.resolution_time_minutes,
      escalationLevel1Minutes: createDto.escalation_level_1_minutes,
      escalationLevel2Minutes: createDto.escalation_level_2_minutes,
      escalationLevel3Minutes: createDto.escalation_level_3_minutes,
      applyBusinessHours: createDto.apply_business_hours ?? true,
      businessStartTime: createDto.business_start_time,
      businessEndTime: createDto.business_end_time,
      workingDays: createDto.working_days,
      excludeHolidays: createDto.exclude_holidays ?? true,
      createdById: userId,
    });

    return this.slaConfigRepository.save(config);
  }

  async findAllConfigurations(companyId: string): Promise<SlaConfiguration[]> {
    return this.slaConfigRepository.find({
      where: { companyId },
      order: { priority: 'ASC' },
    });
  }

  async findActiveConfigurations(companyId: string): Promise<SlaConfiguration[]> {
    return this.slaConfigRepository.find({
      where: { companyId, isActive: true },
      order: { priority: 'ASC' },
    });
  }

  async findConfigurationById(
    companyId: string,
    configId: string,
  ): Promise<SlaConfiguration> {
    const config = await this.slaConfigRepository.findOne({
      where: { id: configId, companyId },
    });

    if (!config) {
      throw new ResourceNotFoundException('SLA Configuration', configId);
    }

    return config;
  }

  async findConfigurationByPriority(
    companyId: string,
    priority: TicketPriority,
  ): Promise<SlaConfiguration | null> {
    return this.slaConfigRepository.findOne({
      where: { companyId, priority, isActive: true },
    });
  }

  async updateConfiguration(
    companyId: string,
    configId: string,
    updateDto: UpdateSlaConfigurationDto,
  ): Promise<SlaConfiguration> {
    const config = await this.findConfigurationById(companyId, configId);

    if (updateDto.name !== undefined) {
      config.name = updateDto.name;
    }
    if (updateDto.description !== undefined) {
      config.description = updateDto.description;
    }
    if (updateDto.first_response_time_minutes !== undefined) {
      config.firstResponseTimeMinutes = updateDto.first_response_time_minutes;
    }
    if (updateDto.acknowledgement_time_minutes !== undefined) {
      config.acknowledgementTimeMinutes = updateDto.acknowledgement_time_minutes;
    }
    if (updateDto.start_work_time_minutes !== undefined) {
      config.startWorkTimeMinutes = updateDto.start_work_time_minutes;
    }
    if (updateDto.resolution_time_minutes !== undefined) {
      config.resolutionTimeMinutes = updateDto.resolution_time_minutes;
    }
    if (updateDto.escalation_level_1_minutes !== undefined) {
      config.escalationLevel1Minutes = updateDto.escalation_level_1_minutes;
    }
    if (updateDto.escalation_level_2_minutes !== undefined) {
      config.escalationLevel2Minutes = updateDto.escalation_level_2_minutes;
    }
    if (updateDto.escalation_level_3_minutes !== undefined) {
      config.escalationLevel3Minutes = updateDto.escalation_level_3_minutes;
    }
    if (updateDto.apply_business_hours !== undefined) {
      config.applyBusinessHours = updateDto.apply_business_hours;
    }
    if (updateDto.business_start_time !== undefined) {
      config.businessStartTime = updateDto.business_start_time;
    }
    if (updateDto.business_end_time !== undefined) {
      config.businessEndTime = updateDto.business_end_time;
    }
    if (updateDto.working_days !== undefined) {
      config.workingDays = updateDto.working_days;
    }
    if (updateDto.exclude_holidays !== undefined) {
      config.excludeHolidays = updateDto.exclude_holidays;
    }
    if (updateDto.is_active !== undefined) {
      config.isActive = updateDto.is_active;
    }

    return this.slaConfigRepository.save(config);
  }

  async deleteConfiguration(companyId: string, configId: string): Promise<void> {
    const config = await this.findConfigurationById(companyId, configId);
    await this.slaConfigRepository.remove(config);
  }

  // Ticket SLA Management
  async initializeTicketSla(
    companyId: string,
    ticketId: string,
    priority: TicketPriority,
  ): Promise<TicketSla | null> {
    const config = await this.findConfigurationByPriority(companyId, priority);

    if (!config) {
      this.logger.warn(
        `No SLA configuration found for priority ${priority} in company ${companyId}`,
      );
      return null;
    }

    const now = new Date();
    const firstResponseDeadline = this.addMinutes(now, config.firstResponseTimeMinutes);
    const responseDeadline = this.addMinutes(now, config.acknowledgementTimeMinutes);
    const resolutionDeadline = this.addMinutes(now, config.resolutionTimeMinutes);

    const ticketSla = this.ticketSlaRepository.create({
      companyId,
      ticketId,
      slaConfigurationId: config.id,
      firstResponseDeadline,
      responseDeadline,
      resolutionDeadline,
      slaStatus: SlaStatus.ON_TRACK,
    });

    return this.ticketSlaRepository.save(ticketSla);
  }

  async getTicketSla(companyId: string, ticketId: string): Promise<TicketSla | null> {
    return this.ticketSlaRepository.findOne({
      where: { companyId, ticketId },
      relations: ['slaConfiguration'],
    });
  }

  async recordFirstResponse(companyId: string, ticketId: string): Promise<TicketSla | null> {
    const ticketSla = await this.getTicketSla(companyId, ticketId);

    if (!ticketSla || ticketSla.firstResponseAt) {
      return ticketSla;
    }

    const now = new Date();
    const oldStatus = ticketSla.slaStatus;
    ticketSla.firstResponseAt = now;
    ticketSla.firstResponseBreached = now > ticketSla.firstResponseDeadline;

    if (ticketSla.firstResponseBreached) {
      ticketSla.slaStatus = SlaStatus.BREACHED;
    }

    const savedSla = await this.ticketSlaRepository.save(ticketSla);

    // Send alert if first response was breached
    if (ticketSla.firstResponseBreached && oldStatus !== SlaStatus.BREACHED) {
      await this.sendSlaAlert(companyId, savedSla, SlaStatus.BREACHED, oldStatus).catch(
        (error) => {
          this.logger.error(
            `Failed to send SLA breach alert for ticket ${ticketId}: ${error.message}`,
          );
        },
      );
    }

    return savedSla;
  }

  async recordAcknowledgement(companyId: string, ticketId: string): Promise<TicketSla | null> {
    const ticketSla = await this.getTicketSla(companyId, ticketId);

    if (!ticketSla || ticketSla.acknowledgedAt) {
      return ticketSla;
    }

    const now = new Date();
    const oldStatus = ticketSla.slaStatus;
    ticketSla.acknowledgedAt = now;
    ticketSla.responseBreached = now > ticketSla.responseDeadline;
    ticketSla.actualResponseMinutes = this.getMinutesDifference(
      ticketSla.createdAt,
      now,
    );

    if (ticketSla.responseBreached) {
      ticketSla.slaStatus = SlaStatus.BREACHED;
    }

    const savedSla = await this.ticketSlaRepository.save(ticketSla);

    // Send alert if response was breached
    if (ticketSla.responseBreached && oldStatus !== SlaStatus.BREACHED) {
      await this.sendSlaAlert(companyId, savedSla, SlaStatus.BREACHED, oldStatus).catch(
        (error) => {
          this.logger.error(
            `Failed to send SLA breach alert for ticket ${ticketId}: ${error.message}`,
          );
        },
      );
    }

    return savedSla;
  }

  async recordResolution(companyId: string, ticketId: string): Promise<TicketSla | null> {
    const ticketSla = await this.getTicketSla(companyId, ticketId);

    if (!ticketSla || ticketSla.resolvedAt) {
      return ticketSla;
    }

    const now = new Date();
    ticketSla.resolvedAt = now;
    ticketSla.resolutionBreached = now > ticketSla.resolutionDeadline;
    ticketSla.actualResolutionMinutes = this.getMinutesDifference(
      ticketSla.createdAt,
      now,
    ) - ticketSla.totalPausedMinutes;

    const oldStatus = ticketSla.slaStatus;
    if (ticketSla.resolutionBreached) {
      ticketSla.slaStatus = SlaStatus.BREACHED;
    } else if (!ticketSla.firstResponseBreached && !ticketSla.responseBreached) {
      ticketSla.slaStatus = SlaStatus.MET;
    }

    const savedSla = await this.ticketSlaRepository.save(ticketSla);

    // Send alert if SLA was breached
    if (ticketSla.resolutionBreached && oldStatus !== SlaStatus.BREACHED) {
      await this.sendSlaAlert(companyId, savedSla, SlaStatus.BREACHED, oldStatus).catch(
        (error) => {
          this.logger.error(
            `Failed to send SLA breach alert for ticket ${ticketId}: ${error.message}`,
          );
        },
      );
    }

    return savedSla;
  }

  async pauseSla(companyId: string, ticketId: string): Promise<TicketSla | null> {
    const ticketSla = await this.getTicketSla(companyId, ticketId);

    if (!ticketSla || ticketSla.pausedAt) {
      return ticketSla;
    }

    ticketSla.pausedAt = new Date();
    ticketSla.slaStatus = SlaStatus.PAUSED;

    return this.ticketSlaRepository.save(ticketSla);
  }

  async resumeSla(companyId: string, ticketId: string): Promise<TicketSla | null> {
    const ticketSla = await this.getTicketSla(companyId, ticketId);

    if (!ticketSla || !ticketSla.pausedAt) {
      return ticketSla;
    }

    const now = new Date();
    const pausedMinutes = this.getMinutesDifference(ticketSla.pausedAt, now);
    ticketSla.totalPausedMinutes += pausedMinutes;

    // Extend deadlines by paused time
    ticketSla.resolutionDeadline = this.addMinutes(
      ticketSla.resolutionDeadline,
      pausedMinutes,
    );

    ticketSla.pausedAt = undefined;
    ticketSla.slaStatus = this.calculateSlaStatus(ticketSla);

    return this.ticketSlaRepository.save(ticketSla);
  }

  async checkAndUpdateSlaStatus(companyId: string): Promise<void> {
    const now = new Date();

    // Find tickets that are at risk (75% of time elapsed)
    const atRiskThreshold = 0.75;

    const activeSlas = await this.ticketSlaRepository.find({
      where: {
        companyId,
        slaStatus: SlaStatus.ON_TRACK,
      },
      relations: ['ticket', 'slaConfiguration'],
    });

    for (const sla of activeSlas) {
      if (
        sla.ticket.status === TicketStatus.CANCELLED
      ) {
        continue;
      }

      const oldStatus = sla.slaStatus;
      const newStatus = this.calculateSlaStatus(sla, now);
      if (newStatus !== sla.slaStatus) {
        sla.slaStatus = newStatus;
        await this.ticketSlaRepository.save(sla);
        
        // Send alert when status changes to AT_RISK or BREACHED
        if (newStatus === SlaStatus.AT_RISK || newStatus === SlaStatus.BREACHED) {
          await this.sendSlaAlert(companyId, sla, newStatus, oldStatus).catch((error) => {
            this.logger.error(
              `Failed to send SLA alert for ticket ${sla.ticketId}: ${error.message}`,
            );
          });
        }
      }
    }
  }

  async getBreachedTickets(companyId: string): Promise<TicketSla[]> {
    return this.ticketSlaRepository.find({
      where: { companyId, slaStatus: SlaStatus.BREACHED },
      relations: ['ticket', 'slaConfiguration'],
    });
  }

  async getAtRiskTickets(companyId: string): Promise<TicketSla[]> {
    return this.ticketSlaRepository.find({
      where: { companyId, slaStatus: SlaStatus.AT_RISK },
      relations: ['ticket', 'slaConfiguration'],
    });
  }

  async getSlaMetrics(companyId: string): Promise<{
    total: number;
    on_track: number;
    at_risk: number;
    breached: number;
    met: number;
    paused: number;
    avg_resolution_minutes: number;
    sla_compliance_rate: number;
  }> {
    const slas = await this.ticketSlaRepository.find({
      where: { companyId },
    });

    const total = slas.length;
    const onTrack = slas.filter((s) => s.slaStatus === SlaStatus.ON_TRACK).length;
    const atRisk = slas.filter((s) => s.slaStatus === SlaStatus.AT_RISK).length;
    const breached = slas.filter((s) => s.slaStatus === SlaStatus.BREACHED).length;
    const met = slas.filter((s) => s.slaStatus === SlaStatus.MET).length;
    const paused = slas.filter((s) => s.slaStatus === SlaStatus.PAUSED).length;

    const resolvedSlas = slas.filter((s) => s.actualResolutionMinutes !== null);
    const avgResolutionMinutes =
      resolvedSlas.length > 0
        ? resolvedSlas.reduce((sum, s) => sum + (s.actualResolutionMinutes || 0), 0) /
          resolvedSlas.length
        : 0;

    const completedSlas = slas.filter(
      (s) => s.slaStatus === SlaStatus.MET || s.slaStatus === SlaStatus.BREACHED,
    );
    const slaComplianceRate =
      completedSlas.length > 0
        ? (met / completedSlas.length) * 100
        : 100;

    return {
      total,
      on_track: onTrack,
      at_risk: atRisk,
      breached,
      met,
      paused,
      avg_resolution_minutes: Math.round(avgResolutionMinutes),
      sla_compliance_rate: Math.round(slaComplianceRate * 100) / 100,
    };
  }

  private calculateSlaStatus(sla: TicketSla, now = new Date()): SlaStatus {
    if (sla.resolvedAt) {
      return sla.resolutionBreached ? SlaStatus.BREACHED : SlaStatus.MET;
    }

    if (now > sla.resolutionDeadline) {
      return SlaStatus.BREACHED;
    }

    // Check if at risk (75% of time elapsed)
    const totalTime = sla.resolutionDeadline.getTime() - sla.createdAt.getTime();
    const elapsedTime = now.getTime() - sla.createdAt.getTime();

    if (elapsedTime / totalTime >= 0.75) {
      return SlaStatus.AT_RISK;
    }

    return SlaStatus.ON_TRACK;
  }

  private addMinutes(date: Date, minutes: number): Date {
    return new Date(date.getTime() + minutes * 60 * 1000);
  }

  private getMinutesDifference(start: Date, end: Date): number {
    return Math.round((end.getTime() - start.getTime()) / (60 * 1000));
  }

  /**
   * Send SLA alert notifications when SLA status changes
   */
  private async sendSlaAlert(
    companyId: string,
    ticketSla: TicketSla,
    newStatus: SlaStatus,
    oldStatus: SlaStatus,
  ): Promise<void> {
    try {
      // Load ticket with relations
      const ticket = await this.ticketRepository.findOne({
        where: { id: ticketSla.ticketId, companyId },
        relations: ['assignedTechnician', 'assignedSupervisor', 'creator'],
      });

      if (!ticket) {
        this.logger.warn(`Ticket not found for SLA alert: ${ticketSla.ticketId}`);
        return;
      }

      // Get notification recipients
      const recipients: User[] = [];

      // Add assigned technician
      if (ticket.assignedTechnician && ticket.assignedTechnician.status === UserStatus.ACTIVE) {
        recipients.push(ticket.assignedTechnician);
      }

      // Add assigned supervisor
      if (ticket.assignedSupervisor && ticket.assignedSupervisor.status === UserStatus.ACTIVE) {
        recipients.push(ticket.assignedSupervisor);
      }

      // Add admins
      const admins = await this.userService.findAdmins(companyId);
      recipients.push(...admins);

      // Remove duplicates
      const uniqueRecipients = recipients.filter(
        (user, index, self) =>
          index === self.findIndex((u) => u.email === user.email),
      );

      if (uniqueRecipients.length === 0) {
        this.logger.warn(`No recipients found for SLA alert: ticketId=${ticketSla.ticketId}`);
        return;
      }

      // Calculate time remaining
      const now = new Date();
      const timeRemaining = ticketSla.resolutionDeadline.getTime() - now.getTime();
      const hoursRemaining = Math.max(0, Math.floor(timeRemaining / (60 * 60 * 1000)));
      const minutesRemaining = Math.max(0, Math.floor((timeRemaining % (60 * 60 * 1000)) / (60 * 1000)));

      // Determine severity and message
      const severity =
        newStatus === SlaStatus.BREACHED
          ? NotificationSeverity.CRITICAL
          : NotificationSeverity.WARNING;
      
      const statusLabel = newStatus === SlaStatus.BREACHED ? 'Breached' : 'At Risk';
      const timeText =
        newStatus === SlaStatus.BREACHED
          ? 'SLA deadline has passed'
          : `${hoursRemaining}h ${minutesRemaining}m remaining`;

      // Send notification to each recipient
      for (const recipient of uniqueRecipients) {
        await this.notificationService.publishEvent({
          type: `sla_${newStatus.toLowerCase()}`,
          companyId,
          recipientUserId: recipient.id,
          severity,
          templateCode: `sla_${newStatus.toLowerCase()}`,
          variables: {
            title: `SLA ${statusLabel}: ${ticket.ticketNumber}`,
            message: `Ticket ${ticket.ticketNumber} SLA is ${statusLabel}. ${timeText}`,
            ticketId: ticket.id,
            ticketNumber: ticket.ticketNumber,
            ticketTitle: ticket.title,
            slaStatus: statusLabel,
            timeRemaining: timeText,
            priority: ticket.priority,
            dueDate: ticketSla.resolutionDeadline.toISOString(),
          },
          channels: ['in_app', 'email', 'push'],
        });
      }

      this.logger.log(
        `SLA ${statusLabel} alert sent to ${uniqueRecipients.length} recipients for ticket ${ticket.ticketNumber}`,
      );
    } catch (error: unknown) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error(
        `Error sending SLA alert for ticket ${ticketSla.ticketId}: ${errorMessage}`,
      );
      // Don't throw - alert failure shouldn't block SLA status update
    }
  }
}

