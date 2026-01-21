/**
 * Script to sync villa occupancy status based on actual tenant assignments
 * 
 * This script fixes existing data where villas may show as VACANT even though
 * tenants are assigned to them.
 * 
 * Usage:
 *   npx ts-node scripts/sync-villa-occupancy.ts [companyId]
 * 
 * If companyId is not provided, it will sync all companies.
 */

import { DataSource } from 'typeorm';
import { Villa } from '../src/modules/tenant/entities/villa.entity';
import { User } from '../src/modules/iam/entities/user.entity';

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

async function syncVillaOccupancy(companyId?: string) {
  await dataSource.initialize();
  console.log('✅ Database connected');

  try {
    const villaRepo = dataSource.getRepository(Villa);
    const userRepo = dataSource.getRepository(User);

    // Build query for villas
    let villaQuery = villaRepo.createQueryBuilder('villa');
    if (companyId) {
      villaQuery = villaQuery.where('villa.companyId = :companyId', { companyId });
    }

    const villas = await villaQuery.getMany();
    console.log(`📊 Found ${villas.length} villas to check`);

    // Get all users with villa assignments
    let userQuery = userRepo.createQueryBuilder('user');
    if (companyId) {
      userQuery = userQuery.where('user.companyId = :companyId', { companyId });
    }

    const users = await userQuery
      .select(['user.villaNumber', 'user.villaNumbers', 'user.companyId'])
      .getMany();

    // Build a map of company -> assigned villa numbers
    const companyVillaMap = new Map<string, Set<string>>();

    users.forEach((user) => {
      if (!companyVillaMap.has(user.companyId)) {
        companyVillaMap.set(user.companyId, new Set<string>());
      }
      const villaSet = companyVillaMap.get(user.companyId)!;

      if (user.villaNumber) {
        villaSet.add(user.villaNumber.toString());
      }
      if (user.villaNumbers && Array.isArray(user.villaNumbers)) {
        user.villaNumbers.forEach((num) => {
          if (num) {
            villaSet.add(num.toString());
          }
        });
      }
    });

    console.log(`👥 Found ${users.length} users with villa assignments`);

    let updated = 0;
    let errors = 0;

    // Update each villa
    for (const villa of villas) {
      try {
        const assignedVillas = companyVillaMap.get(villa.companyId) || new Set<string>();
        const shouldBeOccupied = assignedVillas.has(villa.villaNumber);

        if (villa.isOccupied !== shouldBeOccupied) {
          console.log(
            `🔄 Updating Villa ${villa.villaNumber} (${villa.companyId}): ${villa.isOccupied ? 'OCCUPIED' : 'VACANT'} -> ${shouldBeOccupied ? 'OCCUPIED' : 'VACANT'}`,
          );
          villa.isOccupied = shouldBeOccupied;
          await villaRepo.save(villa);
          updated++;
        }
      } catch (error) {
        console.error(
          `❌ Error syncing villa ${villa.villaNumber} (${villa.companyId}):`,
          error,
        );
        errors++;
      }
    }

    console.log('\n📈 Summary:');
    console.log(`   Total villas: ${villas.length}`);
    console.log(`   Updated: ${updated}`);
    console.log(`   Errors: ${errors}`);
    console.log(`   Unchanged: ${villas.length - updated - errors}`);

    if (updated > 0) {
      console.log('\n✅ Villa occupancy status synced successfully!');
    } else {
      console.log('\n✅ All villas are already in sync.');
    }
  } catch (error) {
    console.error('❌ Error syncing villa occupancy:', error);
    throw error;
  } finally {
    await dataSource.destroy();
  }
}

// Run the script
const companyId = process.argv[2];

if (companyId) {
  console.log(`🔄 Syncing villa occupancy for company: ${companyId}`);
} else {
  console.log('🔄 Syncing villa occupancy for all companies...');
}

syncVillaOccupancy(companyId)
  .then(() => {
    console.log('✅ Script completed');
    process.exit(0);
  })
  .catch((error) => {
    console.error('❌ Script failed:', error);
    process.exit(1);
  });
