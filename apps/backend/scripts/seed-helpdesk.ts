import { DataSource } from 'typeorm';
import * as bcrypt from 'bcrypt';
import { User, UserStatus, AuthProvider } from '../src/modules/iam/entities/user.entity';
import { Company } from '../src/modules/tenant/entities/company.entity';
import { Site } from '../src/modules/tenant/entities/site.entity';
import { Role } from '../src/modules/iam/entities/role.entity';
import { UserRole } from '../src/modules/iam/entities/user-role.entity';
import { Department } from '../src/modules/maintenance-ticket/entities/department.entity';
import { MaintenanceTicket } from '../src/modules/maintenance-ticket/entities/maintenance-ticket.entity';
import { TicketStatusHistory } from '../src/modules/maintenance-ticket/entities/ticket-status-history.entity';
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
const COMPANY_ID = 'eb75a65b-055f-4408-a58c-71d233443c17';

// Dummy maintenance ticket templates
const TICKET_TEMPLATES = [
  {
    title: 'Leaky Faucet in Kitchen',
    description: 'The kitchen faucet is leaking continuously. Water is dripping from the base and handle.',
    priority: TicketPriority.HIGH,
    department: 'Plumbing',
  },
  {
    title: 'AC Not Cooling',
    description: 'Air conditioning unit is not cooling properly. Temperature remains high despite setting it to lowest.',
    priority: TicketPriority.URGENT,
    department: 'HVAC',
  },
  {
    title: 'Broken Light Switch',
    description: 'Light switch in living room is not working. Need to replace the switch.',
    priority: TicketPriority.MEDIUM,
    department: 'Electrical',
  },
  {
    title: 'Garbage Disposal Not Working',
    description: 'Kitchen garbage disposal makes noise but does not grind. May need repair or replacement.',
    priority: TicketPriority.MEDIUM,
    department: 'Plumbing',
  },
  {
    title: 'Window Won\'t Close Properly',
    description: 'Bedroom window cannot be closed completely. Security concern.',
    priority: TicketPriority.HIGH,
    department: 'General Maintenance',
  },
  {
    title: 'Heater Not Working',
    description: 'Heating system is not functioning. Very cold inside the villa.',
    priority: TicketPriority.URGENT,
    department: 'HVAC',
  },
  {
    title: 'Power Outlet Not Working',
    description: 'Power outlet in bedroom is not providing electricity. Checked with multiple devices.',
    priority: TicketPriority.MEDIUM,
    department: 'Electrical',
  },
  {
    title: 'Toilet Running Continuously',
    description: 'Toilet keeps running water even after flushing. Wasting water.',
    priority: TicketPriority.HIGH,
    department: 'Plumbing',
  },
  {
    title: 'Door Lock Malfunction',
    description: 'Main entrance door lock is not responding properly. Sometimes key gets stuck.',
    priority: TicketPriority.HIGH,
    department: 'General Maintenance',
  },
  {
    title: 'Water Pressure Low',
    description: 'Water pressure in shower and kitchen sink is very low. Inconsistent flow.',
    priority: TicketPriority.MEDIUM,
    department: 'Plumbing',
  },
  {
    title: 'Ceiling Fan Making Noise',
    description: 'Ceiling fan in bedroom is making loud grinding noise. Needs inspection.',
    priority: TicketPriority.LOW,
    department: 'Electrical',
  },
  {
    title: 'Garden Sprinkler Broken',
    description: 'Garden sprinkler system is not working. Some sprinklers are not turning on.',
    priority: TicketPriority.LOW,
    department: 'Landscaping',
  },
  {
    title: 'Smoke Detector Beeping',
    description: 'Smoke detector is beeping continuously. Battery may need replacement.',
    priority: TicketPriority.MEDIUM,
    department: 'General Maintenance',
  },
  {
    title: 'Washing Machine Drain Issue',
    description: 'Washing machine drain is backing up. Water not draining properly.',
    priority: TicketPriority.HIGH,
    department: 'Plumbing',
  },
  {
    title: 'AC Filter Replacement Needed',
    description: 'AC filter is dirty and needs replacement. Air quality is poor.',
    priority: TicketPriority.LOW,
    department: 'HVAC',
  },
  {
    title: 'Broken Window Blind',
    description: 'Window blind in living room is broken. Cannot open or close properly.',
    priority: TicketPriority.LOW,
    department: 'General Maintenance',
  },
  {
    title: 'Refrigerator Not Cooling',
    description: 'Refrigerator is not maintaining cold temperature. Food is spoiling.',
    priority: TicketPriority.URGENT,
    department: 'HVAC',
  },
  {
    title: 'Shower Head Leaking',
    description: 'Shower head is leaking from multiple points. Water spraying everywhere.',
    priority: TicketPriority.MEDIUM,
    department: 'Plumbing',
  },
  {
    title: 'Garage Door Opener Not Working',
    description: 'Garage door opener remote is not working. Door cannot be opened remotely.',
    priority: TicketPriority.MEDIUM,
    department: 'General Maintenance',
  },
  {
    title: 'Pool Pump Making Noise',
    description: 'Pool pump is making loud noise. May need maintenance or replacement.',
    priority: TicketPriority.HIGH,
    department: 'General Maintenance',
  },
];

