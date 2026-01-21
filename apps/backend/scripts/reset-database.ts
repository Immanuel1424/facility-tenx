import { DataSource } from 'typeorm';

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

async function resetDatabase() {
  try {
    await dataSource.initialize();
    console.log('Database connected');

    const queryRunner = dataSource.createQueryRunner();
    await queryRunner.connect();

    console.log('\n🗑️  Dropping all tables...');

    // Get all table names
    const tables = await queryRunner.query(`
      SELECT tablename 
      FROM pg_tables 
      WHERE schemaname = 'public' 
      AND tablename NOT LIKE 'pg_%'
      AND tablename NOT LIKE '_prisma%'
      ORDER BY tablename;
    `);

    console.log(`Found ${tables.length} tables to drop`);

    // Drop all tables with CASCADE to handle foreign keys
    for (const table of tables) {
      const tableName = table.tablename;
      try {
        await queryRunner.query(`DROP TABLE IF EXISTS "${tableName}" CASCADE;`);
        console.log(`  ✓ Dropped table: ${tableName}`);
      } catch (error) {
        console.error(`  ✗ Failed to drop table ${tableName}:`, error);
      }
    }

    // Drop all sequences
    const sequences = await queryRunner.query(`
      SELECT sequence_name 
      FROM information_schema.sequences 
      WHERE sequence_schema = 'public';
    `);

    for (const seq of sequences) {
      const seqName = seq.sequence_name;
      try {
        await queryRunner.query(`DROP SEQUENCE IF EXISTS "${seqName}" CASCADE;`);
        console.log(`  ✓ Dropped sequence: ${seqName}`);
      } catch (error) {
        // Ignore errors for sequences
      }
    }

    await queryRunner.release();

    console.log('\n✅ All tables dropped successfully');
    console.log('\n📋 Recreating schema with synchronize...');

    // Create new DataSource with synchronize enabled
    const syncDataSource = new DataSource({
      type: 'postgres',
      host: process.env.DB_HOST || 'localhost',
      port: Number(process.env.DB_PORT || '5432'),
      username: process.env.DB_USER || 'postgres',
      password: process.env.DB_PASSWORD || 'postgres',
      database: process.env.DB_NAME || 'facility_erp',
      entities: [__dirname + '/../src/**/*.entity.{ts,js}'],
      synchronize: true, // This will create all tables
    });

    await syncDataSource.initialize();
    console.log('✅ Schema recreated successfully');
    await syncDataSource.destroy();

    console.log('\n✅ Database reset completed!');
    console.log('You can now run the seed script to populate data.');

    await dataSource.destroy();
  } catch (error) {
    console.error('❌ Database reset failed:', error);
    await dataSource.destroy();
    process.exit(1);
  }
}

resetDatabase();

