import { NestFactory } from '@nestjs/core';
import { AppModule } from '../src/app.module';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { MaintenanceTicket } from '../src/modules/maintenance-ticket/entities/maintenance-ticket.entity';
import { TicketStatus } from '../src/modules/maintenance-ticket/enums/ticket-status.enum';
import { Company } from '../src/modules/tenant/entities/company.entity';
import { User } from '../src/modules/iam/entities/user.entity';

async function checkTicketStatuses() {
  const app = await NestFactory.createApplicationContext(AppModule);
  
  const ticketRepo = app.get<Repository<MaintenanceTicket>>(
    getRepositoryToken(MaintenanceTicket),
  );
  const companyRepo = app.get<Repository<Company>>(
    getRepositoryToken(Company),
  );
  const userRepo = app.get<Repository<User>>(
    getRepositoryToken(User),
  );

  try {
    // Find the company by code
    const companyCode = 'COMP1051';
    const company = await companyRepo.findOne({
      where: { code: companyCode },
    });

    if (!company) {
      console.error(`Company with code ${companyCode} not found`);
      process.exit(1);
    }

    console.log(`\n=== Company: ${company.name} (${company.code}) ===`);
    console.log(`Company ID: ${company.id}\n`);

    // Find the admin user
    const adminEmail = 'admin.com0001@comp1051.com';
    const adminUser = await userRepo.findOne({
      where: { email: adminEmail, companyId: company.id },
    });

    if (!adminUser) {
      console.error(`Admin user ${adminEmail} not found`);
      process.exit(1);
    }

    console.log(`Admin User: ${adminUser.email}`);
    console.log(`User ID: ${adminUser.id}\n`);

    // Get all tickets for this company
    const allTickets = await ticketRepo.find({
      where: { companyId: company.id },
      select: ['id', 'ticketNumber', 'status', 'title', 'createdAt'],
      order: { createdAt: 'DESC' },
    });

    console.log(`\n=== Total Tickets: ${allTickets.length} ===\n`);

    // Group by status
    const statusCounts: Record<string, number> = {};
    allTickets.forEach((ticket) => {
      statusCounts[ticket.status] = (statusCounts[ticket.status] || 0) + 1;
    });

    console.log('=== Status Distribution ===');
    Object.entries(statusCounts).forEach(([status, count]) => {
      console.log(`${status}: ${count}`);
    });

    // Show ON_HOLD tickets specifically
    const onHoldTickets = allTickets.filter(
      (t) => t.status === TicketStatus.ON_HOLD,
    );
    
    console.log(`\n=== ON_HOLD Tickets: ${onHoldTickets.length} ===`);
    if (onHoldTickets.length > 0) {
      onHoldTickets.forEach((ticket) => {
        console.log(
          `  - ${ticket.ticketNumber}: ${ticket.title} (Created: ${ticket.createdAt})`,
        );
      });
    }

    // Show NEW tickets
    const newTickets = allTickets.filter((t) => t.status === TicketStatus.NEW);
    console.log(`\n=== NEW Tickets: ${newTickets.length} ===`);
    if (newTickets.length > 0) {
      newTickets.forEach((ticket) => {
        console.log(
          `  - ${ticket.ticketNumber}: ${ticket.title} (Created: ${ticket.createdAt})`,
        );
      });
    }

    // Verify the dashboard query
    console.log(`\n=== Verifying Dashboard Query ===`);
    const onHoldCount = await ticketRepo
      .createQueryBuilder('ticket')
      .where('ticket.companyId = :companyId', { companyId: company.id })
      .andWhere('ticket.status = :status', { status: TicketStatus.ON_HOLD })
      .getCount();
    
    console.log(`ON_HOLD count from query: ${onHoldCount}`);
    console.log(`ON_HOLD count from array: ${onHoldTickets.length}`);
    
    if (onHoldCount !== onHoldTickets.length) {
      console.error(
        `\n⚠️  MISMATCH: Query count (${onHoldCount}) != Array count (${onHoldTickets.length})`,
      );
    }

    // Check pending (NEW + ON_HOLD)
    const pendingCount = await ticketRepo
      .createQueryBuilder('ticket')
      .where('ticket.companyId = :companyId', { companyId: company.id })
      .andWhere('ticket.status IN (:...statuses)', {
        statuses: [TicketStatus.NEW, TicketStatus.ON_HOLD],
      })
      .getCount();
    
    console.log(`Pending (NEW + ON_HOLD) count: ${pendingCount}`);
    console.log(
      `Expected: ${newTickets.length} + ${onHoldTickets.length} = ${newTickets.length + onHoldTickets.length}`,
    );

    console.log('\n✅ Check complete!\n');
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  } finally {
    await app.close();
  }
}

checkTicketStatuses();

