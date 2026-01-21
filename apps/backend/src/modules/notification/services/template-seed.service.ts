import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { NotificationTemplate } from '../entities/notification-template.entity';
import { NotificationChannel } from '../enums/notification-channel.enum';
import { Company } from '../../tenant/entities/company.entity';

@Injectable()
export class TemplateSeedService {
  private readonly logger = new Logger(TemplateSeedService.name);

  constructor(
    @InjectRepository(NotificationTemplate)
    private readonly templateRepo: Repository<NotificationTemplate>,
    @InjectRepository(Company)
    private readonly companyRepo: Repository<Company>,
  ) {}

  /**
   * Seed default email templates for common events
   */
  async seedEmailTemplates(companyId: string): Promise<void> {
    await this.seedPushTemplates(companyId);
    
    // Fetch company details to use in templates
    const company = await this.companyRepo.findOne({
      where: { id: companyId },
      select: ['name', 'code'],
    });
    
    const companyName = company?.name || 'Facility ERP Team';
    const companyCode = company?.code || 'COMP001';
    
    const templates = [
      {
        code: 'ticket_created',
        channel: NotificationChannel.EMAIL,
        subject: 'New Ticket Created - {{ticketNumber}}',
        body: `Hello,

A new maintenance ticket has been created:

Ticket Number: {{ticketNumber}}
Title: {{title}}
Priority: {{priority}}
Created By: {{creatorName}}
Villa: {{villaNumber}}
Description: {{description}}
Company Code: {{companyCode}}
Site Code: {{siteCode}}

You can view and manage this ticket in the system.

Best regards,
{{companyName}}`,
        defaultVariables: {
          ticketNumber: 'TKT-2025-0001',
          title: 'Sample Ticket Title',
          priority: 'Medium',
          creatorName: 'John Doe',
          villaNumber: null,
          description: null,
          companyCode,
          siteCode: 'SITE001',
          companyName,
        },
      },
      {
        code: 'ticket_updated',
        channel: NotificationChannel.EMAIL,
        subject: 'Ticket Updated - {{ticketNumber}}',
        body: `Hello,

The following maintenance ticket has been updated:

Ticket Number: {{ticketNumber}}
Title: {{title}}
Status: {{status}}
Updated By: {{updatedBy}}
Notes: {{notes}}
Company Code: {{companyCode}}
Site Code: {{siteCode}}

You can view the updated ticket in the system.

Best regards,
{{companyName}}`,
        defaultVariables: {
          ticketNumber: 'TKT-2025-0001',
          title: 'Sample Ticket Title',
          status: 'In Progress',
          updatedBy: null,
          notes: null,
          companyCode,
          siteCode: 'SITE001',
          companyName,
        },
      },
      {
        code: 'ticket_status_changed',
        channel: NotificationChannel.EMAIL,
        subject: 'Ticket Status Changed - {{ticketNumber}}',
        body: `Hello,

The status of your maintenance ticket has been changed:

Ticket Number: {{ticketNumber}}
Title: {{title}}
Previous Status: {{previousStatus}}
New Status: {{newStatus}}
Assigned To: {{assignedTo}}
Company Code: {{companyCode}}
Site Code: {{siteCode}}

You can view the ticket details in the system.

Best regards,
{{companyName}}`,
        defaultVariables: {
          ticketNumber: 'TKT-2025-0001',
          title: 'Sample Ticket Title',
          previousStatus: 'New',
          newStatus: 'In Progress',
          assignedTo: null,
          companyCode,
          siteCode: 'SITE001',
          companyName,
        },
      },
      {
        code: 'user_created',
        channel: NotificationChannel.EMAIL,
        subject: 'Welcome to Facility ERP - Your Account Credentials',
        body: `Hello {{firstName}},

Your account has been created successfully. Please use the following credentials to log in:

Email: {{email}}
Password: {{password}}
Login URL: {{loginUrl}}
Company Code: {{companyCode}}
Site Code: {{siteCode}}

For security reasons, we recommend that you change your password after your first login.

If you did not request this account, please contact support immediately.

Best regards,
{{companyName}}`,
        defaultVariables: {
          firstName: 'John',
          email: 'user@example.com',
          password: 'TemporaryPassword123',
          loginUrl: 'https://example.com',
          companyCode,
          siteCode: 'SITE001',
          companyName,
        },
      },
      {
        code: 'ticket_assigned',
        channel: NotificationChannel.EMAIL,
        subject: 'New Ticket Assigned to You - {{ticketNumber}}',
        body: `Hello,

A new maintenance ticket has been assigned to you:

Ticket Number: {{ticketNumber}}
Title: {{title}}
Priority: {{priority}}
Villa: {{villaNumber}}
Description: {{description}}
Company Code: {{companyCode}}
Site Code: {{siteCode}}

Please review and take appropriate action.

Best regards,
{{companyName}}`,
        defaultVariables: {
          ticketNumber: 'TKT-2025-0001',
          title: 'Sample Ticket Title',
          priority: 'High',
          villaNumber: null,
          description: null,
          companyCode,
          siteCode: 'SITE001',
          companyName,
        },
      },
      {
        code: 'ticket_completed',
        channel: NotificationChannel.EMAIL,
        subject: 'Ticket Completed - {{ticketNumber}}',
        body: `Hello,

The following maintenance ticket has been completed:

Ticket Number: {{ticketNumber}}
Title: {{title}}
Completed By: {{completedBy}}
Resolution Notes: {{resolutionNotes}}
Company Code: {{companyCode}}
Site Code: {{siteCode}}

Thank you for using our services.

Best regards,
{{companyName}}`,
        defaultVariables: {
          ticketNumber: 'TKT-2025-0001',
          title: 'Sample Ticket Title',
          completedBy: 'Technician Name',
          resolutionNotes: null,
          companyCode,
          siteCode: 'SITE001',
          companyName,
        },
      },
      {
        code: 'tenant_ticket_created',
        channel: NotificationChannel.EMAIL,
        subject: 'Ticket Created - {{ticketNumber}}',
        body: `Hello,
        
Your maintenance ticket has been created successfully:

Ticket Number: {{ticketNumber}}
Title: {{title}}
Priority: {{priority}}
Villa: {{villaNumber}}
Status: New
Company Code: {{companyCode}}
Site Code: {{siteCode}}

You will receive email notifications when your ticket status is updated.

Best regards,
{{companyName}}`,
        defaultVariables: {
          ticketNumber: 'TKT-2025-0001',
          title: 'Sample Ticket Title',
          priority: 'Medium',
          villaNumber: null,
          companyCode,
          siteCode: 'SITE001',
          companyName,
        },
      },
      {
        code: 'tenant_ticket_technician_assigned',
        channel: NotificationChannel.EMAIL,
        subject: 'Technician Assigned - {{ticketNumber}}',
        body: `Hello,

A technician has been assigned to your maintenance ticket:

Ticket Number: {{ticketNumber}}
Title: {{title}}
Status: {{status}}
Assigned Technician: {{technicianName}}
Scheduled Visit: {{scheduledAt}}
Company Code: {{companyCode}}
Site Code: {{siteCode}}

{{message}}

You will be notified when the technician starts working on your ticket.

Best regards,
{{companyName}}`,
        defaultVariables: {
          ticketNumber: 'TKT-2025-0001',
          title: 'Sample Ticket Title',
          status: 'Assigned',
          technicianName: 'John Technician',
          scheduledAt: '',
          message: 'Technician John Technician has been assigned to your ticket.',
          companyCode,
          siteCode: 'SITE001',
          companyName,
        },
      },
      {
        code: 'tenant_ticket_status_changed',
        channel: NotificationChannel.EMAIL,
        subject: 'Ticket Status Updated - {{ticketNumber}}',
        body: `Hello,

Your maintenance ticket status has been updated:

Ticket Number: {{ticketNumber}}
Title: {{title}}
Previous Status: {{previousStatus}}
New Status: {{newStatus}}
Assigned To: {{assignedTo}}
Company Code: {{companyCode}}
Site Code: {{siteCode}}

{{message}}

You can view the updated ticket details in the system.

Best regards,
{{companyName}}`,
        defaultVariables: {
          ticketNumber: 'TKT-2025-0001',
          title: 'Sample Ticket Title',
          previousStatus: 'New',
          newStatus: 'In Progress',
          assignedTo: '',
          message: 'Your ticket status has been updated.',
          companyCode,
          siteCode: 'SITE001',
          companyName,
        },
      },
      {
        code: 'tenant_ticket_acknowledged',
        channel: NotificationChannel.EMAIL,
        subject: 'Ticket Acknowledged - {{ticketNumber}}',
        body: `Hello,

Your maintenance ticket has been acknowledged:

Ticket Number: {{ticketNumber}}
Title: {{title}}
Status: {{status}}
Acknowledged By: {{updatedBy}}
Company Code: {{companyCode}}
Site Code: {{siteCode}}

{{message}}

Your ticket is now being reviewed and will be assigned to a technician soon.

Best regards,
{{companyName}}`,
        defaultVariables: {
          ticketNumber: 'TKT-2025-0001',
          title: 'Sample Ticket Title',
          status: 'Acknowledged',
          updatedBy: 'Support Team',
          message: 'Your ticket has been acknowledged.',
          companyCode,
          siteCode: 'SITE001',
          companyName,
        },
      },
      {
        code: 'tenant_ticket_supervisor_assigned',
        channel: NotificationChannel.EMAIL,
        subject: 'Supervisor Assigned - {{ticketNumber}}',
        body: `Hello,

A supervisor has been assigned to review your maintenance ticket:

Ticket Number: {{ticketNumber}}
Title: {{title}}
Status: {{status}}
Assigned Supervisor: {{supervisorName}}
Company Code: {{companyCode}}
Site Code: {{siteCode}}

{{message}}

The supervisor will review your ticket and coordinate the resolution.

Best regards,
{{companyName}}`,
        defaultVariables: {
          ticketNumber: 'TKT-2025-0001',
          title: 'Sample Ticket Title',
          status: 'Assigned',
          supervisorName: 'John Supervisor',
          message: 'Supervisor John Supervisor has been assigned to review your ticket.',
          companyCode,
          siteCode: 'SITE001',
          companyName,
        },
      },
      {
        code: 'tenant_ticket_team_assigned',
        channel: NotificationChannel.EMAIL,
        subject: 'Team Assigned - {{ticketNumber}}',
        body: `Hello,

A team has been assigned to work on your maintenance ticket:

Ticket Number: {{ticketNumber}}
Title: {{title}}
Status: {{status}}
Assigned Team: {{teamName}}
Company Code: {{companyCode}}
Site Code: {{siteCode}}

{{message}}

The team will begin working on your ticket shortly.

Best regards,
{{companyName}}`,
        defaultVariables: {
          ticketNumber: 'TKT-2025-0001',
          title: 'Sample Ticket Title',
          status: 'Assigned',
          teamName: 'Maintenance Team',
          message: 'Team Maintenance Team has been assigned to work on your ticket.',
          companyCode,
          siteCode: 'SITE001',
          companyName,
        },
      },
      {
        code: 'TICKET_ESCALATED_TO_SUPERVISOR_EMAIL',
        channel: NotificationChannel.EMAIL,
        subject: 'Ticket Escalated - {{ticketNumber}} (Level {{escalationLevel}})',
        body: `Hello,

A maintenance ticket has been escalated and requires your attention:

Ticket Number: {{ticketNumber}}
Title: {{ticketTitle}}
Priority: {{priority}}
Escalation Level: {{escalationLevel}}
Escalated To: {{escalationRole}}
Reason: {{reason}}
Escalated At: {{escalatedAt}}
Company Code: {{companyCode}}
Site Code: {{siteCode}}

Please review and take appropriate action to resolve this ticket.

Best regards,
{{companyName}}`,
        defaultVariables: {
          ticketNumber: 'TKT-2025-0001',
          ticketTitle: 'Sample Ticket Title',
          priority: 'High',
          escalationLevel: '1',
          escalationRole: 'SUPERVISOR',
          reason: 'Automatic escalation after SLA threshold exceeded',
          escalatedAt: new Date().toISOString(),
          ticketId: null,
          companyCode,
          siteCode: 'SITE001',
          companyName,
        },
      },
      {
        code: 'TICKET_ESCALATED_TO_COORDINATOR_EMAIL',
        channel: NotificationChannel.EMAIL,
        subject: 'Ticket Escalated - {{ticketNumber}} (Level {{escalationLevel}})',
        body: `Hello,

A maintenance ticket has been escalated and requires your attention:

Ticket Number: {{ticketNumber}}
Title: {{ticketTitle}}
Priority: {{priority}}
Escalation Level: {{escalationLevel}}
Escalated To: {{escalationRole}}
Reason: {{reason}}
Escalated At: {{escalatedAt}}
Company Code: {{companyCode}}
Site Code: {{siteCode}}

Please review and take appropriate action to resolve this ticket.

Best regards,
{{companyName}}`,
        defaultVariables: {
          ticketNumber: 'TKT-2025-0001',
          ticketTitle: 'Sample Ticket Title',
          priority: 'High',
          escalationLevel: '2',
          escalationRole: 'SITE_COORDINATOR',
          reason: 'Automatic escalation after SLA threshold exceeded',
          escalatedAt: new Date().toISOString(),
          ticketId: null,
          companyCode,
          siteCode: 'SITE001',
          companyName,
        },
      },
      {
        code: 'TICKET_ESCALATED_TO_ADMIN_EMAIL',
        channel: NotificationChannel.EMAIL,
        subject: 'Ticket Escalated - {{ticketNumber}} (Level {{escalationLevel}})',
        body: `Hello,

A maintenance ticket has been escalated and requires your immediate attention:

Ticket Number: {{ticketNumber}}
Title: {{ticketTitle}}
Priority: {{priority}}
Escalation Level: {{escalationLevel}}
Escalated To: {{escalationRole}}
Reason: {{reason}}
Escalated At: {{escalatedAt}}
Company Code: {{companyCode}}
Site Code: {{siteCode}}

This ticket requires executive-level attention. Please review and take immediate action.

Best regards,
{{companyName}}`,
        defaultVariables: {
          ticketNumber: 'TKT-2025-0001',
          ticketTitle: 'Sample Ticket Title',
          priority: 'Critical',
          escalationLevel: '3',
          escalationRole: 'ADMIN',
          reason: 'Automatic escalation after SLA threshold exceeded',
          escalatedAt: new Date().toISOString(),
          ticketId: null,
          companyCode,
          siteCode: 'SITE001',
          companyName,
        },
      },
      {
        code: 'TICKET_ESCALATION_WARNING_EMAIL',
        channel: NotificationChannel.EMAIL,
        subject: 'Ticket Escalation Warning - {{ticketNumber}}',
        body: `Hello,

A maintenance ticket is approaching its escalation threshold:

Ticket Number: {{ticketNumber}}
Title: {{ticketTitle}}
Priority: {{priority}}
Current Status: {{status}}
Time Remaining: {{timeRemaining}}
Company Code: {{companyCode}}
Site Code: {{siteCode}}

Please take action to prevent escalation.

Best regards,
{{companyName}}`,
        defaultVariables: {
          ticketNumber: 'TKT-2025-0001',
          ticketTitle: 'Sample Ticket Title',
          priority: 'High',
          status: 'In Progress',
          timeRemaining: '2 hours',
          companyCode,
          siteCode: 'SITE001',
          companyName,
        },
      },
      {
        code: 'sla_at_risk',
        channel: NotificationChannel.EMAIL,
        subject: 'SLA At Risk - {{ticketNumber}}',
        body: `Hello,

A maintenance ticket SLA is at risk and requires attention:

Ticket Number: {{ticketNumber}}
Title: {{ticketTitle}}
Priority: {{priority}}
SLA Status: At Risk
Time Remaining: {{timeRemaining}}
SLA Due Date: {{dueDate}}
Company Code: {{companyCode}}
Site Code: {{siteCode}}

Please take immediate action to resolve this ticket before the SLA deadline.

Best regards,
{{companyName}}`,
        defaultVariables: {
          ticketNumber: 'TKT-2025-0001',
          ticketTitle: 'Sample Ticket Title',
          priority: 'High',
          timeRemaining: '2h 15m',
          dueDate: new Date().toISOString(),
          companyCode,
          siteCode: 'SITE001',
          companyName,
        },
      },
      {
        code: 'sla_breached',
        channel: NotificationChannel.EMAIL,
        subject: 'SLA Breached - {{ticketNumber}}',
        body: `Hello,

A maintenance ticket SLA has been breached:

Ticket Number: {{ticketNumber}}
Title: {{ticketTitle}}
Priority: {{priority}}
SLA Status: BREACHED
SLA Due Date: {{dueDate}}
Company Code: {{companyCode}}
Site Code: {{siteCode}}

This ticket requires immediate attention as the SLA deadline has passed.

Best regards,
{{companyName}}`,
        defaultVariables: {
          ticketNumber: 'TKT-2025-0001',
          ticketTitle: 'Sample Ticket Title',
          priority: 'High',
          dueDate: new Date().toISOString(),
          companyCode,
          siteCode: 'SITE001',
          companyName,
        },
      },
    ];

    for (const templateData of templates) {
      const existing = await this.templateRepo.findOne({
        where: {
          companyId,
          code: templateData.code,
          channel: templateData.channel,
        },
      });

      if (!existing) {
        const template = this.templateRepo.create({
          companyId,
          code: templateData.code,
          channel: templateData.channel,
          subject: templateData.subject,
          body: templateData.body,
          defaultVariables: templateData.defaultVariables,
        });
        await this.templateRepo.save(template);
        this.logger.log(
          `Created email template: ${templateData.code} for company ${companyId}`,
        );
      } else {
        // Update existing template for user_created to ensure it has Company Code and Site Code
        if (templateData.code === 'user_created') {
          existing.body = templateData.body;
          existing.subject = templateData.subject;
          existing.defaultVariables = templateData.defaultVariables;
          await this.templateRepo.save(existing);
          this.logger.log(
            `Updated email template: ${templateData.code} for company ${companyId}`,
          );
        } else {
          this.logger.log(
            `Email template ${templateData.code} already exists for company ${companyId}`,
          );
        }
      }
    }
  }

