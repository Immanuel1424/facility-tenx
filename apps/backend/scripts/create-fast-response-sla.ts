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

/**
 * Creates or updates SLA configuration with 2-minute acknowledgement time
 * This ensures technicians must start work within 2 minutes of receiving a ticket
 */
async function createFastResponseSla() {
  try {
    await dataSource.initialize();
    console.log('⚡ Creating Fast Response SLA (2-minute start work requirement)...\n');

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
    let totalUpdated = 0;

    // Configuration for 2-minute start work requirement
    // This is extremely aggressive - for critical/emergency scenarios
    const fastResponseConfig = {
      name: 'Fast Response SLA - 2 Min Start Work',
      description: 'Technician must acknowledge and start work within 2 minutes of ticket assignment. Escalates immediately if not met.',
      priority: TicketPriority.URGENT,
      firstResponseTimeMinutes: 1, // 1 minute for initial response
      acknowledgementTimeMinutes: 2, // 2 minutes to start work (acknowledge)
      resolutionTimeMinutes: 120, // 2 hours for resolution
      escalationLevel1Minutes: 3, // Escalate to Supervisor after 3 minutes
      escalationLevel2Minutes: 5, // Escalate to Site Coordinator after 5 minutes
      escalationLevel3Minutes: 10, // Escalate to Admin after 10 minutes
      applyBusinessHours: false, // Works 24/7
      businessStartTime: null,
      businessEndTime: null,
      workingDays: null, // All days
      excludeHolidays: false, // Works on holidays
    };

    for (const company of companies) {
      console.log(`\n📦 Processing company: ${company.name} (${company.id})`);

      // Check if configuration already exists for this company and priority
      const existing = await slaConfigRepo.findOne({
        where: {
          companyId: company.id,
          priority: fastResponseConfig.priority,
        },
      });

      if (existing) {
        // Update existing configuration
        existing.name = fastResponseConfig.name;
        existing.description = fastResponseConfig.description;
        existing.firstResponseTimeMinutes = fastResponseConfig.firstResponseTimeMinutes;
        existing.acknowledgementTimeMinutes = fastResponseConfig.acknowledgementTimeMinutes;
        existing.resolutionTimeMinutes = fastResponseConfig.resolutionTimeMinutes;
        existing.escalationLevel1Minutes = fastResponseConfig.escalationLevel1Minutes;
        existing.escalationLevel2Minutes = fastResponseConfig.escalationLevel2Minutes;
        existing.escalationLevel3Minutes = fastResponseConfig.escalationLevel3Minutes;
        existing.applyBusinessHours = fastResponseConfig.applyBusinessHours;
        existing.businessStartTime = fastResponseConfig.businessStartTime ?? undefined;
        existing.businessEndTime = fastResponseConfig.businessEndTime ?? undefined;
        existing.workingDays = fastResponseConfig.workingDays ?? undefined;
        existing.excludeHolidays = fastResponseConfig.excludeHolidays;
        existing.isActive = true;
        if (adminUser?.id) {
          existing.createdById = adminUser.id;
        }

        await slaConfigRepo.save(existing);
        console.log(
          `  🔄 Updated ${fastResponseConfig.name} (${fastResponseConfig.priority})`,
        );
        totalUpdated++;
      } else {
        // Create new configuration
        const slaConfig = slaConfigRepo.create({
          companyId: company.id,
          name: fastResponseConfig.name,
          description: fastResponseConfig.description,
          priority: fastResponseConfig.priority,
          firstResponseTimeMinutes: fastResponseConfig.firstResponseTimeMinutes,
          acknowledgementTimeMinutes: fastResponseConfig.acknowledgementTimeMinutes,
          resolutionTimeMinutes: fastResponseConfig.resolutionTimeMinutes,
          escalationLevel1Minutes: fastResponseConfig.escalationLevel1Minutes,
          escalationLevel2Minutes: fastResponseConfig.escalationLevel2Minutes,
          escalationLevel3Minutes: fastResponseConfig.escalationLevel3Minutes,
          applyBusinessHours: fastResponseConfig.applyBusinessHours,
          businessStartTime: fastResponseConfig.businessStartTime ?? undefined,
          businessEndTime: fastResponseConfig.businessEndTime ?? undefined,
          workingDays: fastResponseConfig.workingDays ?? undefined,
          excludeHolidays: fastResponseConfig.excludeHolidays,
          isActive: true,
          createdById: adminUser?.id ?? undefined,
        });

        await slaConfigRepo.save(slaConfig);
        console.log(
          `  ✅ Created ${fastResponseConfig.name} (${fastResponseConfig.priority})`,
        );
        totalCreated++;
      }
    }

    console.log('\n✅ Fast Response SLA configuration completed!');
    console.log(`\n📊 Summary:`);
    console.log(`   - Created: ${totalCreated} configurations`);
    console.log(`   - Updated: ${totalUpdated} configurations`);
    console.log(`   - Total companies processed: ${companies.length}`);
    console.log(`\n⚡ Configuration Details:`);
    console.log(`   - First Response: ${fastResponseConfig.firstResponseTimeMinutes} minute(s)`);
    console.log(`   - Acknowledgement/Start Work: ${fastResponseConfig.acknowledgementTimeMinutes} minutes`);
    console.log(`   - Resolution Time: ${fastResponseConfig.resolutionTimeMinutes} minutes (${fastResponseConfig.resolutionTimeMinutes / 60} hours)`);
    console.log(`   - Escalation L1 (Supervisor): ${fastResponseConfig.escalationLevel1Minutes} minutes`);
    console.log(`   - Escalation L2 (Site Coordinator): ${fastResponseConfig.escalationLevel2Minutes} minutes`);
    console.log(`   - Escalation L3 (Admin): ${fastResponseConfig.escalationLevel3Minutes} minutes`);
    console.log(`   - 24/7 Support: Yes`);

    await dataSource.destroy();
  } catch (error) {
    console.error('❌ Fast Response SLA configuration failed:', error);
    await dataSource.destroy();
    process.exit(1);
  }
}

// Run the function
createFastResponseSla();
