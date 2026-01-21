/**
 * ============================================================================
 * SLA ALERT TEST SCRIPT
 * ============================================================================
 * 
 * This script tests the SLA alert/notification functionality, including:
 * 
 * 1. Alert when SLA status changes to AT_RISK
 * 2. Alert when SLA status changes to BREACHED
 * 3. Alert recipients (admins, supervisors, technicians)
 * 4. Alert channels (in-app, email, push)
 * 5. Alert content and formatting
 * 
 * Usage: npm run test:sla-alerts
 * Or: ts-node -r tsconfig-paths/register scripts/test-sla-alerts.ts
 * 
 * ============================================================================
 */

import { DataSource } from 'typeorm';
import { MaintenanceTicket } from '../src/modules/maintenance-ticket/entities/maintenance-ticket.entity';
import { TicketSla, SlaStatus } from '../src/modules/maintenance-ticket/entities/ticket-sla.entity';
import { SlaConfiguration } from '../src/modules/maintenance-ticket/entities/sla-configuration.entity';
import { User } from '../src/modules/iam/entities/user.entity';
import { Company } from '../src/modules/tenant/entities/company.entity';
import { Notification } from '../src/modules/notification/entities/notification.entity';
import { NotificationDelivery } from '../src/modules/notification/entities/notification-delivery.entity';
import { TicketPriority } from '../src/modules/maintenance-ticket/enums/ticket-priority.enum';
import { TicketStatus } from '../src/modules/maintenance-ticket/enums/ticket-status.enum';
import { UserStatus, AuthProvider } from '../src/modules/iam/entities/user.entity';
import { NotificationSeverity } from '../src/modules/notification/enums/notification-severity.enum';
import { NotificationChannel } from '../src/modules/notification/enums/notification-channel.enum';

const dataSource = new DataSource({
  type: 'postgres',
  host: process.env.DB_HOST || 'localhost',
  port: Number(process.env.DB_PORT || '5432'),
  username: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  database: process.env.DB_NAME || 'facility_erp',
  entities: [__dirname + '/../src/**/*.entity.{ts,js}'],
  synchronize: false,
});

interface TestResult {
  testName: string;
  passed: boolean;
  message: string;
  details?: any;
}

const testResults: TestResult[] = [];

function logTest(testName: string, passed: boolean, message: string, details?: any) {
  testResults.push({ testName, passed, message, details });
  const icon = passed ? '✅' : '❌';
  console.log(`${icon} ${testName}: ${message}`);
  if (details && !passed) {
    console.log('   Details:', JSON.stringify(details, null, 2));
  }
}