  /**
   * Seed default push notification templates for common events
   */
  async seedPushTemplates(companyId: string): Promise<void> {
    const pushTemplates = [
      {
        code: 'ticket_created',
        channel: NotificationChannel.PUSH,
        body: '{{body}}',
        defaultVariables: {
          title: 'New Ticket Created',
          body: 'A new maintenance ticket has been created',
          ticketId: null,
          ticketNumber: 'TKT-2025-0001',
        },
      },
      {
        code: 'ticket_updated',
        channel: NotificationChannel.PUSH,
        body: '{{body}}',
        defaultVariables: {
          title: 'Ticket Updated',
          body: 'A maintenance ticket has been updated',
          ticketId: null,
          ticketNumber: 'TKT-2025-0001',
        },
      },
      {
        code: 'ticket_status_changed',
        channel: NotificationChannel.PUSH,
        body: '{{body}}',
        defaultVariables: {
          title: 'Ticket Status Changed',
          body: 'The status of a maintenance ticket has changed',
          ticketId: null,
          ticketNumber: 'TKT-2025-0001',
        },
      },
      {
        code: 'ticket_assigned',
        channel: NotificationChannel.PUSH,
        body: '{{body}}',
        defaultVariables: {
          title: 'New Ticket Assigned',
          body: 'A new maintenance ticket has been assigned to you',
          ticketId: null,
          ticketNumber: 'TKT-2025-0001',
        },
      },
      {
        code: 'ticket_completed',
        channel: NotificationChannel.PUSH,
        body: '{{body}}',
        defaultVariables: {
          title: 'Ticket Completed',
          body: 'A maintenance ticket has been completed',
          ticketId: null,
          ticketNumber: 'TKT-2025-0001',
        },
      },
      {
        code: 'tenant_ticket_created',
        channel: NotificationChannel.PUSH,
        body: '{{body}}',
        defaultVariables: {
          title: 'Ticket Created',
          body: 'Your maintenance ticket has been created successfully',
          ticketId: null,
          ticketNumber: 'TKT-2025-0001',
        },
      },
      {
        code: 'TICKET_ESCALATED_TO_SUPERVISOR_PUSH',
        channel: NotificationChannel.PUSH,
        body: '{{body}}',
        defaultVariables: {
          title: 'Ticket Escalated',
          body: 'Ticket {{ticketNumber}} has been escalated to you (Level {{escalationLevel}})',
          ticketId: null,
          ticketNumber: 'TKT-2025-0001',
          escalationLevel: '1',
          escalationRole: 'SUPERVISOR',
          reason: 'Automatic escalation',
        },
      },
      {
        code: 'TICKET_ESCALATED_TO_COORDINATOR_PUSH',
        channel: NotificationChannel.PUSH,
        body: '{{body}}',
        defaultVariables: {
          title: 'Ticket Escalated',
          body: 'Ticket {{ticketNumber}} has been escalated to you (Level {{escalationLevel}})',
          ticketId: null,
          ticketNumber: 'TKT-2025-0001',
          escalationLevel: '2',
          escalationRole: 'SITE_COORDINATOR',
          reason: 'Automatic escalation',
        },
      },
      {
        code: 'TICKET_ESCALATED_TO_ADMIN_PUSH',
        channel: NotificationChannel.PUSH,
        body: '{{body}}',
        defaultVariables: {
          title: 'Ticket Escalated - Immediate Action Required',
          body: 'Ticket {{ticketNumber}} has been escalated to you (Level {{escalationLevel}})',
          ticketId: null,
          ticketNumber: 'TKT-2025-0001',
          escalationLevel: '3',
          escalationRole: 'ADMIN',
          reason: 'Automatic escalation',
        },
      },
      {
        code: 'TICKET_ESCALATION_WARNING_PUSH',
        channel: NotificationChannel.PUSH,
        body: '{{body}}',
        defaultVariables: {
          title: 'Escalation Warning',
          body: 'Ticket {{ticketNumber}} is approaching escalation threshold',
          ticketId: null,
          ticketNumber: 'TKT-2025-0001',
        },
      },
      {
        code: 'sla_at_risk',
        channel: NotificationChannel.PUSH,
        body: '{{body}}',
        defaultVariables: {
          title: 'SLA At Risk',
          body: 'Ticket {{ticketNumber}} SLA is at risk. {{timeRemaining}} remaining',
          ticketId: null,
          ticketNumber: 'TKT-2025-0001',
          timeRemaining: '2h 15m',
        },
      },
      {
        code: 'sla_breached',
        channel: NotificationChannel.PUSH,
        body: '{{body}}',
        defaultVariables: {
          title: 'SLA Breached',
          body: 'Ticket {{ticketNumber}} SLA has been breached',
          ticketId: null,
          ticketNumber: 'TKT-2025-0001',
        },
      },
    ];

    for (const templateData of pushTemplates) {
      const existing = await this.templateRepo.findOne({
        where: {
          companyId,
          code: templateData.code,
          channel: templateData.channel,
        },
      });

      if (!existing) {
        const template = this.templateRepo.create({
          companyId,
          code: templateData.code,
          channel: templateData.channel,
          subject: null, // Push notifications don't have subjects
          body: templateData.body,
          defaultVariables: templateData.defaultVariables,
        });
        await this.templateRepo.save(template);
        this.logger.log(
          `Created push template: ${templateData.code} for company ${companyId}`,
        );
      } else {
        this.logger.log(
          `Push template ${templateData.code} already exists for company ${companyId}`,
        );
      }
    }
  }
}

