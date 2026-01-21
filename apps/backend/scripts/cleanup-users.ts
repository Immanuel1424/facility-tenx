import { DataSource } from 'typeorm';
import { User } from '../src/modules/iam/entities/user.entity';
import { UserRole } from '../src/modules/iam/entities/user-role.entity';
import { Role } from '../src/modules/iam/entities/role.entity';

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

// Define allowed users (villa-maintenance users only)
const ALLOWED_USERS = [
  'vivek.ellappan@helixsense.com',
  'coordinator@villa-maintenance.com',
  'supervisor@villa-maintenance.com',
  'technician1@villa-maintenance.com',
  'technician2@villa-maintenance.com',
];

// Generate allowed tenant emails (villa1@tenant.com through villa86@tenant.com)
for (let i = 1; i <= 86; i++) {
  ALLOWED_USERS.push(`villa${i}@tenant.com`);
}

// Define allowed roles (villa-maintenance roles only)
const ALLOWED_ROLES = [
  'ADMIN',
  'SITE_COORDINATOR',
  'SUPERVISOR',
  'TECHNICIAN',
  'TENANT',
];

async function cleanupUsers() {
  try {
    await dataSource.initialize();
    console.log('Database connected');

    const testCompanyId = 'eb75a65b-055f-4408-a58c-71d233443c17';
    const userRepo = dataSource.getRepository(User);
    const userRoleRepo = dataSource.getRepository(UserRole);
    const roleRepo = dataSource.getRepository(Role);

    // Get all users for the company
    const allUsers = await userRepo.find({
      where: { companyId: testCompanyId },
    });

    console.log(`\n📊 Found ${allUsers.length} total users`);

    // Find users to delete (not in allowed list)
    const usersToDelete = allUsers.filter(
      (user) => !ALLOWED_USERS.includes(user.email),
    );

    console.log(`\n🗑️  Found ${usersToDelete.length} users to delete:`);
    usersToDelete.forEach((user) => {
      console.log(`   - ${user.email}`);
    });

    if (usersToDelete.length === 0) {
      console.log('\n✅ No users to delete. All users are valid villa-maintenance users.');
      await dataSource.destroy();
      return;
    }

    // Delete user roles first (foreign key constraint)
    let deletedUserRoles = 0;
    for (const user of usersToDelete) {
      const userRoles = await userRoleRepo.find({
        where: { companyId: testCompanyId, userId: user.id },
      });
      for (const userRole of userRoles) {
        await userRoleRepo.remove(userRole);
        deletedUserRoles++;
      }
    }
    console.log(`\n✓ Deleted ${deletedUserRoles} user role assignments`);

    // Delete users
    for (const user of usersToDelete) {
      await userRepo.remove(user);
    }
    console.log(`✓ Deleted ${usersToDelete.length} users`);

    // Find roles to delete (not in allowed list)
    const allRoles = await roleRepo.find({
      where: { companyId: testCompanyId },
    });

    const rolesToDelete = allRoles.filter(
      (role) => !ALLOWED_ROLES.includes(role.name),
    );

    console.log(`\n🗑️  Found ${rolesToDelete.length} roles to delete:`);
    rolesToDelete.forEach((role) => {
      console.log(`   - ${role.name}`);
    });

    if (rolesToDelete.length > 0) {
      // Delete role permissions first (foreign key constraint)
      const { RolePermission } = await import(
        '../src/modules/iam/entities/role-permission.entity'
      );
      const rolePermissionRepo = dataSource.getRepository(RolePermission);

      let deletedRolePermissions = 0;
      for (const role of rolesToDelete) {
        const rolePermissions = await rolePermissionRepo.find({
          where: { companyId: testCompanyId, roleId: role.id },
        });
        for (const rolePermission of rolePermissions) {
          await rolePermissionRepo.remove(rolePermission);
          deletedRolePermissions++;
        }
      }
      console.log(`✓ Deleted ${deletedRolePermissions} role permission assignments`);

      // Delete roles
      for (const role of rolesToDelete) {
        await roleRepo.remove(role);
      }
      console.log(`✓ Deleted ${rolesToDelete.length} roles`);
    } else {
      console.log('\n✅ No roles to delete. All roles are valid villa-maintenance roles.');
    }

    // Final summary
    const remainingUsers = await userRepo.find({
      where: { companyId: testCompanyId },
    });
    const remainingRoles = await roleRepo.find({
      where: { companyId: testCompanyId },
    });

    console.log('\n✅ Cleanup completed successfully!');
    console.log(`\n📊 Final counts:`);
    console.log(`   - Users: ${remainingUsers.length}`);
    console.log(`   - Roles: ${remainingRoles.length}`);
    console.log(`\n✅ All remaining users are villa-maintenance users:`);
    remainingUsers.forEach((user) => {
      console.log(`   - ${user.email}`);
    });

    await dataSource.destroy();
  } catch (error) {
    console.error('❌ Cleanup failed:', error);
    await dataSource.destroy();
    process.exit(1);
  }
}

cleanupUsers();

