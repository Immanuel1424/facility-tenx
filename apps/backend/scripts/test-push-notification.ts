import { NestFactory } from '@nestjs/core';
import { AppModule } from '../src/app.module';
import { NotificationService } from '../src/modules/notification/notification.service';
import { NotificationTemplate } from '../src/modules/notification/entities/notification-template.entity';
import { NotificationChannel } from '../src/modules/notification/enums/notification-channel.enum';
import { NotificationSeverity } from '../src/modules/notification/enums/notification-severity.enum';
import { Repository } from 'typeorm';
import { getRepositoryToken } from '@nestjs/typeorm';
import { User } from '../src/modules/iam/entities/user.entity';
import { UserDeviceService } from '../src/modules/iam/services/user-device.service';

async function testPushNotification() {
  console.log('🧪 Testing push notification to admin...\n');

  try {
    // Create NestJS application context to get services
    const app = await NestFactory.createApplicationContext(AppModule);
    const notificationService = app.get(NotificationService);
    const templateRepo = app.get<Repository<NotificationTemplate>>(
      getRepositoryToken(NotificationTemplate),
    );
    const userRepo = app.get<Repository<User>>(getRepositoryToken(User));

    // Test company ID (from seed script)
    const testCompanyId = 'eb75a65b-055f-4408-a58c-71d233443c17';
    const adminEmail = 'vivek.ellappan@helixsense.com';

    // Find admin user
    console.log(`🔍 Looking for admin user: ${adminEmail}`);
    const adminUser = await userRepo.findOne({
      where: { companyId: testCompanyId, email: adminEmail },
    });

    if (!adminUser) {
      console.error(`❌ Admin user ${adminEmail} not found!`);
      console.log('💡 Please run the seed script first to create the admin user.');
      await app.close();
      process.exit(1);
    }

    console.log(`✅ Found admin user: ${adminUser.firstName} ${adminUser.lastName} (ID: ${adminUser.id})\n`);

    // Check if user has registered FCM tokens
    let fcmTokens: string[] = [];
    try {
      const userDeviceService = app.get(UserDeviceService);
      fcmTokens = await userDeviceService.getActiveTokensForUser(
        testCompanyId,
        adminUser.id,
      );

      if (fcmTokens.length === 0) {
        console.log('⚠️  No FCM tokens found for admin user.');
        console.log('💡 The admin user needs to:');
        console.log('   1. Log in to the app (web/mobile)');
        console.log('   2. Grant notification permissions');
        console.log('   3. The app will automatically register the FCM token\n');
        console.log('📱 For testing, you can:');
        console.log('   - Open the app in a browser and log in as admin');
        console.log('   - Or use the mobile app and log in as admin');
        console.log('   - The FCM token will be registered automatically\n');
      } else {
        console.log(`✅ Found ${fcmTokens.length} active FCM token(s) for admin user\n`);
      }
    } catch (error) {
      if (error instanceof Error && error.message.includes('user_devices')) {
        console.log('⚠️  user_devices table does not exist.');
        console.log('💡 Please run the migration to create the table:');
        console.log('   cd apps/backend/migrations');
        console.log('   psql -h localhost -U postgres -d facility_erp -f create-user-devices-table.sql\n');
        console.log('   Or ensure TypeORM synchronize is enabled in development mode\n');
      } else {
        console.log('⚠️  Could not check FCM tokens:', error instanceof Error ? error.message : 'Unknown error\n');
      }
    }

    // Create or get notification template for push
    const templateCode = 'test_push_notification';
    console.log(`📝 Creating/checking notification template: ${templateCode}`);

    let pushTemplate = await templateRepo.findOne({
      where: {
        companyId: testCompanyId,
        code: templateCode,
        channel: NotificationChannel.PUSH,
      },
    });

    if (!pushTemplate) {
      pushTemplate = templateRepo.create({
        companyId: testCompanyId,
        code: templateCode,
        channel: NotificationChannel.PUSH,
        subject: 'Test Notification',
        body: '{{message}}',
        defaultVariables: {
          message: 'This is a test push notification',
        },
      });
      pushTemplate = await templateRepo.save(pushTemplate);
      console.log('✅ Created push notification template\n');
    } else {
      console.log('✅ Push notification template already exists\n');
    }

    // Create in-app template (required for notification creation)
    let inAppTemplate = await templateRepo.findOne({
      where: {
        companyId: testCompanyId,
        code: templateCode,
        channel: NotificationChannel.IN_APP,
      },
    });

    if (!inAppTemplate) {
      inAppTemplate = templateRepo.create({
        companyId: testCompanyId,
        code: templateCode,
        channel: NotificationChannel.IN_APP,
        subject: null,
        body: '{{message}}',
        defaultVariables: {
          message: 'This is a test notification',
        },
      });
      inAppTemplate = await templateRepo.save(inAppTemplate);
      console.log('✅ Created in-app notification template\n');
    }

    // Send test notification
    console.log('📤 Sending test push notification...\n');
    const testMessage = `Hello ${adminUser.firstName}! This is a test push notification from the TENX system. Time: ${new Date().toLocaleString()}`;

    await notificationService.publishEvent({
      type: 'test_notification',
      companyId: testCompanyId,
      recipientUserId: adminUser.id,
      severity: NotificationSeverity.INFO,
      templateCode: templateCode,
      variables: {
        title: 'Test Push Notification',
        message: testMessage,
        recipient: {
          email: adminUser.email,
          firstName: adminUser.firstName,
          lastName: adminUser.lastName,
        },
      },
      channels: ['push', 'in_app'], // Explicitly request push and in-app
    });

    console.log('✅ Test notification sent successfully!\n');
    console.log('📱 If the admin user has the app open:');
    console.log('   - They should see a push notification');
    console.log('   - The notification will also appear in the in-app notifications list\n');
    console.log('💡 To check if it was received:');
    console.log('   1. Open the app as the admin user');
    console.log('   2. Check the notifications list');
    console.log('   3. If push is enabled, you should see a browser/system notification\n');

    await app.close();
    process.exit(0);
  } catch (error) {
    console.error('❌ Error testing push notification:', error);
    if (error instanceof Error) {
      console.error('Error message:', error.message);
      console.error('Stack trace:', error.stack);
    }
    process.exit(1);
  }
}

testPushNotification();