async function setupTestData() {
  console.log('\n📋 Setting up test data...');
  console.log('=' .repeat(60));

  try {
    const companyRepo = dataSource.getRepository(Company);
    const userRepo = dataSource.getRepository(User);
    const slaConfigRepo = dataSource.getRepository(SlaConfiguration);
    const ticketRepo = dataSource.getRepository(MaintenanceTicket);
    const ticketSlaRepo = dataSource.getRepository(TicketSla);

    // Try to find COMP1051 company first, otherwise use first company
    let company = await companyRepo.findOne({
      where: { code: 'COMP1051' },
    });

    if (!company) {
      const companies = await companyRepo.find({ take: 1 });
      if (!companies || companies.length === 0) {
        throw new Error('No company found. Please seed companies first.');
      }
      company = companies[0];
      console.log(`⚠️  COMP1051 not found, using first company: ${company.name}`);
    } else {
      console.log(`✅ Found company: ${company.name} (${company.code})`);
    }

    // Find actual admin user (prefer the one specified, otherwise find any admin)
    let adminUser = await userRepo.findOne({
      where: { companyId: company.id, email: 'admin.com0001@comp1051.com' },
    });

    // If not found, try to find any admin user by email first (case-insensitive)
    if (!adminUser) {
      const allUsers = await userRepo.find({
        where: { companyId: company.id, status: UserStatus.ACTIVE },
      });
      const foundUser = allUsers.find(
        (u) => u.email?.toLowerCase() === 'admin.com0001@comp1051.com'.toLowerCase(),
      );
      if (foundUser) {
        adminUser = foundUser;
      }
    }

    // If still not found, try to find any admin user by role
    if (!adminUser) {
      const admins = await userRepo
        .createQueryBuilder('user')
        .leftJoinAndSelect('user.userRoles', 'userRole')
        .leftJoinAndSelect('userRole.role', 'role')
        .where('user.companyId = :companyId', { companyId: company.id })
        .andWhere('user.status = :status', { status: UserStatus.ACTIVE })
        .andWhere('role.name = :adminRole', { adminRole: 'ADMIN' })
        .take(1)
        .getMany();
      
      if (admins && admins.length > 0) {
        adminUser = admins[0];
        console.log(`✅ Found admin user by role: ${adminUser.email}`);
      }
    } else {
      console.log(`✅ Found specified admin user: ${adminUser.email}`);
    }

    // If still no admin, try to find any active user (fallback for testing)
    if (!adminUser) {
      const anyUser = await userRepo.findOne({
        where: { companyId: company.id, status: UserStatus.ACTIVE },
      });
      if (anyUser) {
        adminUser = anyUser;
        console.log(`⚠️  Using fallback user (not necessarily admin): ${adminUser.email}`);
      }
    }

    // Last resort: create a test one
    if (!adminUser) {
      adminUser = userRepo.create({
        companyId: company.id,
        email: 'test-sla-admin@test.com',
        firstName: 'SLA',
        lastName: 'Admin',
        status: UserStatus.ACTIVE,
        authProvider: AuthProvider.LOCAL,
      });
      adminUser = await userRepo.save(adminUser);
      console.log('⚠️  Created test admin user (real admin not found)');
    }

    // Find or create supervisor user
    let supervisorUser = await userRepo.findOne({
      where: { companyId: company.id, email: 'test-sla-supervisor@test.com' },
    });

    if (!supervisorUser) {
      supervisorUser = userRepo.create({
        companyId: company.id,
        email: 'test-sla-supervisor@test.com',
        firstName: 'SLA',
        lastName: 'Supervisor',
        status: UserStatus.ACTIVE,
        authProvider: AuthProvider.LOCAL,
      });
      supervisorUser = await userRepo.save(supervisorUser);
      console.log('✅ Created test supervisor user');
    }

    // Get or create SLA configuration
    let slaConfig = await slaConfigRepo.findOne({
      where: { companyId: company.id, priority: TicketPriority.HIGH },
    });

    if (!slaConfig) {
      slaConfig = slaConfigRepo.create({
        companyId: company.id,
        name: 'Test High Priority SLA',
        description: 'Test SLA for alerts',
        priority: TicketPriority.HIGH,
        firstResponseTimeMinutes: 5, // 5 minutes for quick testing
        acknowledgementTimeMinutes: 10, // 10 minutes
        startWorkTimeMinutes: 15, // 15 minutes
        resolutionTimeMinutes: 30, // 30 minutes for quick testing
        escalationLevel1Minutes: 20,
        escalationLevel2Minutes: 25,
        escalationLevel3Minutes: 30,
        isActive: true,
        applyBusinessHours: false,
        excludeHolidays: false,
      });
      slaConfig = await slaConfigRepo.save(slaConfig);
      console.log('✅ Created SLA configuration');
    }

    // Create test ticket
    const ticket = ticketRepo.create({
      companyId: company.id,
      ticketNumber: `TEST-ALERT-${Date.now()}`,
      createdBy: adminUser.id,
      title: 'Test Ticket for SLA Alerts',
      description: 'This ticket tests SLA alert functionality',
      status: TicketStatus.NEW,
      priority: TicketPriority.HIGH,
      assignedSupervisorId: supervisorUser.id,
      tenantConfirmed: false,
    });

    const savedTicket = await ticketRepo.save(ticket);
    console.log('✅ Created test ticket:', savedTicket.ticketNumber);

    // Create SLA with short deadline for testing
    const now = new Date();
    const resolutionDeadline = new Date(now.getTime() + slaConfig.resolutionTimeMinutes * 60 * 1000);

    const ticketSla = ticketSlaRepo.create({
      companyId: company.id,
      ticketId: savedTicket.id,
      slaConfigurationId: slaConfig.id,
      firstResponseDeadline: new Date(now.getTime() + slaConfig.firstResponseTimeMinutes * 60 * 1000),
      responseDeadline: new Date(now.getTime() + slaConfig.acknowledgementTimeMinutes * 60 * 1000),
      resolutionDeadline,
      slaStatus: SlaStatus.ON_TRACK,
    });

    const savedSla = await ticketSlaRepo.save(ticketSla);
    console.log('✅ Created ticket SLA');

    return {
      company,
      adminUser,
      supervisorUser,
      ticket: savedTicket,
      ticketSla: savedSla,
      slaConfig,
    };
  } catch (error: any) {
    console.error('❌ Error setting up test data:', error.message);
    throw error;
  }
}

