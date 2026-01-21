import { DataSource } from 'typeorm';
import { TicketCategory } from '../src/modules/maintenance-ticket/entities/ticket-category.entity';
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

const CATEGORIES = [
  { code: 'PLUMBING', name: 'Plumbing', description: 'Plumbing related issues', displayOrder: 1 },
  { code: 'ELECTRICAL', name: 'Electrical', description: 'Electrical related issues', displayOrder: 2 },
  { code: 'HVAC', name: 'HVAC', description: 'Heating, ventilation, and air conditioning', displayOrder: 3 },
  { code: 'CLEANING', name: 'Cleaning', description: 'Cleaning and maintenance requests', displayOrder: 4 },
  { code: 'SECURITY', name: 'Security', description: 'Security related issues', displayOrder: 5 },
  { code: 'GENERAL', name: 'General Maintenance', description: 'General maintenance and repairs', displayOrder: 6 },
  { code: 'LANDSCAPING', name: 'Landscaping', description: 'Landscaping and outdoor maintenance', displayOrder: 7 },
];

async function verifyAndCreateCategories() {
  try {
    await dataSource.initialize();
    console.log('✅ Database connected\n');

    const companyRepo = dataSource.getRepository(Company);
    const categoryRepo = dataSource.getRepository(TicketCategory);

    // Get all companies
    const companies = await companyRepo.find();
    
    if (companies.length === 0) {
      console.log('❌ No companies found. Please run seed script first.');
      await dataSource.destroy();
      process.exit(1);
    }

    console.log(`Found ${companies.length} company/companies\n`);

    for (const company of companies) {
      console.log(`\n📦 Processing company: ${company.name} (${company.id})`);
      console.log('─'.repeat(60));

      for (const catData of CATEGORIES) {
        // Check if category exists by code
        let category = await categoryRepo.findOne({
          where: { companyId: company.id, code: catData.code },
        });

        if (category) {
          console.log(`  ✅ Category "${catData.code}" already exists`);
          console.log(`     - ID: ${category.id}`);
          console.log(`     - Name: ${category.name}`);
          console.log(`     - Active: ${category.isActive}`);
        } else {
          // Create category
          category = categoryRepo.create({
            companyId: company.id,
            code: catData.code,
            name: catData.name,
            description: catData.description,
            displayOrder: catData.displayOrder,
            isActive: true,
          });

          category = await categoryRepo.save(category);
          console.log(`  ✅ Created category "${catData.code}"`);
          console.log(`     - ID: ${category.id}`);
          console.log(`     - Name: ${category.name}`);
        }
      }
    }

    console.log('\n' + '='.repeat(60));
    console.log('✅ Category verification completed!\n');

    // Verify PLUMBING category specifically
    console.log('🔍 Verifying PLUMBING category...');
    for (const company of companies) {
      const plumbingCategory = await categoryRepo.findOne({
        where: [
          { companyId: company.id, code: 'PLUMBING' },
          { companyId: company.id, name: 'Plumbing' },
        ],
      });

      if (plumbingCategory) {
        console.log(`\n✅ PLUMBING category found for company ${company.name}:`);
        console.log(`   - ID: ${plumbingCategory.id}`);
        console.log(`   - Code: ${plumbingCategory.code}`);
        console.log(`   - Name: ${plumbingCategory.name}`);
        console.log(`   - Active: ${plumbingCategory.isActive}`);
        console.log(`   - Company ID: ${plumbingCategory.companyId}`);
      } else {
        console.log(`\n❌ PLUMBING category NOT found for company ${company.name}`);
      }
    }

    await dataSource.destroy();
    console.log('\n✅ Script completed successfully!');
  } catch (error) {
    console.error('❌ Error:', error);
    if (dataSource.isInitialized) {
      await dataSource.destroy();
    }
    process.exit(1);
  }
}

verifyAndCreateCategories();

