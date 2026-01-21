import { DataSource } from 'typeorm';
import { Villa } from '../src/modules/tenant/entities/villa.entity';
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

async function countVillas() {
  try {
    await dataSource.initialize();
    console.log('Connected to database');

    const villaRepository = dataSource.getRepository(Villa);
    const companyRepository = dataSource.getRepository(Company);

    // Get all companies
    const companies = await companyRepository.find();
    console.log(`\nFound ${companies.length} company(ies)\n`);

    // Count villas per company
    for (const company of companies) {
      const totalCount = await villaRepository.count({
        where: { companyId: company.id },
      });

      const activeCount = await villaRepository.count({
        where: { companyId: company.id, isActive: true },
      });

      const occupiedCount = await villaRepository.count({
        where: { companyId: company.id, isOccupied: true },
      });

      console.log(`Company: ${company.name} (ID: ${company.id})`);
      console.log(`  Total Villas: ${totalCount}`);
      console.log(`  Active Villas: ${activeCount}`);
      console.log(`  Occupied Villas: ${occupiedCount}`);
      console.log('');
    }

    // Overall total
    const overallTotal = await villaRepository.count();
    const overallActive = await villaRepository.count({
      where: { isActive: true },
    });
    const overallOccupied = await villaRepository.count({
      where: { isOccupied: true },
    });

    console.log('='.repeat(50));
    console.log(`OVERALL TOTALS:`);
    console.log(`  Total Villas: ${overallTotal}`);
    console.log(`  Active Villas: ${overallActive}`);
    console.log(`  Occupied Villas: ${overallOccupied}`);
    console.log('='.repeat(50));

    await dataSource.destroy();
  } catch (error) {
    console.error('Error counting villas:', error);
    process.exit(1);
  }
}

countVillas();

