import { Controller, Get, Param, Patch, Post, Body, Delete, UseGuards, Req } from '@nestjs/common';
import { ApiBearerAuth, ApiOkResponse, ApiOperation, ApiTags, ApiBody } from '@nestjs/swagger';
import { NotificationService } from './notification.service';
import { TemplateSeedService } from './services/template-seed.service';
import { TenantGuard } from '../../shared/guards/tenant.guard';
import { JwtAuthGuard } from '../../modules/auth/guards/jwt-auth.guard';
import { TenantAwareRequest } from '../../shared/middleware/tenant-resolution.middleware';
import { Request } from 'express';
import { UserDeviceService } from '../iam/services/user-device.service';
import { DevicePlatform } from '../iam/entities/user-device.entity';
import { NotificationSeverity } from './enums/notification-severity.enum';
import { NotificationChannel } from './enums/notification-channel.enum';

interface AuthenticatedRequest extends TenantAwareRequest, Request {
  user: { 
    userId: string;
    email?: string;
    companyId?: string;
    roles?: string[];
    permissions?: string[];
  };
}

@ApiTags('notifications')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, TenantGuard)
@Controller('notifications')
export class NotificationController {
  constructor(
    private readonly notificationService: NotificationService,
    private readonly templateSeedService: TemplateSeedService,
    private readonly userDeviceService: UserDeviceService,
  ) {}

  @Get()
  @ApiOperation({ summary: 'List in-app notifications for current user' })
  @ApiOkResponse({ description: 'List of notifications' })
  async list(@Req() req: AuthenticatedRequest) {
    return this.notificationService.listInAppNotifications(req.companyId!, req.user.userId);
  }

  @Patch('read-all')
  @ApiOperation({ summary: 'Mark all notifications as read' })
  @ApiOkResponse({ description: 'All notifications marked as read' })
  async markAllAsRead(@Req() req: AuthenticatedRequest) {
    await this.notificationService.markAllAsRead(req.companyId!, req.user.userId);
    return { success: true, message: 'All notifications marked as read' };
  }

  @Patch(':id/read')
  @ApiOperation({ summary: 'Mark a notification as read' })
  @ApiOkResponse({ description: 'Updated notification' })
  async markAsRead(@Param('id') id: string, @Req() req: AuthenticatedRequest) {
    return this.notificationService.markAsRead(req.companyId!, req.user.userId, id);
  }