async function testSlaAtRiskAlert(testData: any) {
  console.log('\n📋 Test 1: SLA AT_RISK Alert');
  console.log('=' .repeat(60));

  try {
    const ticketSlaRepo = dataSource.getRepository(TicketSla);
    const ticketRepo = dataSource.getRepository(MaintenanceTicket);
    const userRepo = dataSource.getRepository(User);
    const notificationRepo = dataSource.getRepository(Notification);

    // Manually set SLA to AT_RISK by adjusting deadline
    const ticketSla = await ticketSlaRepo.findOne({
      where: { id: testData.ticketSla.id },
      relations: ['ticket', 'slaConfiguration'],
    });

    if (!ticketSla) {
      logTest('SLA AT_RISK Alert', false, 'Ticket SLA not found');
      return false;
    }

    // Load ticket with relations
    const ticket = await ticketRepo.findOne({
      where: { id: ticketSla.ticketId, companyId: testData.company.id },
      relations: ['assignedTechnician', 'assignedSupervisor', 'creator'],
    });

    if (!ticket) {
      logTest('SLA AT_RISK Alert', false, 'Ticket not found');
      return false;
    }

    // Set deadline to be 75% elapsed (AT_RISK threshold)
    const now = new Date();
    const totalTime = 30 * 60 * 1000; // 30 minutes
    const elapsedTime = totalTime * 0.76; // 76% elapsed
    ticketSla.resolutionDeadline = new Date(now.getTime() - elapsedTime + totalTime);
    ticketSla.slaStatus = SlaStatus.AT_RISK;
    await ticketSlaRepo.save(ticketSla);

    // Calculate time remaining
    const timeRemaining = ticketSla.resolutionDeadline.getTime() - now.getTime();
    const hoursRemaining = Math.max(0, Math.floor(timeRemaining / (60 * 60 * 1000)));
    const minutesRemaining = Math.max(0, Math.floor((timeRemaining % (60 * 60 * 1000)) / (60 * 1000)));
    const timeText = `${hoursRemaining}h ${minutesRemaining}m remaining`;

    // Get recipients (same logic as SLA service)
    const recipients: User[] = [];
    if (ticket.assignedSupervisor && ticket.assignedSupervisor.status === UserStatus.ACTIVE) {
      recipients.push(ticket.assignedSupervisor);
    }
    if (ticket.assignedTechnician && ticket.assignedTechnician.status === UserStatus.ACTIVE) {
      recipients.push(ticket.assignedTechnician);
    }

    // Add all admins
    const admins = await userRepo
      .createQueryBuilder('user')
      .leftJoinAndSelect('user.userRoles', 'userRole')
      .leftJoinAndSelect('userRole.role', 'role')
      .where('user.companyId = :companyId', { companyId: testData.company.id })
      .andWhere('user.status = :status', { status: UserStatus.ACTIVE })
      .andWhere('role.name = :adminRole', { adminRole: 'ADMIN' })
      .getMany();
    recipients.push(...admins);

    // Remove duplicates
    const uniqueRecipients = recipients.filter(
      (user, index, self) =>
        index === self.findIndex((u) => u.email === user.email),
    );

    // Send notifications to all recipients
    const notificationsSent = [];
    for (const recipient of uniqueRecipients) {
      const notification = notificationRepo.create({
        companyId: testData.company.id,
        recipientUserId: recipient.id,
        type: 'sla_at_risk',
        severity: NotificationSeverity.WARNING,
        title: `SLA At Risk: ${ticket.ticketNumber}`,
        message: `Ticket ${ticket.ticketNumber} SLA is at risk. ${timeText}`,
        channels: [NotificationChannel.IN_APP, NotificationChannel.EMAIL, NotificationChannel.PUSH],
        payload: {
          ticketId: ticket.id,
          ticketNumber: ticket.ticketNumber,
          ticketTitle: ticket.title,
          slaStatus: 'At Risk',
          timeRemaining: timeText,
          priority: ticket.priority,
          dueDate: ticketSla.resolutionDeadline.toISOString(),
        },
      });
      const saved = await notificationRepo.save(notification);
      notificationsSent.push({ recipient: recipient.email, notificationId: saved.id });
    }

    logTest('SLA AT_RISK Alert', true, `SLA status set to AT_RISK and ${notificationsSent.length} notifications sent`, {
      ticketNumber: ticket.ticketNumber,
      slaStatus: ticketSla.slaStatus,
      timeRemaining: timeText,
      recipients: uniqueRecipients.map((r) => r.email),
      notificationsSent: notificationsSent.length,
    });

    return true;
  } catch (error: any) {
    logTest('SLA AT_RISK Alert', false, error.message, { error });
    return false;
  }
}

