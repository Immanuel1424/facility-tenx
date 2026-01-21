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
Object.defineProperty(exports, "__esModule", { value: true });
exports.NotificationController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const notification_service_1 = require("./notification.service");
const template_seed_service_1 = require("./services/template-seed.service");
const tenant_guard_1 = require("../../shared/guards/tenant.guard");
const jwt_auth_guard_1 = require("../../modules/auth/guards/jwt-auth.guard");
const user_device_service_1 = require("../iam/services/user-device.service");
const notification_severity_enum_1 = require("./enums/notification-severity.enum");
const notification_channel_enum_1 = require("./enums/notification-channel.enum");
let NotificationController = class NotificationController {
    constructor(notificationService, templateSeedService, userDeviceService) {
        this.notificationService = notificationService;
        this.templateSeedService = templateSeedService;
        this.userDeviceService = userDeviceService;
    }
    async list(req) {
        return this.notificationService.listInAppNotifications(req.companyId, req.user.userId);
    }
    async markAllAsRead(req) {
        await this.notificationService.markAllAsRead(req.companyId, req.user.userId);
        return { success: true, message: 'All notifications marked as read' };
    }
    async markAsRead(id, req) {
        return this.notificationService.markAsRead(req.companyId, req.user.userId, id);
    }
    async registerDevice(body, req) {
        const device = await this.userDeviceService.registerDevice(req.companyId, req.user.userId, body.fcmToken, body.platform, body.deviceInfo);
        return {
            success: true,
            deviceId: device.id,
            message: 'Device registered successfully',
        };
    }
    async unregisterDevice(body, req) {
        await this.userDeviceService.unregisterDevice(req.companyId, req.user.userId, body.fcmToken);
        return {
            success: true,
            message: 'Device unregistered successfully',
        };
    }
    async listTemplates(req) {
        return this.notificationService.listTemplates(req.companyId);
    }
    async listEmailTemplates(req) {
        return this.notificationService.listTemplatesByChannel(req.companyId, 'email');
    }
    async getTemplate(id, req) {
        return this.notificationService.getTemplate(req.companyId, id);
    }
    async createTemplate(body, req) {
        return this.notificationService.createTemplate(req.companyId, body);
    }
    async updateTemplate(id, body, req) {
        return this.notificationService.updateTemplate(req.companyId, id, body);
    }
    async deleteTemplate(id, req) {
        await this.notificationService.deleteTemplate(req.companyId, id);
        return {
            success: true,
            message: 'Template deleted successfully',
        };
    }
    async seedTemplates(req) {
        await this.templateSeedService.seedEmailTemplates(req.companyId);
        return {
            success: true,
            message: 'Default email templates seeded successfully',
        };
    }
    async sendTestPush(body, req) {
        const templateCode = 'test_push_notification';
        const title = body.title || 'Test Notification';
        const messageBody = body.body || 'This is a test push notification from your application';
        const existingTemplates = await this.notificationService.listTemplates(req.companyId);
        const pushTemplate = existingTemplates.find((t) => t.code === templateCode && t.channel === notification_channel_enum_1.NotificationChannel.PUSH);
        if (!pushTemplate) {
            await this.notificationService.createTemplate(req.companyId, {
                code: templateCode,
                channel: notification_channel_enum_1.NotificationChannel.PUSH,
                body: '{{body}}',
                defaultVariables: {},
            });
        }
        await this.notificationService.publishEvent({
            type: 'test_push',
            companyId: req.companyId,
            recipientUserId: req.user.userId,
            severity: notification_severity_enum_1.NotificationSeverity.INFO,
            templateCode,
            variables: {
                title,
                body: messageBody,
                ticketId: body.ticketId || null,
            },
            channels: [notification_channel_enum_1.NotificationChannel.PUSH],
        });
        return {
            success: true,
            message: 'Test push notification sent successfully',
            recipientUserId: req.user.userId,
            title,
            body: messageBody,
        };
    }
};
exports.NotificationController = NotificationController;
__decorate([
    (0, common_1.Get)(),
    (0, swagger_1.ApiOperation)({ summary: 'List in-app notifications for current user' }),
    (0, swagger_1.ApiOkResponse)({ description: 'List of notifications' }),
    __param(0, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], NotificationController.prototype, "list", null);
__decorate([
    (0, common_1.Patch)('read-all'),
    (0, swagger_1.ApiOperation)({ summary: 'Mark all notifications as read' }),
    (0, swagger_1.ApiOkResponse)({ description: 'All notifications marked as read' }),
    __param(0, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], NotificationController.prototype, "markAllAsRead", null);
__decorate([
    (0, common_1.Patch)(':id/read'),
    (0, swagger_1.ApiOperation)({ summary: 'Mark a notification as read' }),
    (0, swagger_1.ApiOkResponse)({ description: 'Updated notification' }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], NotificationController.prototype, "markAsRead", null);
__decorate([
    (0, common_1.Post)('devices/register'),
    (0, swagger_1.ApiOperation)({ summary: 'Register FCM device token for push notifications' }),
    (0, swagger_1.ApiBody)({
        schema: {
            type: 'object',
            properties: {
                fcmToken: { type: 'string', description: 'FCM token from Firebase' },
                platform: { type: 'string', enum: ['web', 'android', 'ios'], description: 'Device platform' },
                deviceInfo: { type: 'object', description: 'Optional device information (browser, OS, etc.)' },
            },
            required: ['fcmToken', 'platform'],
        },
    }),
    (0, swagger_1.ApiOkResponse)({ description: 'Device registered successfully' }),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", Promise)
], NotificationController.prototype, "registerDevice", null);
__decorate([
    (0, common_1.Delete)('devices/unregister'),
    (0, swagger_1.ApiOperation)({ summary: 'Unregister FCM device token' }),
    (0, swagger_1.ApiBody)({
        schema: {
            type: 'object',
            properties: {
                fcmToken: { type: 'string', description: 'FCM token to unregister' },
            },
            required: ['fcmToken'],
        },
    }),
    (0, swagger_1.ApiOkResponse)({ description: 'Device unregistered successfully' }),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", Promise)
], NotificationController.prototype, "unregisterDevice", null);
__decorate([
    (0, common_1.Get)('templates'),
    (0, swagger_1.ApiOperation)({ summary: 'List all notification templates (Admin only)' }),
    (0, swagger_1.ApiOkResponse)({ description: 'List of notification templates' }),
    __param(0, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], NotificationController.prototype, "listTemplates", null);
__decorate([
    (0, common_1.Get)('templates/email'),
    (0, swagger_1.ApiOperation)({ summary: 'List all email templates (Admin only)' }),
    (0, swagger_1.ApiOkResponse)({ description: 'List of email templates' }),
    __param(0, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], NotificationController.prototype, "listEmailTemplates", null);
__decorate([
    (0, common_1.Get)('templates/:id'),
    (0, swagger_1.ApiOperation)({ summary: 'Get a notification template by ID (Admin only)' }),
    (0, swagger_1.ApiOkResponse)({ description: 'Notification template' }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], NotificationController.prototype, "getTemplate", null);
__decorate([
    (0, common_1.Post)('templates'),
    (0, swagger_1.ApiOperation)({ summary: 'Create a new notification template (Admin only)' }),
    (0, swagger_1.ApiBody)({
        schema: {
            type: 'object',
            properties: {
                code: { type: 'string', description: 'Template code (e.g., ticket_created)' },
                channel: { type: 'string', enum: ['email', 'sms', 'push', 'whatsapp'], description: 'Notification channel' },
                subject: { type: 'string', nullable: true, description: 'Email subject (for email channel)' },
                body: { type: 'string', description: 'Template body with {{variables}}' },
                defaultVariables: { type: 'object', nullable: true, description: 'Default variables for template' },
            },
            required: ['code', 'channel', 'body'],
        },
    }),
    (0, swagger_1.ApiOkResponse)({ description: 'Created template' }),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", Promise)
], NotificationController.prototype, "createTemplate", null);
__decorate([
    (0, common_1.Patch)('templates/:id'),
    (0, swagger_1.ApiOperation)({ summary: 'Update a notification template (Admin only)' }),
    (0, swagger_1.ApiBody)({
        schema: {
            type: 'object',
            properties: {
                subject: { type: 'string', nullable: true, description: 'Email subject (for email channel)' },
                body: { type: 'string', description: 'Template body with {{variables}}' },
                defaultVariables: { type: 'object', nullable: true, description: 'Default variables for template' },
            },
        },
    }),
    (0, swagger_1.ApiOkResponse)({ description: 'Updated template' }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __param(2, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object, Object]),
    __metadata("design:returntype", Promise)
], NotificationController.prototype, "updateTemplate", null);
__decorate([
    (0, common_1.Delete)('templates/:id'),
    (0, swagger_1.ApiOperation)({ summary: 'Delete a notification template (Admin only)' }),
    (0, swagger_1.ApiOkResponse)({ description: 'Template deleted successfully' }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], NotificationController.prototype, "deleteTemplate", null);
__decorate([
    (0, common_1.Post)('templates/seed'),
    (0, swagger_1.ApiOperation)({ summary: 'Seed default email templates (Admin only)' }),
    (0, swagger_1.ApiOkResponse)({ description: 'Default templates seeded successfully' }),
    __param(0, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], NotificationController.prototype, "seedTemplates", null);
__decorate([
    (0, common_1.Post)('test/push'),
    (0, swagger_1.ApiOperation)({ summary: 'Send a test push notification to current user' }),
    (0, swagger_1.ApiBody)({
        schema: {
            type: 'object',
            properties: {
                title: { type: 'string', description: 'Notification title', default: 'Test Notification' },
                body: { type: 'string', description: 'Notification body', default: 'This is a test push notification' },
                ticketId: { type: 'string', nullable: true, description: 'Optional ticket ID for navigation' },
            },
            required: ['title', 'body'],
        },
    }),
    (0, swagger_1.ApiOkResponse)({ description: 'Test notification sent successfully' }),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", Promise)
], NotificationController.prototype, "sendTestPush", null);
exports.NotificationController = NotificationController = __decorate([
    (0, swagger_1.ApiTags)('notifications'),
    (0, swagger_1.ApiBearerAuth)('access-token'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, tenant_guard_1.TenantGuard),
    (0, common_1.Controller)('notifications'),
    __metadata("design:paramtypes", [notification_service_1.NotificationService,
        template_seed_service_1.TemplateSeedService,
        user_device_service_1.UserDeviceService])
], NotificationController);
