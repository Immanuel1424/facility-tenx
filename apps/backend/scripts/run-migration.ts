import { DataSource } from 'typeorm';
import * as fs from 'fs';
import * as path from 'path';

const dataSource = new DataSource({
  type: 'postgres',
  host: process.env.DB_HOST || 'localhost',
  port: Number(process.env.DB_PORT || '5432'),
  username: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  database: process.env.DB_NAME || 'facility_erp',
  synchronize: false,
});

async function runMigration(migrationFile: string) {
  try {
    await dataSource.initialize();
    console.log('✅ Database connected');

    const migrationPath = path.join(
      __dirname,
      '../migrations',
      migrationFile,
    );

    if (!fs.existsSync(migrationPath)) {
      console.error(`❌ Migration file not found: ${migrationPath}`);
      process.exit(1);
    }

    const sql = fs.readFileSync(migrationPath, 'utf8');
    console.log(`\n📄 Running migration: ${migrationFile}`);
    console.log('SQL:');
    console.log(sql);

    const queryRunner = dataSource.createQueryRunner();
    await queryRunner.connect();

    try {
      await queryRunner.query(sql);
      console.log('\n✅ Migration completed successfully!');
    } catch (error: any) {
      if (error.message?.includes('already exists') || error.message?.includes('IF NOT EXISTS')) {
        console.log('\n⚠️  Column already exists (this is OK)');
      } else {
        console.error('\n❌ Migration failed:', error.message);
        throw error;
      }
    } finally {
      await queryRunner.release();
    }

    await dataSource.destroy();
    console.log('✅ Database connection closed');
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

// Get migration file from command line argument
const migrationFile = process.argv[2];

if (!migrationFile) {
  console.error('Usage: ts-node scripts/run-migration.ts <migration-file.sql>');
  console.error('Example: ts-node scripts/run-migration.ts add-location-detail-to-maintenance-tickets.sql');
  process.exit(1);
}

runMigration(migrationFile);

