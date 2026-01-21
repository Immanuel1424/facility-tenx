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

async function checkFcmDevices() {
  try {
    await dataSource.initialize();
    console.log('✅ Connected to database\n');

    const query = `
      SELECT 
        u.email,
        u.id as user_id,
        ud.platform,
        ud.is_active,
        ud.last_used_at,
        ud.created_at,
        ud.fcm_token,
        ud.device_info
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
      console.log('─'.repeat(100));
      console.log(
        'Email'.padEnd(40) +
          'Platform'.padEnd(12) +
          'Active'.padEnd(8) +
          'Last Used'.padEnd(20) +
          'Token (first 50 chars)',
      );
      console.log('─'.repeat(100));

      result.forEach((device: any) => {
        const email = (device.email || 'N/A').substring(0, 38).padEnd(40);
        const platform = (device.platform || 'N/A').padEnd(12);
        const isActive = (device.is_active ? 'Yes' : 'No').padEnd(8);
        const lastUsed = device.last_used_at
          ? new Date(device.last_used_at).toLocaleString().padEnd(20)
          : 'Never'.padEnd(20);
        const tokenPreview = device.fcm_token
          ? device.fcm_token.substring(0, 50) + '...'
          : 'N/A';

        console.log(`${email}${platform}${isActive}${lastUsed}${tokenPreview}`);
      });

      console.log('─'.repeat(100));
      console.log(`\n📊 Summary:`);
      console.log(`   Total active devices: ${result.length}`);
      
      const platformCounts = result.reduce((acc: any, device: any) => {
        const platform = device.platform || 'unknown';
        acc[platform] = (acc[platform] || 0) + 1;
        return acc;
      }, {});

      console.log(`   By platform:`);
      Object.entries(platformCounts).forEach(([platform, count]) => {
        console.log(`     ${platform}: ${count}`);
      });
    }

    // Also check users without FCM tokens
    const usersWithoutTokens = await dataSource.query(`
      SELECT 
        u.email,
        u.id as user_id,
        COUNT(ud.id) as device_count
      FROM users u
      LEFT JOIN user_devices ud ON u.id = ud.user_id AND ud.is_active = true
      GROUP BY u.id, u.email
      HAVING COUNT(ud.id) = 0
      ORDER BY u.email
      LIMIT 10;
    `);

    if (usersWithoutTokens.length > 0) {
      console.log(`\n⚠️  Users without FCM tokens (showing first 10):`);
      usersWithoutTokens.forEach((user: any) => {
        console.log(`   - ${user.email} (${user.user_id})`);
      });
      if (usersWithoutTokens.length === 10) {
        console.log(`   ... and more`);
      }
    }

    await dataSource.destroy();
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

checkFcmDevices();

