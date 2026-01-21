/**
 * Seed script for villa type configurations
 * Run with: npm run seed:villa-types
 * Or: ts-node scripts/seed-villa-type-configs.ts
 */

import { DataSource } from 'typeorm';
import { VillaTypeConfig } from '../src/modules/tenant/entities/villa-type-config.entity';
import { typeOrmConfig } from '../src/shared/config/typeorm.config';

async function seedVillaTypeConfigs() {
  const dataSource = new DataSource(await typeOrmConfig());
  await dataSource.initialize();

  const configRepo = dataSource.getRepository(VillaTypeConfig);

  // Get the first company (or modify to use a specific company ID)
  const companyId = process.env.COMPANY_ID;
  if (!companyId) {
    console.error('Error: COMPANY_ID environment variable is required');
    console.log('Usage: COMPANY_ID=<uuid> npm run seed:villa-types');
    process.exit(1);
  }

  // Dubai Region Standards for Alosool Group (www.alosoolgroup.com)
  const defaultConfigs = [
    {
      villaType: 'Studio',
      displayName: 'Studio Apartment',
      defaultBedroomCount: 1,
      defaultFloorCount: 1,
      defaultAreaSqm: 35.0,
      displayOrder: 0,
      isActive: true,
    },
    {
      villaType: '1BHK',
      displayName: '1 Bedroom Hall Kitchen',
      defaultBedroomCount: 1,
      defaultFloorCount: 1,
      defaultAreaSqm: 60.0,
      displayOrder: 1,
      isActive: true,
    },
    {
      villaType: '2BHK',
      displayName: '2 Bedroom Hall Kitchen',
      defaultBedroomCount: 2,
      defaultFloorCount: 1,
      defaultAreaSqm: 95.0,
      displayOrder: 2,
      isActive: true,
    },
    {
      villaType: '3BHK',
      displayName: '3 Bedroom Hall Kitchen',
      defaultBedroomCount: 3,
      defaultFloorCount: 1,
      defaultAreaSqm: 140.0,
      displayOrder: 3,
      isActive: true,
    },
    {
      villaType: '4BHK',
      displayName: '4 Bedroom Hall Kitchen',
      defaultBedroomCount: 4,
      defaultFloorCount: 1,
      defaultAreaSqm: 200.0,
      displayOrder: 4,
      isActive: true,
    },
    {
      villaType: '5BHK',
      displayName: '5 Bedroom Hall Kitchen',
      defaultBedroomCount: 5,
      defaultFloorCount: 1,
      defaultAreaSqm: 275.0,
      displayOrder: 5,
      isActive: true,
    },
    {
      villaType: 'Penthouse',
      displayName: 'Penthouse',
      defaultBedroomCount: undefined,
      defaultFloorCount: 1,
      defaultAreaSqm: 300.0,
      displayOrder: 6,
      isActive: true,
    },
    {
      villaType: 'Duplex',
      displayName: 'Duplex Villa',
      defaultBedroomCount: undefined,
      defaultFloorCount: 2,
      defaultAreaSqm: 200.0,
      displayOrder: 7,
      isActive: true,
    },
    {
      villaType: 'Townhouse',
      displayName: 'Townhouse',
      defaultBedroomCount: undefined,
      defaultFloorCount: 2,
      defaultAreaSqm: 200.0,
      displayOrder: 8,
      isActive: true,
    },
    {
      villaType: 'Villa',
      displayName: 'Independent Villa',
      defaultBedroomCount: undefined,
      defaultFloorCount: undefined,
      defaultAreaSqm: undefined,
      displayOrder: 9,
      isActive: true,
    },
    {
      villaType: 'Mansion',
      displayName: 'Mansion',
      defaultBedroomCount: undefined,
      defaultFloorCount: undefined,
      defaultAreaSqm: 450.0,
      displayOrder: 10,
      isActive: true,
    },
  ];

  console.log(`Seeding villa type configurations for company: ${companyId}`);

  for (const config of defaultConfigs) {
    const existing = await configRepo.findOne({
      where: { companyId, villaType: config.villaType },
    });

    if (existing) {
      console.log(`  ✓ ${config.villaType} already exists, skipping...`);
      continue;
    }

    const newConfig = configRepo.create({
      companyId,
      ...config,
    });

    await configRepo.save(newConfig);
    console.log(`  ✓ Created ${config.villaType} - ${config.displayName}`);
  }

  console.log('\n✅ Seeding completed!');
  await dataSource.destroy();
}

seedVillaTypeConfigs().catch((error) => {
  console.error('Error seeding villa type configurations:', error);
  process.exit(1);
});

