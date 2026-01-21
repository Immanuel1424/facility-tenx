import { Injectable, Inject, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThan } from 'typeorm';
import { Notification } from './entities/notification.entity';
import { NotificationDelivery, DeliveryStatus } from './entities/notification-delivery.entity';
import { NotificationTemplate } from './entities/notification-template.entity';
import { NotificationAuditLog } from './entities/notification-audit-log.entity';
import { NotificationEvent } from './events/notification-event';
import { NotificationChannel } from './enums/notification-channel.enum';
import { NotificationSeverity } from './enums/notification-severity.enum';
import {
  ChannelSendPayload,
  NotificationChannelAdapter,
} from './channels/notification-channel.interface';
import { EmailChannel } from './channels/email.channel';
import { SmsChannel } from './channels/sms.channel';
import { WhatsappChannel } from './channels/whatsapp.channel';
import { PushChannel } from './channels/push.channel';
import { Company } from '../tenant/entities/company.entity';
import { Site } from '../tenant/entities/site.entity';
import { User } from '../iam/entities/user.entity';

const MAX_RETRY_ATTEMPTS = 3;

@Injectable()
export class NotificationService {
  private readonly channelAdapters: Map<NotificationChannel, NotificationChannelAdapter>;
  private readonly logger = new Logger(NotificationService.name);

  constructor(
    @InjectRepository(Notification)
    private readonly notificationRepo: Repository<Notification>,
    @InjectRepository(NotificationDelivery)
    private readonly deliveryRepo: Repository<NotificationDelivery>,
    @InjectRepository(NotificationTemplate)
    private readonly templateRepo: Repository<NotificationTemplate>,
    @InjectRepository(NotificationAuditLog)
    private readonly auditRepo: Repository<NotificationAuditLog>,
    @InjectRepository(Company)
    private readonly companyRepo: Repository<Company>,
    @InjectRepository(Site)
    private readonly siteRepo: Repository<Site>,
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
    private readonly emailChannel: EmailChannel,
    private readonly smsChannel: SmsChannel,
    private readonly whatsappChannel: WhatsappChannel,
    private readonly pushChannel: PushChannel,
  ) {
    this.channelAdapters = new Map<NotificationChannel, NotificationChannelAdapter>([
      [NotificationChannel.EMAIL, emailChannel],
      [NotificationChannel.SMS, smsChannel],
      [NotificationChannel.WHATSAPP, whatsappChannel],
      [NotificationChannel.PUSH, pushChannel],
    ]);
  }

