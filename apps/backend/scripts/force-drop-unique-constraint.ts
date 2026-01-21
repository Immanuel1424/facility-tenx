import { DataSource } from 'typeorm';
import * as fs from 'fs';
import * as path from 'path';

// Try to load .env manually since we are running a standalone script
const envPath = path.resolve(__dirname, '../.env');
if (fs.existsSync(envPath)) {
  console.log(`Loading .env from ${envPath}`);
  const envConfig = require('dotenv').parse(fs.readFileSync(envPath));
  for (const k in envConfig) {
    process.env[k] = envConfig[k];
  }
} else {
    console.log('No .env file found at ' + envPath);
}

const dataSource = new DataSource({
  type: 'postgres',
  host: process.env.DB_HOST || 'localhost',
  port: Number(process.env.DB_PORT || '5432'),
  username: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  database: process.env.DB_NAME || 'facility_erp',
  entities: [],
  synchronize: false,
});

async function forceDropConstraint() {
  try {
    await dataSource.initialize();
    console.log('Database connected');

    const queryRunner = dataSource.createQueryRunner();
    await queryRunner.connect();

    console.log('\n🔍 Looking for unique constraints on maintenance_tickets...');

    const indices = await queryRunner.query(`
      SELECT
        i.relname as index_name,
        array_agg(a.attname) as column_names
      FROM
        pg_class t,
        pg_class i,
        pg_index ix,
        pg_attribute a
      WHERE
        t.oid = ix.indrelid
        AND i.oid = ix.indexrelid
        AND a.attrelid = t.oid
        AND a.attnum = ANY(ix.indkey)
        AND t.relkind = 'r'
        AND t.relname = 'maintenance_tickets'
        AND ix.indisunique = true
      GROUP BY
        i.relname
    `);

    console.log('Found unique indices:', indices);

    const target = indices.find((idx: any) => {
        const cols = idx.column_names;
        return cols.includes('company_id') && cols.includes('ticket_number') && cols.length === 2;
    });

    if (target) {
      console.log(`\nFound target unique index: ${target.index_name}`);
      console.log('Dropping it...');
      
      // Try dropping as constraint first (if it is one), otherwise index
      try {
        await queryRunner.query(`ALTER TABLE "maintenance_tickets" DROP CONSTRAINT "${target.index_name}";`);
        console.log('Dropped as constraint.');
      } catch (e) {
        console.log('Not a constraint or failed to drop as constraint, trying DROP INDEX...');
        await queryRunner.query(`DROP INDEX IF EXISTS "${target.index_name}";`);
        console.log('Dropped as index.');
      }
      
      console.log('✅ Success.');
    } else {
      console.log('\n⚠️ No unique index found on (company_id, ticket_number).');
      console.log('Listing all indices on table:');
      const allIndices = await queryRunner.query(`
         SELECT indexname, indexdef FROM pg_indexes WHERE tablename = 'maintenance_tickets';
      `);
      console.log(allIndices);
    }

    await queryRunner.release();
    await dataSource.destroy();
  } catch (error) {
    console.error('❌ Error:', error);
    if (dataSource.isInitialized) {
        await dataSource.destroy();
    }
    process.exit(1);
  }
}

forceDropConstraint();
