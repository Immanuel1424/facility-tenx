import { DataSource } from 'typeorm';
import { SlaConfiguration } from '../src/modules/maintenance-ticket/entities/sla-configuration.entity';
import { TicketPriority } from '../src/modules/maintenance-ticket/enums/ticket-priority.enum';
import { Company } from '../src/modules/tenant/entities/company.entity';
import { User } from '../src/modules/iam/entities/user.entity';

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

// SLA Configuration templates for each priority
const SLA_CONFIGURATIONS = [
  {
    name: 'Low Priority SLA',
    description: 'Standard SLA for low priority maintenance tickets',
    priority: TicketPriority.LOW,
    firstResponseTimeMinutes: 240, // 4 hours
    acknowledgementTimeMinutes: 480, // 8 hours
    resolutionTimeMinutes: 2880, // 48 hours (2 days)
    escalationLevel1Minutes: 1440, // 24 hours - Escalate to Supervisor
    escalationLevel2Minutes: 2160, // 36 hours - Escalate to Site Coordinator
    escalationLevel3Minutes: 2880, // 48 hours - Escalate to Admin
    applyBusinessHours: true,
    businessStartTime: '09:00',
    businessEndTime: '18:00',
    workingDays: '1,2,3,4,5', // Monday to Friday
    excludeHolidays: true,
  },
  {
    name: 'Medium Priority SLA',
    description: 'Standard SLA for medium priority maintenance tickets',
    priority: TicketPriority.MEDIUM,
    firstResponseTimeMinutes: 120, // 2 hours
    acknowledgementTimeMinutes: 240, // 4 hours
    resolutionTimeMinutes: 1440, // 24 hours (1 day)
    escalationLevel1Minutes: 720, // 12 hours - Escalate to Supervisor
    escalationLevel2Minutes: 1080, // 18 hours - Escalate to Site Coordinator
    escalationLevel3Minutes: 1440, // 24 hours - Escalate to Admin
    applyBusinessHours: true,
    businessStartTime: '09:00',
    businessEndTime: '18:00',
    workingDays: '1,2,3,4,5', // Monday to Friday
    excludeHolidays: true,
  },
  {
    name: 'High Priority SLA',
    description: 'Standard SLA for high priority maintenance tickets',
    priority: TicketPriority.HIGH,
    firstResponseTimeMinutes: 30, // 30 minutes
    acknowledgementTimeMinutes: 60, // 1 hour
    resolutionTimeMinutes: 480, // 8 hours
    escalationLevel1Minutes: 240, // 4 hours - Escalate to Supervisor
    escalationLevel2Minutes: 360, // 6 hours - Escalate to Site Coordinator
    escalationLevel3Minutes: 480, // 8 hours - Escalate to Admin
    applyBusinessHours: true,
    businessStartTime: '09:00',
    businessEndTime: '18:00',
    workingDays: '1,2,3,4,5,6,7', // All days (including weekends)
    excludeHolidays: false, // High priority works on holidays too
  },
  {
    name: 'Urgent Priority SLA',
    description: 'Standard SLA for urgent priority maintenance tickets - 24/7 support',
    priority: TicketPriority.URGENT,
    firstResponseTimeMinutes: 15, // 15 minutes
    acknowledgementTimeMinutes: 30, // 30 minutes
    resolutionTimeMinutes: 240, // 4 hours
    escalationLevel1Minutes: 60, // 1 hour - Escalate to Supervisor
    escalationLevel2Minutes: 120, // 2 hours - Escalate to Site Coordinator
    escalationLevel3Minutes: 240, // 4 hours - Escalate to Admin
    applyBusinessHours: false, // Urgent works 24/7
    businessStartTime: null,
    businessEndTime: null,
    workingDays: null, // All days
    excludeHolidays: false, // Urgent works on holidays
  },
];

async function seedSlaConfigurations() {
  try {
    await dataSource.initialize();
    console.log('📊 Seeding SLA Configurations...\n');

    const slaConfigRepo = dataSource.getRepository(SlaConfiguration);
    const companyRepo = dataSource.getRepository(Company);
    const userRepo = dataSource.getRepository(User);

    // Get all companies
    const companies = await companyRepo.find();
    if (companies.length === 0) {
      console.log('⚠️  No companies found. Please run the main seed script first.');
      await dataSource.destroy();
      return;
    }

    // Get admin user for createdById
    const adminUser = await userRepo.findOne({
      where: { email: 'vivek.ellappan@helixsense.com' },
    });

    let totalCreated = 0;
    let totalSkipped = 0;

    for (const company of companies) {
      console.log(`\n📦 Processing company: ${company.name} (${company.id})`);

      for (const configTemplate of SLA_CONFIGURATIONS) {
        // Check if configuration already exists for this company and priority
        const existing = await slaConfigRepo.findOne({
          where: {
            companyId: company.id,
            priority: configTemplate.priority,
          },
        });

        if (existing) {
          console.log(
            `  ⏭️  Skipped ${configTemplate.name} (${configTemplate.priority}) - already exists`,
          );
          totalSkipped++;
          continue;
        }

        // Create SLA configuration
        const slaConfig = slaConfigRepo.create({
          companyId: company.id,
          name: configTemplate.name,
          description: configTemplate.description,
          priority: configTemplate.priority,
          firstResponseTimeMinutes: configTemplate.firstResponseTimeMinutes,
          acknowledgementTimeMinutes: configTemplate.acknowledgementTimeMinutes,
          resolutionTimeMinutes: configTemplate.resolutionTimeMinutes,
          escalationLevel1Minutes: configTemplate.escalationLevel1Minutes,
          escalationLevel2Minutes: configTemplate.escalationLevel2Minutes,
          escalationLevel3Minutes: configTemplate.escalationLevel3Minutes,
          applyBusinessHours: configTemplate.applyBusinessHours,
          businessStartTime: configTemplate.businessStartTime ?? undefined,
          businessEndTime: configTemplate.businessEndTime ?? undefined,
          workingDays: configTemplate.workingDays ?? undefined,
          excludeHolidays: configTemplate.excludeHolidays,
          isActive: true,
          createdById: adminUser?.id ?? undefined,
        });

        await slaConfigRepo.save(slaConfig);
        console.log(
          `  ✅ Created ${configTemplate.name} (${configTemplate.priority})`,
        );
        totalCreated++;
      }
    }

    console.log('\n✅ SLA Configuration seeding completed!');
    console.log(`\n📊 Summary:`);
    console.log(`   - Created: ${totalCreated} configurations`);
    console.log(`   - Skipped: ${totalSkipped} configurations (already exist)`);
    console.log(
      `   - Total companies processed: ${companies.length}`,
    );

    await dataSource.destroy();
  } catch (error) {
    console.error('❌ SLA Configuration seeding failed:', error);
    await dataSource.destroy();
    process.exit(1);
  }
}

// Run the seed function
seedSlaConfigurations();