  @Post('devices/register')
  @ApiOperation({ summary: 'Register FCM device token for push notifications' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        fcmToken: { type: 'string', description: 'FCM token from Firebase' },
        platform: { type: 'string', enum: ['web', 'android', 'ios'], description: 'Device platform' },
        deviceInfo: { type: 'object', description: 'Optional device information (browser, OS, etc.)' },
      },
      required: ['fcmToken', 'platform'],
    },
  })
  @ApiOkResponse({ description: 'Device registered successfully' })
  async registerDevice(
    @Body() body: { fcmToken: string; platform: DevicePlatform; deviceInfo?: Record<string, unknown> },
    @Req() req: AuthenticatedRequest,
  ) {
    const device = await this.userDeviceService.registerDevice(
      req.companyId!,
      req.user.userId,
      body.fcmToken,
      body.platform,
      body.deviceInfo,
    );
    return {
      success: true,
      deviceId: device.id,
      message: 'Device registered successfully',
    };
  }

  @Delete('devices/unregister')
  @ApiOperation({ summary: 'Unregister FCM device token' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        fcmToken: { type: 'string', description: 'FCM token to unregister' },
      },
      required: ['fcmToken'],
    },
  })
  @ApiOkResponse({ description: 'Device unregistered successfully' })
  async unregisterDevice(
    @Body() body: { fcmToken: string },
    @Req() req: AuthenticatedRequest,
  ) {
    await this.userDeviceService.unregisterDevice(
      req.companyId!,
      req.user.userId,
      body.fcmToken,
    );
    return {
      success: true,
      message: 'Device unregistered successfully',
    };
  }

  // Email Template Management (Admin only)
  @Get('templates')
  @ApiOperation({ summary: 'List all notification templates (Admin only)' })
  @ApiOkResponse({ description: 'List of notification templates' })
  async listTemplates(@Req() req: AuthenticatedRequest) {
    return this.notificationService.listTemplates(req.companyId!);
  }

  @Get('templates/email')
  @ApiOperation({ summary: 'List all email templates (Admin only)' })
  @ApiOkResponse({ description: 'List of email templates' })
  async listEmailTemplates(@Req() req: AuthenticatedRequest) {
    return this.notificationService.listTemplatesByChannel(req.companyId!, 'email');
  }

  @Get('templates/:id')
  @ApiOperation({ summary: 'Get a notification template by ID (Admin only)' })
  @ApiOkResponse({ description: 'Notification template' })
  async getTemplate(@Param('id') id: string, @Req() req: AuthenticatedRequest) {
    return this.notificationService.getTemplate(req.companyId!, id);
  }

  @Post('templates')
  @ApiOperation({ summary: 'Create a new notification template (Admin only)' })
  @ApiBody({
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
  })
  @ApiOkResponse({ description: 'Created template' })
  async createTemplate(
    @Body() body: { code: string; channel: string; subject?: string | null; body: string; defaultVariables?: Record<string, unknown> | null },
    @Req() req: AuthenticatedRequest,
  ) {
    return this.notificationService.createTemplate(req.companyId!, body);
  }

  @Patch('templates/:id')
  @ApiOperation({ summary: 'Update a notification template (Admin only)' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        subject: { type: 'string', nullable: true, description: 'Email subject (for email channel)' },
        body: { type: 'string', description: 'Template body with {{variables}}' },
        defaultVariables: { type: 'object', nullable: true, description: 'Default variables for template' },
      },
    },
  })
  @ApiOkResponse({ description: 'Updated template' })
  async updateTemplate(
    @Param('id') id: string,
    @Body() body: { subject?: string | null; body?: string; defaultVariables?: Record<string, unknown> | null },
    @Req() req: AuthenticatedRequest,
  ) {
    return this.notificationService.updateTemplate(req.companyId!, id, body);
  }

  @Delete('templates/:id')
  @ApiOperation({ summary: 'Delete a notification template (Admin only)' })
  @ApiOkResponse({ description: 'Template deleted successfully' })
  async deleteTemplate(@Param('id') id: string, @Req() req: AuthenticatedRequest) {
    await this.notificationService.deleteTemplate(req.companyId!, id);
    return {
      success: true,
      message: 'Template deleted successfully',
    };
  }

  @Post('templates/seed')
  @ApiOperation({ summary: 'Seed default email templates (Admin only)' })
  @ApiOkResponse({ description: 'Default templates seeded successfully' })
  async seedTemplates(@Req() req: AuthenticatedRequest) {
    await this.templateSeedService.seedEmailTemplates(req.companyId!);
    return {
      success: true,
      message: 'Default email templates seeded successfully',
    };
  }

  @Post('test/push')
  @ApiOperation({ summary: 'Send a test push notification to current user' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        title: { type: 'string', description: 'Notification title', default: 'Test Notification' },
        body: { type: 'string', description: 'Notification body', default: 'This is a test push notification' },
        ticketId: { type: 'string', nullable: true, description: 'Optional ticket ID for navigation' },
      },
      required: ['title', 'body'],
    },
  })
  @ApiOkResponse({ description: 'Test notification sent successfully' })
  async sendTestPush(
    @Body() body: { title?: string; body?: string; ticketId?: string },
    @Req() req: AuthenticatedRequest,
  ) {
    const templateCode = 'test_push_notification';
    const title = body.title || 'Test Notification';
    const messageBody = body.body || 'This is a test push notification from your application';
    
    // Check if template exists by code, if not create a simple one
    const existingTemplates = await this.notificationService.listTemplates(req.companyId!);
    const pushTemplate = existingTemplates.find(
      (t) => t.code === templateCode && t.channel === NotificationChannel.PUSH,
    );
    
    if (!pushTemplate) {
      // Template doesn't exist, create it
      await this.notificationService.createTemplate(req.companyId!, {
        code: templateCode,
        channel: NotificationChannel.PUSH,
        body: '{{body}}',
        defaultVariables: {},
      });
    }

    // Send test notification
    await this.notificationService.publishEvent({
      type: 'test_push',
      companyId: req.companyId!,
      recipientUserId: req.user.userId,
      severity: NotificationSeverity.INFO,
      templateCode,
      variables: {
        title,
        body: messageBody,
        ticketId: body.ticketId || null,
      },
      channels: [NotificationChannel.PUSH],
    });

    return {
      success: true,
      message: 'Test push notification sent successfully',
      recipientUserId: req.user.userId,
      title,
      body: messageBody,
    };
  }
}