  async publishEvent(event: NotificationEvent): Promise<void> {
    const severity = event.severity;
    const channels = this.resolveChannelsForEvent(event);

    // Enrich variables with companyCode and siteCode if not already provided
    const enrichedVariables = await this.enrichVariablesWithCompanyAndSite(
      event.companyId,
      event.variables,
    );

    const templateMap = await this.loadTemplates(
      event.companyId,
      event.templateCode,
      channels,
    );

    const messageBodyPerChannel: Map<NotificationChannel, string> = new Map();
    const subjectPerChannel: Map<NotificationChannel, string | undefined> = new Map();

    for (const [channel, template] of templateMap.entries()) {
      const rendered = this.renderTemplate(template.body, {
        ...(template.defaultVariables ?? {}),
        ...enrichedVariables,
      });
      messageBodyPerChannel.set(channel, rendered);
      subjectPerChannel.set(
        channel,
        template.subject
          ? this.renderTemplate(template.subject, {
              ...(template.defaultVariables ?? {}),
              ...enrichedVariables,
            })
          : undefined,
      );
    }

    // Get IN_APP message - use template if available, otherwise fallback to message variable
    let inAppMessage = messageBodyPerChannel.get(NotificationChannel.IN_APP);
    if (!inAppMessage && channels.includes(NotificationChannel.IN_APP)) {
      // Fallback: use message variable if IN_APP template is missing
      inAppMessage = (event.variables['message'] as string) || '';
    }

    // Prevent duplicate notifications: check if a similar notification was created recently (within last 10 seconds)
    // This prevents race conditions or duplicate calls from creating multiple notifications
    // Check by type AND ticketId (if present in payload) to catch duplicates more reliably
    if (event.recipientUserId && channels.includes(NotificationChannel.IN_APP)) {
      const ticketId = enrichedVariables['ticketId'] as string | undefined;
      const tenSecondsAgo = new Date(Date.now() - 10000);
      
      // Build query to find duplicates
      // Check by ticketId in payload (most reliable) AND by similar notification type
      const duplicateQuery = this.notificationRepo
        .createQueryBuilder('notification')
        .where('notification.companyId = :companyId', { companyId: event.companyId })
        .andWhere('notification.recipientUserId = :recipientUserId', { recipientUserId: event.recipientUserId })
        .andWhere('notification.createdAt > :tenSecondsAgo', { tenSecondsAgo });
      
      // If ticketId is present, check by ticketId in payload (most reliable)
      if (ticketId) {
        duplicateQuery.andWhere("notification.payload->>'ticketId' = :ticketId", { ticketId });
      }
      
      // Also check by similar notification type (catches duplicates even if ticketId format differs)
      // Match types that contain "ticket" and the update type (e.g., "created", "status_changed")
      // Handle both "tenant_ticket_created" and "tenant_ticket_ticket_created" patterns
      const typeKeywords = event.type.toLowerCase().split('_').filter(k => k !== 'tenant' && k !== 'ticket');
      if (typeKeywords.length > 0) {
        const typePattern = `%${typeKeywords.join('%')}%`;
        // Match both exact type and similar patterns (handles tenant_ticket_created vs tenant_ticket_ticket_created)
        duplicateQuery.andWhere(
          '(notification.type LIKE :typePattern OR notification.type = :exactType OR notification.type LIKE :ticketCreatedPattern)',
          { 
            typePattern,
            exactType: event.type,
            ticketCreatedPattern: event.type.includes('created') ? '%ticket%created%' : typePattern,
          },
        );
      } else {
        duplicateQuery.andWhere('(notification.type = :exactType OR notification.type LIKE :ticketPattern)', { 
          exactType: event.type,
          ticketPattern: '%ticket%',
        });
      }
      
      const recentDuplicate = await duplicateQuery
        .orderBy('notification.createdAt', 'DESC')
        .getOne();

      if (recentDuplicate) {
        // If a duplicate exists, update it instead of creating a new one
        // This handles cases where the first notification might have an empty message or different content
        const shouldUpdate = 
          !recentDuplicate.message || 
          recentDuplicate.message.trim() === '' ||
          (inAppMessage && inAppMessage.trim() !== '' && recentDuplicate.message !== inAppMessage);
        
        if (shouldUpdate) {
          recentDuplicate.message = inAppMessage || messageBodyPerChannel.get(NotificationChannel.IN_APP) || recentDuplicate.message || '';
          recentDuplicate.title = enrichedVariables['title'] as string | null || recentDuplicate.title;
          recentDuplicate.payload = enrichedVariables;
          recentDuplicate.channels = channels;
          await this.notificationRepo.save(recentDuplicate);
        }
        // Always return to prevent creating a duplicate, even if we didn't update
        return;
      }
    }

    const notification = this.notificationRepo.create({
      companyId: event.companyId,
      recipientUserId: event.recipientUserId ?? null,
      type: event.type,
      severity,
      title: enrichedVariables['title'] as string | null,
      message: inAppMessage || messageBodyPerChannel.get(NotificationChannel.IN_APP) || '',
      payload: enrichedVariables,
      isRead: false,
      readAt: null,
      channels,
    });
    const savedNotification = await this.notificationRepo.save(notification);

    const audit = this.auditRepo.create({
      companyId: event.companyId,
      eventType: event.type,
      severity,
      recipientUserId: event.recipientUserId ?? null,
      eventPayload: enrichedVariables,
      metadata: { channels },
    });
    await this.auditRepo.save(audit);

    for (const channel of channels) {
      if (channel === NotificationChannel.IN_APP) {
        await this.deliveryRepo.save(
          this.deliveryRepo.create({
            companyId: event.companyId,
            notificationId: savedNotification.id,
            channel,
            status: DeliveryStatus.SUCCESS,
            attemptCount: 0,
            lastError: null,
          }),
        );
        continue;
      }

      // For push notifications, use title variable if subject is not available
      let subject = subjectPerChannel.get(channel);
      if (channel === NotificationChannel.PUSH && !subject) {
        subject = (enrichedVariables['title'] as string) || undefined;
      }

      const recipientAddress = await this.resolveRecipientAddress(
        channel,
        event,
        enrichedVariables,
      );

      if (!recipientAddress) {
        this.logger.warn(
          `No recipient address found for channel ${channel}, notification ${savedNotification.id}, skipping delivery`,
        );
        // Create a failed delivery record
        await this.deliveryRepo.save(
          this.deliveryRepo.create({
            companyId: event.companyId,
            notificationId: savedNotification.id,
            channel,
            status: DeliveryStatus.FAILED,
            attemptCount: 0,
            lastError: `No recipient address found for channel ${channel}`,
          }),
        );
        continue;
      }

      const payload: ChannelSendPayload = {
        to: recipientAddress,
        subject,
        body: messageBodyPerChannel.get(channel) ?? '',
        metadata: {
          eventType: event.type,
          companyId: event.companyId,
          // Include ticketId in metadata for navigation
          ...(enrichedVariables['ticketId'] ? { ticketId: String(enrichedVariables['ticketId']) } : {}),
        },
      };

      await this.sendWithRetry(savedNotification, channel, payload);
    }
  }