function getRandomStatus(): TicketStatus {
  const statuses = [
    TicketStatus.NEW,
    TicketStatus.ACKNOWLEDGED,
    TicketStatus.ASSIGNED,
    TicketStatus.IN_PROGRESS,
    TicketStatus.ON_HOLD,
    TicketStatus.COMPLETED,
  ];
  return statuses[Math.floor(Math.random() * statuses.length)];
}

function getStatusSequence(status: TicketStatus): TicketStatus[] {
  const sequences: Record<TicketStatus, TicketStatus[]> = {
    [TicketStatus.NEW]: [TicketStatus.NEW],
    [TicketStatus.ACKNOWLEDGED]: [TicketStatus.NEW, TicketStatus.ACKNOWLEDGED],
    [TicketStatus.ASSIGNED]: [
      TicketStatus.NEW,
      TicketStatus.ACKNOWLEDGED,
      TicketStatus.ASSIGNED,
    ],
    [TicketStatus.IN_PROGRESS]: [
      TicketStatus.NEW,
      TicketStatus.ACKNOWLEDGED,
      TicketStatus.ASSIGNED,
      TicketStatus.IN_PROGRESS,
    ],
    [TicketStatus.ON_HOLD]: [
      TicketStatus.NEW,
      TicketStatus.ACKNOWLEDGED,
      TicketStatus.ASSIGNED,
      TicketStatus.IN_PROGRESS,
      TicketStatus.ON_HOLD,
    ],
    [TicketStatus.COMPLETED]: [
      TicketStatus.NEW,
      TicketStatus.ACKNOWLEDGED,
      TicketStatus.ASSIGNED,
      TicketStatus.IN_PROGRESS,
      TicketStatus.COMPLETED,
    ],
    [TicketStatus.CANCELLED]: [TicketStatus.NEW, TicketStatus.CANCELLED],
  };
  return sequences[status] || [TicketStatus.NEW];
}

function getRandomDateInPast(daysAgo: number): Date {
  const date = new Date();
  date.setDate(date.getDate() - daysAgo);
  date.setHours(Math.floor(Math.random() * 24));
  date.setMinutes(Math.floor(Math.random() * 60));
  return date;
}

