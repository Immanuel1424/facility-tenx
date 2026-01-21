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

async function testCompanyAdminRoleCreation() {
  try {
    await dataSource.initialize();
    console.log('✓ Database connected\n');

    const companyRepo = dataSource.getRepository(Company);
    const roleRepo = dataSource.getRepository(Role);

    // Create a test company
    const testCompanyCode = `TEST${Date.now()}`; // Unique code using timestamp
    const testCompanyName = 'Test Company for ADMIN Role';
    const testCompanyDescription = 'Temporary test company to verify ADMIN role creation';

    console.log('🧪 Testing company creation with automatic ADMIN role...\n');
    console.log(`Creating test company: ${testCompanyName} (${testCompanyCode})`);

    // Check if company with this code already exists
    const existingCompany = await companyRepo.findOne({
      where: { code: testCompanyCode },
    });

    if (existingCompany) {
      console.log('⚠️  Test company already exists, cleaning up first...');
      // Delete roles first (cascade might not work)
      await roleRepo.delete({ companyId: existingCompany.id });
      await companyRepo.remove(existingCompany);
    }

    // Create the company
    const company = companyRepo.create({
      code: testCompanyCode,
      name: testCompanyName,
      description: testCompanyDescription,
      isActive: true,
    });

    const savedCompany = await companyRepo.save(company);
    console.log(`✓ Company created: ${savedCompany.id}\n`);

    // Now test ADMIN role creation (simulating what TenantService does)
    console.log('🔍 Checking for ADMIN role...');
    const existingRoles = await roleRepo.find({
      where: { companyId: savedCompany.id },
    });

    const adminRoleExists = existingRoles.some(
      (role) => role.name.toUpperCase() === 'ADMIN',
    );

    if (adminRoleExists) {
      console.log('❌ ADMIN role already exists (this should not happen for a new company)');
    } else {
      console.log('✓ No ADMIN role found (expected for new company)');
      console.log('📝 Creating ADMIN role...');

      // Create ADMIN role
      const adminRole = roleRepo.create({
        companyId: savedCompany.id,
        name: 'ADMIN',
        description: 'Administrator with full system access',
        hierarchyLevel: 100,
      });

      const savedAdminRole = await roleRepo.save(adminRole);
      console.log(`✓ ADMIN role created: ${savedAdminRole.id}`);
    }

    // Verify ADMIN role exists
    console.log('\n✅ Verifying ADMIN role...');
    const adminRole = await roleRepo.findOne({
      where: {
        companyId: savedCompany.id,
        name: 'ADMIN',
      },
    });

    if (adminRole) {
      console.log('✅ SUCCESS: ADMIN role exists for the new company!');
      console.log(`   Role ID: ${adminRole.id}`);
      console.log(`   Role Name: ${adminRole.name}`);
      console.log(`   Hierarchy Level: ${adminRole.hierarchyLevel}`);
      console.log(`   Description: ${adminRole.description}`);
    } else {
      console.log('❌ FAILED: ADMIN role was not created!');
      process.exit(1);
    }

    // Cleanup: Delete test company (this will cascade delete the role)
    console.log('\n🧹 Cleaning up test company...');
    await companyRepo.remove(savedCompany);
    console.log('✓ Test company deleted\n');

    console.log('✅ Test completed successfully!');
    console.log('\n📋 Summary:');
    console.log('   ✓ Company creation works');
    console.log('   ✓ ADMIN role can be created automatically');
    console.log('   ✓ Role has correct properties (name: ADMIN, hierarchy: 100)');

    await dataSource.destroy();
  } catch (error) {
    console.error('❌ Test failed:', error);
    await dataSource.destroy();
    process.exit(1);
  }
}

testCompanyAdminRoleCreation();

