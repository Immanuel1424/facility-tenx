import { DataSource } from 'typeorm';
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

async function updateCompanyCode() {
  try {
    await dataSource.initialize();
    console.log('✅ Database connected\n');

    const companyRepo = dataSource.getRepository(Company);

    // Find company with code "VMC"
    const company = await companyRepo.findOne({
      where: { code: 'VMC' },
    });

    if (!company) {
      console.error('❌ Company with code "VMC" not found');
      console.log('\n📋 Available companies:');
      const allCompanies = await companyRepo.find();
      for (const c of allCompanies) {
        console.log(`   - Code: ${c.code}, Name: ${c.name}, ID: ${c.id}`);
      }
      await dataSource.destroy();
      process.exit(1);
    }

    console.log('📋 Current company information:');
    console.log(`   ID: ${company.id}`);
    console.log(`   Code: ${company.code}`);
    console.log(`   Name: ${company.name}\n`);

    // Check if "ALOS" already exists
    const existingAlos = await companyRepo.findOne({
      where: { code: 'ALOS' },
    });

    if (existingAlos && existingAlos.id !== company.id) {
      console.error('❌ Company with code "ALOS" already exists:');
      console.log(`   ID: ${existingAlos.id}`);
      console.log(`   Name: ${existingAlos.name}`);
      console.log('\n⚠️  Cannot update: code "ALOS" is already in use');
      await dataSource.destroy();
      process.exit(1);
    }

    // Update the code
    console.log('🔄 Updating company code from "VMC" to "ALOS"...');
    company.code = 'ALOS';
    const updatedCompany = await companyRepo.save(company);

    console.log('\n✅ Company code updated successfully!');
    console.log('📋 Updated company information:');
    console.log(`   ID: ${updatedCompany.id}`);
    console.log(`   Code: ${updatedCompany.code}`);
    console.log(`   Name: ${updatedCompany.name}\n`);

    await dataSource.destroy();
    process.exit(0);
  } catch (error: any) {
    console.error('❌ Error updating company code:', error.message);
    if (error.stack) {
      console.error(error.stack);
    }
    await dataSource.destroy();
    process.exit(1);
  }
}

updateCompanyCode();