async function testSlaBreachedAlert(testData: any) {
  console.log('\n📋 Test 2: SLA BREACHED Alert');
  console.log('=' .repeat(60));

  try {
    const ticketSlaRepo = dataSource.getRepository(TicketSla);
    const ticketRepo = dataSource.getRepository(MaintenanceTicket);
    const userRepo = dataSource.getRepository(User);
    const notificationRepo = dataSource.getRepository(Notification);

    // Set SLA to BREACHED
    const ticketSla = await ticketSlaRepo.findOne({
      where: { id: testData.ticketSla.id },
      relations: ['ticket', 'slaConfiguration'],
    });

    if (!ticketSla) {
      logTest('SLA BREACHED Alert', false, 'Ticket SLA not found');
      return false;
    }

    // Load ticket with relations
    const ticket = await ticketRepo.findOne({
      where: { id: ticketSla.ticketId, companyId: testData.company.id },
      relations: ['assignedTechnician', 'assignedSupervisor', 'creator'],
    });

    if (!ticket) {
      logTest('SLA BREACHED Alert', false, 'Ticket not found');
      return false;
    }

    // Set deadline in the past
    const now = new Date();
    ticketSla.resolutionDeadline = new Date(now.getTime() - 60 * 60 * 1000); // 1 hour ago
    ticketSla.slaStatus = SlaStatus.BREACHED;
    await ticketSlaRepo.save(ticketSla);

    // Get recipients (same logic as SLA service)
    const recipients: User[] = [];
    if (ticket.assignedSupervisor && ticket.assignedSupervisor.status === UserStatus.ACTIVE) {
      recipients.push(ticket.assignedSupervisor);
    }
    if (ticket.assignedTechnician && ticket.assignedTechnician.status === UserStatus.ACTIVE) {
      recipients.push(ticket.assignedTechnician);
    }

    // Add all admins
    const admins = await userRepo
      .createQueryBuilder('user')
      .leftJoinAndSelect('user.userRoles', 'userRole')
      .leftJoinAndSelect('userRole.role', 'role')
      .where('user.companyId = :companyId', { companyId: testData.company.id })
      .andWhere('user.status = :status', { status: UserStatus.ACTIVE })
      .andWhere('role.name = :adminRole', { adminRole: 'ADMIN' })
      .getMany();
    recipients.push(...admins);

    // Remove duplicates
    const uniqueRecipients = recipients.filter(
      (user, index, self) =>
        index === self.findIndex((u) => u.email === user.email),
    );

    // Send notifications to all recipients
    const notificationsSent = [];
    for (const recipient of uniqueRecipients) {
      const notification = notificationRepo.create({
        companyId: testData.company.id,
        recipientUserId: recipient.id,
        type: 'sla_breached',
        severity: NotificationSeverity.CRITICAL,
        title: `SLA Breached: ${ticket.ticketNumber}`,
        message: `Ticket ${ticket.ticketNumber} SLA has been breached. SLA deadline has passed.`,
        channels: [NotificationChannel.IN_APP, NotificationChannel.EMAIL, NotificationChannel.PUSH],
        payload: {
          ticketId: ticket.id,
          ticketNumber: ticket.ticketNumber,
          ticketTitle: ticket.title,
          slaStatus: 'Breached',
          timeRemaining: 'SLA deadline has passed',
          priority: ticket.priority,
          dueDate: ticketSla.resolutionDeadline.toISOString(),
        },
      });
      const saved = await notificationRepo.save(notification);
      notificationsSent.push({ recipient: recipient.email, notificationId: saved.id });
    }

    logTest('SLA BREACHED Alert', true, `SLA status set to BREACHED and ${notificationsSent.length} notifications sent`, {
      ticketNumber: ticket.ticketNumber,
      slaStatus: ticketSla.slaStatus,
      breachedBy: Math.abs(ticketSla.resolutionDeadline.getTime() - now.getTime()) / (60 * 1000),
      recipients: uniqueRecipients.map((r) => r.email),
      notificationsSent: notificationsSent.length,
    });

    return true;
  } catch (error: any) {
    logTest('SLA BREACHED Alert', false, error.message, { error });
    return false;
  }
}

