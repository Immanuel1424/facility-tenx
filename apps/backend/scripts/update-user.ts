import { NestFactory } from '@nestjs/core';
import { DataSource } from 'typeorm';
import { AppModule } from '../src/app.module';
import { UserService } from '../src/modules/iam/services/user.service';
import { User } from '../src/modules/iam/entities/user.entity';
import { UserStatus } from '../src/modules/iam/entities/user.entity';

async function updateUser() {
  console.log('🔄 Updating user information...\n');

  try {
    const app = await NestFactory.createApplicationContext(AppModule);
    const userService = app.get(UserService);
    const dataSource = app.get(DataSource);

    const email = 'vivek.ellappan@sembiyan.in';
    
    console.log(`🔍 Looking for user with email: ${email}\n`);

    // Find user across all companies
    const userRepository = dataSource.getRepository(User);
    
    const user = await userRepository.findOne({
      where: { email },
      relations: ['userRoles', 'userRoles.role'],
    });

    if (!user) {
      console.error(`❌ User with email ${email} not found`);
      process.exit(1);
    }

    console.log('📋 Current user information:');
    console.log(`   ID: ${user.id}`);
    console.log(`   Email: ${user.email}`);
    console.log(`   Name: ${user.firstName || ''} ${user.lastName || ''}`.trim() || 'N/A');
    console.log(`   Company ID: ${user.companyId}`);
    console.log(`   Status: ${user.status}`);
    console.log(`   Villa Number: ${user.villaNumber || 'N/A'}`);
    console.log(`   Phone: ${user.phoneNumber || 'N/A'}`);
    console.log(`   Auth Provider: ${user.authProvider}\n`);

    // Update user - customize these fields as needed
    const updates: any = {
      // Uncomment and modify the fields you want to update:
      // firstName: 'Vivek',
      // lastName: 'Ellappan',
      // phoneNumber: '+1234567890',
      // status: UserStatus.ACTIVE,
      // villaNumber: 101,
    };

    // Check if there are any updates to apply
    const hasUpdates = Object.keys(updates).length > 0;

    if (!hasUpdates) {
      console.log('ℹ️  No updates specified. Edit this script to add update fields.');
      console.log('   Example updates you can add:');
      console.log('   - firstName: "Vivek"');
      console.log('   - lastName: "Ellappan"');
      console.log('   - phoneNumber: "+1234567890"');
      console.log('   - status: UserStatus.ACTIVE');
      console.log('   - villaNumber: 101');
      await app.close();
      process.exit(0);
    }

    console.log('📝 Applying updates...');
    const updatedUser = await userService.update(user.companyId, user.id, updates);

    console.log('\n✅ User updated successfully!');
    console.log('📋 Updated user information:');
    console.log(`   ID: ${updatedUser.id}`);
    console.log(`   Email: ${updatedUser.email}`);
    console.log(`   Name: ${updatedUser.firstName || ''} ${updatedUser.lastName || ''}`.trim() || 'N/A');
    console.log(`   Status: ${updatedUser.status}`);
    console.log(`   Villa Number: ${updatedUser.villaNumber || 'N/A'}`);
    console.log(`   Phone: ${updatedUser.phoneNumber || 'N/A'}\n`);

    await app.close();
    process.exit(0);
  } catch (error: any) {
    console.error('❌ Error updating user:', error.message);
    if (error.stack) {
      console.error(error.stack);
    }
    process.exit(1);
  }
}

updateUser();

