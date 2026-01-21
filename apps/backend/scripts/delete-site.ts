import { DataSource } from 'typeorm';
import { Site } from '../src/modules/tenant/entities/site.entity';
import { UserSite } from '../src/modules/tenant/entities/user-site.entity';
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
  siteId?: string;
  siteCode?: string;
  companyCode?: string;
  force?: boolean;
} {
  const args: {
    siteId?: string;
    siteCode?: string;
    companyCode?: string;
    force?: boolean;
  } = {};

  process.argv.slice(2).forEach((arg) => {
    if (arg.startsWith('--siteId=')) {
      args.siteId = arg.split('=')[1];
    } else if (arg.startsWith('--siteCode=')) {
      args.siteCode = arg.split('=')[1];
    } else if (arg.startsWith('--companyCode=')) {
      args.companyCode = arg.split('=')[1];
    } else if (arg === '--force') {
      args.force = true;
    }
  });

  return args;
}

async function deleteSite() {
  try {
    await dataSource.initialize();
    console.log('✓ Database connected\n');

    const args = parseArgs();

    if (!args.siteId && !args.siteCode) {
      console.error('❌ Error: Either --siteId or --siteCode is required');
      console.log('\nUsage:');
      console.log(
        '  npm run delete:site -- --siteId=<uuid> [--force]',
      );
      console.log(
        '  npm run delete:site -- --siteCode=<code> --companyCode=<code> [--force]',
      );
      await dataSource.destroy();
      process.exit(1);
    }

    const siteRepo = dataSource.getRepository(Site);
    const userSiteRepo = dataSource.getRepository(UserSite);
    const companyRepo = dataSource.getRepository(Company);

    // Resolve site
    let site: Site | null = null;
    if (args.siteId) {
      site = await siteRepo.findOne({
        where: { id: args.siteId },
        relations: ['company'],
      });
    } else if (args.siteCode && args.companyCode) {
      const company = await companyRepo.findOne({
        where: { code: args.companyCode },
      });
      if (!company) {
        console.error(`❌ Company with code '${args.companyCode}' not found`);
        await dataSource.destroy();
        process.exit(1);
      }
      site = await siteRepo.findOne({
        where: { code: args.siteCode, companyId: company.id },
        relations: ['company'],
      });
    }

    if (!site) {
      console.error(
        `❌ Site not found${args.siteCode ? ` with code '${args.siteCode}'` : ` with id '${args.siteId}'`}`,
      );
      await dataSource.destroy();
      process.exit(1);
    }

    console.log(`✓ Found site: ${site.name} (${site.code})`);
    console.log(`  Site ID: ${site.id}`);
    console.log(`  Company: ${site.company?.name || 'N/A'} (${site.companyId})`);
    console.log(`  Is Active: ${site.isActive}`);

    // Check for dependencies
    const userSiteCount = await userSiteRepo.count({
      where: { siteId: site.id },
    });

    console.log(`\n📋 Dependencies:`);
    console.log(`  Users assigned to site: ${userSiteCount}`);

    if (userSiteCount > 0 && !args.force) {
      console.error(
        `\n❌ Cannot delete site: ${userSiteCount} user(s) are assigned to this site.`,
      );
      console.log(
        `   Use --force to delete anyway (will remove all user-site assignments).`,
      );
      await dataSource.destroy();
      process.exit(1);
    }

    // Confirm deletion
    if (!args.force) {
      console.log(
        `\n⚠️  This will permanently delete the site and all associated data.`,
      );
      console.log(`   Use --force to skip this confirmation.`);
      await dataSource.destroy();
      process.exit(0);
    }

    // Delete user-site assignments first
    if (userSiteCount > 0) {
      console.log(`\n🗑️  Deleting ${userSiteCount} user-site assignment(s)...`);
      await userSiteRepo.delete({ siteId: site.id });
      console.log(`✓ Deleted user-site assignments`);
    }

    // Delete the site
    console.log(`\n🗑️  Deleting site...`);
    await siteRepo.remove(site);

    console.log(`\n✅ Site deleted successfully!`);
    console.log(`   Deleted: ${site.name} (${site.code})`);

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
deleteSite();