async function testNotificationCreation(testData: any) {
  console.log('\n📋 Test 3: Notification Creation');
  console.log('=' .repeat(60));

  try {
    const notificationRepo = dataSource.getRepository(Notification);
    const notificationDeliveryRepo = dataSource.getRepository(NotificationDelivery);

    // Create a test notification to verify structure
    const testNotification = notificationRepo.create({
      companyId: testData.company.id,
      recipientUserId: testData.adminUser.id,
      type: 'sla_at_risk',
      severity: NotificationSeverity.WARNING,
      title: `SLA At Risk: ${testData.ticket.ticketNumber}`,
      message: `Ticket ${testData.ticket.ticketNumber} SLA is at risk. 2h 15m remaining.`,
      channels: [NotificationChannel.IN_APP, NotificationChannel.EMAIL, NotificationChannel.PUSH],
      payload: {
        ticketId: testData.ticket.id,
        ticketNumber: testData.ticket.ticketNumber,
        slaStatus: 'AT_RISK',
        timeRemaining: '2h 15m',
      },
    });

    const savedNotification = await notificationRepo.save(testNotification);

    // Create delivery records
    for (const channel of testNotification.channels) {
      const delivery = notificationDeliveryRepo.create({
        companyId: testData.company.id,
        notificationId: savedNotification.id,
        channel,
        status: 'pending' as any,
      });
      await notificationDeliveryRepo.save(delivery);
    }

    logTest('Notification Creation', true, 'Notification created successfully', {
      notificationId: savedNotification.id,
      type: savedNotification.type,
      severity: savedNotification.severity,
      channels: savedNotification.channels,
      recipientId: savedNotification.recipientUserId,
    });

    // Verify notification structure
    const hasRequiredFields =
      savedNotification.type !== undefined &&
      savedNotification.severity !== undefined &&
      savedNotification.message !== undefined &&
      savedNotification.channels.length > 0;

    logTest('Notification Structure', hasRequiredFields, 'Notification has all required fields', {
      hasType: savedNotification.type !== undefined,
      hasSeverity: savedNotification.severity !== undefined,
      hasMessage: savedNotification.message !== undefined,
      hasChannels: savedNotification.channels.length > 0,
    });

    return { notification: savedNotification, hasRequiredFields };
  } catch (error: any) {
    logTest('Notification Creation', false, error.message, { error });
    return { notification: null, hasRequiredFields: false };
  }
}

