import { DataSource } from 'typeorm';
import { config } from 'dotenv';
import { Permission } from '../src/modules/iam/entities/permission.entity';
import { Role } from '../src/modules/iam/entities/role.entity';
import { RolePermission } from '../src/modules/iam/entities/role-permission.entity';
import { Company } from '../src/modules/tenant/entities/company.entity';

config();

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

async function fixAnnouncementPermissions() {
  try {
    await dataSource.initialize();
    console.log('✓ Database connected');

    const permissionRepo = dataSource.getRepository(Permission);
    const roleRepo = dataSource.getRepository(Role);
    const rolePermissionRepo = dataSource.getRepository(RolePermission);

    // Get all companies (or use a specific company ID)
    const companyRepo = dataSource.getRepository(Company);
    const companies = await companyRepo.find();

    if (companies.length === 0) {
      console.log('⚠️  No companies found. Please run the seed script first.');
      return;
    }

    // Find or create the announcement:read permission (global, no companyId)
    let permission = await permissionRepo.findOne({
      where: { resource: 'announcement', action: 'read' },
    });

    if (!permission) {
      console.log('⚠️  Permission announcement:read not found. Creating...');
      permission = permissionRepo.create({
        resource: 'announcement',
        action: 'read',
        description: 'Read announcements',
      });
      permission = await permissionRepo.save(permission);
      console.log('✓ Created permission: announcement:read');
    } else {
      console.log('✓ Found permission: announcement:read');
    }

    // For each company, ensure SITE_COORDINATOR role has the permission
    for (const company of companies) {
      console.log(`\n📦 Processing company: ${company.name} (${company.companyId})`);

      // Find SITE_COORDINATOR role for this company
      const siteCoordinatorRole = await roleRepo.findOne({
        where: {
          companyId: company.companyId,
          name: 'SITE_COORDINATOR',
        },
      });

      if (!siteCoordinatorRole) {
        console.log(`⚠️  SITE_COORDINATOR role not found for company ${company.name}`);
        continue;
      }

      console.log(`✓ Found SITE_COORDINATOR role: ${siteCoordinatorRole.id}`);

      // Check if permission is already assigned
      const existingRolePermission = await rolePermissionRepo.findOne({
        where: {
          companyId: company.companyId,
          roleId: siteCoordinatorRole.id,
          permissionId: permission.id,
        },
      });

      if (existingRolePermission) {
        console.log(`✓ Permission already assigned to SITE_COORDINATOR in ${company.name}`);
      } else {
        // Assign permission to role
        const rolePermission = rolePermissionRepo.create({
          companyId: company.companyId,
          roleId: siteCoordinatorRole.id,
          permissionId: permission.id,
        });
        await rolePermissionRepo.save(rolePermission);
        console.log(`✅ Assigned announcement:read permission to SITE_COORDINATOR in ${company.name}`);
      }
    }

    console.log('\n✅ Fix completed!');
  } catch (error) {
    console.error('❌ Error:', error);
    throw error;
  } finally {
    await dataSource.destroy();
  }
}

fixAnnouncementPermissions()
  .then(() => {
    console.log('Done');
    process.exit(0);
  })
  .catch((error) => {
    console.error('Failed:', error);
    process.exit(1);
  });

