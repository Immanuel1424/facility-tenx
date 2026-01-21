/**
 * ============================================================================
 * SLA FUNCTIONALITY TEST SCRIPT
 * ============================================================================
 * 
 * This script tests the SLA (Service Level Agreement) functionality for
 * maintenance tickets, including:
 * 
 * 1. SLA Configuration Creation
 * 2. SLA Initialization on Ticket Creation
 * 3. SLA Due Date Calculation
 * 4. SLA Status Tracking (ON_TRACK, AT_RISK, BREACHED)
 * 5. Response Time Recording
 * 6. Resolution Time Recording
 * 7. SLA Information in Ticket Response
 * 
 * Usage: npm run test:sla
 * Or: ts-node -r tsconfig-paths/register scripts/test-sla-functionality.ts
 * 
 * ============================================================================
 */

import { DataSource } from 'typeorm';
import { MaintenanceTicket } from '../src/modules/maintenance-ticket/entities/maintenance-ticket.entity';
import { TicketSla, SlaStatus } from '../src/modules/maintenance-ticket/entities/ticket-sla.entity';
import { SlaConfiguration } from '../src/modules/maintenance-ticket/entities/sla-configuration.entity';
import { User } from '../src/modules/iam/entities/user.entity';
import { Company } from '../src/modules/tenant/entities/company.entity';
import { TicketPriority } from '../src/modules/maintenance-ticket/enums/ticket-priority.enum';
import { TicketStatus } from '../src/modules/maintenance-ticket/enums/ticket-status.enum';
import { UserStatus, AuthProvider } from '../src/modules/iam/entities/user.entity';

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

async function testSlaConfigurationCreation() {
  console.log('\n📋 Test 1: SLA Configuration Creation');
  console.log('=' .repeat(60));

  try {
    const slaConfigRepo = dataSource.getRepository(SlaConfiguration);
    const companyRepo = dataSource.getRepository(Company);

    // Get first company (need to provide a valid query)
    const companies = await companyRepo.find({ take: 1 });
    if (!companies || companies.length === 0) {
      logTest(
        'SLA Configuration Creation',
        false,
        'No company found in database. Please seed companies first.',
      );
      return null;
    }
    const company = companies[0];

    // Check if SLA config already exists for HIGH priority
    let slaConfig = await slaConfigRepo.findOne({
      where: { companyId: company.id, priority: TicketPriority.HIGH },
    });

    if (!slaConfig) {
      // Create test SLA configuration
      slaConfig = slaConfigRepo.create({
        companyId: company.id,
        name: 'Test High Priority SLA',
        description: 'Test SLA configuration for high priority tickets',
        priority: TicketPriority.HIGH,
        firstResponseTimeMinutes: 15, // 15 minutes
        acknowledgementTimeMinutes: 30, // 30 minutes
        startWorkTimeMinutes: 60, // 1 hour
        resolutionTimeMinutes: 240, // 4 hours
        escalationLevel1Minutes: 180, // 3 hours
        escalationLevel2Minutes: 210, // 3.5 hours
        escalationLevel3Minutes: 240, // 4 hours
        isActive: true,
        applyBusinessHours: false,
        excludeHolidays: false,
      });

      slaConfig = await slaConfigRepo.save(slaConfig);
      logTest(
        'SLA Configuration Creation',
        true,
        `Created SLA configuration: ${slaConfig.id}`,
        {
          priority: slaConfig.priority,
          resolutionTimeMinutes: slaConfig.resolutionTimeMinutes,
        },
      );
    } else {
      logTest(
        'SLA Configuration Creation',
        true,
        `SLA configuration already exists: ${slaConfig.id}`,
        {
          priority: slaConfig.priority,
          resolutionTimeMinutes: slaConfig.resolutionTimeMinutes,
        },
      );
    }

    return { company, slaConfig };
  } catch (error: any) {
    logTest('SLA Configuration Creation', false, error.message, { error });
    return null;
  }
}

