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

// Company name prefixes and suffixes for variety
const COMPANY_PREFIXES = [
  'Global', 'International', 'National', 'Premier', 'Elite', 'Advanced', 'Modern',
  'Innovative', 'Strategic', 'Dynamic', 'Prime', 'Superior', 'Excellence', 'Pro',
  'Tech', 'Digital', 'Smart', 'Future', 'Next', 'Ultra', 'Mega', 'Max', 'Pro',
  'Alpha', 'Beta', 'Gamma', 'Delta', 'Omega', 'Apex', 'Summit', 'Peak',
  'Enterprise', 'Corporate', 'Business', 'Commercial', 'Industrial', 'Professional',
];

const COMPANY_NAMES = [
  'Solutions', 'Systems', 'Services', 'Group', 'Holdings', 'Industries', 'Corporation',
  'Enterprises', 'Partners', 'Associates', 'Alliance', 'Network', 'Ventures', 'Capital',
  'Management', 'Consulting', 'Advisory', 'Resources', 'Technologies', 'Innovations',
  'Developments', 'Operations', 'Logistics', 'Supply', 'Distribution', 'Manufacturing',
  'Trading', 'Commerce', 'Retail', 'Wholesale', 'Import', 'Export', 'International',
  'Global', 'Worldwide', 'Regional', 'Local', 'National', 'Federal', 'State',
];

const COMPANY_TYPES = [
  'Facility Management', 'Property Management', 'Real Estate', 'Construction',
  'Maintenance Services', 'Cleaning Services', 'Security Services', 'IT Services',
  'Consulting', 'Trading', 'Manufacturing', 'Logistics', 'Healthcare', 'Education',
  'Hospitality', 'Retail', 'Finance', 'Insurance', 'Legal', 'Marketing', 'Media',
  'Telecommunications', 'Energy', 'Utilities', 'Transportation', 'Automotive',
  'Food & Beverage', 'Fashion', 'Entertainment', 'Sports', 'Fitness', 'Wellness',
];

const TIMEZONES = [
  'UTC', 'America/New_York', 'America/Chicago', 'America/Denver', 'America/Los_Angeles',
  'America/Toronto', 'America/Mexico_City', 'Europe/London', 'Europe/Paris', 'Europe/Berlin',
  'Europe/Rome', 'Europe/Madrid', 'Europe/Amsterdam', 'Asia/Dubai', 'Asia/Singapore',
  'Asia/Tokyo', 'Asia/Shanghai', 'Asia/Hong_Kong', 'Asia/Mumbai', 'Asia/Kolkata',
  'Asia/Bangkok', 'Asia/Jakarta', 'Australia/Sydney', 'Australia/Melbourne',
  'Pacific/Auckland', 'America/Sao_Paulo', 'America/Buenos_Aires',
];

const CURRENCIES = [
  'USD', 'EUR', 'GBP', 'JPY', 'CNY', 'INR', 'AED', 'SAR', 'AUD', 'CAD', 'CHF',
  'SGD', 'HKD', 'NZD', 'MXN', 'BRL', 'ZAR', 'KRW', 'THB', 'MYR', 'IDR', 'PHP',
];

const COMPANY_DESCRIPTIONS = [
  'Leading provider of comprehensive facility management solutions',
  'Premier property management and maintenance services',
  'Innovative solutions for modern businesses',
  'Trusted partner for enterprise operations',
  'Excellence in service delivery and customer satisfaction',
  'Cutting-edge technology solutions for facility management',
  'Comprehensive maintenance and support services',
  'Professional property management and real estate services',
  'Reliable partner for all your facility needs',
  'Industry-leading solutions and exceptional service quality',
  'Dedicated to providing top-tier facility management services',
  'Your trusted partner in property and facility operations',
  'Comprehensive solutions for modern facility challenges',
  'Excellence in maintenance, operations, and customer service',
  'Innovative approaches to facility and property management',
];

function generateCompanyName(index: number): string {
  const prefix = COMPANY_PREFIXES[Math.floor(Math.random() * COMPANY_PREFIXES.length)];
  const name = COMPANY_NAMES[Math.floor(Math.random() * COMPANY_NAMES.length)];
  const type = COMPANY_TYPES[Math.floor(Math.random() * COMPANY_TYPES.length)];
  
  // Mix different naming patterns for variety
  const pattern = index % 5;
  switch (pattern) {
    case 0:
      return `${prefix} ${name}`;
    case 1:
      return `${prefix} ${type}`;
    case 2:
      return `${name} ${type}`;
    case 3:
      return `${prefix} ${name} ${type}`;
    default:
      return `${name} ${type}`;
  }
}

