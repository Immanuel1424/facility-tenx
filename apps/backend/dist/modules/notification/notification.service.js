"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
var NotificationService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.NotificationService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const notification_entity_1 = require("./entities/notification.entity");
const notification_delivery_entity_1 = require("./entities/notification-delivery.entity");
const notification_template_entity_1 = require("./entities/notification-template.entity");
const notification_audit_log_entity_1 = require("./entities/notification-audit-log.entity");
const notification_channel_enum_1 = require("./enums/notification-channel.enum");
const notification_severity_enum_1 = require("./enums/notification-severity.enum");
const email_channel_1 = require("./channels/email.channel");
const sms_channel_1 = require("./channels/sms.channel");
const whatsapp_channel_1 = require("./channels/whatsapp.channel");
const push_channel_1 = require("./channels/push.channel");
const company_entity_1 = require("../tenant/entities/company.entity");
const site_entity_1 = require("../tenant/entities/site.entity");
const user_entity_1 = require("../iam/entities/user.entity");
const MAX_RETRY_ATTEMPTS = 3;
let NotificationService = NotificationService_1 = class NotificationService {
    constructor(notificationRepo, deliveryRepo, templateRepo, auditRepo, companyRepo, siteRepo, userRepo, emailChannel, smsChannel, whatsappChannel, pushChannel) {
        this.notificationRepo = notificationRepo;
        this.deliveryRepo = deliveryRepo;
        this.templateRepo = templateRepo;
        this.auditRepo = auditRepo;
        this.companyRepo = companyRepo;
        this.siteRepo = siteRepo;
        this.userRepo = userRepo;
        this.emailChannel = emailChannel;
        this.smsChannel = smsChannel;
        this.whatsappChannel = whatsappChannel;
        this.pushChannel = pushChannel;
        this.logger = new common_1.Logger(NotificationService_1.name);
        this.channelAdapters = new Map([
            [notification_channel_enum_1.NotificationChannel.EMAIL, emailChannel],
            [notification_channel_enum_1.NotificationChannel.SMS, smsChannel],
            [notification_channel_enum_1.NotificationChannel.WHATSAPP, whatsappChannel],
            [notification_channel_enum_1.NotificationChannel.PUSH, pushChannel],
        ]);
    }
    async publishEvent(event) {
        const severity = event.severity;
        const channels = this.resolveChannelsForEvent(event);
        const enrichedVariables = await this.enrichVariablesWithCompanyAndSite(event.companyId, event.variables);
        const templateMap = await this.loadTemplates(event.companyId, event.templateCode, channels);
        const messageBodyPerChannel = new Map();
        const subjectPerChannel = new Map();
        for (const [channel, template] of templateMap.entries()) {
            const rendered = this.renderTemplate(template.body, {
                ...(template.defaultVariables ?? {}),
                ...enrichedVariables,
            });
            messageBodyPerChannel.set(channel, rendered);
            subjectPerChannel.set(channel, template.subject
                ? this.renderTemplate(template.subject, {
                    ...(template.defaultVariables ?? {}),
                    ...enrichedVariables,
                })
                : undefined);
        }
        let inAppMessage = messageBodyPerChannel.get(notification_channel_enum_1.NotificationChannel.IN_APP);
        if (!inAppMessage && channels.includes(notification_channel_enum_1.NotificationChannel.IN_APP)) {
            inAppMessage = event.variables['message'] || '';
        }
        if (event.recipientUserId && channels.includes(notification_channel_enum_1.NotificationChannel.IN_APP)) {
            const ticketId = enrichedVariables['ticketId'];
            const tenSecondsAgo = new Date(Date.now() - 10000);
            const duplicateQuery = this.notificationRepo
                .createQueryBuilder('notification')
                .where('notification.companyId = :companyId', { companyId: event.companyId })
                .andWhere('notification.recipientUserId = :recipientUserId', { recipientUserId: event.recipientUserId })
                .andWhere('notification.createdAt > :tenSecondsAgo', { tenSecondsAgo });
            if (ticketId) {
                duplicateQuery.andWhere("notification.payload->>'ticketId' = :ticketId", { ticketId });
            }
            const typeKeywords = event.type.toLowerCase().split('_').filter(k => k !== 'tenant' && k !== 'ticket');
            if (typeKeywords.length > 0) {
                const typePattern = `%${typeKeywords.join('%')}%`;
                duplicateQuery.andWhere('(notification.type LIKE :typePattern OR notification.type = :exactType OR notification.type LIKE :ticketCreatedPattern)', {
                    typePattern,
                    exactType: event.type,
                    ticketCreatedPattern: event.type.includes('created') ? '%ticket%created%' : typePattern,
                });
            }
            else {
                duplicateQuery.andWhere('(notification.type = :exactType OR notification.type LIKE :ticketPattern)', {
                    exactType: event.type,
                    ticketPattern: '%ticket%',
                });
            }
            const recentDuplicate = await duplicateQuery
                .orderBy('notification.createdAt', 'DESC')
                .getOne();
            if (recentDuplicate) {
                const shouldUpdate = !recentDuplicate.message ||
                    recentDuplicate.message.trim() === '' ||
                    (inAppMessage && inAppMessage.trim() !== '' && recentDuplicate.message !== inAppMessage);
                if (shouldUpdate) {
                    recentDuplicate.message = inAppMessage || messageBodyPerChannel.get(notification_channel_enum_1.NotificationChannel.IN_APP) || recentDuplicate.message || '';
                    recentDuplicate.title = enrichedVariables['title'] || recentDuplicate.title;
                    recentDuplicate.payload = enrichedVariables;
                    recentDuplicate.channels = channels;
                    await this.notificationRepo.save(recentDuplicate);
                }
                return;
            }
        }
        const notification = this.notificationRepo.create({
            companyId: event.companyId,
            recipientUserId: event.recipientUserId ?? null,
            type: event.type,
            severity,
            title: enrichedVariables['title'],
            message: inAppMessage || messageBodyPerChannel.get(notification_channel_enum_1.NotificationChannel.IN_APP) || '',
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
            if (channel === notification_channel_enum_1.NotificationChannel.IN_APP) {
                await this.deliveryRepo.save(this.deliveryRepo.create({
                    companyId: event.companyId,
                    notificationId: savedNotification.id,
                    channel,
                    status: notification_delivery_entity_1.DeliveryStatus.SUCCESS,
                    attemptCount: 0,
                    lastError: null,
                }));
                continue;
            }
            let subject = subjectPerChannel.get(channel);
            if (channel === notification_channel_enum_1.NotificationChannel.PUSH && !subject) {
                subject = enrichedVariables['title'] || undefined;
            }
            const recipientAddress = await this.resolveRecipientAddress(channel, event, enrichedVariables);
            if (!recipientAddress) {
                this.logger.warn(`No recipient address found for channel ${channel}, notification ${savedNotification.id}, skipping delivery`);
                await this.deliveryRepo.save(this.deliveryRepo.create({
                    companyId: event.companyId,
                    notificationId: savedNotification.id,
                    channel,
                    status: notification_delivery_entity_1.DeliveryStatus.FAILED,
                    attemptCount: 0,
                    lastError: `No recipient address found for channel ${channel}`,
                }));
                continue;
            }
            const payload = {
                to: recipientAddress,
                subject,
                body: messageBodyPerChannel.get(channel) ?? '',
                metadata: {
                    eventType: event.type,
                    companyId: event.companyId,
                    ...(enrichedVariables['ticketId'] ? { ticketId: String(enrichedVariables['ticketId']) } : {}),
                },
            };
            await this.sendWithRetry(savedNotification, channel, payload);
        }
    }
    async listInAppNotifications(companyId, userId) {
        return this.notificationRepo.find({
            where: {
                companyId,
                recipientUserId: userId,
            },
            order: { createdAt: 'DESC' },
        });
    }
    async markAsRead(companyId, userId, id) {
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
    async markAllAsRead(companyId, userId) {
        await this.notificationRepo.update({
            companyId,
            recipientUserId: userId,
            isRead: false,
        }, {
            isRead: true,
            readAt: new Date(),
        });
    }
    resolveChannelsForEvent(event) {
        if (event.channels && event.channels.length > 0) {
            return event.channels
                .map((c) => c.toLowerCase())
                .map((c) => {
                switch (c) {
                    case 'email':
                    case notification_channel_enum_1.NotificationChannel.EMAIL:
                        return notification_channel_enum_1.NotificationChannel.EMAIL;
                    case 'sms':
                    case notification_channel_enum_1.NotificationChannel.SMS:
                        return notification_channel_enum_1.NotificationChannel.SMS;
                    case 'whatsapp':
                    case notification_channel_enum_1.NotificationChannel.WHATSAPP:
                        return notification_channel_enum_1.NotificationChannel.WHATSAPP;
                    case 'push':
                    case notification_channel_enum_1.NotificationChannel.PUSH:
                        return notification_channel_enum_1.NotificationChannel.PUSH;
                    case 'in_app':
                    case notification_channel_enum_1.NotificationChannel.IN_APP:
                        return notification_channel_enum_1.NotificationChannel.IN_APP;
                    default:
                        console.warn(`Unrecognized notification channel: ${c}, skipping`);
                        return null;
                }
            })
                .filter((c) => c !== null);
        }
        if (event.severity === notification_severity_enum_1.NotificationSeverity.CRITICAL) {
            return [
                notification_channel_enum_1.NotificationChannel.IN_APP,
                notification_channel_enum_1.NotificationChannel.PUSH,
                notification_channel_enum_1.NotificationChannel.SMS,
                notification_channel_enum_1.NotificationChannel.EMAIL,
            ];
        }
        if (event.severity === notification_severity_enum_1.NotificationSeverity.WARNING) {
            return [notification_channel_enum_1.NotificationChannel.IN_APP, notification_channel_enum_1.NotificationChannel.EMAIL];
        }
        return [notification_channel_enum_1.NotificationChannel.IN_APP];
    }
    async loadTemplates(companyId, templateCode, channels) {
        const templates = await this.templateRepo.find({
            where: {
                companyId,
                code: templateCode,
            },
        });
        const map = new Map();
        for (const t of templates) {
            map.set(t.channel, t);
        }
        for (const channel of channels) {
            if (channel === notification_channel_enum_1.NotificationChannel.IN_APP) {
                continue;
            }
            if (!map.has(channel)) {
                this.logger.error(`Missing template for code ${templateCode} and channel ${channel} in company ${companyId}. Please seed templates using TemplateSeedService.`);
                throw new Error(`Missing template for code ${templateCode} and channel ${channel}`);
            }
        }
        return map;
    }
    async enrichVariablesWithCompanyAndSite(companyId, variables) {
        const enriched = { ...variables };
        if (!enriched['companyCode'] || !enriched['companyName']) {
            try {
                const company = await this.companyRepo.findOne({
                    where: { id: companyId },
                    select: ['code', 'name'],
                });
                if (company) {
                    if (!enriched['companyCode']) {
                        enriched['companyCode'] = company.code;
                    }
                    if (!enriched['companyName']) {
                        enriched['companyName'] = company.name;
                    }
                }
                else {
                    this.logger.warn(`Company not found for companyId: ${companyId}`);
                    if (!enriched['companyCode']) {
                        enriched['companyCode'] = '';
                    }
                    if (!enriched['companyName']) {
                        enriched['companyName'] = 'Facility ERP Team';
                    }
                }
            }
            catch (error) {
                this.logger.error(`Failed to fetch company details for ${companyId}:`, error);
                if (!enriched['companyCode']) {
                    enriched['companyCode'] = '';
                }
                if (!enriched['companyName']) {
                    enriched['companyName'] = 'Facility ERP Team';
                }
            }
        }
        if (!enriched['siteCode']) {
            const siteId = enriched['siteId'];
            if (siteId) {
                try {
                    const site = await this.siteRepo.findOne({
                        where: { id: siteId, companyId },
                        select: ['code'],
                    });
                    if (site) {
                        enriched['siteCode'] = site.code;
                    }
                    else {
                        this.logger.warn(`Site not found for siteId: ${siteId}, companyId: ${companyId}`);
                        enriched['siteCode'] = '';
                    }
                }
                catch (error) {
                    this.logger.error(`Failed to fetch site code for ${siteId}:`, error);
                    enriched['siteCode'] = '';
                }
            }
            else {
                try {
                    const site = await this.siteRepo.findOne({
                        where: { companyId, isActive: true },
                        select: ['code'],
                        order: { createdAt: 'ASC' },
                    });
                    if (site) {
                        enriched['siteCode'] = site.code;
                    }
                    else {
                        enriched['siteCode'] = '';
                    }
                }
                catch (error) {
                    this.logger.error(`Failed to fetch default site code for company ${companyId}:`, error);
                    enriched['siteCode'] = '';
                }
            }
        }
        return enriched;
    }
    renderTemplate(template, variables) {
        return template.replace(/{{\s*([\w.]+)\s*}}/g, (_match, key) => {
            const value = variables[key];
            return typeof value === 'undefined' || value === null ? '' : String(value);
        });
    }
    async sendWithRetry(notification, channel, payload) {
        const adapter = this.channelAdapters.get(channel);
        if (!adapter) {
            throw new Error(`No adapter registered for channel ${channel}`);
        }
        let attempt = 0;
        let lastError = null;
        let status = notification_delivery_entity_1.DeliveryStatus.PENDING;
        while (attempt < MAX_RETRY_ATTEMPTS) {
            attempt += 1;
            const result = await adapter.send(payload);
            if (result.success) {
                status = notification_delivery_entity_1.DeliveryStatus.SUCCESS;
                lastError = null;
                break;
            }
            status = notification_delivery_entity_1.DeliveryStatus.RETRYING;
            lastError = result.errorMessage ?? 'Unknown error';
        }
        if (status !== notification_delivery_entity_1.DeliveryStatus.SUCCESS) {
            status = notification_delivery_entity_1.DeliveryStatus.FAILED;
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
    async resolveRecipientAddress(channel, event, enrichedVariables) {
        const variables = enrichedVariables ?? event.variables;
        const recipient = variables['recipient'];
        switch (channel) {
            case notification_channel_enum_1.NotificationChannel.EMAIL: {
                if (recipient && recipient['email']) {
                    return String(recipient['email']);
                }
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
                        this.logger.warn(`User not found or email missing for userId: ${event.recipientUserId}, companyId: ${event.companyId}`);
                    }
                    catch (error) {
                        const errorMessage = error instanceof Error ? error.message : String(error);
                        this.logger.error(`Failed to fetch user email for userId ${event.recipientUserId}: ${errorMessage}`);
                    }
                }
                return '';
            }
            case notification_channel_enum_1.NotificationChannel.SMS:
            case notification_channel_enum_1.NotificationChannel.WHATSAPP: {
                if (recipient && recipient['phone']) {
                    return String(recipient['phone']);
                }
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
                    }
                    catch (error) {
                        const errorMessage = error instanceof Error ? error.message : String(error);
                        this.logger.error(`Failed to fetch user phone for userId ${event.recipientUserId}: ${errorMessage}`);
                    }
                }
                return '';
            }
            case notification_channel_enum_1.NotificationChannel.PUSH:
                return String(event.recipientUserId ?? '');
            default:
                return '';
        }
    }
    async listTemplates(companyId) {
        return this.templateRepo.find({
            where: { companyId },
            order: { code: 'ASC', channel: 'ASC' },
        });
    }
    async listTemplatesByChannel(companyId, channel) {
        return this.templateRepo.find({
            where: {
                companyId,
                channel: channel,
            },
            order: { code: 'ASC' },
        });
    }
    async getTemplate(companyId, id) {
        const template = await this.templateRepo.findOne({
            where: { id, companyId },
        });
        if (!template) {
            throw new Error(`Template with id ${id} not found`);
        }
        return template;
    }
    async createTemplate(companyId, data) {
        const template = this.templateRepo.create({
            companyId,
            code: data.code,
            channel: data.channel,
            subject: data.subject ?? null,
            body: data.body,
            defaultVariables: data.defaultVariables ?? null,
        });
        return this.templateRepo.save(template);
    }
    async updateTemplate(companyId, id, data) {
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
    async deleteTemplate(companyId, id) {
        const template = await this.getTemplate(companyId, id);
        await this.templateRepo.remove(template);
    }
};
exports.NotificationService = NotificationService;
exports.NotificationService = NotificationService = NotificationService_1 = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(notification_entity_1.Notification)),
    __param(1, (0, typeorm_1.InjectRepository)(notification_delivery_entity_1.NotificationDelivery)),
    __param(2, (0, typeorm_1.InjectRepository)(notification_template_entity_1.NotificationTemplate)),
    __param(3, (0, typeorm_1.InjectRepository)(notification_audit_log_entity_1.NotificationAuditLog)),
    __param(4, (0, typeorm_1.InjectRepository)(company_entity_1.Company)),
    __param(5, (0, typeorm_1.InjectRepository)(site_entity_1.Site)),
    __param(6, (0, typeorm_1.InjectRepository)(user_entity_1.User)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository,
        email_channel_1.EmailChannel,
        sms_channel_1.SmsChannel,
        whatsapp_channel_1.WhatsappChannel,
        push_channel_1.PushChannel])
], NotificationService);
