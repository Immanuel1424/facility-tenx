/**
 * ============================================================================
 * SEND SLA ALERT TO ADMIN
 * ============================================================================
 * 
 * This script sends a test SLA alert directly to admin.com0001@comp1051.com
 * 
 * Usage: npm run send-sla-alert
 * Or: ts-node -r tsconfig-paths/register scripts/send-sla-alert-to-admin.ts
 * 
 * ============================================================================
 */

import { DataSource } from 'typeorm';
import { User } from '../src/modules/iam/entities/user.entity';
import { Company } from '../src/modules/tenant/entities/company.entity';
import { Notification } from '../src/modules/notification/entities/notification.entity';
import { NotificationDelivery } from '../src/modules/notification/entities/notification-delivery.entity';
import { NotificationSeverity } from '../src/modules/notification/enums/notification-severity.enum';
import { NotificationChannel } from '../src/modules/notification/enums/notification-channel.enum';
import { UserStatus } from '../src/modules/iam/entities/user.entity';

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

async function sendAlertToAdmin() {
  console.log('\n');
  console.log('=' .repeat(60));
  console.log('🔔 SENDING SLA ALERT TO ADMIN');
  console.log('=' .repeat(60));

  try {
    await dataSource.initialize();
    console.log('✅ Database connected\n');

    const companyRepo = dataSource.getRepository(Company);
    const userRepo = dataSource.getRepository(User);
    const notificationRepo = dataSource.getRepository(Notification);
    const notificationDeliveryRepo = dataSource.getRepository(NotificationDelivery);

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
    console.log(`📋 Using company: ${company.name} (${company.id})\n`);

    // Find admin user by email (case-insensitive)
    const allUsers = await userRepo.find({
      where: { companyId: company.id },
    });

    console.log(`📋 Found ${allUsers.length} users in company\n`);

    // Try exact match first
    let adminUser = allUsers.find(
      (u) => u.email?.toLowerCase() === 'admin.com0001@comp1051.com'.toLowerCase(),
    );

    // If not found, try partial match
    if (!adminUser) {
      adminUser = allUsers.find(
        (u) => u.email?.toLowerCase().includes('admin.com0001'),
      );
    }

    // If still not found, try to find any admin by role
    if (!adminUser) {
      const admins = await userRepo
        .createQueryBuilder('user')
        .leftJoinAndSelect('user.userRoles', 'userRole')
        .leftJoinAndSelect('userRole.role', 'role')
        .where('user.companyId = :companyId', { companyId: company.id })
        .andWhere('user.status = :status', { status: UserStatus.ACTIVE })
        .andWhere('role.name = :adminRole', { adminRole: 'ADMIN' })
        .getMany();
      
      if (admins && admins.length > 0) {
        adminUser = admins[0];
        console.log(`✅ Found admin user by role: ${adminUser.email}`);
      }
    }

    if (!adminUser) {
      console.log('❌ Admin user not found!');
      console.log('\n📋 Available users:');
      allUsers.forEach((u) => {
        console.log(`   - ${u.email} (${u.firstName} ${u.lastName}) - Status: ${u.status}`);
      });
      throw new Error('Admin user admin.com0001@comp1051.com not found');
    }

    console.log(`✅ Found admin user: ${adminUser.email} (${adminUser.firstName} ${adminUser.lastName})\n`);

    // Create test SLA alert notification
    const notification = notificationRepo.create({
      companyId: company.id,
      recipientUserId: adminUser.id,
      type: 'sla_breached',
      severity: NotificationSeverity.CRITICAL,
      title: 'SLA Breached: TEST-TICKET-001',
      message: 'Ticket TEST-TICKET-001 SLA has been breached. SLA deadline has passed.',
      channels: [NotificationChannel.IN_APP, NotificationChannel.EMAIL, NotificationChannel.PUSH],
      payload: {
        ticketId: 'test-ticket-id',
        ticketNumber: 'TEST-TICKET-001',
        ticketTitle: 'Test Ticket for SLA Alert',
        slaStatus: 'Breached',
        timeRemaining: 'SLA deadline has passed',
        priority: 'HIGH',
        dueDate: new Date().toISOString(),
      },
    });

    const savedNotification = await notificationRepo.save(notification);
    console.log(`✅ Created notification: ${savedNotification.id}`);

    // Create delivery records for each channel
    const deliveries = [];
    for (const channel of notification.channels) {
      const delivery = notificationDeliveryRepo.create({
        companyId: company.id,
        notificationId: savedNotification.id,
        channel,
        status: 'pending' as any,
      });
      const saved = await notificationDeliveryRepo.save(delivery);
      deliveries.push({ channel, deliveryId: saved.id });
    }

    console.log(`✅ Created ${deliveries.length} delivery records`);
    console.log('\n📋 Delivery Channels:');
    deliveries.forEach((d) => {
      console.log(`   - ${d.channel}: ${d.deliveryId}`);
    });

    console.log('\n');
    console.log('=' .repeat(60));
    console.log('✅ SUCCESS');
    console.log('=' .repeat(60));
    console.log(`Notification sent to: ${adminUser.email}`);
    console.log(`Notification ID: ${savedNotification.id}`);
    console.log(`Channels: ${notification.channels.join(', ')}`);
    console.log('\n');

    await dataSource.destroy();
    process.exit(0);
  } catch (error: any) {
    console.error('\n❌ Error:', error.message);
    console.error(error.stack);
    await dataSource.destroy();
    process.exit(1);
  }
}

// Run
sendAlertToAdmin();
