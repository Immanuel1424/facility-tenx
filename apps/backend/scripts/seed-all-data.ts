import { DataSource, IsNull } from 'typeorm';
import * as bcrypt from 'bcrypt';
import { User, UserStatus, AuthProvider } from '../src/modules/iam/entities/user.entity';
import { Company } from '../src/modules/tenant/entities/company.entity';
import { Site } from '../src/modules/tenant/entities/site.entity';
import { SpaceCategory } from '../src/modules/tenant/entities/space-category.entity';
import { Role } from '../src/modules/iam/entities/role.entity';
import { Permission } from '../src/modules/iam/entities/permission.entity';
import { RolePermission } from '../src/modules/iam/entities/role-permission.entity';
import { UserRole } from '../src/modules/iam/entities/user-role.entity';
import { AclEntry } from '../src/modules/iam/entities/acl-entry.entity';
import { Department } from '../src/modules/maintenance-ticket/entities/department.entity';
import { MaintenanceTicket } from '../src/modules/maintenance-ticket/entities/maintenance-ticket.entity';
import { TicketStatusHistory } from '../src/modules/maintenance-ticket/entities/ticket-status-history.entity';
import { TicketStatus } from '../src/modules/maintenance-ticket/enums/ticket-status.enum';
import { TicketPriority } from '../src/modules/maintenance-ticket/enums/ticket-priority.enum';
import { ServiceRequest } from '../src/modules/service-request/entities/service-request.entity';
import { ServiceRequestStatusTransition } from '../src/modules/service-request/entities/service-request-status-transition.entity';
import { ServiceRequestWorkflow } from '../src/modules/service-request/entities/service-request-workflow.entity';
import { Notification } from '../src/modules/notification/entities/notification.entity';
import { NotificationTemplate } from '../src/modules/notification/entities/notification-template.entity';
import { NotificationDelivery, DeliveryStatus } from '../src/modules/notification/entities/notification-delivery.entity';
import { NotificationAuditLog } from '../src/modules/notification/entities/notification-audit-log.entity';
import { NotificationChannel } from '../src/modules/notification/enums/notification-channel.enum';
import { NotificationSeverity } from '../src/modules/notification/enums/notification-severity.enum';
import { HierarchyNode } from '../src/modules/hierarchy/entities/hierarchy-node.entity';

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
  console.log('🚀 Starting comprehensive seed for all tables...\n');

  await dataSource.initialize();
  const queryRunner = dataSource.createQueryRunner();
  await queryRunner.connect();
  await queryRunner.startTransaction();

  try {
    // ==================== COMPANY ====================
    console.log('📦 Creating Company...');
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
      // Set companyId to its own ID for the top-level company
      company.companyId = company.id;
      company = await queryRunner.manager.save(company);
      console.log(`✅ Created company: ${company.name} (${company.id})\n`);
    } else {
      console.log(`✅ Using existing company: ${company.name} (${company.id})\n`);
    }

    const companyId = company.companyId;

    // ==================== SITES ====================
    console.log('🏢 Creating Sites...');
    const sitesData = [
      { code: 'SITE1', name: 'Main Villa Complex', isParent: true },
      { code: 'SITE2', name: 'North Wing', isParent: false },
      { code: 'SITE3', name: 'South Wing', isParent: false },
      { code: 'SITE4', name: 'East Wing', isParent: false },
      { code: 'SITE5', name: 'West Wing', isParent: false },
    ];

    const sites: Site[] = [];
    let parentSite: Site | null = null;

    for (const siteData of sitesData) {
      let site = await queryRunner.manager.findOne(Site, {
        where: { code: siteData.code },
      });

      if (!site) {
        site = queryRunner.manager.create(Site, {
          code: siteData.code,
          name: siteData.name,
          isParent: siteData.isParent,
          parentSite: siteData.isParent ? undefined : parentSite || undefined,
        });
        site = await queryRunner.manager.save(site);
        console.log(`  ✅ Created site: ${site.name}`);
      } else {
        console.log(`  ✅ Using existing site: ${site.name}`);
      }

      if (siteData.isParent) {
        parentSite = site;
      }
      sites.push(site);
    }
    console.log(`✅ Created/verified ${sites.length} sites\n`);

    // ==================== SPACE CATEGORIES ====================
    console.log('📋 Creating Space Categories...');
    const spaceCategoriesData = [
      { code: 'RES', name: 'Residential', description: 'Residential spaces' },
      { code: 'COM', name: 'Commercial', description: 'Commercial spaces' },
      { code: 'COMN', name: 'Common Area', description: 'Common areas' },
      { code: 'PARK', name: 'Parking', description: 'Parking spaces' },
      { code: 'AMEN', name: 'Amenity', description: 'Amenity spaces' },
    ];

    const spaceCategories: SpaceCategory[] = [];
    for (const catData of spaceCategoriesData) {
      let category = await queryRunner.manager.findOne(SpaceCategory, {
        where: { code: catData.code },
      });

      if (!category) {
        category = queryRunner.manager.create(SpaceCategory, {
          code: catData.code,
          name: catData.name,
          description: catData.description,
          isActive: true,
        });
        category = await queryRunner.manager.save(category);
        console.log(`  ✅ Created category: ${category.name}`);
      } else {
        console.log(`  ✅ Using existing category: ${category.name}`);
      }
      spaceCategories.push(category);
    }
    console.log(`✅ Created/verified ${spaceCategories.length} space categories\n`);

    // ==================== ROLES ====================
    console.log('👥 Creating Roles...');
    const rolesData = [
      { name: 'TENANT', hierarchyLevel: 10, description: 'Tenant - Villa resident' },
      { name: 'ADMIN', hierarchyLevel: 100, description: 'Administrator - Full access' },
      { name: 'SITE_COORDINATOR', hierarchyLevel: 80, description: 'Site Coordinator' },
      { name: 'SUPERVISOR', hierarchyLevel: 60, description: 'Supervisor' },
      { name: 'TECHNICIAN', hierarchyLevel: 30, description: 'Technician - Update assigned tickets, add work notes' },
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
    console.log(`✅ Created/verified ${roles.size} roles\n`);

    // ==================== PERMISSIONS ====================
    console.log('🔐 Creating Permissions...');
    const permissionsData = [
      { resource: 'user', action: 'create', description: 'Create users' },
      { resource: 'user', action: 'read', description: 'Read users' },
      { resource: 'user', action: 'update', description: 'Update users' },
      { resource: 'user', action: 'delete', description: 'Delete users' },
      { resource: 'maintenance_ticket', action: 'create', description: 'Create tickets' },
      { resource: 'maintenance_ticket', action: 'read', description: 'Read tickets' },
      { resource: 'maintenance_ticket', action: 'update', description: 'Update tickets' },
      { resource: 'maintenance_ticket', action: 'assign', description: 'Assign tickets' },
      { resource: 'service_request', action: 'create', description: 'Create service requests' },
      { resource: 'service_request', action: 'read', description: 'Read service requests' },
      { resource: 'service_request', action: 'update', description: 'Update service requests' },
      { resource: 'department', action: 'create', description: 'Create departments' },
      { resource: 'department', action: 'read', description: 'Read departments' },
      { resource: 'department', action: 'update', description: 'Update departments' },
      { resource: 'notification', action: 'read', description: 'Read notifications' },
      { resource: 'notification', action: 'send', description: 'Send notifications' },
    ];

    const permissions: Map<string, Permission> = new Map();
    for (const permData of permissionsData) {
      const key = `${permData.resource}:${permData.action}`;
      let permission = await queryRunner.manager.findOne(Permission, {
        where: { companyId, resource: permData.resource, action: permData.action },
      });

      if (!permission) {
        permission = queryRunner.manager.create(Permission, {
          companyId,
          resource: permData.resource,
          action: permData.action,
          description: permData.description,
        });
        permission = await queryRunner.manager.save(permission);
        console.log(`  ✅ Created permission: ${key}`);
      } else {
        console.log(`  ✅ Using existing permission: ${key}`);
      }
      permissions.set(key, permission);
    }
    console.log(`✅ Created/verified ${permissions.size} permissions\n`);

    // ==================== ROLE PERMISSIONS ====================
    console.log('🔗 Assigning Permissions to Roles...');
    const rolePermissionMappings = [
      { role: 'ADMIN', permissions: Array.from(permissions.keys()) },
      { role: 'SITE_COORDINATOR', permissions: ['maintenance_ticket:read', 'maintenance_ticket:assign', 'department:read'] },
      { role: 'SUPERVISOR', permissions: ['maintenance_ticket:read', 'maintenance_ticket:update', 'maintenance_ticket:assign'] },
      { role: 'TECHNICIAN', permissions: ['maintenance_ticket:read', 'maintenance_ticket:update'] },
      { role: 'TENANT', permissions: ['maintenance_ticket:create', 'maintenance_ticket:read'] },
    ];

    let rolePermissionCount = 0;
    for (const mapping of rolePermissionMappings) {
      const role = roles.get(mapping.role);
      if (!role) continue;

      for (const permKey of mapping.permissions) {
        const permission = permissions.get(permKey);
        if (!permission) continue;

        const existing = await queryRunner.manager.findOne(RolePermission, {
          where: { companyId, roleId: role.id, permissionId: permission.id },
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
    console.log(`✅ Created ${rolePermissionCount} role-permission mappings\n`);

    // ==================== USERS ====================
    console.log('👤 Creating Users...');
    const passwordHash = await bcrypt.hash(DEFAULT_PASSWORD, 10);

    // Staff users
    const staffUsersData = [
      { email: 'vivek.ellappan@helixsense.com', firstName: 'Vivek', lastName: 'Ellappan', role: 'ADMIN' },
      { email: 'coordinator@villa-maintenance.com', firstName: 'Site', lastName: 'Coordinator', role: 'SITE_COORDINATOR' },
      { email: 'supervisor@villa-maintenance.com', firstName: 'Maintenance', lastName: 'Supervisor', role: 'SUPERVISOR' },
      { email: 'technician1@villa-maintenance.com', firstName: 'John', lastName: 'Technician', role: 'TECHNICIAN' },
      { email: 'technician2@villa-maintenance.com', firstName: 'Jane', lastName: 'Technician', role: 'TECHNICIAN' },
      { email: 'technician3@villa-maintenance.com', firstName: 'Bob', lastName: 'Smith', role: 'TECHNICIAN' },
      { email: 'technician4@villa-maintenance.com', firstName: 'Alice', lastName: 'Johnson', role: 'TECHNICIAN' },
    ];

    const staffUsers: User[] = [];
    for (const userData of staffUsersData) {
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

        const role = roles.get(userData.role);
        if (role) {
          const userRole = queryRunner.manager.create(UserRole, {
            companyId,
            userId: user.id,
            roleId: role.id,
          });
          await queryRunner.manager.save(userRole);
        }

        console.log(`  ✅ Created user: ${user.email} (${userData.role})`);
      } else {
        console.log(`  ✅ Using existing user: ${user.email}`);
        
        // Ensure user has the correct role assigned
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
            console.log(`    ✅ Assigned ${userData.role} role to ${user.email}`);
          }
        }
        
        // For admin user, ensure they don't have TENANT role
        if (userData.role === 'ADMIN') {
          const tenantRole = roles.get('TENANT');
          if (tenantRole) {
            const tenantUserRole = await queryRunner.manager.findOne(UserRole, {
              where: {
                companyId,
                userId: user.id,
                roleId: tenantRole.id,
              },
            });
            
            if (tenantUserRole) {
              await queryRunner.manager.remove(tenantUserRole);
              console.log(`    ✅ Removed TENANT role from admin user: ${user.email}`);
            }
          }
        }
      }
      staffUsers.push(user);
    }

    // Tenant users (86 villas)
    console.log('  Creating 86 tenant users...');
    const tenantRole = roles.get('TENANT')!;
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
          firstName: `Villa`,
          lastName: `${villaNumber}`,
          villaNumber,
          status: UserStatus.ACTIVE,
          authProvider: AuthProvider.LOCAL,
        });
        tenant = await queryRunner.manager.save(tenant);

        const userRole = queryRunner.manager.create(UserRole, {
          companyId,
          userId: tenant.id,
          roleId: tenantRole.id,
        });
        await queryRunner.manager.save(userRole);

        if (villaNumber % 20 === 0) {
          console.log(`    Created ${villaNumber} tenant users...`);
        }
      } else {
        // Update villa number if it's missing or incorrect
        if (tenant.villaNumber !== villaNumber) {
          // Check if another user has this villa number
          const existingUser = await queryRunner.manager.findOne(User, {
            where: { 
              companyId, 
              villaNumber,
            },
          });
          
          if (existingUser && existingUser.id !== tenant.id) {
            // Clear the villa number from the other user
            existingUser.villaNumber = undefined;
            await queryRunner.manager.save(existingUser);
          }
          
          tenant.villaNumber = villaNumber;
          tenant = await queryRunner.manager.save(tenant);
          if (villaNumber === 1 || villaNumber === 86) {
            console.log(`    ✓ Updated villa number for ${email} to ${villaNumber}`);
          }
        }
        
        // Ensure user has TENANT role
        const existingUserRole = await queryRunner.manager.findOne(UserRole, {
          where: {
            companyId,
            userId: tenant.id,
            roleId: tenantRole.id,
          },
        });
        
        if (!existingUserRole) {
          const userRole = queryRunner.manager.create(UserRole, {
            companyId,
            userId: tenant.id,
            roleId: tenantRole.id,
          });
          await queryRunner.manager.save(userRole);
        }
      }
      tenantUsers.push(tenant);
    }
    console.log(`✅ Created/verified ${staffUsers.length} staff users and ${tenantUsers.length} tenant users\n`);

    const allUsers = [...staffUsers, ...tenantUsers];
    const adminUser = staffUsers.find(u => u.email === 'vivek.ellappan@helixsense.com')!;
    const coordinatorUser = staffUsers.find(u => u.email === 'coordinator@villa-maintenance.com')!;
    const supervisorUser = staffUsers.find(u => u.email === 'supervisor@villa-maintenance.com')!;
    const technician1User = staffUsers.find(u => u.email === 'technician1@villa-maintenance.com')!;
    const technician2User = staffUsers.find(u => u.email === 'technician2@villa-maintenance.com')!;

    // ==================== DEPARTMENTS ====================
    console.log('🏭 Creating Departments...');
    const departmentsData = [
      { name: 'Plumbing', description: 'Plumbing and water systems' },
      { name: 'Electrical', description: 'Electrical systems and repairs' },
      { name: 'HVAC', description: 'Heating, ventilation, and air conditioning' },
      { name: 'General Maintenance', description: 'General maintenance and repairs' },
      { name: 'Landscaping', description: 'Landscaping and outdoor maintenance' },
      { name: 'Security', description: 'Security systems and monitoring' },
      { name: 'Cleaning', description: 'Cleaning and janitorial services' },
    ];

    const departments: Department[] = [];
    for (const deptData of departmentsData) {
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
        console.log(`  ✅ Created department: ${department.name}`);
      } else {
        console.log(`  ✅ Using existing department: ${department.name}`);
      }
      departments.push(department);
    }
    console.log(`✅ Created/verified ${departments.length} departments\n`);

    // ==================== MAINTENANCE TICKETS ====================
    console.log('🎫 Creating Maintenance Tickets...');
    const ticketStatuses = [
      TicketStatus.NEW,
      TicketStatus.ACKNOWLEDGED,
      TicketStatus.ASSIGNED,
      TicketStatus.IN_PROGRESS,
      TicketStatus.ON_HOLD,
      TicketStatus.COMPLETED,
    ];

    const priorities = [
      TicketPriority.LOW,
      TicketPriority.MEDIUM,
      TicketPriority.HIGH,
      TicketPriority.URGENT,
    ];

    const ticketTitles = [
      'Leaking faucet in kitchen',
      'AC not working',
      'Broken light switch',
      'Water heater malfunction',
      'Door lock not working',
      'Garbage disposal stuck',
      'Window won\'t close properly',
      'Toilet keeps running',
      'Electrical outlet sparking',
      'HVAC filter needs replacement',
      'Dishwasher not draining',
      'Garage door opener broken',
      'Smoke detector beeping',
      'Water pressure too low',
      'Ceiling fan making noise',
    ];

    const tickets: MaintenanceTicket[] = [];
    const currentYear = new Date().getFullYear();
    
    // Find the highest existing ticket number to avoid duplicates
    const existingTickets = await queryRunner.manager.find(MaintenanceTicket, {
      where: { companyId },
      order: { ticketNumber: 'DESC' },
      take: 1,
    });
    
    let ticketCounter = 1;
    if (existingTickets.length > 0) {
      const lastTicketNumber = existingTickets[0].ticketNumber;
      const match = lastTicketNumber.match(new RegExp(`TKT-${currentYear}-(\\d+)`));
      if (match) {
        ticketCounter = parseInt(match[1], 10) + 1;
      }
    }

    for (let i = 0; i < 50; i++) {
      const villaNumber = Math.floor(Math.random() * 86) + 1;
      const tenant = tenantUsers.find(u => u.villaNumber === villaNumber) || tenantUsers[0];
      const status = ticketStatuses[Math.floor(Math.random() * ticketStatuses.length)];
      const priority = priorities[Math.floor(Math.random() * priorities.length)];
      const title = ticketTitles[Math.floor(Math.random() * ticketTitles.length)];
      const department = departments[Math.floor(Math.random() * departments.length)];
      
      let assignedTechnician: User | null = null;
      if (status !== TicketStatus.NEW && status !== TicketStatus.CANCELLED) {
        assignedTechnician = Math.random() > 0.5 ? technician1User : technician2User;
      }

      const ticketNumber = `TKT-${currentYear}-${ticketCounter.toString().padStart(4, '0')}`;
      ticketCounter++;

      const createdAt = new Date();
      createdAt.setDate(createdAt.getDate() - Math.floor(Math.random() * 30));

      const ticket = queryRunner.manager.create(MaintenanceTicket, {
        companyId,
        ticketNumber,
        villaNumber,
        createdBy: tenant.id,
        title,
        description: `Detailed description for ${title}. This is a sample maintenance request.`,
        status,
        priority,
        departmentId: status !== TicketStatus.NEW ? department.id : undefined,
        assignedTechnicianId: assignedTechnician?.id,
        assignedBy: assignedTechnician ? supervisorUser.id : undefined,
        assignedAt: assignedTechnician ? new Date(createdAt.getTime() + 3600000) : undefined,
        scheduledAt: status === TicketStatus.ASSIGNED || status === TicketStatus.IN_PROGRESS 
          ? new Date(createdAt.getTime() + 86400000) 
          : undefined,
        technicianNotes: status === TicketStatus.IN_PROGRESS || status === TicketStatus.COMPLETED
          ? 'Work in progress. Parts ordered and will be installed soon.'
          : undefined,
        resolutionNotes: status === TicketStatus.COMPLETED
          ? 'Issue resolved successfully. All systems tested and working properly.'
          : undefined,
        completedAt: status === TicketStatus.COMPLETED
          ? new Date(createdAt.getTime() + 172800000)
          : undefined,
        closedAt: undefined,
        tenantConfirmed: status === TicketStatus.COMPLETED && Math.random() > 0.3,
        createdAt,
        updatedAt: createdAt,
      });

      const savedTicket = await queryRunner.manager.save(ticket);
      tickets.push(savedTicket);

      // Create status history
      const statusHistory = queryRunner.manager.create(TicketStatusHistory, {
        companyId,
        ticketId: savedTicket.id,
        previousStatus: undefined,
        newStatus: TicketStatus.NEW,
        changedBy: tenant.id,
        notes: 'Ticket created',
      });
      await queryRunner.manager.save(statusHistory);

      if (status !== TicketStatus.NEW) {
        const history = queryRunner.manager.create(TicketStatusHistory, {
          companyId,
          ticketId: savedTicket.id,
          previousStatus: TicketStatus.NEW,
          newStatus: status,
          changedBy: adminUser.id,
          notes: `Status changed to ${status}`,
        });
        await queryRunner.manager.save(history);
      }

      if (i % 10 === 0) {
        console.log(`  Created ${i + 1} tickets...`);
      }
    }
    console.log(`✅ Created ${tickets.length} maintenance tickets\n`);

    // ==================== SERVICE REQUESTS ====================
    console.log('📋 Creating Service Requests...');
    const serviceRequestStatuses = ['NEW', 'ASSIGNED', 'IN_PROGRESS', 'COMPLETED'];
    const serviceRequestPriorities = ['LOW', 'MEDIUM', 'HIGH', 'URGENT'];
    const serviceRequestCategories = ['Maintenance', 'Repair', 'Installation', 'Inspection', 'Emergency'];

    const serviceRequests: ServiceRequest[] = [];
    
    // Find the highest existing service request number to avoid duplicates
    const existingServiceRequests = await queryRunner.manager.find(ServiceRequest, {
      where: { companyId },
      order: { requestNumber: 'DESC' },
      take: 1,
    });
    
    let requestCounter = 1;
    if (existingServiceRequests.length > 0) {
      const lastRequestNumber = existingServiceRequests[0].requestNumber;
      const match = lastRequestNumber.match(new RegExp(`SR-${currentYear}-(\\d+)`));
      if (match) {
        requestCounter = parseInt(match[1], 10) + 1;
      }
    }

    // Create 60 service requests (increased from 30)
    // First 20 will be recent (within last 7 days) to appear in recent tickets list
    for (let i = 0; i < 60; i++) {
      const status = serviceRequestStatuses[Math.floor(Math.random() * serviceRequestStatuses.length)];
      const priority = serviceRequestPriorities[Math.floor(Math.random() * serviceRequestPriorities.length)];
      const category = serviceRequestCategories[Math.floor(Math.random() * serviceRequestCategories.length)];
      const site = sites[Math.floor(Math.random() * sites.length)];

      const requestNumber = `SR-${currentYear}-${requestCounter.toString().padStart(4, '0')}`;
      requestCounter++;

      const createdAt = new Date();
      // First 20 tickets are recent (within last 7 days), rest are older (up to 30 days)
      if (i < 20) {
        createdAt.setDate(createdAt.getDate() - Math.floor(Math.random() * 7));
      } else {
        createdAt.setDate(createdAt.getDate() - Math.floor(Math.random() * 30) - 7);
      }

      const serviceRequest = queryRunner.manager.create(ServiceRequest, {
        companyId,
        requestNumber,
        siteId: site.id,
        title: `Service Request: ${category} - ${ticketTitles[Math.floor(Math.random() * ticketTitles.length)]}`,
        description: `Service request description for ${category} category.`,
        category,
        status,
        priority,
        assignedTechnicianId: status !== 'NEW' ? technician1User.id : undefined,
        slaDueAt: new Date(createdAt.getTime() + 172800000), // 2 days
        isEscalated: Math.random() > 0.8,
        createdAt,
        updatedAt: createdAt,
      });

      const savedRequest = await queryRunner.manager.save(serviceRequest);
      serviceRequests.push(savedRequest);

      // Create status transition
      if (status !== 'NEW') {
        const transition = queryRunner.manager.create(ServiceRequestStatusTransition, {
          serviceRequest: savedRequest,
          fromStatus: 'NEW',
          toStatus: status,
          changedByUserId: adminUser.id,
          reason: `Status changed to ${status}`,
        });
        await queryRunner.manager.save(transition);
      }

      if (i % 15 === 0) {
        console.log(`  Created ${i + 1} service requests...`);
      }
    }
    console.log(`✅ Created ${serviceRequests.length} service requests\n`);

    // ==================== SERVICE REQUEST WORKFLOWS ====================
    console.log('⚙️ Creating Service Request Workflows...');
    const workflow = queryRunner.manager.create(ServiceRequestWorkflow, {
      companyId,
      name: 'Standard Maintenance Workflow',
      category: 'Maintenance',
      statuses: [
        { code: 'new', label: 'New', color: '#9e9e9e' },
        { code: 'assigned', label: 'Assigned', color: '#2196f3' },
        { code: 'in_progress', label: 'In Progress', color: '#ff9800' },
        { code: 'completed', label: 'Completed', color: '#4caf50' },
        { code: 'closed', label: 'Closed', color: '#607d8b' },
      ] as unknown as Record<string, unknown>[],
      transitions: [
        { from: 'new', to: 'assigned' },
        { from: 'assigned', to: 'in_progress' },
        { from: 'in_progress', to: 'completed' },
        { from: 'completed', to: 'closed' },
        { from: 'new', to: 'closed' },
        { from: 'assigned', to: 'closed' },
        { from: 'in_progress', to: 'closed' },
      ] as unknown as Record<string, unknown>[],
      slaRules: [
        { matcher: 'priority=low', slaHours: 72, warnBeforeHours: 24 },
        { matcher: 'priority=medium', slaHours: 48, warnBeforeHours: 12 },
        { matcher: 'priority=high', slaHours: 24, warnBeforeHours: 6 },
        { matcher: 'priority=urgent', slaHours: 4, warnBeforeHours: 1 },
      ] as unknown as Record<string, unknown>[],
    });
    await queryRunner.manager.save(workflow);
    console.log(`✅ Created service request workflow\n`);

    // ==================== NOTIFICATION TEMPLATES ====================
    console.log('📧 Creating Notification Templates...');
    const templatesData = [
      {
        code: 'ticket_created',
        channel: NotificationChannel.EMAIL,
        subject: 'New Maintenance Ticket Created',
        body: 'A new maintenance ticket {{ticketNumber}} has been created for Villa {{villaNumber}}.',
      },
      {
        code: 'ticket_assigned',
        channel: NotificationChannel.EMAIL,
        subject: 'Ticket Assigned to You',
        body: 'Maintenance ticket {{ticketNumber}} has been assigned to you.',
      },
      {
        code: 'ticket_completed',
        channel: NotificationChannel.EMAIL,
        subject: 'Ticket Completed',
        body: 'Maintenance ticket {{ticketNumber}} has been completed.',
      },
      {
        code: 'ticket_created',
        channel: NotificationChannel.PUSH,
        subject: null,
        body: 'New ticket {{ticketNumber}} created',
      },
    ];

    for (const templateData of templatesData) {
      let template = await queryRunner.manager.findOne(NotificationTemplate, {
        where: { companyId, code: templateData.code, channel: templateData.channel },
      });

      if (!template) {
        template = queryRunner.manager.create(NotificationTemplate, {
          companyId,
          code: templateData.code,
          channel: templateData.channel,
          subject: templateData.subject,
          body: templateData.body,
          defaultVariables: { companyName: company.name },
        });
        await queryRunner.manager.save(template);
        console.log(`  ✅ Created template: ${templateData.code} (${templateData.channel})`);
      }
    }
    console.log(`✅ Created/verified notification templates\n`);

    // ==================== NOTIFICATIONS ====================
    console.log('🔔 Creating Notifications...');
    const notificationTypes = ['ticket_created', 'ticket_assigned', 'ticket_completed', 'ticket_updated'];
    const notifications: Notification[] = [];

    for (let i = 0; i < 40; i++) {
      const recipient = allUsers[Math.floor(Math.random() * allUsers.length)];
      const type = notificationTypes[Math.floor(Math.random() * notificationTypes.length)];
      const severity = Object.values(NotificationSeverity)[Math.floor(Math.random() * Object.values(NotificationSeverity).length)];

      const createdAt = new Date();
      createdAt.setHours(createdAt.getHours() - Math.floor(Math.random() * 168)); // Last week

      const notification = queryRunner.manager.create(Notification, {
        companyId,
        recipientUserId: recipient.id,
        type,
        severity,
        title: `Notification: ${type}`,
        message: `This is a sample notification for ${type}.`,
        payload: { ticketId: tickets[Math.floor(Math.random() * tickets.length)]?.id },
        isRead: Math.random() > 0.3,
        readAt: Math.random() > 0.3 ? createdAt : null,
        channels: [NotificationChannel.EMAIL, NotificationChannel.PUSH],
        createdAt,
        updatedAt: createdAt,
      });

      const savedNotification = await queryRunner.manager.save(notification);
      notifications.push(savedNotification);

      // Create delivery record
      const delivery = queryRunner.manager.create(NotificationDelivery, {
        companyId,
        notificationId: savedNotification.id,
        channel: NotificationChannel.EMAIL,
        status: savedNotification.isRead ? DeliveryStatus.SUCCESS : DeliveryStatus.PENDING,
        attemptCount: savedNotification.isRead ? 1 : 0,
        lastError: null,
      });
      await queryRunner.manager.save(delivery);

      if (i % 10 === 0) {
        console.log(`  Created ${i + 1} notifications...`);
      }
    }
    console.log(`✅ Created ${notifications.length} notifications\n`);

    // ==================== HIERARCHY NODES ====================
    console.log('🌳 Creating Hierarchy Nodes...');
    const hierarchyTypes = ['organization', 'department', 'location', 'team'];
    const hierarchyNodes: HierarchyNode[] = [];

    // Create root node
    let rootNode = await queryRunner.manager.findOne(HierarchyNode, {
      where: { companyId, type: 'organization', parentId: IsNull() },
    });

    if (!rootNode) {
      rootNode = queryRunner.manager.create(HierarchyNode, {
        companyId,
        type: 'organization',
        name: company.name,
        externalId: company.id,
        metadata: { level: 0 },
      });
      rootNode = await queryRunner.manager.save(rootNode);
      console.log(`  ✅ Created root node: ${rootNode.name}`);
    }
    hierarchyNodes.push(rootNode);

    // Create department nodes
    for (const dept of departments) {
      let deptNode = await queryRunner.manager.findOne(HierarchyNode, {
        where: { companyId, type: 'department', externalId: dept.id },
      });

      if (!deptNode) {
        deptNode = queryRunner.manager.create(HierarchyNode, {
          companyId,
          type: 'department',
          name: dept.name,
          externalId: dept.id,
          parentId: rootNode.id,
          metadata: { level: 1, departmentId: dept.id },
        });
        deptNode = await queryRunner.manager.save(deptNode);
        console.log(`  ✅ Created department node: ${deptNode.name}`);
      }
      hierarchyNodes.push(deptNode);
    }
    console.log(`✅ Created/verified ${hierarchyNodes.length} hierarchy nodes\n`);

    // ==================== ACL ENTRIES ====================
    console.log('🔒 Creating ACL Entries...');
    // Create some ACL entries for specific resource access
    const aclEntries = [
      {
        userId: technician1User.id,
        resourceType: 'maintenance_ticket',
        resourceId: tickets[0]?.id,
        permissionId: permissions.get('maintenance_ticket:update')?.id,
      },
      {
        userId: technician2User.id,
        resourceType: 'maintenance_ticket',
        resourceId: tickets[1]?.id,
        permissionId: permissions.get('maintenance_ticket:update')?.id,
      },
    ];

    for (const aclData of aclEntries) {
      if (!aclData.resourceId || !aclData.permissionId) continue;

      const existing = await queryRunner.manager.findOne(AclEntry, {
        where: {
          companyId,
          userId: aclData.userId,
          resourceType: aclData.resourceType,
          resourceId: aclData.resourceId,
        },
      });

      if (!existing) {
        const aclEntry = queryRunner.manager.create(AclEntry, {
          companyId,
          userId: aclData.userId,
          resourceType: aclData.resourceType,
          resourceId: aclData.resourceId,
          permissionId: aclData.permissionId,
        });
        await queryRunner.manager.save(aclEntry);
      }
    }
    console.log(`✅ Created ACL entries\n`);

    // ==================== SUMMARY ====================
    console.log('\n' + '='.repeat(60));
    console.log('✅ SEED COMPLETED SUCCESSFULLY!');
    console.log('='.repeat(60));
    console.log(`\n📊 Summary:`);
    console.log(`  Company: ${company.name}`);
    console.log(`  Sites: ${sites.length}`);
    console.log(`  Space Categories: ${spaceCategories.length}`);
    console.log(`  Roles: ${roles.size}`);
    console.log(`  Permissions: ${permissions.size}`);
    console.log(`  Users: ${allUsers.length} (${staffUsers.length} staff + ${tenantUsers.length} tenants)`);
    console.log(`  Departments: ${departments.length}`);
    console.log(`  Maintenance Tickets: ${tickets.length}`);
    console.log(`  Service Requests: ${serviceRequests.length}`);
    console.log(`  Notifications: ${notifications.length}`);
    console.log(`  Hierarchy Nodes: ${hierarchyNodes.length}`);
    console.log(`\n🔑 Test Credentials (all passwords: ${DEFAULT_PASSWORD}):`);
    console.log(`  Admin: vivek.ellappan@helixsense.com`);
    console.log(`  Site Coordinator: coordinator@villa-maintenance.com`);
    console.log(`  Supervisor: supervisor@villa-maintenance.com`);
    console.log(`  Technician 1: technician1@villa-maintenance.com`);
    console.log(`  Technician 2: technician2@villa-maintenance.com`);
    console.log(`  Tenants: villa1@tenant.com through villa86@tenant.com`);
    console.log('='.repeat(60) + '\n');

    await queryRunner.commitTransaction();
  } catch (error) {
    await queryRunner.rollbackTransaction();
    console.error('❌ Error seeding data:', error);
    throw error;
  } finally {
    await queryRunner.release();
    await dataSource.destroy();
  }
}

seed()
  .then(() => {
    console.log('🎉 Seed script completed successfully!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('💥 Seed script failed:', error);
    process.exit(1);
  });

