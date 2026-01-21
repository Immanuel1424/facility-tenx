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

interface CategoryData {
  code: string;
  name: string;
  description: string;
  displayOrder: number;
  icon?: string;
  colorCode?: string;
  defaultSlaHours?: number;
}

const DEFAULT_CATEGORIES: CategoryData[] = [
  {
    code: 'PLUMBING',
    name: 'Plumbing',
    description: 'Plumbing related issues including leaks, clogs, water pressure, and fixture repairs',
    displayOrder: 1,
    icon: 'plumber',
    colorCode: '#007be5',
    defaultSlaHours: 24,
  },
  {
    code: 'ELECTRICAL',
    name: 'Electrical',
    description: 'Electrical issues including power outages, faulty wiring, switch repairs, and lighting',
    displayOrder: 2,
    icon: 'lightning-bolt',
    colorCode: '#FFD700',
    defaultSlaHours: 12,
  },
  {
    code: 'HVAC',
    name: 'HVAC',
    description: 'Heating, ventilation, and air conditioning issues including temperature control and air quality',
    displayOrder: 3,
    icon: 'snowflake',
    colorCode: '#00CED1',
    defaultSlaHours: 24,
  },
  {
    code: 'CLEANING',
    name: 'Cleaning',
    description: 'Cleaning and maintenance requests for common areas, villas, and facilities',
    displayOrder: 4,
    icon: 'broom',
    colorCode: '#32CD32',
    defaultSlaHours: 48,
  },
  {
    code: 'SECURITY',
    name: 'Security',
    description: 'Security related issues including access control, CCTV, alarms, and safety concerns',
    displayOrder: 5,
    icon: 'shield',
    colorCode: '#FF4500',
    defaultSlaHours: 6,
  },
  {
    code: 'GENERAL_MAINTENANCE',
    name: 'General Maintenance',
    description: 'General maintenance and repairs including painting, carpentry, and minor fixes',
    displayOrder: 6,
    icon: 'wrench',
    colorCode: '#808080',
    defaultSlaHours: 72,
  },
  {
    code: 'LANDSCAPING',
    name: 'Landscaping',
    description: 'Landscaping and outdoor maintenance including gardening, irrigation, and outdoor repairs',
    displayOrder: 7,
    icon: 'tree',
    colorCode: '#228B22',
    defaultSlaHours: 48,
  },
  {
    code: 'IT',
    name: 'IT Support',
    description: 'IT related issues including network problems, computer repairs, and system updates',
    displayOrder: 8,
    icon: 'computer',
    colorCode: '#4169E1',
    defaultSlaHours: 24,
  },
  {
    code: 'SAFETY',
    name: 'Safety',
    description: 'Safety concerns including fire safety equipment, emergency exits, and hazard reports',
    displayOrder: 9,
    icon: 'exclamation-triangle',
    colorCode: '#FF0000',
    defaultSlaHours: 4,
  },
  {
    code: 'APPLIANCE',
    name: 'Appliance Repair',
    description: 'Appliance repairs including refrigerators, washing machines, dishwashers, and other household appliances',
    displayOrder: 10,
    icon: 'home',
    colorCode: '#9370DB',
    defaultSlaHours: 48,
  },
  {
    code: 'PEST_CONTROL',
    name: 'Pest Control',
    description: 'Pest control services including insects, rodents, and other pest-related issues',
    displayOrder: 11,
    icon: 'bug',
    colorCode: '#8B4513',
    defaultSlaHours: 24,
  },
  {
    code: 'ELEVATOR',
    name: 'Elevator',
    description: 'Elevator maintenance, repairs, and service issues',
    displayOrder: 12,
    icon: 'arrow-up',
    colorCode: '#2F4F4F',
    defaultSlaHours: 6,
  },
];

