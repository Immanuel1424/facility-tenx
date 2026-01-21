import { DataSource } from 'typeorm';
import * as bcrypt from 'bcrypt';
import { Company } from '../src/modules/tenant/entities/company.entity';
import { Site } from '../src/modules/tenant/entities/site.entity';
import { User, UserStatus, AuthProvider } from '../src/modules/iam/entities/user.entity';
import { Role } from '../src/modules/iam/entities/role.entity';
import { UserRole } from '../src/modules/iam/entities/user-role.entity';
import { UserSite } from '../src/modules/tenant/entities/user-site.entity';

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

const SITE_NAMES = [
  'Headquarters', 'Main Office', 'Regional Office', 'Branch Office', 'Service Center',
  'Distribution Center', 'Warehouse', 'Manufacturing Plant', 'Research Facility',
  'Data Center', 'Call Center', 'Retail Store', 'Showroom', 'Training Center',
  'Operations Center', 'Support Office', 'Sales Office', 'Development Center',
  'Testing Facility', 'Quality Assurance Center', 'Logistics Hub', 'Transportation Hub',
  'Maintenance Depot', 'Service Station', 'Field Office', 'Satellite Office',
  'Corporate Office', 'Administrative Center', 'Business Center', 'Innovation Hub',
];

const SITE_LOCATIONS = [
  'North', 'South', 'East', 'West', 'Central', 'Downtown', 'Uptown', 'Midtown',
  'Airport', 'Harbor', 'Port', 'Industrial', 'Business District', 'Tech Park',
  'Science Park', 'Campus', 'Plaza', 'Square', 'Tower', 'Complex', 'Center',
];

function generateSiteName(companyName: string, index: number): string {
  const location = SITE_LOCATIONS[Math.floor(Math.random() * SITE_LOCATIONS.length)];
  const siteType = SITE_NAMES[Math.floor(Math.random() * SITE_NAMES.length)];
  
  // Mix different naming patterns
  const pattern = index % 4;
  switch (pattern) {
    case 0:
      return `${companyName} ${siteType}`;
    case 1:
      return `${location} ${siteType}`;
    case 2:
      return `${companyName} ${location} ${siteType}`;
    default:
      return `${siteType} - ${location}`;
  }
}

async function generateUniqueSiteCode(
  companyId: string,
  siteRepo: any,
  baseCode: string,
): Promise<string> {
  // Extract base code from company name or use provided base
  let code = baseCode.toUpperCase().replace(/[^A-Z0-9]/g, '').substring(0, 3);
  if (code.length < 3) {
    code = 'SITE';
  }

  // Try base code with numeric suffix
  for (let i = 1; i <= 9999; i++) {
    const candidate = `${code}${String(i).padStart(4, '0')}`;
    if (candidate.length > 20) break; // Site code max length is 20

    const existing = await siteRepo.findOne({
      where: { companyId, code: candidate },
    });

    if (!existing) {
      return candidate;
    }
  }

  // Fallback: use timestamp-based code
  return `SITE${Date.now().toString().slice(-8)}`;
}

async function generateUniqueEmail(
  companyId: string,
  userRepo: any,
  siteCode: string,
  companyCode: string,
  siteIndex: number,
): Promise<string> {
  // Clean site code for email (remove special chars, lowercase)
  const cleanSiteCode = siteCode.toLowerCase().replace(/[^a-z0-9]/g, '');
  const cleanCompanyCode = companyCode.toLowerCase().replace(/[^a-z0-9]/g, '');
  
  const baseEmail = `admin.${cleanSiteCode}@${cleanCompanyCode}.com`;
  
  // Check if email exists
  const existing = await userRepo.findOne({
    where: { companyId, email: baseEmail },
  });

  if (!existing) {
    return baseEmail;
  }

  // Try with numeric suffix
  for (let i = 1; i <= 9999; i++) {
    const candidate = `admin.${cleanSiteCode}.${i}@${cleanCompanyCode}.com`;
    const existingUser = await userRepo.findOne({
      where: { companyId, email: candidate },
    });
    if (!existingUser) {
      return candidate;
    }
  }

  // Fallback: use timestamp
  return `admin.${cleanSiteCode}.${Date.now()}@${cleanCompanyCode}.com`;
}

async function getOrCreateAdminRole(
  companyId: string,
  roleRepo: any,
): Promise<Role> {
  // Check if ADMIN role exists
  let adminRole = await roleRepo.findOne({
    where: { companyId, name: 'ADMIN' },
  });

  if (!adminRole) {
    // Create ADMIN role
    adminRole = roleRepo.create({
      companyId,
      name: 'ADMIN',
      description: 'Administrator with full system access',
      hierarchyLevel: 100,
    });
    adminRole = await roleRepo.save(adminRole);
    console.log(`  ✓ Created ADMIN role for company ${companyId}`);
  }

  return adminRole;
}