  async listInAppNotifications(companyId: string, userId: string): Promise<Notification[]> {
    return this.notificationRepo.find({
      where: {
        companyId,
        recipientUserId: userId,
      },
      order: { createdAt: 'DESC' },
    });
  }

  async markAsRead(companyId: string, userId: string, id: string): Promise<Notification> {
    const notification = await this.notificationRepo.findOne({
      where: { id, companyId, recipientUserId: userId },
    });
    if (!notification) {
      throw new Error('Notification not found');
    }
    if (!notification.isRead) {
      notification.isRead = true;
      notification.readAt = new Date();
      await this.notificationRepo.save(notification);
    }
    return notification;
  }

  async markAllAsRead(companyId: string, userId: string): Promise<void> {
    await this.notificationRepo.update(
      {
        companyId,
        recipientUserId: userId,
        isRead: false,
      },
      {
        isRead: true,
        readAt: new Date(),
      },
    );
  }

  private resolveChannelsForEvent(event: NotificationEvent): NotificationChannel[] {
    if (event.channels && event.channels.length > 0) {
      return event.channels
        .map((c) => c.toLowerCase())
        .map((c) => {
          switch (c) {
            case 'email':
            case NotificationChannel.EMAIL:
              return NotificationChannel.EMAIL;
            case 'sms':
            case NotificationChannel.SMS:
              return NotificationChannel.SMS;
            case 'whatsapp':
            case NotificationChannel.WHATSAPP:
              return NotificationChannel.WHATSAPP;
            case 'push':
            case NotificationChannel.PUSH:
              return NotificationChannel.PUSH;
            case 'in_app':
            case NotificationChannel.IN_APP:
              return NotificationChannel.IN_APP;
            default:
              // Log warning for unrecognized channel but don't default to IN_APP
              console.warn(`Unrecognized notification channel: ${c}, skipping`);
              return null;
          }
        })
        .filter((c): c is NotificationChannel => c !== null);
    }

    if (event.severity === NotificationSeverity.CRITICAL) {
      return [
        NotificationChannel.IN_APP,
        NotificationChannel.PUSH,
        NotificationChannel.SMS,
        NotificationChannel.EMAIL,
      ];
    }
    if (event.severity === NotificationSeverity.WARNING) {
      return [NotificationChannel.IN_APP, NotificationChannel.EMAIL];
    }
    return [NotificationChannel.IN_APP];
  }

  private async loadTemplates(
    companyId: string,
    templateCode: string,
    channels: NotificationChannel[],
  ): Promise<Map<NotificationChannel, NotificationTemplate>> {
    const templates = await this.templateRepo.find({
      where: {
        companyId,
        code: templateCode,
      },
    });

    const map = new Map<NotificationChannel, NotificationTemplate>();
    for (const t of templates) {
      map.set(t.channel, t);
    }

    for (const channel of channels) {
      if (channel === NotificationChannel.IN_APP) {
        continue;
      }
      if (!map.has(channel)) {
        this.logger.error(
          `Missing template for code ${templateCode} and channel ${channel} in company ${companyId}. Please seed templates using TemplateSeedService.`,
        );
        throw new Error(
          `Missing template for code ${templateCode} and channel ${channel}`,
        );
      }
    }

    return map;
  }

