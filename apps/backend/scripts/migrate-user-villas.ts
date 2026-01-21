import { DataSource } from 'typeorm';

/**
 * Lightweight migration script to create the user_villas table if it does not exist.
 * This avoids the "relation \"user_villas\" does not exist" error in multi-villa
 * logic while relying on the legacy users.villa_number field as a fallback.
 *
 * NOTE: This script does NOT backfill data; MaintenanceTicketService will fall back
 * to user.villaNumber when user_villas is empty.
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

async function migrateUserVillas() {
  console.log('🏗  Creating user_villas table if needed...');

  await dataSource.initialize();
  const queryRunner = dataSource.createQueryRunner();
  await queryRunner.connect();
  await queryRunner.startTransaction();

  try {
    // Create table and indexes if not exist
    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS user_villas (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        company_id UUID NOT NULL,
        user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        villa_id UUID NOT NULL REFERENCES villas(id) ON DELETE CASCADE,
        created_at TIMESTAMPTZ DEFAULT now(),
        CONSTRAINT uq_user_villas_company_user_villa UNIQUE (company_id, user_id, villa_id)
      );
    `);

    await queryRunner.query(`
      CREATE INDEX IF NOT EXISTS idx_user_villas_company_user
        ON user_villas(company_id, user_id);
    `);

    await queryRunner.query(`
      CREATE INDEX IF NOT EXISTS idx_user_villas_company_villa
        ON user_villas(company_id, villa_id);
    `);

    await queryRunner.commitTransaction();
    console.log('✅ user_villas table is ready');
  } catch (error) {
    console.error('❌ Failed to create user_villas table:', error);
    await queryRunner.rollbackTransaction();
    process.exitCode = 1;
  } finally {
    await queryRunner.release();
    await dataSource.destroy();
  }
}

migrateUserVillas().catch((error) => {
  console.error('❌ Unexpected error during user_villas migration:', error);
  process.exit(1);
});


