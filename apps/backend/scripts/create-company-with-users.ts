/**
 * Create Company with Users Script
 * 
 * This script creates a new company with all required roles and users.
 * 
 * CONFIGURATION:
 * Edit apps/backend/scripts/company-config.ts to set:
 *   - Company name, code (optional), description
 *   - User details (email, firstName, lastName, role)
 * 
 * USAGE:
 *   1. Edit company-config.ts with your details
 *   2. Run: npm run create:company
 * 
 * See CREATE_COMPANY_GUIDE.md for detailed instructions.
 */

import { DataSource } from 'typeorm';
import * as bcrypt from 'bcrypt';
import { User, UserStatus, AuthProvider } from '../src/modules/iam/entities/user.entity';
import { Company } from '../src/modules/tenant/entities/company.entity';
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

const DEFAULT_PASSWORD = 'password123';

/**
 * Generate a unique company code from company name
 * Format: First 3-5 uppercase letters from each word, max 10 chars
 */
function generateCompanyCode(name: string): string {
  // Remove special characters and split into words
  const words = name
    .toUpperCase()
    .replace(/[^A-Z0-9\s]/g, '')
    .trim()
    .split(/\s+/)
    .filter((w) => w.length > 0);

  if (words.length === 0) {
    // Fallback: use first 10 uppercase alphanumeric characters
    return name
      .toUpperCase()
      .replace(/[^A-Z0-9]/g, '')
      .substring(0, 10) || 'COMPANY';
  }

  // Take first 2-3 letters from each word, up to 10 characters total
  let code = '';
  for (const word of words) {
    if (code.length >= 10) break;
    const charsToTake = Math.min(3, 10 - code.length);
    code += word.substring(0, charsToTake);
  }

  // Ensure minimum length of 3
  if (code.length < 3) {
    code = code.padEnd(3, 'X');
  }

  return code.substring(0, 10);
}

/**
 * Generate a unique company code that doesn't exist in the database
 */
async function generateUniqueCompanyCode(
  queryRunner: any,
  baseName: string,
): Promise<string> {
  let code = generateCompanyCode(baseName);
  let counter = 1;
  const maxAttempts = 100;

  while (counter < maxAttempts) {
    const existing = await queryRunner.manager.findOne(Company, {
      where: { code },
    });

    if (!existing) {
      return code;
    }

    // Append counter to make it unique
    const baseCode = generateCompanyCode(baseName);
    code = `${baseCode}${counter}`.substring(0, 10);
    counter++;
  }

  // Fallback: use UUID first 8 chars
  return `COMP${Date.now().toString().slice(-6)}`;
}

interface CompanyConfig {
  name: string;
  code?: string; // Optional - will be auto-generated if not provided
  description?: string;
  timezone?: string;
  currency?: string;
}

interface UserConfig {
  email: string;
  firstName: string;
  lastName: string;
  role: string;
}

/**
 * Create a company with all roles and users
 */
