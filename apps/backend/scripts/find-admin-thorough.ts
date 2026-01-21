/**
 * ============================================================================
 * THOROUGH ADMIN USER SEARCH
 * ============================================================================
 * 
 * This script thoroughly searches for admin.com0001@comp1051.com
 * 
 * Usage: npm run find-admin-thorough
 * 
 * ============================================================================
 */

import { DataSource } from 'typeorm';
import { User } from '../src/modules/iam/entities/user.entity';
import { Company } from '../src/modules/tenant/entities/company.entity';

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

async function findAdminThorough() {
  console.log('\n');
  console.log('=' .repeat(60));
  console.log('🔍 THOROUGH ADMIN USER SEARCH');
  console.log('=' .repeat(60));

  try {
    await dataSource.initialize();
    console.log('✅ Database connected\n');

    const userRepo = dataSource.getRepository(User);
    const companyRepo = dataSource.getRepository(Company);

    const targetEmail = 'admin.com0001@comp1051.com';
    const targetEmailLower = targetEmail.toLowerCase();

    console.log(`🔍 Searching for: ${targetEmail}\n`);

    // Method 1: Direct query with case-insensitive search
    console.log('📋 Method 1: Case-insensitive email search...');
    const usersByEmail = await userRepo
      .createQueryBuilder('user')
      .where('LOWER(user.email) = LOWER(:email)', { email: targetEmail })
      .getMany();

    if (usersByEmail.length > 0) {
      console.log(`✅ Found ${usersByEmail.length} user(s) by email:\n`);
      for (const user of usersByEmail) {
        const company = await companyRepo.findOne({ where: { id: user.companyId } });
        console.log(`   Email: ${user.email}`);
        console.log(`   ID: ${user.id}`);
        console.log(`   Name: ${user.firstName} ${user.lastName}`);
        console.log(`   Company: ${company?.name || 'N/A'} (${company?.code || 'N/A'})`);
        console.log(`   Company ID: ${user.companyId}`);
        console.log(`   Status: ${user.status}`);
        console.log(`   Created: ${user.createdAt}`);
        console.log('');
      }
    } else {
      console.log('   ❌ No exact match found\n');
    }

    // Method 2: Partial match search
    console.log('📋 Method 2: Partial email search (admin.com0001)...');
    const usersPartial = await userRepo
      .createQueryBuilder('user')
      .where('LOWER(user.email) LIKE LOWER(:pattern)', { pattern: `%admin.com0001%` })
      .getMany();

    if (usersPartial.length > 0) {
      console.log(`✅ Found ${usersPartial.length} user(s) with partial match:\n`);
      for (const user of usersPartial) {
        const company = await companyRepo.findOne({ where: { id: user.companyId } });
        console.log(`   Email: ${user.email}`);
        console.log(`   ID: ${user.id}`);
        console.log(`   Name: ${user.firstName} ${user.lastName}`);
        console.log(`   Company: ${company?.name || 'N/A'} (${company?.code || 'N/A'})`);
        console.log(`   Company ID: ${user.companyId}`);
        console.log(`   Status: ${user.status}`);
        console.log('');
      }
    } else {
      console.log('   ❌ No partial match found\n');
    }

    // Method 3: Search for comp1051 domain
    console.log('📋 Method 3: Domain search (@comp1051.com)...');
    const usersByDomain = await userRepo
      .createQueryBuilder('user')
      .where('LOWER(user.email) LIKE LOWER(:pattern)', { pattern: `%@comp1051.com%` })
      .getMany();

    if (usersByDomain.length > 0) {
      console.log(`✅ Found ${usersByDomain.length} user(s) with @comp1051.com domain:\n`);
      for (const user of usersByDomain) {
        const company = await companyRepo.findOne({ where: { id: user.companyId } });
        console.log(`   Email: ${user.email}`);
        console.log(`   ID: ${user.id}`);
        console.log(`   Name: ${user.firstName} ${user.lastName}`);
        console.log(`   Company: ${company?.name || 'N/A'} (${company?.code || 'N/A'})`);
        console.log(`   Company ID: ${user.companyId}`);
        console.log(`   Status: ${user.status}`);
        console.log('');
      }
    } else {
      console.log('   ❌ No users found with @comp1051.com domain\n');
    }

    // Method 4: Search all users and filter manually
    console.log('📋 Method 4: Full database scan (checking all users)...');
    const allUsers = await userRepo.find();
    console.log(`   Total users in database: ${allUsers.length}`);

    const matches: User[] = [];
    for (const user of allUsers) {
      if (user.email) {
        const emailLower = user.email.toLowerCase();
        if (
          emailLower === targetEmailLower ||
          emailLower.includes('admin.com0001') ||
          emailLower.includes('comp1051')
        ) {
          matches.push(user);
        }
      }
    }

    if (matches.length > 0) {
      console.log(`✅ Found ${matches.length} potential match(es):\n`);
      for (const user of matches) {
        const company = await companyRepo.findOne({ where: { id: user.companyId } });
        console.log(`   Email: ${user.email}`);
        console.log(`   ID: ${user.id}`);
        console.log(`   Name: ${user.firstName} ${user.lastName}`);
        console.log(`   Company: ${company?.name || 'N/A'} (${company?.code || 'N/A'})`);
        console.log(`   Company ID: ${user.companyId}`);
        console.log(`   Status: ${user.status}`);
        console.log(`   Created: ${user.createdAt}`);
        console.log('');
      }
    } else {
      console.log('   ❌ No matches found in full scan\n');
    }

    // Method 5: Raw SQL query
    console.log('📋 Method 5: Raw SQL query...');
    const rawResults = await userRepo.query(
      `SELECT id, email, first_name, last_name, company_id, status, created_at 
       FROM users 
       WHERE LOWER(email) = LOWER($1) 
       OR LOWER(email) LIKE LOWER($2)
       OR LOWER(email) LIKE LOWER($3)`,
      [targetEmail, `%admin.com0001%`, `%@comp1051.com%`],
    );

    if (rawResults.length > 0) {
      console.log(`✅ Found ${rawResults.length} user(s) via raw SQL:\n`);
      for (const row of rawResults) {
        const company = await companyRepo.findOne({ where: { id: row.company_id } });
        console.log(`   Email: ${row.email}`);
        console.log(`   ID: ${row.id}`);
        console.log(`   Name: ${row.first_name} ${row.last_name}`);
        console.log(`   Company: ${company?.name || 'N/A'} (${company?.code || 'N/A'})`);
        console.log(`   Company ID: ${row.company_id}`);
        console.log(`   Status: ${row.status}`);
        console.log(`   Created: ${row.created_at}`);
        console.log('');
      }
    } else {
      console.log('   ❌ No matches found via raw SQL\n');
    }

    console.log('=' .repeat(60));
    console.log('✅ SEARCH COMPLETE');
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
findAdminThorough();
