/**
 * ============================================================================
 * FIND OR CREATE ADMIN USER
 * ============================================================================
 * 
 * This script finds or creates the admin user admin.com0001@comp1051.com
 * 
 * Usage: npm run find-or-create-admin
 * 
 * ============================================================================
 */

import { DataSource } from 'typeorm';
import { User } from '../src/modules/iam/entities/user.entity';
import { Company } from '../src/modules/tenant/entities/company.entity';
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

async function findOrCreateAdmin() {
  console.log('\n');
  console.log('=' .repeat(60));
  console.log('👤 FIND OR CREATE ADMIN USER');
  console.log('=' .repeat(60));

  try {
    await dataSource.initialize();
    console.log('✅ Database connected\n');

    const companyRepo = dataSource.getRepository(Company);
    const userRepo = dataSource.getRepository(User);

    // Get all companies
    const companies = await companyRepo.find();
    console.log(`📋 Found ${companies.length} companies\n`);

    for (const company of companies) {
      console.log(`\n📋 Checking company: ${company.name} (${company.code || 'N/A'})`);
      
      // Find admin user
      const allUsers = await userRepo.find({
        where: { companyId: company.id },
      });

      console.log(`   Users in company: ${allUsers.length}`);

      let adminUser = allUsers.find(
        (u) => u.email?.toLowerCase() === 'admin.com0001@comp1051.com'.toLowerCase(),
      );

      if (adminUser) {
        console.log(`   ✅ Found admin user: ${adminUser.email}`);
        console.log(`      ID: ${adminUser.id}`);
        console.log(`      Name: ${adminUser.firstName} ${adminUser.lastName}`);
        console.log(`      Status: ${adminUser.status}`);
      } else {
        console.log(`   ❌ Admin user not found in this company`);
        
        // Optionally create it
        if (companies.length === 1) {
          console.log(`   🔨 Creating admin user...`);
          adminUser = userRepo.create({
            companyId: company.id,
            email: 'admin.com0001@comp1051.com',
            firstName: 'Admin',
            lastName: 'User',
            status: UserStatus.ACTIVE,
            authProvider: AuthProvider.LOCAL,
          });
          adminUser = await userRepo.save(adminUser);
          console.log(`   ✅ Created admin user: ${adminUser.email} (${adminUser.id})`);
          console.log(`   ⚠️  Note: You'll need to assign ADMIN role to this user manually`);
        }
      }
    }

    console.log('\n');
    console.log('=' .repeat(60));
    console.log('✅ COMPLETE');
    console.log('=' .repeat(60));
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
findOrCreateAdmin();