function generateCompanyCode(index: number): string {
  // Generate unique codes: COMP001, COMP002, etc.
  return `COMP${String(index + 1).padStart(3, '0')}`;
}

function generateDescription(): string {
  const base = COMPANY_DESCRIPTIONS[Math.floor(Math.random() * COMPANY_DESCRIPTIONS.length)];
  const additions = [
    ' with a focus on quality and efficiency.',
    ' serving clients across multiple industries.',
    ' committed to sustainable practices.',
    ' leveraging advanced technology and expertise.',
    ' with a proven track record of success.',
    ' dedicated to exceeding client expectations.',
    ' providing 24/7 support and maintenance.',
    ' with extensive industry experience.',
  ];
  return base + additions[Math.floor(Math.random() * additions.length)];
}

function generateLogoUrl(): string | undefined {
  // 70% chance of having a logo URL
  if (Math.random() > 0.3) {
    const logoTypes = ['logo', 'brand', 'icon', 'mark'];
    const logoType = logoTypes[Math.floor(Math.random() * logoTypes.length)];
    const id = Math.floor(Math.random() * 1000);
    return `https://example.com/logos/${logoType}-${id}.png`;
  }
  return undefined;
}

async function seedCompanies() {
  try {
    await dataSource.initialize();
    console.log('Database connected');

    const companyRepo = dataSource.getRepository(Company);

    // Get all existing company codes to avoid duplicates
    const existingCompanies = await companyRepo.find({ select: ['code'] });
    const existingCodes = new Set(existingCompanies.map((c) => c.code));
    const existingCount = existingCodes.size;
    console.log(`Existing companies in database: ${existingCount}`);

    // Allow target count to be set via environment variable, default to 2500
    const targetCount = Number(process.env.TARGET_COMPANIES) || 2500;
    const companiesToCreate = targetCount - existingCount;

    if (companiesToCreate <= 0) {
      console.log(`Database already has ${existingCount} companies. Target is ${targetCount}.`);
      console.log('No new companies to create.');
      await dataSource.destroy();
      return;
    }

    console.log(`Creating ${companiesToCreate} new companies...`);

    const companies: Partial<Company>[] = [];
    const batchSize = 50; // Insert in batches for better performance
    let codeCounter = existingCount;

    for (let i = 0; i < companiesToCreate; i++) {
      // Generate unique code
      let code: string;
      let attempts = 0;
      do {
        code = generateCompanyCode(codeCounter);
        codeCounter++;
        attempts++;
        if (attempts > 1000) {
          // Fallback to timestamp-based code if too many attempts
          code = `COMP${Date.now()}-${i}`;
          break;
        }
      } while (existingCodes.has(code));

      existingCodes.add(code); // Mark as used

      const company: Partial<Company> = {
        code,
        name: generateCompanyName(i),
        description: generateDescription(),
        logoUrl: generateLogoUrl(),
        timezone: TIMEZONES[Math.floor(Math.random() * TIMEZONES.length)],
        currency: CURRENCIES[Math.floor(Math.random() * CURRENCIES.length)],
        isActive: Math.random() > 0.1, // 90% active, 10% inactive
      };

      companies.push(company);

      // Insert in batches
      if (companies.length >= batchSize || i === companiesToCreate - 1) {
        await companyRepo.save(companies);
        console.log(`Created batch: ${companies.length} companies (Progress: ${i + 1}/${companiesToCreate})`);
        companies.length = 0; // Clear array for next batch
      }
    }

    const finalCount = await companyRepo.count();
    console.log(`\n✅ Successfully seeded companies!`);
    console.log(`Total companies in database: ${finalCount}`);

    // Show sample of created companies
    const sampleCompanies = await companyRepo.find({
      take: 5,
      order: { createdAt: 'DESC' },
    });

    console.log('\n📋 Sample of created companies:');
    sampleCompanies.forEach((company) => {
      console.log(`  - ${company.code}: ${company.name} (${company.currency}, ${company.timezone})`);
    });

    await dataSource.destroy();
    console.log('\n✅ Database connection closed');
  } catch (error) {
    console.error('❌ Error seeding companies:', error);
    if (dataSource.isInitialized) {
      await dataSource.destroy();
    }
    process.exit(1);
  }
}

// Run the seed function
seedCompanies();

