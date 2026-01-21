import { DataSource } from 'typeorm';
import * as dotenv from 'dotenv';
import { join } from 'path';

// Load environment variables
dotenv.config({ path: join(__dirname, '../.env') });

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

async function queryFcmDevices() {
  try {
    await dataSource.initialize();
    console.log('✅ Connected to database\n');

    // Your exact query
    const query = `
      SELECT 
        u.email,
        ud.platform,
        ud.is_active,
        ud.last_used_at,
        ud.created_at
      FROM user_devices ud
      JOIN users u ON u.id = ud.user_id
      WHERE ud.is_active = true
      ORDER BY ud.last_used_at DESC;
    `;

    const result = await dataSource.query(query);

    if (result.length === 0) {
      console.log('❌ No active FCM devices found');
    } else {
      console.log(`✅ Found ${result.length} active FCM device(s):\n`);
      
      // Format as table
      console.table(result.map((row: any) => ({
        email: row.email,
        platform: row.platform,
        is_active: row.is_active,
        last_used_at: row.last_used_at ? new Date(row.last_used_at).toLocaleString() : 'Never',
        created_at: row.created_at ? new Date(row.created_at).toLocaleString() : 'N/A',
      })));
    }

    await dataSource.destroy();
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

queryFcmDevices();