  /**
   * Enrich notification variables with companyCode, companyName, and siteCode if not already provided
   * This ensures all email templates have access to these values
   */
  private async enrichVariablesWithCompanyAndSite(
    companyId: string,
    variables: Record<string, unknown>,
  ): Promise<Record<string, unknown>> {
    const enriched = { ...variables };

    // Fetch company details if not already provided or if empty string
    if (!enriched['companyCode'] || enriched['companyCode'] === '') {
      try {
        const company = await this.companyRepo.findOne({
          where: { id: companyId },
          select: ['code', 'name'],
        });
        if (company) {
          enriched['companyCode'] = company.code;
        } else {
          this.logger.warn(`Company not found for companyId: ${companyId}`);
          enriched['companyCode'] = 'N/A';
        }
      } catch (error) {
        this.logger.error(`Failed to fetch company details for ${companyId}:`, error);
        enriched['companyCode'] = 'N/A';
      }
    }
    // Fetch company name if not already provided
    if (!enriched['companyName']) {
      try {
        const company = await this.companyRepo.findOne({
          where: { id: companyId },
          select: ['name'],
        });
        if (company) {
          enriched['companyName'] = company.name;
        } else {
          enriched['companyName'] = 'Facility ERP Team';
        }
      } catch (error) {
        this.logger.error(`Failed to fetch company name for ${companyId}:`, error);
        enriched['companyName'] = 'Facility ERP Team';
      }
    }

    // Fetch siteCode if not already provided or if empty string
    if (!enriched['siteCode'] || enriched['siteCode'] === '') {
      const siteId = enriched['siteId'] as string | undefined;
      if (siteId) {
        try {
          const site = await this.siteRepo.findOne({
            where: { id: siteId, companyId },
            select: ['code'],
          });
          if (site) {
            enriched['siteCode'] = site.code;
          } else {
            this.logger.warn(`Site not found for siteId: ${siteId}, companyId: ${companyId}`);
            enriched['siteCode'] = 'N/A';
          }
        } catch (error) {
          this.logger.error(`Failed to fetch site code for ${siteId}:`, error);
          enriched['siteCode'] = 'N/A';
        }
      } else {
        // If no siteId provided, try to get the first active site for the company
        try {
          const site = await this.siteRepo.findOne({
            where: { companyId, isActive: true },
            select: ['code'],
            order: { createdAt: 'ASC' },
          });
          if (site) {
            enriched['siteCode'] = site.code;
          } else {
            enriched['siteCode'] = 'N/A';
          }
        } catch (error) {
          this.logger.error(`Failed to fetch default site code for company ${companyId}:`, error);
          enriched['siteCode'] = 'N/A';
        }
      }
    }

    return enriched;
  }

  private renderTemplate(
    template: string,
    variables: Record<string, unknown>,
  ): string {
    return template.replace(/{{\s*([\w.]+)\s*}}/g, (_match, key: string) => {
      const value = variables[key];
      return typeof value === 'undefined' || value === null ? '' : String(value);
    });
  }

  private async sendWithRetry(
    notification: Notification,
    channel: NotificationChannel,
    payload: ChannelSendPayload,
  ): Promise<void> {
    const adapter = this.channelAdapters.get(channel);
    if (!adapter) {
      throw new Error(`No adapter registered for channel ${channel}`);
    }

    let attempt = 0;
    let lastError: string | null = null;
    let status: DeliveryStatus = DeliveryStatus.PENDING;

    while (attempt < MAX_RETRY_ATTEMPTS) {
      attempt += 1;
      const result = await adapter.send(payload);
      if (result.success) {
        status = DeliveryStatus.SUCCESS;
        lastError = null;
        break;
      }
      status = DeliveryStatus.RETRYING;
      lastError = result.errorMessage ?? 'Unknown error';
    }

    if (status !== DeliveryStatus.SUCCESS) {
      status = DeliveryStatus.FAILED;
    }

    const delivery = this.deliveryRepo.create({
      companyId: notification.companyId,
      notificationId: notification.id,
      channel,
      status,
      attemptCount: attempt,
      lastError,
    });
    await this.deliveryRepo.save(delivery);
  }

