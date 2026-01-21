import { DataSource } from 'typeorm';
import { User } from '../src/modules/iam/entities/user.entity';
import { MaintenanceTicket } from '../src/modules/maintenance-ticket/entities/maintenance-ticket.entity';
import { TicketStatus } from '../src/modules/maintenance-ticket/enums/ticket-status.enum';

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

async function queryUserTickets(email: string) {
  console.log(`\n🔍 Querying tickets for user: ${email}\n`);

  await dataSource.initialize();
  const queryRunner = dataSource.createQueryRunner();
  await queryRunner.connect();

  try {
    // Find user by email
    const user = await queryRunner.manager.findOne(User, {
      where: { email },
      relations: ['userRoles', 'userRoles.role'],
    });

    if (!user) {
      console.log(`❌ User not found with email: ${email}`);
      return;
    }

    console.log('📋 User Information:');
    console.log(`   ID: ${user.id}`);
    console.log(`   Name: ${user.firstName} ${user.lastName || ''}`.trim());
    console.log(`   Email: ${user.email}`);
    console.log(`   Villa Number: ${user.villaNumber ?? 'Not set'}`);
    console.log(`   Company ID: ${user.companyId}`);
    console.log(`   Status: ${user.status}`);
    
    if (user.userRoles && user.userRoles.length > 0) {
      const roles = user.userRoles.map(ur => ur.role?.name || 'Unknown').join(', ');
      console.log(`   Roles: ${roles}`);
    }

    if (!user.villaNumber) {
      console.log(`\n⚠️  User does not have a villa number assigned. Cannot query tickets.`);
      return;
    }

    // Query tickets for this villa number
    const tickets = await queryRunner.manager.find(MaintenanceTicket, {
      where: {
        companyId: user.companyId,
        villaNumber: user.villaNumber,
      },
      relations: [
        'creator',
        'department',
        'category',
        'assignedSupervisor',
        'assignedTechnician',
        'assigner',
        'acknowledger',
      ],
      order: {
        createdAt: 'DESC',
      },
    });

    console.log(`\n🎫 Tickets for Villa ${user.villaNumber}:`);
    console.log(`   Total Tickets: ${tickets.length}\n`);

    if (tickets.length === 0) {
      console.log('   No tickets found for this villa.\n');
      return;
    }

    // Group tickets by status
    const ticketsByStatus = tickets.reduce((acc, ticket) => {
      const status = ticket.status || 'UNKNOWN';
      if (!acc[status]) {
        acc[status] = [];
      }
      acc[status].push(ticket);
      return acc;
    }, {} as Record<string, MaintenanceTicket[]>);

    console.log('📊 Tickets by Status:');
    Object.entries(ticketsByStatus).forEach(([status, statusTickets]) => {
      console.log(`   ${status}: ${statusTickets.length}`);
    });

    console.log('\n📝 Ticket Details:\n');
    console.log('═'.repeat(100));

    tickets.forEach((ticket, index) => {
      console.log(`\n${index + 1}. Ticket #${ticket.ticketNumber}`);
      console.log(`   ID: ${ticket.id}`);
      console.log(`   Title: ${ticket.title}`);
      console.log(`   Status: ${ticket.status}`);
      console.log(`   Priority: ${ticket.priority}`);
      console.log(`   Villa Number: ${ticket.villaNumber}`);
      console.log(`   Created: ${ticket.createdAt ? new Date(ticket.createdAt).toLocaleString() : 'N/A'}`);
      console.log(`   Updated: ${ticket.updatedAt ? new Date(ticket.updatedAt).toLocaleString() : 'N/A'}`);
      
      if (ticket.description) {
        const desc = ticket.description.length > 100 
          ? ticket.description.substring(0, 100) + '...' 
          : ticket.description;
        console.log(`   Description: ${desc}`);
      }

      if (ticket.creator) {
        console.log(`   Created By: ${ticket.creator.firstName} ${ticket.creator.lastName || ''} (${ticket.creator.email})`.trim());
      }

      if (ticket.department) {
        console.log(`   Department: ${ticket.department.name}`);
      }

      if (ticket.category) {
        console.log(`   Category: ${ticket.category.name}`);
      }

      if (ticket.assignedTechnician) {
        console.log(`   Assigned Technician: ${ticket.assignedTechnician.firstName} ${ticket.assignedTechnician.lastName || ''} (${ticket.assignedTechnician.email})`.trim());
      }

      if (ticket.assignedSupervisor) {
        console.log(`   Assigned Supervisor: ${ticket.assignedSupervisor.firstName} ${ticket.assignedSupervisor.lastName || ''} (${ticket.assignedSupervisor.email})`.trim());
      }

      if (ticket.contactNumber) {
        console.log(`   Contact Number: ${ticket.contactNumber}`);
      }

      if (ticket.alternateContact) {
        console.log(`   Alternate Contact: ${ticket.alternateContact}`);
      }

      if (ticket.preferredTime) {
        console.log(`   Preferred Time: ${ticket.preferredTime}`);
      }

      if (ticket.isEscalated) {
        console.log(`   ⚠️  ESCALATED`);
      }

      if (ticket.autoCloseAt) {
        const autoCloseDate = new Date(ticket.autoCloseAt);
        const now = new Date();
        if (autoCloseDate < now && !['COMPLETED', 'CANCELLED'].includes(ticket.status || '')) {
          console.log(`   ⏰ OVERDUE (Auto-close: ${autoCloseDate.toLocaleString()})`);
        } else {
          console.log(`   Auto-close: ${autoCloseDate.toLocaleString()}`);
        }
      }

      console.log('─'.repeat(100));
    });

    console.log('\n✅ Query completed.\n');

  } catch (error) {
    console.error('❌ Error querying tickets:', error);
    throw error;
  } finally {
    await queryRunner.release();
    await dataSource.destroy();
  }
}

// Get email from command line argument or use default
const email = process.argv[2] || 'villa86@tenant.com';

queryUserTickets(email)
  .then(() => {
    console.log('Script completed successfully.');
    process.exit(0);
  })
  .catch((error) => {
    console.error('Script failed:', error);
    process.exit(1);
  });

