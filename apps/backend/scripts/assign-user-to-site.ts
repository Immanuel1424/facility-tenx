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
  userId?: string;
  siteId?: string;
  companyId?: string;
  userEmail?: string;
  siteCode?: string;
  companyCode?: string;
} {
  const args: {
    userId?: string;
    siteId?: string;
    companyId?: string;
    userEmail?: string;
    siteCode?: string;
    companyCode?: string;
  } = {};

  process.argv.slice(2).forEach((arg) => {
    if (arg.startsWith('--userId=')) {
      args.userId = arg.split('=')[1];
    } else if (arg.startsWith('--siteId=')) {
      args.siteId = arg.split('=')[1];
    } else if (arg.startsWith('--companyId=')) {
      args.companyId = arg.split('=')[1];
    } else if (arg.startsWith('--userEmail=')) {
      args.userEmail = arg.split('=')[1];
    } else if (arg.startsWith('--siteCode=')) {
      args.siteCode = arg.split('=')[1];
    } else if (arg.startsWith('--companyCode=')) {
      args.companyCode = arg.split('=')[1];
    }
  });

  return args;
}

async function assignUserToSite() {
  try {
    await dataSource.initialize();
    console.log('✓ Database connected\n');

    const args = parseArgs();

    // Validate required arguments
    if (!args.userId && !args.userEmail) {
      console.error('❌ Error: Either --userId or --userEmail is required');
      console.log('\nUsage:');
      console.log(
        '  npm run assign:user-to-site -- --userId=<uuid> --siteId=<uuid> [--companyId=<uuid>]',
      );
      console.log(
        '  npm run assign:user-to-site -- --userEmail=<email> --siteCode=<code> [--companyCode=<code>]',
      );
      await dataSource.destroy();
      process.exit(1);
    }

    if (!args.siteId && !args.siteCode) {
      console.error('❌ Error: Either --siteId or --siteCode is required');
      console.log('\nUsage:');
      console.log(
        '  npm run assign:user-to-site -- --userId=<uuid> --siteId=<uuid> [--companyId=<uuid>]',
      );
      console.log(
        '  npm run assign:user-to-site -- --userEmail=<email> --siteCode=<code> [--companyCode=<code>]',
      );
      await dataSource.destroy();
      process.exit(1);
    }

    const userRepo = dataSource.getRepository(User);
    const siteRepo = dataSource.getRepository(Site);
    const companyRepo = dataSource.getRepository(Company);
    const userSiteRepo = dataSource.getRepository(UserSite);

    // Resolve company
    let companyId: string | undefined = args.companyId;
    if (!companyId && args.companyCode) {
      const company = await companyRepo.findOne({
        where: { code: args.companyCode },
      });
      if (!company) {
        console.error(`❌ Company with code '${args.companyCode}' not found`);
        await dataSource.destroy();
        process.exit(1);
      }
      companyId = company.id;
      console.log(`✓ Found company: ${company.name} (${company.code})`);
    }

    // Resolve user
    let user: User | null = null;
    if (args.userId) {
      user = await userRepo.findOne({
        where: { id: args.userId },
      });
    } else if (args.userEmail && companyId) {
      user = await userRepo.findOne({
        where: { email: args.userEmail, companyId },
      });
    } else if (args.userEmail) {
      // Search across all companies if companyId not provided
      user = await userRepo.findOne({
        where: { email: args.userEmail },
      });
    }

    if (!user) {
      console.error(
        `❌ User not found${args.userEmail ? ` with email '${args.userEmail}'` : ` with id '${args.userId}'`}`,
      );
      await dataSource.destroy();
      process.exit(1);
    }

    if (!companyId) {
      companyId = user.companyId;
    }

    if (user.companyId !== companyId) {
      console.error(
        `❌ User belongs to different company. User company: ${user.companyId}, Expected: ${companyId}`,
      );
      await dataSource.destroy();
      process.exit(1);
    }

    console.log(
      `✓ Found user: ${user.email} (${user.firstName || ''} ${user.lastName || ''})`.trim(),
    );

    // Resolve site
    let site: Site | null = null;
    if (args.siteId) {
      site = await siteRepo.findOne({
        where: { id: args.siteId, companyId },
      });
    } else if (args.siteCode && companyId) {
      site = await siteRepo.findOne({
        where: { code: args.siteCode, companyId },
      });
    }

    if (!site) {
      console.error(
        `❌ Site not found${args.siteCode ? ` with code '${args.siteCode}'` : ` with id '${args.siteId}'`} in company ${companyId}`,
      );
      await dataSource.destroy();
      process.exit(1);
    }

    console.log(`✓ Found site: ${site.name} (${site.code})`);

    // Check if assignment already exists
    const existing = await userSiteRepo.findOne({
      where: { companyId, userId: user.id, siteId: site.id },
    });

    if (existing) {
      console.log('\n⚠️  User is already assigned to this site');
      await dataSource.destroy();
      process.exit(0);
    }

    // Create assignment
    const userSite = userSiteRepo.create({
      companyId,
      userId: user.id,
      siteId: site.id,
    });

    await userSiteRepo.save(userSite);

    console.log('\n✅ User assigned to site successfully!');
    console.log(`   User: ${user.email}`);
    console.log(`   Site: ${site.name} (${site.code})`);
    console.log(`   Company: ${companyId}`);

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
assignUserToSite();