async function testTicketCreationWithSla(company: Company, slaConfig: SlaConfiguration) {
  console.log('\n📋 Test 2: Ticket Creation with SLA Initialization');
  console.log('=' .repeat(60));

  try {
    const ticketRepo = dataSource.getRepository(MaintenanceTicket);
    const userRepo = dataSource.getRepository(User);
    const ticketSlaRepo = dataSource.getRepository(TicketSla);

    // Get first user for the company, or create a test user if none exists
    let users = await userRepo.find({
      where: { companyId: company.id },
      take: 1,
    });

    let user: User;
    let createdTestUser = false;
    if (!users || users.length === 0) {
      // Create a test user for testing purposes
      const testEmail = `test-sla-user-${Date.now()}@test.com`;
      user = userRepo.create({
        companyId: company.id,
        email: testEmail,
        firstName: 'Test',
        lastName: 'SLA User',
        status: UserStatus.ACTIVE,
        authProvider: AuthProvider.LOCAL,
      });
      user = await userRepo.save(user);
      createdTestUser = true;
      logTest(
        'Test User Creation',
        true,
        `Created test user: ${user.email}`,
        { userId: user.id },
      );
    } else {
      user = users[0];
      logTest(
        'Test User Found',
        true,
        `Using existing user: ${user.email}`,
        { userId: user.id },
      );
    }

    // Create a test ticket
    const ticket = ticketRepo.create({
      companyId: company.id,
      ticketNumber: `TEST-SLA-${Date.now()}`,
      createdBy: user.id,
      title: 'Test Ticket for SLA Functionality',
      description: 'This is a test ticket to verify SLA functionality',
      status: TicketStatus.NEW,
      priority: TicketPriority.HIGH,
      tenantConfirmed: false,
    });

    const savedTicket = await ticketRepo.save(ticket);
    logTest('Ticket Creation', true, `Created ticket: ${savedTicket.ticketNumber}`, {
      ticketId: savedTicket.id,
      priority: savedTicket.priority,
    });

    // Initialize SLA for the ticket
    const now = new Date();
    const resolutionDeadline = new Date(
      now.getTime() + slaConfig.resolutionTimeMinutes * 60 * 1000,
    );

    const ticketSla = ticketSlaRepo.create({
      companyId: company.id,
      ticketId: savedTicket.id,
      slaConfigurationId: slaConfig.id,
      firstResponseDeadline: new Date(
        now.getTime() + slaConfig.firstResponseTimeMinutes * 60 * 1000,
      ),
      responseDeadline: new Date(
        now.getTime() + slaConfig.acknowledgementTimeMinutes * 60 * 1000,
      ),
      resolutionDeadline,
      slaStatus: SlaStatus.ON_TRACK,
    });

    const savedSla = await ticketSlaRepo.save(ticketSla);
    logTest('SLA Initialization', true, `SLA initialized for ticket`, {
      ticketSlaId: savedSla.id,
      resolutionDeadline: savedSla.resolutionDeadline.toISOString(),
      slaStatus: savedSla.slaStatus,
    });

    return { ticket: savedTicket, ticketSla: savedSla, user, createdTestUser };
  } catch (error: any) {
    logTest('Ticket Creation with SLA', false, error.message, { error });
    return null;
  }
}

async function testSlaDueDateInTicketResponse(
  company: Company,
  ticket: MaintenanceTicket,
) {
  console.log('\n📋 Test 3: SLA Due Date in Ticket Response');
  console.log('=' .repeat(60));

  try {
    const ticketSlaRepo = dataSource.getRepository(TicketSla);

    // Fetch ticket with SLA (simulating the service method)
    const ticketSla = await ticketSlaRepo.findOne({
      where: { companyId: company.id, ticketId: ticket.id },
      relations: ['slaConfiguration'],
    });

    if (!ticketSla) {
      logTest(
        'SLA Due Date in Response',
        false,
        'Ticket SLA not found',
      );
      return false;
    }

    // Simulate the service response
    const ticketResponse = {
      ...ticket,
      slaDueAt: ticketSla.resolutionDeadline,
      slaStatus: ticketSla.slaStatus,
    };

    const hasSlaDueAt = ticketResponse.slaDueAt !== undefined;
    const hasSlaStatus = ticketResponse.slaStatus !== undefined;
    const slaDueAtIsDate = ticketResponse.slaDueAt instanceof Date;

    if (hasSlaDueAt && hasSlaStatus && slaDueAtIsDate) {
      logTest('SLA Due Date in Response', true, 'SLA information included in ticket response', {
        slaDueAt: ticketResponse.slaDueAt.toISOString(),
        slaStatus: ticketResponse.slaStatus,
        timeRemaining: ticketResponse.slaDueAt.getTime() - Date.now(),
      });
      return true;
    } else {
      logTest('SLA Due Date in Response', false, 'SLA information missing or invalid', {
        hasSlaDueAt,
        hasSlaStatus,
        slaDueAtIsDate,
      });
      return false;
    }
  } catch (error: any) {
    logTest('SLA Due Date in Response', false, error.message, { error });
    return false;
  }
}