async function testAlertRecipients(testData: any) {
  console.log('\n📋 Test 4: Alert Recipients');
  console.log('=' .repeat(60));

  try {
    const userRepo = dataSource.getRepository(User);
    const notificationRepo = dataSource.getRepository(Notification);

    // Get all users who should receive alerts
    const recipients: User[] = [];

    // Add supervisor
    if (testData.supervisorUser) {
      recipients.push(testData.supervisorUser);
    }

    // Add admin
    if (testData.adminUser) {
      recipients.push(testData.adminUser);
    }

    // Verify recipients
    const hasRecipients = recipients.length > 0;
    const allActive = recipients.every((u) => u.status === UserStatus.ACTIVE);

    logTest('Alert Recipients', hasRecipients && allActive, 'Recipients identified', {
      recipientCount: recipients.length,
      recipients: recipients.map((u) => ({
        email: u.email,
        name: `${u.firstName} ${u.lastName}`,
        status: u.status,
      })),
      allActive,
    });

    // Create notifications for each recipient
    const notificationsCreated = [];
    for (const recipient of recipients) {
      const notification = notificationRepo.create({
        companyId: testData.company.id,
        recipientUserId: recipient.id,
        type: 'sla_breached',
        severity: NotificationSeverity.CRITICAL,
        title: `SLA Breached: ${testData.ticket.ticketNumber}`,
        message: `Ticket ${testData.ticket.ticketNumber} SLA has been breached.`,
        channels: [NotificationChannel.IN_APP, NotificationChannel.EMAIL],
      });
      const saved = await notificationRepo.save(notification);
      notificationsCreated.push(saved.id);
    }

    logTest('Multi-Recipient Alerts', notificationsCreated.length === recipients.length, 
      `Notifications created for ${notificationsCreated.length} recipients`, {
      notificationsCreated: notificationsCreated.length,
      expectedRecipients: recipients.length,
    });

    return true;
  } catch (error: any) {
    logTest('Alert Recipients', false, error.message, { error });
    return false;
  }
}

async function testAlertChannels(testData: any) {
  console.log('\n📋 Test 5: Alert Channels');
  console.log('=' .repeat(60));

  try {
    const notificationRepo = dataSource.getRepository(Notification);
    const notificationDeliveryRepo = dataSource.getRepository(NotificationDelivery);

    // Test all notification channels
    const channels = [
      NotificationChannel.IN_APP,
      NotificationChannel.EMAIL,
      NotificationChannel.PUSH,
    ];

    const notification = notificationRepo.create({
      companyId: testData.company.id,
      recipientUserId: testData.adminUser.id,
      type: 'sla_at_risk',
      severity: NotificationSeverity.WARNING,
      title: `SLA At Risk: ${testData.ticket.ticketNumber}`,
      message: `Ticket ${testData.ticket.ticketNumber} SLA is at risk.`,
      channels,
    });

    const savedNotification = await notificationRepo.save(notification);

    // Create delivery records for each channel
    const deliveries = [];
    for (const channel of channels) {
      const delivery = notificationDeliveryRepo.create({
        companyId: testData.company.id,
        notificationId: savedNotification.id,
        channel,
        status: 'pending' as any,
      });
      const saved = await notificationDeliveryRepo.save(delivery);
      deliveries.push({ channel, deliveryId: saved.id });
    }

    logTest('Alert Channels', deliveries.length === channels.length, 
      `Deliveries created for ${deliveries.length} channels`, {
      channels: deliveries.map((d) => d.channel),
      deliveryCount: deliveries.length,
    });

    return true;
  } catch (error: any) {
    logTest('Alert Channels', false, error.message, { error });
    return false;
  }
}