async function seedHelpdesk() {
  console.log('🚀 Starting helpdesk seed...');

  await dataSource.initialize();
  const queryRunner = dataSource.createQueryRunner();
  await queryRunner.connect();
  await queryRunner.startTransaction();

  try {
    // Create Company (use id as primary key; Company does not have companyId column)
    let company = await queryRunner.manager.findOne(Company, {
      where: { id: COMPANY_ID },
    });

    if (!company) {
      company = queryRunner.manager.create(Company, {
        id: COMPANY_ID,
        name: 'Villa Maintenance Company',
        code: 'VMC',
      });
      company = await queryRunner.manager.save(company);
      console.log(`✓ Created company: ${company.name}`);
    } else {
      console.log(`✓ Using existing company: ${company.name}`);
    }

    const companyId = company.id;

    // Create a default Site so /public/lookup/villas (sites) returns data
    let site = await queryRunner.manager.findOne(Site, {
      where: { companyId, code: 'VMC_MAIN' },
    });

    if (!site) {
      site = queryRunner.manager.create(Site, {
        companyId,
        code: 'VMC_MAIN',
        name: 'Villa Maintenance Main Site',
        description: 'Primary site for all seeded villas',
        address: 'Main Street',
        city: 'Test City',
        country: 'Test Country',
        isParent: true,
        isActive: true,
      });
      site = await queryRunner.manager.save(site);
      console.log(`✓ Created site: ${site.name}`);
    } else {
      console.log(`✓ Using existing site: ${site.name}`);
    }

    // Create Roles
    const rolesToCreate = [
      {
        name: MaintenanceUserRole.TENANT,
        hierarchyLevel: 10,
        description: 'Tenant - Villa resident',
      },
      {
        name: MaintenanceUserRole.ADMIN,
        hierarchyLevel: 100,
        description: 'Administrator - Full access',
      },
      {
        name: MaintenanceUserRole.SITE_COORDINATOR,
        hierarchyLevel: 80,
        description: 'Site Coordinator - View all, assign department, schedule',
      },
      {
        name: MaintenanceUserRole.SUPERVISOR,
        hierarchyLevel: 60,
        description: 'Supervisor - Assign technicians, update work status',
      },
      {
        name: MaintenanceUserRole.TECHNICIAN,
        hierarchyLevel: 30,
        description: 'Technician - Update assigned tickets, add work notes',
      },
    ];

    const roles = new Map<string, Role>();
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
        console.log(`✓ Created role: ${role.name}`);
      }
      roles.set(roleData.name, role);
    }

    const adminRole = roles.get(MaintenanceUserRole.ADMIN)!;
    const siteCoordinatorRole = roles.get(MaintenanceUserRole.SITE_COORDINATOR)!;
    const supervisorRole = roles.get(MaintenanceUserRole.SUPERVISOR)!;
    const technicianRole = roles.get(MaintenanceUserRole.TECHNICIAN)!;
    const tenantRole = roles.get(MaintenanceUserRole.TENANT)!;

    // Create Users
    const passwordHash = await bcrypt.hash(DEFAULT_PASSWORD, 10);

    // Staff Users
    const staffUsers = [
      {
        email: 'vivek.ellappan@helixsense.com',
        firstName: 'Vivek',
        lastName: 'Ellappan',
        role: adminRole,
      },
      {
        email: 'coordinator@villa-maintenance.com',
        firstName: 'Site',
        lastName: 'Coordinator',
        role: siteCoordinatorRole,
      },
      {
        email: 'supervisor@villa-maintenance.com',
        firstName: 'Maintenance',
        lastName: 'Supervisor',
        role: supervisorRole,
      },
      {
        email: 'technician1@villa-maintenance.com',
        firstName: 'John',
        lastName: 'Technician',
        role: technicianRole,
      },
      {
        email: 'technician2@villa-maintenance.com',
        firstName: 'Jane',
        lastName: 'Technician',
        role: technicianRole,
      },
    ];

    const staffUserMap = new Map<string, User>();
    for (const staffData of staffUsers) {
      let user = await queryRunner.manager.findOne(User, {
        where: { companyId, email: staffData.email },
      });

      if (!user) {
        user = queryRunner.manager.create(User, {
          companyId,
          email: staffData.email,
          passwordHash,
          firstName: staffData.firstName,
          lastName: staffData.lastName,
          status: UserStatus.ACTIVE,
          authProvider: AuthProvider.LOCAL,
        });
        user = await queryRunner.manager.save(user);

        const userRole = queryRunner.manager.create(UserRole, {
          companyId,
          userId: user.id,
          roleId: staffData.role.id,
        });
        await queryRunner.manager.save(userRole);
        console.log(`✓ Created staff user: ${user.email}`);
      }
      staffUserMap.set(staffData.email, user);
    }

    const adminUser = staffUserMap.get('vivek.ellappan@helixsense.com')!;
    const coordinatorUser = staffUserMap.get('coordinator@villa-maintenance.com')!;
    const supervisorUser = staffUserMap.get('supervisor@villa-maintenance.com')!;
    const technician1User = staffUserMap.get('technician1@villa-maintenance.com')!;
    const technician2User = staffUserMap.get('technician2@villa-maintenance.com')!;

    // Create Tenant Users (86 tenants)
    console.log('\n👥 Creating 86 tenant users...');
    const tenantUsers: User[] = [];
    for (let villaNumber = 1; villaNumber <= 86; villaNumber++) {
      const email = `villa${villaNumber}@tenant.com`;
      let tenant = await queryRunner.manager.findOne(User, {
        where: { companyId, email },
      });

      if (!tenant) {
        tenant = queryRunner.manager.create(User, {
          companyId,
          email,
          passwordHash,
          firstName: 'Villa',
          lastName: `${villaNumber}`,
          villaNumber,
          status: UserStatus.ACTIVE,
          authProvider: AuthProvider.LOCAL,
        });
        tenant = await queryRunner.manager.save(tenant);

        const tenantUserRole = queryRunner.manager.create(UserRole, {
          companyId,
          userId: tenant.id,
          roleId: tenantRole.id,
        });
        await queryRunner.manager.save(tenantUserRole);

        tenantUsers.push(tenant);
        if (villaNumber % 20 === 0) {
          console.log(`  ✓ Created ${villaNumber} tenant users...`);
        }
      } else {
        tenantUsers.push(tenant);
      }
    }
    console.log(`✓ Created/verified ${tenantUsers.length} tenant users`);

    // Create Departments
    const departments = [
      { name: 'Plumbing', description: 'Plumbing and water systems' },
      { name: 'Electrical', description: 'Electrical systems and repairs' },
      { name: 'HVAC', description: 'Heating, ventilation, and air conditioning' },
      { name: 'General Maintenance', description: 'General maintenance and repairs' },
      { name: 'Landscaping', description: 'Landscaping and outdoor maintenance' },
    ];

    const departmentMap = new Map<string, Department>();
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
        console.log(`✓ Created department: ${department.name}`);
      }
      departmentMap.set(deptData.name, department);
    }

    // Create Maintenance Tickets
    console.log('\n🎫 Creating maintenance tickets...');
    let ticketCounter = 1;

    // Create tickets for different villas with various statuses
    for (let i = 0; i < 150; i++) {
      const template =
        TICKET_TEMPLATES[i % TICKET_TEMPLATES.length];
      const villaNumber = Math.floor(Math.random() * 86) + 1;
      const tenant = tenantUsers[villaNumber - 1];
      const status = getRandomStatus();
      const statusSequence = getStatusSequence(status);
      const createdDate = getRandomDateInPast(Math.floor(Math.random() * 30) + 1);

      const ticketNumber = `TKT-${String(ticketCounter).padStart(6, '0')}`;
      ticketCounter++;

      const department = departmentMap.get(template.department);

      // Determine assigned technician based on status
      let assignedTechnician: User | undefined;
      let assignedBy: User | undefined;
      let assignedAt: Date | undefined;
      let scheduledAt: Date | undefined;
      let completedAt: Date | undefined;
      let closedAt: Date | undefined;

      if (
        status === TicketStatus.ASSIGNED ||
        status === TicketStatus.IN_PROGRESS ||
        status === TicketStatus.ON_HOLD ||
        status === TicketStatus.COMPLETED
      ) {
        assignedTechnician =
          Math.random() > 0.5 ? technician1User : technician2User;
        assignedBy = supervisorUser;
        assignedAt = new Date(createdDate);
        assignedAt.setHours(assignedAt.getHours() + Math.floor(Math.random() * 24) + 1);
      }

      if (
        status === TicketStatus.IN_PROGRESS ||
        status === TicketStatus.ON_HOLD ||
        status === TicketStatus.COMPLETED
      ) {
        scheduledAt = assignedAt
          ? new Date(assignedAt)
          : new Date(createdDate);
        scheduledAt.setDate(scheduledAt.getDate() + Math.floor(Math.random() * 3));
      }

      if (status === TicketStatus.COMPLETED) {
        completedAt = scheduledAt
          ? new Date(scheduledAt)
          : new Date(createdDate);
        completedAt.setDate(completedAt.getDate() + Math.floor(Math.random() * 5) + 1);
        completedAt.setHours(completedAt.getHours() + Math.floor(Math.random() * 8) + 1);
      }

      // closedAt is set when tenant confirms completion (handled separately)
      closedAt = undefined;

      const ticket = queryRunner.manager.create(MaintenanceTicket, {
        companyId,
        ticketNumber,
        villaNumber,
        createdBy: tenant.id,
        title: template.title,
        description: template.description,
        status,
        priority: template.priority,
        departmentId: department?.id,
        assignedTechnicianId: assignedTechnician?.id,
        assignedBy: assignedBy?.id,
        assignedAt,
        scheduledAt,
        completedAt,
        closedAt,
        technicianNotes:
          assignedTechnician && status !== TicketStatus.NEW
            ? `Work in progress. ${template.department} issue being addressed.`
            : undefined,
        resolutionNotes:
          status === TicketStatus.COMPLETED
            ? `Issue resolved. ${template.department} work completed successfully.`
            : undefined,
        tenantConfirmed:
          status === TicketStatus.COMPLETED
            ? Math.random() > 0.3
            : false,
      });

      const savedTicket = await queryRunner.manager.save(ticket);

      // Create Status History
      for (let j = 0; j < statusSequence.length; j++) {
        const currentStatus = statusSequence[j];
        const previousStatus = j > 0 ? statusSequence[j - 1] : undefined;
        const statusDate = new Date(createdDate);
        statusDate.setHours(statusDate.getHours() + j * 2);

        let changedBy: User;
        if (currentStatus === TicketStatus.NEW) {
          changedBy = tenant;
        } else if (
          currentStatus === TicketStatus.ACKNOWLEDGED ||
          currentStatus === TicketStatus.ASSIGNED
        ) {
          changedBy = coordinatorUser;
        } else if (
          currentStatus === TicketStatus.IN_PROGRESS ||
          currentStatus === TicketStatus.ON_HOLD ||
          currentStatus === TicketStatus.COMPLETED
        ) {
          changedBy = assignedTechnician || supervisorUser;
        } else {
          changedBy = adminUser;
        }

        const history = queryRunner.manager.create(TicketStatusHistory, {
          companyId,
          ticketId: savedTicket.id,
          previousStatus,
          newStatus: currentStatus,
          changedBy: changedBy.id,
          notes:
            currentStatus === TicketStatus.ACKNOWLEDGED
              ? 'Ticket acknowledged by site coordinator'
              : currentStatus === TicketStatus.ASSIGNED
              ? `Assigned to ${assignedTechnician?.firstName} ${assignedTechnician?.lastName}`
              : currentStatus === TicketStatus.IN_PROGRESS
              ? 'Work started'
              :             currentStatus === TicketStatus.COMPLETED
              ? 'Work completed'
              : undefined,
        });

        await queryRunner.manager.save(history);
      }

      if ((i + 1) % 25 === 0) {
        console.log(`  ✓ Created ${i + 1} tickets...`);
      }
    }

    console.log(`✓ Created ${ticketCounter - 1} maintenance tickets`);

    await queryRunner.commitTransaction();

    console.log('\n✅ Helpdesk seed completed successfully!');
    console.log('\n📊 Summary:');
    console.log(`   - Company: ${company.name}`);
    console.log(`   - Roles: ${roles.size}`);
    console.log(`   - Staff Users: ${staffUsers.length}`);
    console.log(`   - Tenant Users: ${tenantUsers.length}`);
    console.log(`   - Departments: ${departmentMap.size}`);
    console.log(`   - Maintenance Tickets: ${ticketCounter - 1}`);
    console.log('\n🔑 Test Credentials:');
    console.log('   Admin: vivek.ellappan@helixsense.com / password123');
    console.log('   Site Coordinator: coordinator@villa-maintenance.com / password123');
    console.log('   Supervisor: supervisor@villa-maintenance.com / password123');
    console.log('   Technician 1: technician1@villa-maintenance.com / password123');
    console.log('   Technician 2: technician2@villa-maintenance.com / password123');
    console.log('   Tenants: villa1@tenant.com through villa86@tenant.com / password123');
  } catch (error) {
    await queryRunner.rollbackTransaction();
    console.error('❌ Seed failed:', error);
    throw error;
  } finally {
    await queryRunner.release();
    await dataSource.destroy();
  }
}

seedHelpdesk()
  .then(() => {
    console.log('\n✅ Seed script completed');
    process.exit(0);
  })
  .catch((error) => {
    console.error('❌ Seed script failed:', error);
    process.exit(1);
  });

