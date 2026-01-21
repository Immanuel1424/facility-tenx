import { DataSource } from 'typeorm';
import { UserSite } from '../src/modules/tenant/entities/user-site.entity';
import { User } from '../src/modules/iam/entities/user.entity';
import { Site } from '../src/modules/tenant/entities/site.entity';

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

async function verifyAssignment() {
  try {
    await dataSource.initialize();
    console.log('✓ Database connected\n');

    const userRepo = dataSource.getRepository(User);
    const siteRepo = dataSource.getRepository(Site);
    const userSiteRepo = dataSource.getRepository(UserSite);

    const email = 'vivek.ellappan@helixsense.com';
    const siteCode = 'COM0001';

    // Find user
    const user = await userRepo.findOne({
      where: { email },
    });

    if (!user) {
      console.error(`❌ User not found: ${email}`);
      await dataSource.destroy();
      process.exit(1);
    }

    console.log(`✓ User: ${email}`);
    console.log(`  User ID: ${user.id}`);
    console.log(`  Company ID: ${user.companyId}\n`);

    // Find site in user's company
    const site = await siteRepo.findOne({
      where: { code: siteCode, companyId: user.companyId },
      relations: ['company'],
    });

    if (!site) {
      console.error(
        `❌ Site '${siteCode}' not found in company ${user.companyId}`,
      );
      await dataSource.destroy();
      process.exit(1);
    }

    console.log(`✓ Site: ${site.name} (${site.code})`);
    console.log(`  Site ID: ${site.id}`);
    console.log(`  Company ID: ${site.companyId}\n`);

    // Check assignment
    const assignment = await userSiteRepo.findOne({
      where: {
        companyId: user.companyId,
        userId: user.id,
        siteId: site.id,
      },
    });

    if (assignment) {
      console.log('✅ Assignment EXISTS!');
      console.log(`  Assignment ID: ${assignment.id}`);
      console.log(`  Company ID: ${assignment.companyId}`);
      console.log(`  User ID: ${assignment.userId}`);
      console.log(`  Site ID: ${assignment.siteId}`);
      console.log('\n✅ User can login successfully!');
    } else {
      console.log('❌ Assignment NOT FOUND!');
      console.log('   User cannot login.');
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

verifyAssignment();