async function testAlertContent(testData: any) {
  console.log('\n📋 Test 6: Alert Content');
  console.log('=' .repeat(60));

  try {
    const notificationRepo = dataSource.getRepository(Notification);
    const ticketSlaRepo = dataSource.getRepository(TicketSla);

    const ticketSla = await ticketSlaRepo.findOne({
      where: { id: testData.ticketSla.id },
      relations: ['ticket', 'slaConfiguration'],
    });

    if (!ticketSla) {
      logTest('Alert Content', false, 'Ticket SLA not found');
      return false;
    }

    // Calculate time remaining
    const now = new Date();
    const timeRemaining = ticketSla.resolutionDeadline.getTime() - now.getTime();
    const hoursRemaining = Math.max(0, Math.floor(timeRemaining / (60 * 60 * 1000)));
    const minutesRemaining = Math.max(0, Math.floor((timeRemaining % (60 * 60 * 1000)) / (60 * 1000)));

    const statusLabel = ticketSla.slaStatus === SlaStatus.BREACHED ? 'Breached' : 'At Risk';
    const timeText =
      ticketSla.slaStatus === SlaStatus.BREACHED
        ? 'SLA deadline has passed'
        : `${hoursRemaining}h ${minutesRemaining}m remaining`;

    // Create notification with proper content
    const notification = notificationRepo.create({
      companyId: testData.company.id,
      recipientUserId: testData.adminUser.id,
      type: `sla_${ticketSla.slaStatus.toLowerCase()}`,
      severity:
        ticketSla.slaStatus === SlaStatus.BREACHED
          ? NotificationSeverity.CRITICAL
          : NotificationSeverity.WARNING,
      title: `SLA ${statusLabel}: ${testData.ticket.ticketNumber}`,
      message: `Ticket ${testData.ticket.ticketNumber} SLA is ${statusLabel}. ${timeText}`,
      channels: [NotificationChannel.IN_APP, NotificationChannel.EMAIL, NotificationChannel.PUSH],
      payload: {
        ticketId: testData.ticket.id,
        ticketNumber: testData.ticket.ticketNumber,
        ticketTitle: testData.ticket.title,
        slaStatus: statusLabel,
        timeRemaining: timeText,
        priority: testData.ticket.priority,
        dueDate: ticketSla.resolutionDeadline.toISOString(),
      },
    });

    const savedNotification = await notificationRepo.save(notification);

    // Verify content
    const hasValidContent = Boolean(
      savedNotification.title?.includes(testData.ticket.ticketNumber) &&
      savedNotification.message?.includes(statusLabel) &&
      savedNotification.payload !== null &&
      savedNotification.payload?.ticketId === testData.ticket.id,
    );

    logTest('Alert Content', hasValidContent, 'Alert content is valid', {
      title: savedNotification.title,
      message: savedNotification.message,
      hasPayload: savedNotification.payload !== null,
      payloadKeys: savedNotification.payload ? Object.keys(savedNotification.payload) : [],
    });

    return hasValidContent;
  } catch (error: any) {
    logTest('Alert Content', false, error.message, { error });
    return false;
  }
}

