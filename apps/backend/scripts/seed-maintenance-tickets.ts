import { DataSource } from 'typeorm';
import * as bcrypt from 'bcrypt';
import { User, UserStatus, AuthProvider } from '../src/modules/iam/entities/user.entity';
import { Company } from '../src/modules/tenant/entities/company.entity';
import { Role } from '../src/modules/iam/entities/role.entity';
import { UserRole } from '../src/modules/iam/entities/user-role.entity';
import { Department } from '../src/modules/maintenance-ticket/entities/department.entity';
import { MaintenanceTicket } from '../src/modules/maintenance-ticket/entities/maintenance-ticket.entity';
import { TicketStatus } from '../src/modules/maintenance-ticket/enums/ticket-status.enum';
import { TicketPriority } from '../src/modules/maintenance-ticket/enums/ticket-priority.enum';
import { UserRole as MaintenanceUserRole } from '../src/modules/maintenance-ticket/enums/user-role.enum';

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

async function seed() {
  console.log('Starting maintenance ticket system seed...');

  await dataSource.initialize();
  const queryRunner = dataSource.createQueryRunner();
  await queryRunner.connect();
  await queryRunner.startTransaction();

  try {
    const testCompanyId = 'eb75a65b-055f-4408-a58c-71d233443c17';
    let company = await queryRunner.manager.findOne(Company, {
      where: { companyId: testCompanyId },
    });

    if (!company) {
      company = queryRunner.manager.create(Company, {
        companyId: testCompanyId,
        name: 'Villa Maintenance Company',
        code: 'VMC',
      });
      company = await queryRunner.manager.save(company);
      console.log(`Created company: ${company.name} (${company.id})`);
    } else {
      console.log(`Using existing company: ${company.name} (${company.id})`);
    }

    const companyId = company.companyId;

    const rolesToCreate = [
      { name: MaintenanceUserRole.TENANT, hierarchyLevel: 10, description: 'Tenant - Villa resident' },
      { name: MaintenanceUserRole.ADMIN, hierarchyLevel: 100, description: 'Administrator - Full access' },
      { name: MaintenanceUserRole.SITE_COORDINATOR, hierarchyLevel: 80, description: 'Site Coordinator - View all, assign department, schedule' },
      { name: MaintenanceUserRole.SUPERVISOR, hierarchyLevel: 60, description: 'Supervisor - Assign technicians, update work status' },
      { name: MaintenanceUserRole.TECHNICIAN, hierarchyLevel: 30, description: 'Technician - Update assigned tickets, add work notes' },
    ];

    const roles: Map<string, Role> = new Map();

    for (const roleData of rolesToCreate) {
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
        console.log(`Created role: ${role.name}`);
      } else {
        console.log(`Using existing role: ${role.name}`);
      }

      roles.set(roleData.name, role);
    }

    const adminRole = roles.get(MaintenanceUserRole.ADMIN)!;
    const siteCoordinatorRole = roles.get(MaintenanceUserRole.SITE_COORDINATOR)!;
    const supervisorRole = roles.get(MaintenanceUserRole.SUPERVISOR)!;
    const technicianRole = roles.get(MaintenanceUserRole.TECHNICIAN)!;
    const tenantRole = roles.get(MaintenanceUserRole.TENANT)!;

    const passwordHash = await bcrypt.hash(DEFAULT_PASSWORD, 10);

    const adminUser = await queryRunner.manager.findOne(User, {
      where: { companyId, email: 'vivek.ellappan@helixsense.com' },
    });

    if (!adminUser) {
      const newAdmin = queryRunner.manager.create(User, {
        companyId,
        email: 'vivek.ellappan@helixsense.com',
        passwordHash,
        firstName: 'System',
        lastName: 'Administrator',
        status: UserStatus.ACTIVE,
        authProvider: AuthProvider.LOCAL,
      });
      const savedAdmin = await queryRunner.manager.save(newAdmin);

      const adminUserRole = queryRunner.manager.create(UserRole, {
        companyId,
        userId: savedAdmin.id,
        roleId: adminRole.id,
      });
      await queryRunner.manager.save(adminUserRole);
      console.log(`Created admin user: ${savedAdmin.email}`);
    } else {
      console.log(`Using existing admin user: ${adminUser.email}`);
    }

    const siteCoordinatorUser = await queryRunner.manager.findOne(User, {
      where: { companyId, email: 'coordinator@villa-maintenance.com' },
    });

    if (!siteCoordinatorUser) {
      const newCoordinator = queryRunner.manager.create(User, {
        companyId,
        email: 'coordinator@villa-maintenance.com',
        passwordHash,
        firstName: 'Site',
        lastName: 'Coordinator',
        status: UserStatus.ACTIVE,
        authProvider: AuthProvider.LOCAL,
      });
      const savedCoordinator = await queryRunner.manager.save(newCoordinator);

      const coordinatorUserRole = queryRunner.manager.create(UserRole, {
        companyId,
        userId: savedCoordinator.id,
        roleId: siteCoordinatorRole.id,
      });
      await queryRunner.manager.save(coordinatorUserRole);
      console.log(`Created site coordinator user: ${savedCoordinator.email}`);
    } else {
      console.log(`Using existing site coordinator user: ${siteCoordinatorUser.email}`);
    }

    const supervisorUser = await queryRunner.manager.findOne(User, {
      where: { companyId, email: 'supervisor@villa-maintenance.com' },
    });

    if (!supervisorUser) {
      const newSupervisor = queryRunner.manager.create(User, {
        companyId,
        email: 'supervisor@villa-maintenance.com',
        passwordHash,
        firstName: 'Maintenance',
        lastName: 'Supervisor',
        status: UserStatus.ACTIVE,
        authProvider: AuthProvider.LOCAL,
      });
      const savedSupervisor = await queryRunner.manager.save(newSupervisor);

      const supervisorUserRole = queryRunner.manager.create(UserRole, {
        companyId,
        userId: savedSupervisor.id,
        roleId: supervisorRole.id,
      });
      await queryRunner.manager.save(supervisorUserRole);
      console.log(`Created supervisor user: ${savedSupervisor.email}`);
    } else {
      console.log(`Using existing supervisor user: ${supervisorUser.email}`);
    }

    const technician1User = await queryRunner.manager.findOne(User, {
      where: { companyId, email: 'technician1@villa-maintenance.com' },
    });

    if (!technician1User) {
      const newTech1 = queryRunner.manager.create(User, {
        companyId,
        email: 'technician1@villa-maintenance.com',
        passwordHash,
        firstName: 'John',
        lastName: 'Technician',
        status: UserStatus.ACTIVE,
        authProvider: AuthProvider.LOCAL,
      });
      const savedTech1 = await queryRunner.manager.save(newTech1);

      const tech1UserRole = queryRunner.manager.create(UserRole, {
        companyId,
        userId: savedTech1.id,
        roleId: technicianRole.id,
      });
      await queryRunner.manager.save(tech1UserRole);
      console.log(`Created technician 1 user: ${savedTech1.email}`);
    } else {
      console.log(`Using existing technician 1 user: ${technician1User.email}`);
    }

    const technician2User = await queryRunner.manager.findOne(User, {
      where: { companyId, email: 'technician2@villa-maintenance.com' },
    });

    if (!technician2User) {
      const newTech2 = queryRunner.manager.create(User, {
        companyId,
        email: 'technician2@villa-maintenance.com',
        passwordHash,
        firstName: 'Jane',
        lastName: 'Technician',
        status: UserStatus.ACTIVE,
        authProvider: AuthProvider.LOCAL,
      });
      const savedTech2 = await queryRunner.manager.save(newTech2);

      const tech2UserRole = queryRunner.manager.create(UserRole, {
        companyId,
        userId: savedTech2.id,
        roleId: technicianRole.id,
      });
      await queryRunner.manager.save(tech2UserRole);
      console.log(`Created technician 2 user: ${savedTech2.email}`);
    } else {
      console.log(`Using existing technician 2 user: ${technician2User.email}`);
    }

    console.log('Creating 86 tenant users (one per villa)...');
    const tenantUsers: User[] = [];

    for (let villaNumber = 1; villaNumber <= 86; villaNumber++) {
      const email = `villa${villaNumber}@tenant.com`;
      let tenant = await queryRunner.manager.findOne(User, {
        where: { companyId, email },
      });

      if (!tenant) {
        const newTenant = queryRunner.manager.create(User, {
          companyId,
          email,
          passwordHash,
          firstName: `Villa`,
          lastName: `${villaNumber}`,
          villaNumber,
          status: UserStatus.ACTIVE,
          authProvider: AuthProvider.LOCAL,
        });
        const savedTenant = await queryRunner.manager.save(newTenant);

        const tenantUserRole = queryRunner.manager.create(UserRole, {
          companyId,
          userId: savedTenant.id,
          roleId: tenantRole.id,
        });
        await queryRunner.manager.save(tenantUserRole);

        tenantUsers.push(savedTenant);
        if (villaNumber % 10 === 0) {
          console.log(`Created ${villaNumber} tenant users...`);
        }
      } else {
        tenantUsers.push(tenant);
      }
    }

    console.log(`Created/verified ${tenantUsers.length} tenant users`);

    const departments = [
      { name: 'Plumbing', description: 'Plumbing and water systems' },
      { name: 'Electrical', description: 'Electrical systems and repairs' },
      { name: 'HVAC', description: 'Heating, ventilation, and air conditioning' },
      { name: 'General Maintenance', description: 'General maintenance and repairs' },
      { name: 'Landscaping', description: 'Landscaping and outdoor maintenance' },
    ];

    const departmentEntities: Department[] = [];

    for (const deptData of departments) {
      let department = await queryRunner.manager.findOne(Department, {
        where: { companyId, name: deptData.name },
      });

      if (!department) {
        department = queryRunner.manager.create(Department, {
          companyId,
          name: deptData.name,
          description: deptData.description,
          isActive: true,
        });
        department = await queryRunner.manager.save(department);
        console.log(`Created department: ${department.name}`);
      } else {
        console.log(`Using existing department: ${department.name}`);
      }

      departmentEntities.push(department);
    }

    console.log('Seed completed successfully!');
    console.log('\n=== Summary ===');
    console.log(`Company: ${company.name} (${company.id})`);
    console.log(`Roles created: ${roles.size}`);
    console.log(`Tenant users: ${tenantUsers.length}`);
    console.log(`Departments: ${departmentEntities.length}`);
    console.log('\n=== Test Credentials ===');
    console.log('Admin: vivek.ellappan@helixsense.com / password123');
    console.log('Site Coordinator: coordinator@villa-maintenance.com / password123');
    console.log('Supervisor: supervisor@villa-maintenance.com / password123');
    console.log('Technician 1: technician1@villa-maintenance.com / password123');
    console.log('Technician 2: technician2@villa-maintenance.com / password123');
    console.log('Tenants: villa1@tenant.com through villa86@tenant.com / password123');

    await queryRunner.commitTransaction();
  } catch (error) {
    await queryRunner.rollbackTransaction();
    console.error('Error seeding data:', error);
    throw error;
  } finally {
    await queryRunner.release();
    await dataSource.destroy();
  }
}

seed()
  .then(() => {
    console.log('Seed script completed');
    process.exit(0);
  })
  .catch((error) => {
    console.error('Seed script failed:', error);
    process.exit(1);
  });

