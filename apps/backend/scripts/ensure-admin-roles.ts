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

async function ensureAdminRoles() {
  try {
    await dataSource.initialize();
    console.log('✓ Database connected');

    const companyRepo = dataSource.getRepository(Company);
    const roleRepo = dataSource.getRepository(Role);

    // Get all companies
    const companies = await companyRepo.find();
    console.log(`\n📋 Found ${companies.length} company(ies)`);

    let createdCount = 0;
    let existingCount = 0;
    let errorCount = 0;

    for (const company of companies) {
      try {
        // Check if ADMIN role already exists for this company
        const existingAdminRole = await roleRepo.findOne({
          where: {
            companyId: company.id,
            name: 'ADMIN',
          },
        });

        if (existingAdminRole) {
          console.log(
            `  ✓ Company "${company.name}" (${company.code}) already has ADMIN role`,
          );
          existingCount++;
        } else {
          // Create ADMIN role
          const adminRole = roleRepo.create({
            companyId: company.id,
            name: 'ADMIN',
            description: 'Administrator with full system access',
            hierarchyLevel: 100,
          });
          await roleRepo.save(adminRole);
          console.log(
            `  ✓ Created ADMIN role for company "${company.name}" (${company.code})`,
          );
          createdCount++;
        }
      } catch (error) {
        console.error(
          `  ✗ Error processing company "${company.name}" (${company.code}):`,
          error,
        );
        errorCount++;
      }
    }

    console.log('\n📊 Summary:');
    console.log(`  ✓ Created: ${createdCount} ADMIN role(s)`);
    console.log(`  ✓ Existing: ${existingCount} ADMIN role(s)`);
    if (errorCount > 0) {
      console.log(`  ✗ Errors: ${errorCount} company(ies)`);
    }
    console.log('\n✅ Done!');

    await dataSource.destroy();
  } catch (error) {
    console.error('❌ Error:', error);
    await dataSource.destroy();
    process.exit(1);
  }
}

ensureAdminRoles();

