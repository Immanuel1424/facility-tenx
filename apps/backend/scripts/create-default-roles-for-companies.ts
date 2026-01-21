import { DataSource } from 'typeorm';
import { Company } from '../src/modules/tenant/entities/company.entity';
import { Role } from '../src/modules/iam/entities/role.entity';

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
 * Default roles configuration
 */
const DEFAULT_ROLES = [
  {
    name: 'ADMIN',
    description: 'Administrator with full system access',
    hierarchyLevel: 100,
  },
  {
    name: 'SITE_COORDINATOR',
    description: 'Site Coordinator - View all, assign department, schedule',
    hierarchyLevel: 80,
  },
  {
    name: 'SUPERVISOR',
    description: 'Supervisor - Assign technicians, update work status',
    hierarchyLevel: 60,
  },
  {
    name: 'TECHNICIAN',
    description: 'Technician - Update assigned tickets, add work notes',
    hierarchyLevel: 30,
  },
  {
    name: 'TENANT',
    description: 'Tenant - Villa resident',
    hierarchyLevel: 10,
  },
];

async function createDefaultRolesForCompanies() {
  try {
    await dataSource.initialize();
    console.log('✓ Database connected\n');

    const companyRepo = dataSource.getRepository(Company);
    const roleRepo = dataSource.getRepository(Role);

    // Get all companies
    const companies = await companyRepo.find({
      order: { name: 'ASC' },
    });

    if (companies.length === 0) {
      console.log('⚠️  No companies found in database.');
      await dataSource.destroy();
      process.exit(0);
    }

    console.log(`Found ${companies.length} company(ies):\n`);

    let totalCreated = 0;
    let totalSkipped = 0;

    for (const company of companies) {
      console.log(`Processing company: ${company.name} (${company.code})`);
      console.log(`  Company ID: ${company.id}`);

      // Get existing roles for this company
      const existingRoles = await roleRepo.find({
        where: { companyId: company.id },
      });
      const existingRoleNames = existingRoles.map((role) =>
        role.name.toUpperCase(),
      );

      console.log(
        `  Existing roles: ${existingRoleNames.length > 0 ? existingRoleNames.join(', ') : 'None'}`,
      );

      let companyCreated = 0;
      let companySkipped = 0;

      // Create default roles
      for (const roleConfig of DEFAULT_ROLES) {
        const roleNameUpper = roleConfig.name.toUpperCase();

        // Skip if role already exists
        if (existingRoleNames.includes(roleNameUpper)) {
          console.log(`  ⏭️  ${roleConfig.name} - already exists`);
          companySkipped++;
          continue;
        }

        try {
          const role = roleRepo.create({
            companyId: company.id,
            name: roleConfig.name,
            description: roleConfig.description,
            hierarchyLevel: roleConfig.hierarchyLevel,
            parentRoleId: undefined,
          });

          await roleRepo.save(role);
          console.log(`  ✅ ${roleConfig.name} - created`);
          companyCreated++;
        } catch (error) {
          console.error(
            `  ❌ ${roleConfig.name} - failed to create:`,
            error instanceof Error ? error.message : error,
          );
        }
      }

      totalCreated += companyCreated;
      totalSkipped += companySkipped;

      console.log(
        `  Summary: ${companyCreated} created, ${companySkipped} skipped\n`,
      );
    }

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`Total: ${totalCreated} roles created, ${totalSkipped} roles skipped`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    await dataSource.destroy();
    console.log('✓ Database connection closed');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    if (dataSource.isInitialized) {
      await dataSource.destroy();
    }
    process.exit(1);
  }
}

// Run the script
createDefaultRolesForCompanies();