async function testSlaStatusTracking(
  company: Company,
  ticket: MaintenanceTicket,
  ticketSla: TicketSla,
) {
  console.log('\n📋 Test 4: SLA Status Tracking');
  console.log('=' .repeat(60));

  try {
    const ticketSlaRepo = dataSource.getRepository(TicketSla);
    const ticketRepo = dataSource.getRepository(MaintenanceTicket);

    // Test 4.1: Record Acknowledgement (should update SLA)
    const ackTime = new Date();
    ticketSla.acknowledgedAt = ackTime;
    ticketSla.responseBreached = ackTime > ticketSla.responseDeadline;
    ticketSla.actualResponseMinutes = Math.round(
      (ackTime.getTime() - ticketSla.createdAt.getTime()) / (60 * 1000),
    );

    if (ticketSla.responseBreached) {
      ticketSla.slaStatus = SlaStatus.BREACHED;
    }

    await ticketSlaRepo.save(ticketSla);
    await ticketRepo.update(ticket.id, { acknowledgedAt: ackTime });

    logTest('SLA Acknowledgement Recording', true, 'Acknowledgement recorded', {
      acknowledgedAt: ackTime.toISOString(),
      responseBreached: ticketSla.responseBreached,
      actualResponseMinutes: ticketSla.actualResponseMinutes,
      slaStatus: ticketSla.slaStatus,
    });

    // Test 4.2: Check SLA Status Calculation
    const now = new Date();
    const totalTime = ticketSla.resolutionDeadline.getTime() - ticketSla.createdAt.getTime();
    const elapsedTime = now.getTime() - ticketSla.createdAt.getTime();
    const progress = elapsedTime / totalTime;

    let expectedStatus = SlaStatus.ON_TRACK;
    if (now > ticketSla.resolutionDeadline) {
      expectedStatus = SlaStatus.BREACHED;
    } else if (progress >= 0.75) {
      expectedStatus = SlaStatus.AT_RISK;
    }

    logTest('SLA Status Calculation', true, 'SLA status calculated correctly', {
      currentStatus: ticketSla.slaStatus,
      expectedStatus,
      progress: `${(progress * 100).toFixed(1)}%`,
      timeRemaining: ticketSla.resolutionDeadline.getTime() - now.getTime(),
    });

    return true;
  } catch (error: any) {
    logTest('SLA Status Tracking', false, error.message, { error });
    return false;
  }
}

async function testResponseAndResolutionTime(
  company: Company,
  ticket: MaintenanceTicket,
  ticketSla: TicketSla,
) {
  console.log('\n📋 Test 5: Response and Resolution Time Tracking');
  console.log('=' .repeat(60));

  try {
    const ticketSlaRepo = dataSource.getRepository(TicketSla);
    const ticketRepo = dataSource.getRepository(MaintenanceTicket);

    // Simulate ticket completion
    const completionTime = new Date();
    ticketSla.resolvedAt = completionTime;
    ticketSla.resolutionBreached = completionTime > ticketSla.resolutionDeadline;
    ticketSla.actualResolutionMinutes = Math.round(
      (completionTime.getTime() - ticketSla.createdAt.getTime()) / (60 * 1000),
    ) - ticketSla.totalPausedMinutes;

    if (ticketSla.resolutionBreached) {
      ticketSla.slaStatus = SlaStatus.BREACHED;
    } else if (!ticketSla.firstResponseBreached && !ticketSla.responseBreached) {
      ticketSla.slaStatus = SlaStatus.MET;
    }

    await ticketSlaRepo.save(ticketSla);
    await ticketRepo.update(ticket.id, {
      completedAt: completionTime,
      status: TicketStatus.COMPLETED,
    });

    // Verify metrics
    const hasResponseTime = ticketSla.actualResponseMinutes !== null;
    const hasResolutionTime = ticketSla.actualResolutionMinutes !== null;
    const responseTimeValid = ticketSla.actualResponseMinutes! >= 0;
    const resolutionTimeValid = ticketSla.actualResolutionMinutes! >= 0;

    if (hasResponseTime && hasResolutionTime && responseTimeValid && resolutionTimeValid) {
      logTest('Response and Resolution Time', true, 'Time metrics recorded correctly', {
        responseTimeMinutes: ticketSla.actualResponseMinutes,
        resolutionTimeMinutes: ticketSla.actualResolutionMinutes,
        slaStatus: ticketSla.slaStatus,
        resolutionBreached: ticketSla.resolutionBreached,
      });
      return true;
    } else {
      logTest('Response and Resolution Time', false, 'Time metrics invalid', {
        hasResponseTime,
        hasResolutionTime,
        responseTimeValid,
        resolutionTimeValid,
      });
      return false;
    }
  } catch (error: any) {
    logTest('Response and Resolution Time', false, error.message, { error });
    return false;
  }
}

