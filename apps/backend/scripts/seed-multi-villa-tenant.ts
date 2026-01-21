import { DataSource } from 'typeorm';
import { User } from '../src/modules/iam/entities/user.entity';
import { Villa } from '../src/modules/tenant/entities/villa.entity';

/**
 * Utility seed script to attach multiple villas to a single tenant user
 * using the user_villas junction table.
 *
 * This script is intentionally scoped to the default demo company and
 * the tenant user `villa86@tenant.com`, and will create three villa
 * mappings for that user if matching villas exist.
 */

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

async function seedMultiVillaTenant(): Promise<void> {
  const companyId = 'eb75a65b-055f-4408-a58c-71d233443c17';
  const tenantEmail = 'villa86@tenant.com';

  try {
    await dataSource.initialize();
    console.log('✓ Database connected\n');

    const queryRunner = dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      const userRepo = dataSource.getRepository(User);
      const villaRepo = dataSource.getRepository(Villa);

      const user = await userRepo.findOne({
        where: { companyId, email: tenantEmail },
      });

      if (!user) {
        console.log(`⚠️  User ${tenantEmail} not found in company ${companyId}`);
        await queryRunner.rollbackTransaction();
        await queryRunner.release();
        await dataSource.destroy();
        process.exit(0);
        return;
      }

      console.log(`👤 Found tenant user: ${user.email} (${user.id})`);

      // Pick three villa numbers to attach/create for this user:
      //  - 86 (their original demo villa number)
      //  - 85 and 84 as additional villas for demo purposes.
      const villaNumbers = [84, 85, 86];

      // Ensure villas exist for these numbers; create minimal rows if missing.
      const villaRows: Array<{ id: string; villa_number: number }> = [];

      for (const num of villaNumbers) {
        let existing = await villaRepo.findOne({
          where: { companyId, villaNumber: num },
        });

        if (!existing) {
          const created = villaRepo.create({
            companyId,
            villaNumber: num,
            villaCode: `V${num}`,
            isActive: true,
            isOccupied: true,
          });
          existing = await villaRepo.save(created);
          console.log(`🏗  Created villa ${num} (${existing.id}) for company ${companyId}`);
        } else {
          console.log(`✓ Found existing villa ${num} (${existing.id})`);
        }

        villaRows.push({
          id: existing.id,
          villa_number: existing.villaNumber,
        });
      }

      console.log('🏘  Villas for multi-villa tenant:');
      for (const row of villaRows) {
        console.log(`   - Villa ${row.villa_number} (${row.id})`);
      }

      // Insert mappings into user_villas if they do not already exist.
      for (const row of villaRows) {
        const existing: Array<{ id: string }> = await queryRunner.query(
          `
            SELECT id
            FROM user_villas
            WHERE company_id = $1
              AND user_id = $2
              AND villa_id = $3
          `,
          [companyId, user.id, row.id],
        );

        if (existing.length > 0) {
          console.log(
            `✓ Mapping already exists for user ${tenantEmail} and villa ${row.villa_number}`,
          );
          continue;
        }

        await queryRunner.query(
          `
            INSERT INTO user_villas (company_id, user_id, villa_id)
            VALUES ($1, $2, $3)
          `,
          [companyId, user.id, row.id],
        );

        console.log(
          `✅ Added user_villas mapping: ${tenantEmail} -> villa ${row.villa_number}`,
        );
      }

      await queryRunner.commitTransaction();
      await queryRunner.release();
      console.log('\n✅ Multi-villa tenant seed completed successfully');
    } catch (error) {
      console.error('❌ Error seeding multi-villa tenant:', error);
      await queryRunner.rollbackTransaction();
      throw error;
    } finally {
      await dataSource.destroy();
    }
  } catch (error) {
    console.error('❌ Unexpected error during seed-multi-villa-tenant:', error);
    process.exit(1);
  }
}

seedMultiVillaTenant().catch((error) => {
  console.error('❌ Fatal error in seed-multi-villa-tenant:', error);
  process.exit(1);
});