async function createCompanyWithUsers(config: {
  company: CompanyConfig;
  users: UserConfig[];
}) {
  console.log('🚀 Starting company creation with users...\n');

  await dataSource.initialize();
  const queryRunner = dataSource.createQueryRunner();
  await queryRunner.connect();
  await queryRunner.startTransaction();

  try {
    // ==================== COMPANY ====================
    console.log('📦 Creating Company...');
    
    // Use provided code or generate one
    let companyCode: string;
    if (config.company.code) {
      // Check if provided code is available
      const existing = await queryRunner.manager.findOne(Company, {
        where: { code: config.company.code },
      });
      
      if (existing) {
        throw new Error(
          `Company with code '${config.company.code}' already exists. Please use a different code.`,
        );
      }
      
      companyCode = config.company.code.toUpperCase().substring(0, 10);
      console.log(`  Using provided company code: ${companyCode}`);
    } else {
      companyCode = await generateUniqueCompanyCode(
        queryRunner,
        config.company.name,
      );
      console.log(`  Auto-generated company code: ${companyCode}`);
    }

    let company = await queryRunner.manager.findOne(Company, {
      where: { code: companyCode },
    });

    if (company) {
      console.log(
        `⚠️  Company with code '${companyCode}' already exists. Using existing company.`,
      );
    } else {
      company = queryRunner.manager.create(Company, {
        code: companyCode,
        name: config.company.name,
        description: config.company.description,
        timezone: config.company.timezone || 'UTC',
        currency: config.company.currency || 'USD',
        isActive: true,
      });
      company = await queryRunner.manager.save(company);
      console.log(
        `✅ Created company: ${company.name} (Code: ${company.code}, ID: ${company.id})`,
      );
    }

    const companyId = company.id;

    // ==================== ROLES ====================
    console.log('\n👥 Creating Roles...');
    const rolesData = [
      {
        name: 'ADMIN',
        hierarchyLevel: 100,
        description: 'Administrator - Full access',
      },
      {
        name: 'SITE_COORDINATOR',
        hierarchyLevel: 80,
        description: 'Site Coordinator - View all, assign department, schedule',
      },
      {
        name: 'SUPERVISOR',
        hierarchyLevel: 60,
        description: 'Supervisor - Assign technicians, update work status',
      },
      {
        name: 'TECHNICIAN',
        hierarchyLevel: 30,
        description: 'Technician - Update assigned tickets, add work notes',
      },
      {
        name: 'TENANT',
        hierarchyLevel: 10,
        description: 'Tenant - Villa resident',
      },
    ];

    const roles: Map<string, Role> = new Map();
    for (const roleData of rolesData) {
      let role = await queryRunner.manager.findOne(Role, {
        where: { companyId, name: roleData.name },
      });

      if (!role) {
        role = queryRunner.manager.create(Role, {
          companyId,
          name: roleData.name,
          description: roleData.description,
          hierarchyLevel: roleData.hierarchyLevel,
        });
        role = await queryRunner.manager.save(role);
        console.log(`  ✅ Created role: ${role.name}`);
      } else {
        console.log(`  ✅ Using existing role: ${role.name}`);
      }
      roles.set(roleData.name, role);
    }

    // ==================== PERMISSIONS ====================
    console.log('\n🔐 Creating Permissions...');
    const permissionsData = [
      { resource: 'maintenance_ticket', action: 'create' },
      { resource: 'maintenance_ticket', action: 'read' },
      { resource: 'maintenance_ticket', action: 'update' },
      { resource: 'maintenance_ticket', action: 'delete' },
      { resource: 'maintenance_ticket', action: 'assign' },
      { resource: 'department', action: 'create' },
      { resource: 'department', action: 'read' },
      { resource: 'department', action: 'update' },
      { resource: 'department', action: 'delete' },
      { resource: 'user', action: 'create' },
      { resource: 'user', action: 'read' },
      { resource: 'user', action: 'update' },
      { resource: 'user', action: 'delete' },
      { resource: 'role', action: 'create' },
      { resource: 'role', action: 'read' },
      { resource: 'role', action: 'update' },
      { resource: 'role', action: 'delete' },
      { resource: 'site', action: 'create' },
      { resource: 'site', action: 'read' },
      { resource: 'site', action: 'update' },
      { resource: 'site', action: 'delete' },
      { resource: 'report', action: 'read' },
      { resource: 'notification', action: 'read' },
      { resource: 'hierarchy', action: 'read' },
    ];

    const permissions: Map<string, Permission> = new Map();
    for (const permData of permissionsData) {
      const key = `${permData.resource}:${permData.action}`;
      // Permissions are GLOBAL (not tenant-scoped)
      let permission = await queryRunner.manager.findOne(Permission, {
        where: {
          resource: permData.resource,
          action: permData.action,
        },
      });

      if (!permission) {
        permission = queryRunner.manager.create(Permission, {
          resource: permData.resource,
          action: permData.action,
          description: `${permData.action} ${permData.resource}`,
        });
        permission = await queryRunner.manager.save(permission);
      }
      permissions.set(key, permission);
    }
    console.log(`✅ Created/verified ${permissions.size} permissions`);

    // ==================== ROLE PERMISSIONS ====================
    console.log('\n🔗 Assigning Permissions to Roles...');
    const rolePermissionMappings = [
      {
        role: 'ADMIN',
        permissions: Array.from(permissions.keys()),
      },
      {
        role: 'SITE_COORDINATOR',
        permissions: [
          'maintenance_ticket:read',
          'maintenance_ticket:assign',
          'department:read',
          'site:read',
          'report:read',
          'notification:read',
        ],
      },
      {
        role: 'SUPERVISOR',
        permissions: [
          'maintenance_ticket:read',
          'maintenance_ticket:update',
          'maintenance_ticket:assign',
          'department:read',
          'report:read',
          'notification:read',
        ],
      },
      {
        role: 'TECHNICIAN',
        permissions: [
          'maintenance_ticket:read',
          'maintenance_ticket:update',
          'report:read',
          'notification:read',
        ],
      },
      {
        role: 'TENANT',
        permissions: ['maintenance_ticket:create', 'maintenance_ticket:read'],
      },
    ];

    let rolePermissionCount = 0;
    for (const mapping of rolePermissionMappings) {
      const role = roles.get(mapping.role);
      if (!role) continue;

      for (const permKey of mapping.permissions) {
        const permission = permissions.get(permKey);
        if (!permission) continue;

        const existing = await queryRunner.manager.findOne(RolePermission, {
          where: {
            companyId,
            roleId: role.id,
            permissionId: permission.id,
          },
        });

        if (!existing) {
          const rolePermission = queryRunner.manager.create(RolePermission, {
            companyId,
            roleId: role.id,
            permissionId: permission.id,
          });
          await queryRunner.manager.save(rolePermission);
          rolePermissionCount++;
        }
      }
    }
    console.log(`✅ Created ${rolePermissionCount} role-permission mappings`);

    // ==================== USERS ====================
    console.log('\n👤 Creating Users...');
    const passwordHash = await bcrypt.hash(DEFAULT_PASSWORD, 10);

    // Users from config (required)
    const usersToCreate = config.users;
    
    if (!usersToCreate || usersToCreate.length === 0) {
      throw new Error('At least one user must be provided in the configuration');
    }
    const createdUsers: Array<{ user: User; roleName: string }> = [];

    for (const userData of usersToCreate) {
      let user = await queryRunner.manager.findOne(User, {
        where: { companyId, email: userData.email },
      });

      if (!user) {
        user = queryRunner.manager.create(User, {
          companyId,
          email: userData.email,
          passwordHash,
          firstName: userData.firstName,
          lastName: userData.lastName,
          status: UserStatus.ACTIVE,
          authProvider: AuthProvider.LOCAL,
        });
        user = await queryRunner.manager.save(user);
        console.log(`  ✅ Created user: ${user.email}`);
      } else {
        console.log(`  ✅ Using existing user: ${user.email}`);
      }

      // Assign role to user
      const role = roles.get(userData.role);
      if (role) {
        const existingUserRole = await queryRunner.manager.findOne(UserRole, {
          where: {
            companyId,
            userId: user.id,
            roleId: role.id,
          },
        });

        if (!existingUserRole) {
          const userRole = queryRunner.manager.create(UserRole, {
            companyId,
            userId: user.id,
            roleId: role.id,
          });
          await queryRunner.manager.save(userRole);
          console.log(`    ✅ Assigned ${userData.role} role`);
        } else {
          console.log(`    ✅ User already has ${userData.role} role`);
        }

        // For admin user, ensure they don't have TENANT role
        if (userData.role === 'ADMIN') {
          const tenantRole = roles.get('TENANT');
          if (tenantRole) {
            const tenantUserRole = await queryRunner.manager.findOne(
              UserRole,
              {
                where: {
                  companyId,
                  userId: user.id,
                  roleId: tenantRole.id,
                },
              },
            );

            if (tenantUserRole) {
              await queryRunner.manager.remove(tenantUserRole);
              console.log(`    ✅ Removed TENANT role from admin user`);
            }
          }
        }
      }

      createdUsers.push({ user, roleName: userData.role });
    }

    await queryRunner.commitTransaction();
    console.log('\n✅ Company and users created successfully!\n');

    // Print summary
    console.log('📋 Summary:');
    console.log(`   Company: ${company.name} (${company.code})`);
    console.log(`   Company ID: ${company.id}`);
    console.log(`   Roles Created: ${roles.size}`);
    console.log(`   Users Created: ${createdUsers.length}\n`);

    console.log('👤 Users:');
    for (const { user, roleName } of createdUsers) {
      console.log(
        `   - ${user.email} (${roleName}) - Password: ${DEFAULT_PASSWORD}`,
      );
    }

    console.log('\n🎉 Done!\n');
  } catch (error) {
    await queryRunner.rollbackTransaction();
    console.error('❌ Error creating company and users:', error);
    throw error;
  } finally {
    await queryRunner.release();
    await dataSource.destroy();
  }
}