  private async resolveRecipientAddress(
    channel: NotificationChannel,
    event: NotificationEvent,
    enrichedVariables?: Record<string, unknown>,
  ): Promise<string> {
    const variables = enrichedVariables ?? event.variables;
    const recipient = variables['recipient'] as Record<string, unknown> | undefined;

    switch (channel) {
      case NotificationChannel.EMAIL: {
        // First check if email is provided in recipient object
        if (recipient && recipient['email']) {
          return String(recipient['email']);
        }
        // If recipientUserId is provided, fetch user email from database
        if (event.recipientUserId && event.companyId) {
          try {
            const user = await this.userRepo.findOne({
              where: {
                id: event.recipientUserId,
                companyId: event.companyId,
              },
              select: ['email'],
            });
            if (user && user.email) {
              return user.email;
            }
            this.logger.warn(
              `User not found or email missing for userId: ${event.recipientUserId}, companyId: ${event.companyId}`,
            );
          } catch (error) {
            const errorMessage = error instanceof Error ? error.message : String(error);
            this.logger.error(
              `Failed to fetch user email for userId ${event.recipientUserId}: ${errorMessage}`,
            );
          }
        }
        return '';
      }
      case NotificationChannel.SMS:
      case NotificationChannel.WHATSAPP: {
        // First check if phone is provided in recipient object
        if (recipient && recipient['phone']) {
          return String(recipient['phone']);
        }
        // If recipientUserId is provided, fetch user phone from database
        if (event.recipientUserId && event.companyId) {
          try {
            const user = await this.userRepo.findOne({
              where: {
                id: event.recipientUserId,
                companyId: event.companyId,
              },
              select: ['phoneNumber', 'alternatePhoneNumber'],
            });
            if (user) {
              return String(user.phoneNumber || user.alternatePhoneNumber || '');
            }
          } catch (error) {
            const errorMessage = error instanceof Error ? error.message : String(error);
            this.logger.error(
              `Failed to fetch user phone for userId ${event.recipientUserId}: ${errorMessage}`,
            );
          }
        }
        return '';
      }
      case NotificationChannel.PUSH:
        // For push, we use userId to look up FCM tokens from database
        return String(event.recipientUserId ?? '');
      default:
        return '';
    }
  }

  // Template Management Methods
  async listTemplates(companyId: string): Promise<NotificationTemplate[]> {
    return this.templateRepo.find({
      where: { companyId },
      order: { code: 'ASC', channel: 'ASC' },
    });
  }

  async listTemplatesByChannel(companyId: string, channel: string): Promise<NotificationTemplate[]> {
    return this.templateRepo.find({
      where: {
        companyId,
        channel: channel as NotificationChannel,
      },
      order: { code: 'ASC' },
    });
  }

  async getTemplate(companyId: string, id: string): Promise<NotificationTemplate> {
    const template = await this.templateRepo.findOne({
      where: { id, companyId },
    });
    if (!template) {
      throw new Error(`Template with id ${id} not found`);
    }
    return template;
  }

  async createTemplate(
    companyId: string,
    data: {
      code: string;
      channel: string;
      subject?: string | null;
      body: string;
      defaultVariables?: Record<string, unknown> | null;
    },
  ): Promise<NotificationTemplate> {
    const template = this.templateRepo.create({
      companyId,
      code: data.code,
      channel: data.channel as NotificationChannel,
      subject: data.subject ?? null,
      body: data.body,
      defaultVariables: data.defaultVariables ?? null,
    });
    return this.templateRepo.save(template);
  }

  async updateTemplate(
    companyId: string,
    id: string,
    data: {
      subject?: string | null;
      body?: string;
      defaultVariables?: Record<string, unknown> | null;
    },
  ): Promise<NotificationTemplate> {
    const template = await this.getTemplate(companyId, id);
    if (data.subject !== undefined) {
      template.subject = data.subject;
    }
    if (data.body !== undefined) {
      template.body = data.body;
    }
    if (data.defaultVariables !== undefined) {
      template.defaultVariables = data.defaultVariables;
    }
    return this.templateRepo.save(template);
  }

  async deleteTemplate(companyId: string, id: string): Promise<void> {
    const template = await this.getTemplate(companyId, id);
    await this.templateRepo.remove(template);
  }
}
