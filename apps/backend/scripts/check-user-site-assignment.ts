import { DataSource } from 'typeorm';
import { UserSite } from '../src/modules/tenant/entities/user-site.entity';
import { User } from '../src/modules/iam/entities/user.entity';
import { Site } from '../src/modules/tenant/entities/site.entity';
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

/**
 * Parse command line arguments
 */
function parseArgs(): {
  userEmail?: string;
  siteCode?: string;
} {
  const args: { userEmail?: string; siteCode?: string } = {};

  process.argv.slice(2).forEach((arg) => {
    if (arg.startsWith('--userEmail=')) {
      args.userEmail = arg.split('=')[1];
    } else if (arg.startsWith('--siteCode=')) {
      args.siteCode = arg.split('=')[1];
    }
  });

  return args;
}

async function checkUserSiteAssignment() {
  try {
    await dataSource.initialize();
    console.log('✓ Database connected\n');

    const args = parseArgs();

    if (!args.userEmail || !args.siteCode) {
      console.error('❌ Error: --userEmail and --siteCode are required');
      console.log('\nUsage:');
      console.log(
        '  npm run check:user-site -- --userEmail=<email> --siteCode=<code>',
      );
      await dataSource.destroy();
      process.exit(1);
    }

    const userRepo = dataSource.getRepository(User);
    const siteRepo = dataSource.getRepository(Site);
    const userSiteRepo = dataSource.getRepository(UserSite);

    // Find user
    const user = await userRepo.findOne({
      where: { email: args.userEmail },
      relations: ['userRoles', 'userRoles.role'],
    });

    if (!user) {
      console.error(`❌ User with email '${args.userEmail}' not found`);
      await dataSource.destroy();
      process.exit(1);
    }

    console.log(`✓ Found user: ${user.email}`);
    console.log(`  User ID: ${user.id}`);
    console.log(`  User Company ID: ${user.companyId}`);
    console.log(`  User Roles: ${user.userRoles?.map((ur) => ur.role?.name).join(', ') || 'None'}`);

    // Find site
    const site = await siteRepo.findOne({
      where: { code: args.siteCode },
      relations: ['company'],
    });

    if (!site) {
      console.error(`❌ Site with code '${args.siteCode}' not found`);
      await dataSource.destroy();
      process.exit(1);
    }

    console.log(`\n✓ Found site: ${site.name} (${site.code})`);
    console.log(`  Site ID: ${site.id}`);
    console.log(`  Site Company ID: ${site.companyId}`);
    console.log(`  Site Company: ${site.company?.name || 'N/A'}`);

    // Check company match
    if (user.companyId !== site.companyId) {
      console.error(
        `\n❌ COMPANY ID MISMATCH!`,
      );
      console.error(`  User belongs to company: ${user.companyId}`);
      console.error(`  Site belongs to company: ${site.companyId}`);
      console.error(`  This is the problem! User and site must be in the same company.`);
    } else {
      console.log(`\n✓ User and site are in the same company: ${user.companyId}`);
    }

    // Check all user-site assignments for this user
    const allUserSites = await userSiteRepo.find({
      where: { userId: user.id },
      relations: ['site'],
    });

    console.log(`\n📋 All site assignments for this user (${allUserSites.length}):`);
    allUserSites.forEach((us) => {
      const matches = us.siteId === site.id;
      console.log(
        `  ${matches ? '✅' : '  '} Site: ${us.site?.name || 'N/A'} (${us.site?.code || 'N/A'}) ` +
          `- companyId: ${us.companyId}, siteId: ${us.siteId}`,
      );
    });

    // Check specific assignment
    const specificAssignment = await userSiteRepo.findOne({
      where: {
        companyId: site.companyId,
        userId: user.id,
        siteId: site.id,
      },
    });

    console.log(`\n🔍 Checking assignment with:`);
    console.log(`  companyId: ${site.companyId}`);
    console.log(`  userId: ${user.id}`);
    console.log(`  siteId: ${site.id}`);

    if (specificAssignment) {
      console.log(`\n✅ Assignment EXISTS in database!`);
      console.log(`  Assignment ID: ${specificAssignment.id}`);
      console.log(`  Assignment Company ID: ${specificAssignment.companyId}`);
    } else {
      console.log(`\n❌ Assignment NOT FOUND in database!`);
      
      // Check if assignment exists with different companyId
      const assignmentWithDifferentCompany = await userSiteRepo.findOne({
        where: {
          userId: user.id,
          siteId: site.id,
        },
      });

      if (assignmentWithDifferentCompany) {
        console.log(`\n⚠️  Found assignment with DIFFERENT companyId:`);
        console.log(`  Assignment Company ID: ${assignmentWithDifferentCompany.companyId}`);
        console.log(`  Expected Company ID: ${site.companyId}`);
        console.log(`  This is the problem! The assignment has wrong companyId.`);
      }
    }

    await dataSource.destroy();
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
checkUserSiteAssignment();