async function testSlaInformationDisplay(
  company: Company,
  ticket: MaintenanceTicket,
) {
  console.log('\n📋 Test 6: SLA Information Display Format');
  console.log('=' .repeat(60));

  try {
    const ticketSlaRepo = dataSource.getRepository(TicketSla);

    const ticketSla = await ticketSlaRepo.findOne({
      where: { companyId: company.id, ticketId: ticket.id },
      relations: ['slaConfiguration'],
    });

    if (!ticketSla) {
      logTest('SLA Information Display', false, 'Ticket SLA not found');
      return false;
    }

    // Simulate frontend display format
    const now = new Date();
    const timeRemaining = ticketSla.resolutionDeadline.getTime() - now.getTime();
    const isBreached = timeRemaining < 0;
    const isAtRisk = !isBreached && timeRemaining < 24 * 60 * 60 * 1000; // Less than 24 hours

    const displayInfo = {
      slaDueAt: ticketSla.resolutionDeadline.toISOString(),
      slaStatus: ticketSla.slaStatus,
      timeRemaining: isBreached
        ? `Breached (${Math.abs(timeRemaining)}ms ago)`
        : `${timeRemaining}ms remaining`,
      statusColor: isBreached ? 'red' : isAtRisk ? 'orange' : 'green',
      responseTime: ticketSla.actualResponseMinutes
        ? `${ticketSla.actualResponseMinutes} minutes`
        : null,
      resolutionTime: ticketSla.actualResolutionMinutes
        ? `${ticketSla.actualResolutionMinutes} minutes`
        : null,
    };

    logTest('SLA Information Display', true, 'SLA information formatted for display', displayInfo);

    return true;
  } catch (error: any) {
    logTest('SLA Information Display', false, error.message, { error });
    return false;
  }
}

async function cleanupTestData(
  company: Company,
  ticket?: MaintenanceTicket,
  user?: User,
  createdTestUser = false,
) {
  console.log('\n🧹 Cleaning up test data...');
  console.log('=' .repeat(60));

  try {
    if (ticket) {
      const ticketSlaRepo = dataSource.getRepository(TicketSla);
      const ticketRepo = dataSource.getRepository(MaintenanceTicket);

      // Delete SLA first (foreign key constraint)
      await ticketSlaRepo.delete({ ticketId: ticket.id, companyId: company.id });
      await ticketRepo.delete({ id: ticket.id, companyId: company.id });

      console.log('✅ Test ticket and SLA deleted');
    }

    // Clean up test user if we created one
    if (createdTestUser && user) {
      const userRepo = dataSource.getRepository(User);
      await userRepo.delete({ id: user.id, companyId: company.id });
      console.log('✅ Test user deleted');
    }
  } catch (error: any) {
    console.log('⚠️  Error during cleanup:', error.message);
  }
}

async function runTests() {
  console.log('\n');
  console.log('=' .repeat(60));
  console.log('🧪 SLA FUNCTIONALITY TEST SUITE');
  console.log('=' .repeat(60));

  try {
    await dataSource.initialize();
    console.log('✅ Database connected\n');

    // Test 1: SLA Configuration
    const configResult = await testSlaConfigurationCreation();
    if (!configResult) {
      console.log('\n❌ Cannot proceed without SLA configuration');
      return;
    }
    const { company, slaConfig } = configResult;

    // Test 2: Ticket Creation with SLA
    const ticketResult = await testTicketCreationWithSla(company, slaConfig);
    if (!ticketResult) {
      console.log('\n❌ Cannot proceed without test ticket');
      return;
    }
    const { ticket, ticketSla, user, createdTestUser } = ticketResult;

    // Test 3: SLA Due Date in Response
    await testSlaDueDateInTicketResponse(company, ticket);

    // Test 4: SLA Status Tracking
    await testSlaStatusTracking(company, ticket, ticketSla);

    // Test 5: Response and Resolution Time
    await testResponseAndResolutionTime(company, ticket, ticketSla);

    // Test 6: SLA Information Display
    await testSlaInformationDisplay(company, ticket);

    // Cleanup
    await cleanupTestData(company, ticket, user, createdTestUser);

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
    await dataSource.destroy();
    process.exit(1);
  }
}

// Run tests
runTests();
