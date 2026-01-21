import { NestFactory } from '@nestjs/core';
import { AppModule } from '../src/app.module';
import { EmailChannel } from '../src/modules/notification/channels/email.channel';

async function testSmtp2go() {
  console.log('🧪 Testing SMTP2GO email integration...\n');

  try {
    // Create NestJS application context to get services
    const app = await NestFactory.createApplicationContext(AppModule);
    const emailChannel = app.get(EmailChannel);

    const testEmail = 'vivek.ellappan@sembiyan.in';
    const testSubject = 'Hello Vivek';
    const testBody = 'Congratulations Vivek, you just sent an email with SMTP2GO! You are truly awesome!';

    console.log(`📧 Sending test email to: ${testEmail}`);
    console.log(`📝 Subject: ${testSubject}`);
    console.log(`📄 Body: ${testBody}\n`);

    // Test email channel
    const result = await emailChannel.send({
      to: `Vivek <${testEmail}>`,
      subject: testSubject,
      body: testBody,
    });

    if (result.success) {
      console.log('\n✅ Test email sent successfully!');
      console.log('📬 Check your inbox at:', testEmail);
    } else {
      console.error('\n❌ Failed to send email:', result.errorMessage);
      process.exit(1);
    }

    await app.close();
    process.exit(0);
  } catch (error) {
    console.error('❌ Error testing SMTP2GO:', error);
    process.exit(1);
  }
}

testSmtp2go();

