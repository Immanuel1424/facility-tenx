import { NestFactory } from '@nestjs/core';
import { AppModule } from '../src/app.module';
import { UserDeviceService } from '../src/modules/iam/services/user-device.service';
import { User } from '../src/modules/iam/entities/user.entity';
import { UserDevice } from '../src/modules/iam/entities/user-device.entity';
import { Repository } from 'typeorm';
import { getRepositoryToken } from '@nestjs/typeorm';

async function checkFcmTokens() {
  console.log('🔍 Checking FCM token registration status...\n');

  try {
    const app = await NestFactory.createApplicationContext(AppModule);
    const userDeviceService = app.get(UserDeviceService);
    const userRepo = app.get<Repository<User>>(getRepositoryToken(User));

    const testCompanyId = 'eb75a65b-055f-4408-a58c-71d233443c17';
    const adminEmail = 'vivek.ellappan@helixsense.com';

    // Find admin user
    const adminUser = await userRepo.findOne({
      where: { companyId: testCompanyId, email: adminEmail },
    });

    if (!adminUser) {
      console.error(`❌ Admin user ${adminEmail} not found!`);
      await app.close();
      process.exit(1);
    }

    console.log(`✅ Found admin user: ${adminUser.firstName} ${adminUser.lastName} (ID: ${adminUser.id})\n`);

    // Get all devices for the user
    const fcmTokens = await userDeviceService.getActiveTokensForUser(
      testCompanyId,
      adminUser.id,
    );

    if (fcmTokens.length === 0) {
      console.log('⚠️  No FCM tokens registered yet.\n');
      console.log('📱 To register FCM token:');
      console.log('   1. Open the app (web or mobile)');
      console.log('   2. Log in as:', adminEmail);
      console.log('   3. Grant notification permissions');
      console.log('   4. The app will automatically register the FCM token\n');
    } else {
      console.log(`✅ Found ${fcmTokens.length} active FCM token(s):\n`);
      fcmTokens.forEach((token, index) => {
        console.log(`   ${index + 1}. ${token.substring(0, 50)}...`);
      });
      console.log('\n✅ Admin user is ready to receive push notifications!\n');
    }

    // Get all registered devices with details
    const deviceRepo = app.get<Repository<UserDevice>>(
      getRepositoryToken(UserDevice),
    );

    const devices = await deviceRepo.find({
      where: {
        companyId: testCompanyId,
        userId: adminUser.id,
        isActive: true,
      },
      order: { lastUsedAt: 'DESC' },
    });

    if (devices.length > 0) {
      console.log('📱 Registered devices:\n');
      devices.forEach((device, index) => {
        console.log(`   ${index + 1}. Platform: ${device.platform}`);
        console.log(`      Token: ${device.fcmToken.substring(0, 50)}...`);
        console.log(`      Last used: ${device.lastUsedAt?.toLocaleString() || 'Never'}`);
        console.log(`      Created: ${device.createdAt.toLocaleString()}`);
        if (device.deviceInfo) {
          console.log(`      Device info: ${JSON.stringify(device.deviceInfo)}`);
        }
        console.log('');
      });
    }

    await app.close();
    process.exit(0);
  } catch (error) {
    console.error('❌ Error checking FCM tokens:', error);
    if (error instanceof Error) {
      console.error('Error message:', error.message);
    }
    process.exit(1);
  }
}

checkFcmTokens();