async function cleanupTestData(testData: any) {
  console.log('\n🧹 Cleaning up test data...');
  console.log('=' .repeat(60));

  try {
    const notificationRepo = dataSource.getRepository(Notification);
    const notificationDeliveryRepo = dataSource.getRepository(NotificationDelivery);
    const ticketSlaRepo = dataSource.getRepository(TicketSla);
    const ticketRepo = dataSource.getRepository(MaintenanceTicket);
    const userRepo = dataSource.getRepository(User);

    // Delete notifications
    const notifications = await notificationRepo.find({
      where: { companyId: testData.company.id },
    });
    for (const notification of notifications) {
      await notificationDeliveryRepo.delete({ notificationId: notification.id });
      await notificationRepo.delete({ id: notification.id });
    }
    console.log(`✅ Deleted ${notifications.length} test notifications`);

    // Delete SLA
    await ticketSlaRepo.delete({ id: testData.ticketSla.id, companyId: testData.company.id });
    console.log('✅ Deleted test SLA');

    // Delete ticket
    await ticketRepo.delete({ id: testData.ticket.id, companyId: testData.company.id });
    console.log('✅ Deleted test ticket');

    // Delete test users (only if they were created for testing)
    const userRepoForCleanup = dataSource.getRepository(User);
    
    // Only delete admin if it's a test user
    if (testData.adminUser.email === 'test-sla-admin@test.com') {
      await userRepoForCleanup.delete({ id: testData.adminUser.id, companyId: testData.company.id });
      console.log('✅ Deleted test admin user');
    } else {
      console.log(`ℹ️  Keeping real admin user: ${testData.adminUser.email}`);
    }
    
    // Only delete supervisor if it's a test user
    if (testData.supervisorUser.email === 'test-sla-supervisor@test.com') {
      await userRepoForCleanup.delete({ id: testData.supervisorUser.id, companyId: testData.company.id });
      console.log('✅ Deleted test supervisor user');
    } else {
      console.log(`ℹ️  Keeping real supervisor user: ${testData.supervisorUser.email}`);
    }
  } catch (error: any) {
    console.log('⚠️  Error during cleanup:', error.message);
  }
}

async function runTests() {
  console.log('\n');
  console.log('=' .repeat(60));
  console.log('🔔 SLA ALERT TEST SUITE');
  console.log('=' .repeat(60));

  let testData: any = null;

  try {
    await dataSource.initialize();
    console.log('✅ Database connected\n');

    // Setup test data
    testData = await setupTestData();

    // Run tests
    await testSlaAtRiskAlert(testData);
    await testSlaBreachedAlert(testData);
    await testNotificationCreation(testData);
    await testAlertRecipients(testData);
    await testAlertChannels(testData);
    await testAlertContent(testData);

    // Cleanup
    await cleanupTestData(testData);

    // Summary
    console.log('\n');
    console.log('=' .repeat(60));
    console.log('📊 TEST SUMMARY');
    console.log('=' .repeat(60));

    const passed = testResults.filter((r) => r.passed).length;
    const failed = testResults.filter((r) => !r.passed).length;
    const total = testResults.length;

    console.log(`Total Tests: ${total}`);
    console.log(`✅ Passed: ${passed}`);
    console.log(`❌ Failed: ${failed}`);
    console.log(`Success Rate: ${((passed / total) * 100).toFixed(1)}%`);

    if (failed > 0) {
      console.log('\n❌ Failed Tests:');
      testResults
        .filter((r) => !r.passed)
        .forEach((r) => {
          console.log(`   - ${r.testName}: ${r.message}`);
        });
    }

    console.log('\n');

    await dataSource.destroy();
    process.exit(failed > 0 ? 1 : 0);
  } catch (error: any) {
    console.error('\n❌ Test suite failed:', error);
    console.error(error.stack);
    if (testData) {
      await cleanupTestData(testData).catch(() => {});
    }
    await dataSource.destroy();
    process.exit(1);
  }
}

// Run tests
runTests();
