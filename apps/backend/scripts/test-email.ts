import { DataSource } from 'typeorm';
import { EmailService } from '../src/modules/auth/services/email.service';
import { ConfigModule } from '@nestjs/config';
import { NestFactory } from '@nestjs/core';
import { AppModule } from '../src/app.module';

async function testEmail() {
  console.log('🧪 Testing email service...\n');

  try {
    // Create NestJS application context to get services
    const app = await NestFactory.createApplicationContext(AppModule);
    const emailService = app.get(EmailService);

    const testEmail = 'adithan549@gmail.com';
    const testOtp = '123456';
    const testFirstName = 'Adithan';

    console.log(`📧 Sending test OTP email to: ${testEmail}`);
    console.log(`🔢 Test OTP: ${testOtp}\n`);

    // Test password reset OTP email
    await emailService.sendPasswordResetOtp(testEmail, testOtp, testFirstName);

    console.log('\n✅ Test email sent successfully!');
    console.log('📬 Check your inbox at:', testEmail);
    console.log('💡 If AWS SES is not configured, check the console logs above for errors.\n');

    // Test confirmation email
    console.log('📧 Sending test confirmation email...');
    await emailService.sendPasswordResetConfirmation(testEmail, testFirstName);
    console.log('✅ Confirmation email sent!\n');

    await app.close();
    process.exit(0);
  } catch (error) {
    console.error('❌ Error testing email:', error);
    process.exit(1);
  }
}

testEmail();

