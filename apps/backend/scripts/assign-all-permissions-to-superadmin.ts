import { DataSource } from 'typeorm';
import { User } from '../src/modules/iam/entities/user.entity';
import { Role } from '../src/modules/iam/entities/role.entity';
import { Permission } from '../src/modules/iam/entities/permission.entity';
import { RolePermission } from '../src/modules/iam/entities/role-permission.entity';
import { UserRole } from '../src/modules/iam/entities/user-role.entity';

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

async function assignAllPermissionsToAdmin() {
  try {
    await dataSource.initialize();
    console.log('Database connected');

    const userRepo = dataSource.getRepository(User);
    const roleRepo = dataSource.getRepository(Role);
    const permissionRepo = dataSource.getRepository(Permission);
    const rolePermissionRepo = dataSource.getRepository(RolePermission);
    const userRoleRepo = dataSource.getRepository(UserRole);

    const testCompanyId = 'eb75a65b-055f-4408-a58c-71d233443c17';
    const adminEmail = 'vivek.ellappan@helixsense.com';

    // Find the user
    const user = await userRepo.findOne({
      where: { companyId: testCompanyId, email: adminEmail },
    });

    if (!user) {
      console.error(`❌ User ${adminEmail} not found!`);
      console.log('Please run the seed script first to create the user.');
      await dataSource.destroy();
      process.exit(1);
    }

    console.log(`✓ Found user: ${adminEmail} (ID: ${user.id})`);

    // Find or create ADMIN role
    let adminRole = await roleRepo.findOne({
      where: { companyId: testCompanyId, name: 'ADMIN' },
    });

    if (!adminRole) {
      adminRole = roleRepo.create({
        companyId: testCompanyId,
        name: 'ADMIN',
        hierarchyLevel: 100,
        description: 'Administrator with full system access',
      });
      adminRole = await roleRepo.save(adminRole);
      console.log('✓ Created ADMIN role');
    } else {
      console.log('✓ Found ADMIN role');
    }

    // Ensure user has ADMIN role
    const existingUserRole = await userRoleRepo.findOne({
      where: {
        companyId: testCompanyId,
        userId: user.id,
        roleId: adminRole.id,
      },
    });

    if (!existingUserRole) {
      const userRole = userRoleRepo.create({
        companyId: testCompanyId,
        userId: user.id,
        roleId: adminRole.id,
      });
      await userRoleRepo.save(userRole);
      console.log('✓ Assigned ADMIN role to user');
    } else {
      console.log('✓ User already has ADMIN role');
    }

    // Get all permissions (permissions are global, not tenant-scoped)
    const allPermissions = await permissionRepo.find();

    console.log(`\n✓ Found ${allPermissions.length} permissions`);

    // Assign all permissions to ADMIN role
    let assignedCount = 0;
    let skippedCount = 0;

    for (const permission of allPermissions) {
      const existingRolePermission = await rolePermissionRepo.findOne({
        where: {
          companyId: testCompanyId,
          roleId: adminRole.id,
          permissionId: permission.id,
        },
      });

      if (!existingRolePermission) {
        const rolePermission = rolePermissionRepo.create({
          companyId: testCompanyId,
          roleId: adminRole.id,
          permissionId: permission.id,
        });
        await rolePermissionRepo.save(rolePermission);
        console.log(`  ✓ Assigned: ${permission.resource}:${permission.action}`);
        assignedCount++;
      } else {
        skippedCount++;
      }
    }

    // Also create any missing common permissions and assign them
    const commonResources = [
      'user', 'company', 'site', 'role', 'permission', 'service-request', 
      'service_request', 'report', 'notification', 'announcement', 'hierarchy', 'tenant',
      'team', 'technician', 'workflow', 'sla', 'escalation', 'audit', 'log'
    ];
    const commonActions = ['create', 'read', 'update', 'delete', 'list', 'export', 'import'];

    let createdCount = 0;
    for (const resource of commonResources) {
      for (const action of commonActions) {
        let permission = await permissionRepo.findOne({
          where: { resource, action },
        });

        if (!permission) {
          permission = permissionRepo.create({
            resource,
            action,
          });
          permission = await permissionRepo.save(permission);
          console.log(`  ✓ Created new permission: ${resource}:${action}`);
          createdCount++;

          // Assign to ADMIN
          const rolePermission = rolePermissionRepo.create({
            companyId: testCompanyId,
            roleId: adminRole.id,
            permissionId: permission.id,
          });
          await rolePermissionRepo.save(rolePermission);
          assignedCount++;
        } else {
          // Permission exists, check if it's assigned to ADMIN
          const existingRolePermission = await rolePermissionRepo.findOne({
            where: {
              companyId: testCompanyId,
              roleId: adminRole.id,
              permissionId: permission.id,
            },
          });

          if (!existingRolePermission) {
            const rolePermission = rolePermissionRepo.create({
              companyId: testCompanyId,
              roleId: adminRole.id,
              permissionId: permission.id,
            });
            await rolePermissionRepo.save(rolePermission);
            console.log(`  ✓ Assigned existing permission: ${resource}:${action}`);
            assignedCount++;
          }
        }
      }
    }

    // Create announcement-specific permissions (including 'publish')
    const announcementActions = ['create', 'read', 'update', 'delete', 'publish'];
    for (const action of announcementActions) {
      let permission = await permissionRepo.findOne({
        where: { resource: 'announcement', action },
      });

      if (!permission) {
        permission = permissionRepo.create({
          resource: 'announcement',
          action,
        });
        permission = await permissionRepo.save(permission);
        console.log(`  ✓ Created new permission: announcement:${action}`);
        createdCount++;

        // Assign to ADMIN
        const rolePermission = rolePermissionRepo.create({
          companyId: testCompanyId,
          roleId: adminRole.id,
          permissionId: permission.id,
        });
        await rolePermissionRepo.save(rolePermission);
        assignedCount++;
      } else {
        // Permission exists, check if it's assigned to ADMIN
        const existingRolePermission = await rolePermissionRepo.findOne({
          where: {
            companyId: testCompanyId,
            roleId: adminRole.id,
            permissionId: permission.id,
          },
        });

        if (!existingRolePermission) {
          const rolePermission = rolePermissionRepo.create({
            companyId: testCompanyId,
            roleId: adminRole.id,
            permissionId: permission.id,
          });
          await rolePermissionRepo.save(rolePermission);
          console.log(`  ✓ Assigned existing permission: announcement:${action}`);
          assignedCount++;
        }
      }
    }

    console.log(`\n✅ Completed!`);
    console.log(`   - Created ${createdCount} new permissions`);
    console.log(`   - Assigned ${assignedCount} new permissions`);
    console.log(`   - Skipped ${skippedCount} existing permissions`);
    
    // Get final count
    const finalPermissions = await permissionRepo.find();
    const finalRolePermissions = await rolePermissionRepo.find({
      where: { companyId: testCompanyId, roleId: adminRole.id },
    });
    
    console.log(`   - Total permissions in system: ${finalPermissions.length}`);
    console.log(`   - Total permissions for ADMIN: ${finalRolePermissions.length}`);

    await dataSource.destroy();
  } catch (error) {
    console.error('❌ Failed:', error);
    await dataSource.destroy();
    process.exit(1);
  }
}

assignAllPermissionsToAdmin();

