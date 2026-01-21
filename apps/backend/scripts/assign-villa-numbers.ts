import { DataSource } from 'typeorm';
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

async function assignVillaNumbers() {
  try {
    await dataSource.initialize();
    console.log('✓ Database connected\n');

    const userRepo = dataSource.getRepository(User);
    const testCompanyId = 'eb75a65b-055f-4408-a58c-71d233443c17';

    // Users to update with their villa numbers
    // Assign villa numbers to all tenant users (villa1@tenant.com through villa86@tenant.com)
    const usersToUpdate: Array<{ email: string; villaNumber: number }> = [];
    for (let i = 1; i <= 86; i++) {
      usersToUpdate.push({
        email: `villa${i}@tenant.com`,
        villaNumber: i,
      });
    }

    console.log('Assigning villa numbers to tenant users...\n');

    for (const { email, villaNumber } of usersToUpdate) {
      // Find the user
      const user = await userRepo.findOne({
        where: { companyId: testCompanyId, email },
      });

      if (!user) {
        console.log(`⚠️  User ${email} not found - skipping`);
        continue;
      }

      // Check if villa number is already set correctly
      if (user.villaNumber === villaNumber) {
        console.log(`✓ ${email} already has villa number ${villaNumber}`);
        continue;
      }

      // Check if another user already has this villa number
      if (villaNumber) {
        const existingUser = await userRepo.findOne({
          where: { 
            companyId: testCompanyId, 
            villaNumber,
          },
        });

        if (existingUser && existingUser.id !== user.id) {
          console.log(`⚠️  Villa number ${villaNumber} is already assigned to ${existingUser.email}`);
          console.log(`   Clearing villa number from ${existingUser.email}...`);
          existingUser.villaNumber = undefined;
          await userRepo.save(existingUser);
        }
      }

      // Update the user's villa number
      user.villaNumber = villaNumber;
      await userRepo.save(user);
      console.log(`✓ Assigned villa number ${villaNumber} to ${email}`);
    }

    console.log('\n✅ Villa number assignment completed!');
    await dataSource.destroy();
    process.exit(0);
  } catch (error) {
    console.error('❌ Error assigning villa numbers:', error);
    await dataSource.destroy();
    process.exit(1);
  }
}

assignVillaNumbers();