async function seedCategories() {
  try {
    await dataSource.initialize();
    console.log('✅ Database connected\n');

    const companyRepo = dataSource.getRepository(Company);
    const categoryRepo = dataSource.getRepository(TicketCategory);

    // Get all companies
    const companies = await companyRepo.find();

    if (companies.length === 0) {
      console.log('❌ No companies found. Please create a company first.');
      await dataSource.destroy();
      process.exit(1);
    }

    console.log(`📦 Found ${companies.length} company/companies\n`);
    console.log('='.repeat(80));

    let totalCreated = 0;
    let totalSkipped = 0;

    for (const company of companies) {
      console.log(`\n🏢 Processing Company: ${company.name} (${company.code})`);
      console.log('─'.repeat(80));

      let createdForCompany = 0;
      let skippedForCompany = 0;

      for (const catData of DEFAULT_CATEGORIES) {
        // Check if category exists by code
        let category = await categoryRepo.findOne({
          where: { companyId: company.id, code: catData.code },
        });

        if (category) {
          console.log(`  ⚠️  Category "${catData.name}" (${catData.code}) already exists`);
          console.log(`     ID: ${category.id}`);
          console.log(`     Active: ${category.isActive ? '✅' : '❌'}`);
          skippedForCompany++;
          totalSkipped++;
        } else {
          // Create category
          category = categoryRepo.create({
            companyId: company.id,
            code: catData.code,
            name: catData.name,
            description: catData.description,
            displayOrder: catData.displayOrder,
            isActive: true,
            icon: catData.icon,
            colorCode: catData.colorCode,
            defaultSlaHours: catData.defaultSlaHours,
          });

          category = await categoryRepo.save(category);
          console.log(`  ✅ Created category "${catData.name}" (${catData.code})`);
          console.log(`     ID: ${category.id}`);
          console.log(`     SLA: ${catData.defaultSlaHours} hours`);
          createdForCompany++;
          totalCreated++;
        }
      }

      // Display summary for this company
      console.log(`\n  📊 Summary for ${company.name}:`);
      console.log(`     - Created in this run: ${createdForCompany}`);
      console.log(`     - Already Existed: ${skippedForCompany}`);
      console.log(`     - Total Categories: ${DEFAULT_CATEGORIES.length}`);
    }

    // Final summary
    console.log('\n' + '='.repeat(80));
    console.log('📋 FINAL SUMMARY');
    console.log('='.repeat(80));
    console.log(`✅ Total Categories Created: ${totalCreated}`);
    console.log(`⚠️  Total Categories Skipped (already exist): ${totalSkipped}`);
    console.log(`📦 Total Companies Processed: ${companies.length}`);

    // Display all category names
    console.log('\n' + '='.repeat(80));
    console.log('📝 DEFAULT CATEGORIES LOADED:');
    console.log('='.repeat(80));
    for (let i = 0; i < DEFAULT_CATEGORIES.length; i++) {
      const cat = DEFAULT_CATEGORIES[i];
      console.log(
        `  ${(i + 1).toString().padStart(2, ' ')}. ${cat.name.padEnd(25, ' ')} (${cat.code.padEnd(20, ' ')}) - ${cat.description}`,
      );
    }

    // Verify categories for each company
    console.log('\n' + '='.repeat(80));
    console.log('🔍 VERIFICATION - Categories by Company:');
    console.log('='.repeat(80));

    for (const company of companies) {
      const categories = await categoryRepo.find({
        where: { companyId: company.id },
        order: { displayOrder: 'ASC' },
      });

      console.log(`\n🏢 ${company.name} (${company.code}):`);
      console.log(`   Total Categories: ${categories.length}`);
      console.log('   Categories:');
      for (const cat of categories) {
        const status = cat.isActive ? '✅' : '❌';
        console.log(`     ${status} ${cat.name.padEnd(25, ' ')} (${cat.code})`);
      }
    }

    await dataSource.destroy();
    console.log('\n✅ Script completed successfully!\n');
  } catch (error) {
    console.error('❌ Error:', error);
    if (dataSource.isInitialized) {
      await dataSource.destroy();
    }
    process.exit(1);
  }
}

seedCategories();