// Main execution
async function main() {
  try {
    // Import configuration from company-config.ts
    const { companyConfig } = await import('./company-config');
    
    console.log('📋 Loading configuration from company-config.ts...\n');
    
    // Validate configuration
    if (!companyConfig.company || !companyConfig.company.name) {
      throw new Error('Company name is required in company-config.ts');
    }
    
    if (!companyConfig.users || companyConfig.users.length === 0) {
      throw new Error('At least one user is required in company-config.ts');
    }
    
    // Validate user roles
    const validRoles = ['ADMIN', 'SITE_COORDINATOR', 'SUPERVISOR', 'TECHNICIAN', 'TENANT'];
    for (const user of companyConfig.users) {
      if (!validRoles.includes(user.role)) {
        throw new Error(
          `Invalid role '${user.role}' for user ${user.email}. Valid roles: ${validRoles.join(', ')}`,
        );
      }
    }
    
    await createCompanyWithUsers(companyConfig);
  } catch (error: any) {
    if (error.code === 'MODULE_NOT_FOUND' && error.message.includes('company-config')) {
      console.error('❌ Error: company-config.ts file not found!');
      console.error('   Please create apps/backend/scripts/company-config.ts');
      console.error('   You can copy from the template in CREATE_COMPANY_GUIDE.md\n');
    } else {
      console.error('❌ Error:', error.message || error);
    }
    process.exit(1);
  }
}

// Run if executed directly
if (require.main === module) {
  main().catch((error) => {
    console.error('Fatal error:', error);
    process.exit(1);
  });
}

export {
  createCompanyWithUsers,
  generateCompanyCode,
  generateUniqueCompanyCode,
  type CompanyConfig,
  type UserConfig,
};

