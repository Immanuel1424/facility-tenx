import { DataSource } from 'typeorm';
import { Company } from '../src/modules/tenant/entities/company.entity';
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

const COMPANY_ID = 'eb75a65b-055f-4408-a58c-71d233443c17';

async function seedSites() {
  console.log('🏗  Seeding default sites...');

  await dataSource.initialize();
  const queryRunner = dataSource.createQueryRunner();
  await queryRunner.connect();
  await queryRunner.startTransaction();

  try {
    let company = await queryRunner.manager.findOne(Company, {
      where: { id: COMPANY_ID },
    });

    if (!company) {
      company = queryRunner.manager.create(Company, {
        id: COMPANY_ID,
        name: 'Villa Maintenance Company',
        code: 'VMC',
      });
      company = await queryRunner.manager.save(company);
      console.log(`✓ Created company: ${company.name}`);
    } else {
      console.log(`✓ Using existing company: ${company.name}`);
    }

    const companyId = company.id;

    let site = await queryRunner.manager.findOne(Site, {
      where: { companyId, code: 'VMC_MAIN' },
    });

    if (!site) {
      site = queryRunner.manager.create(Site, {
        companyId,
        code: 'VMC_MAIN',
        name: 'Villa Maintenance Main Site',
        description: 'Primary site for villa maintenance',
        isParent: true,
        isActive: true,
      });
      site = await queryRunner.manager.save(site);
      console.log(`✓ Created site: ${site.name}`);
    } else {
      console.log(`✓ Using existing site: ${site.name}`);
    }

    await queryRunner.commitTransaction();
    console.log('✅ Site seed completed successfully');
  } catch (error) {
    console.error('❌ Site seed failed:', error);
    await queryRunner.rollbackTransaction();
  } finally {
    await queryRunner.release();
    await dataSource.destroy();
  }
}

seedSites().catch((error) => {
  console.error('❌ Unexpected error during site seed:', error);
  process.exit(1);
});