async function seedSitesWithAdmins() {
  try {
    await dataSource.initialize();
    console.log('Database connected');

    const companyRepo = dataSource.getRepository(Company);
    const siteRepo = dataSource.getRepository(Site);
    const userRepo = dataSource.getRepository(User);
    const roleRepo = dataSource.getRepository(Role);
    const userRoleRepo = dataSource.getRepository(UserRole);
    const userSiteRepo = dataSource.getRepository(UserSite);

    // Get all companies
    const companies = await companyRepo.find();
    const companyCount = companies.length;

    if (companyCount === 0) {
      console.error('❌ No companies found in database. Please create companies first.');
      await dataSource.destroy();
      process.exit(1);
    }

    console.log(`Found ${companyCount} companies`);

    // Check existing sites
    const existingSites = await siteRepo.count();
    // Allow target count to be set via environment variable, default to 5000
    const targetSites = Number(process.env.TARGET_SITES) || 5000;
    const sitesToCreate = targetSites - existingSites;

    if (sitesToCreate <= 0) {
      console.log(`Database already has ${existingSites} sites. Target is ${targetSites}.`);
      console.log('No new sites to create.');
      await dataSource.destroy();
      return;
    }

    console.log(`\nCreating ${sitesToCreate} new sites with admin users...`);
    console.log(`Distributing evenly across ${companyCount} companies...`);

    // Calculate sites per company
    const sitesPerCompany = Math.floor(sitesToCreate / companyCount);
    const remainder = sitesToCreate % companyCount;

    let totalCreated = 0;
    const batchSize = 20; // Process in batches for better performance

    for (let c = 0; c < companyCount; c++) {
      const company = companies[c];
      const sitesForThisCompany = sitesPerCompany + (c < remainder ? 1 : 0);

      if (sitesForThisCompany === 0) continue;

      console.log(`\n📦 Company ${c + 1}/${companyCount}: ${company.name} (${company.code})`);
      console.log(`   Creating ${sitesForThisCompany} sites...`);

      // Get or create ADMIN role for this company
      const adminRole = await getOrCreateAdminRole(company.id, roleRepo);

      // Get existing site codes for this company to avoid duplicates
      const existingSitesForCompany = await siteRepo.find({
        where: { companyId: company.id },
        select: ['code'],
      });
      const existingCodes = new Set(existingSitesForCompany.map((s) => s.code));

      const sites: Site[] = [];
      const users: User[] = [];
      const userRoles: UserRole[] = [];
      const userSites: UserSite[] = [];

      for (let s = 0; s < sitesForThisCompany; s++) {
        // Generate site name and code
        const siteName = generateSiteName(company.name, s);
        const baseCode = company.code.substring(0, 3).toUpperCase();
        const siteCode = await generateUniqueSiteCode(
          company.id,
          siteRepo,
          baseCode,
        );

        // Skip if code already exists
        if (existingCodes.has(siteCode)) {
          console.warn(`  ⚠️  Site code ${siteCode} already exists, skipping...`);
          continue;
        }
        existingCodes.add(siteCode);

        // Create site
        const site = siteRepo.create({
          companyId: company.id,
          code: siteCode,
          name: siteName,
          description: `${siteName} for ${company.name}`,
          isParent: true,
          isActive: true,
        });
        sites.push(site);

        // Generate unique email for admin user
        const adminEmail = await generateUniqueEmail(
          company.id,
          userRepo,
          siteCode,
          company.code,
          s,
        );

        // Hash password
        const passwordHash = await bcrypt.hash('Admin@123', 10);

        // Create admin user
        const user = userRepo.create({
          companyId: company.id,
          email: adminEmail,
          passwordHash,
          firstName: 'Admin',
          lastName: siteName,
          status: UserStatus.ACTIVE,
          authProvider: AuthProvider.LOCAL,
        });
        users.push(user);
      }

      // Save sites in batch
      if (sites.length > 0) {
        const savedSites = await siteRepo.save(sites);
        console.log(`  ✓ Created ${savedSites.length} sites`);

        // Save users in batch
        const savedUsers = await userRepo.save(users);
        console.log(`  ✓ Created ${savedUsers.length} admin users`);

        // Create UserRole and UserSite relationships
        for (let i = 0; i < savedSites.length; i++) {
          const site = savedSites[i];
          const user = savedUsers[i];

          // Create UserRole (assign ADMIN role)
          const userRole = userRoleRepo.create({
            companyId: company.id,
            userId: user.id,
            roleId: adminRole.id,
          });
          userRoles.push(userRole);

          // Create UserSite (link user to site)
          const userSite = userSiteRepo.create({
            companyId: company.id,
            userId: user.id,
            siteId: site.id,
          });
          userSites.push(userSite);
        }

        // Save relationships in batch
        if (userRoles.length > 0) {
          await userRoleRepo.save(userRoles);
          console.log(`  ✓ Assigned ADMIN role to ${userRoles.length} users`);
        }

        if (userSites.length > 0) {
          await userSiteRepo.save(userSites);
          console.log(`  ✓ Linked ${userSites.length} users to sites`);
        }

        totalCreated += savedSites.length;
      }
    }

    const finalSiteCount = await siteRepo.count();
    // Count admin users (users with ADMIN role)
    const adminUserRoles = await userRoleRepo
      .createQueryBuilder('userRole')
      .innerJoin('userRole.role', 'role')
      .where('role.name = :roleName', { roleName: 'ADMIN' })
      .getCount();

    console.log(`\n✅ Successfully seeded sites and admin users!`);
    console.log(`Total sites in database: ${finalSiteCount}`);
    console.log(`Total admin users created: ${totalCreated}`);
    console.log(`Total admin users with ADMIN role: ${adminUserRoles}`);

    // Show sample
    const sampleSites = await siteRepo.find({
      take: 5,
      order: { createdAt: 'DESC' },
      relations: ['company'],
    });

    console.log('\n📋 Sample of created sites:');
    for (const site of sampleSites) {
      const userSite = await userSiteRepo.findOne({
        where: { siteId: site.id },
        relations: ['user'],
      });
      console.log(
        `  - ${site.code}: ${site.name} (Company: ${site.company.name})`,
      );
      if (userSite?.user) {
        console.log(`    Admin: ${userSite.user.email}`);
      }
    }

    await dataSource.destroy();
    console.log('\n✅ Database connection closed');
  } catch (error) {
    console.error('❌ Error seeding sites and admins:', error);
    if (dataSource.isInitialized) {
      await dataSource.destroy();
    }
    process.exit(1);
  }
}

// Run the seed function
seedSitesWithAdmins();

