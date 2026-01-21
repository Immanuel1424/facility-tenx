import { DataSource, IsNull } from 'typeorm';
import * as bcrypt from 'bcrypt';
import { User, UserStatus, AuthProvider } from '../src/modules/iam/entities/user.entity';
import { Company } from '../src/modules/tenant/entities/company.entity';
import { Site } from '../src/modules/tenant/entities/site.entity';
import { SpaceCategory } from '../src/modules/tenant/entities/space-category.entity';
import { ServiceRequest } from '../src/modules/service-request/entities/service-request.entity';
import { ServiceRequestWorkflow } from '../src/modules/service-request/entities/service-request-workflow.entity';
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

// Define villa-maintenance user types and their configurations
const USER_TYPES = [
  {
    roleName: 'ADMIN',
    hierarchyLevel: 100,
    description: 'Administrator - Full access',
    user: {
      email: 'vivek.ellappan@helixsense.com',
      firstName: 'Vivek',
      lastName: 'Ellappan',
      password: 'password123',
    },
  },
  {
    roleName: 'SITE_COORDINATOR',
    hierarchyLevel: 80,
    description: 'Site Coordinator - View all, assign department, schedule',
    user: {
      email: 'coordinator@villa-maintenance.com',
      firstName: 'Site',
      lastName: 'Coordinator',
      password: 'password123',
    },
  },
  {
    roleName: 'SUPERVISOR',
    hierarchyLevel: 60,
    description: 'Supervisor - Assign technicians, update work status',
    user: {
      email: 'supervisor@villa-maintenance.com',
      firstName: 'Maintenance',
      lastName: 'Supervisor',
      password: 'password123',
    },
  },
  {
    roleName: 'TECHNICIAN',
    hierarchyLevel: 30,
    description: 'Technician - Update assigned tickets, add work notes',
    user: {
      email: 'technician@villa-maintenance.com',
      firstName: 'John',
      lastName: 'Technician',
      password: 'password123',
    },
  },
];

// Tenant users (86 villas) - will be created separately
const TENANT_ROLE = {
  roleName: 'TENANT',
  hierarchyLevel: 10,
  description: 'Tenant - Villa resident',
};

// Define comprehensive permissions for ERP system
const PERMISSIONS = [
  // User management
  { resource: 'user', action: 'create', roles: ['ADMIN'] },
  { resource: 'user', action: 'read', roles: ['ADMIN', 'SITE_COORDINATOR', 'SUPERVISOR'] },
  { resource: 'user', action: 'update', roles: ['ADMIN'] },
  { resource: 'user', action: 'delete', roles: ['ADMIN'] },
  
  // Company/Tenant management
  { resource: 'company', action: 'create', roles: ['ADMIN'] },
  { resource: 'company', action: 'read', roles: ['ADMIN', 'SITE_COORDINATOR', 'SUPERVISOR'] },
  { resource: 'company', action: 'update', roles: ['ADMIN'] },
  { resource: 'company', action: 'delete', roles: ['ADMIN'] },
  
  // Role management
  { resource: 'role', action: 'create', roles: ['ADMIN'] },
  { resource: 'role', action: 'read', roles: ['ADMIN', 'SITE_COORDINATOR', 'SUPERVISOR'] },
  { resource: 'role', action: 'update', roles: ['ADMIN'] },
  { resource: 'role', action: 'delete', roles: ['ADMIN'] },
  
  // Permission management
  { resource: 'permission', action: 'create', roles: ['ADMIN'] },
  { resource: 'permission', action: 'read', roles: ['ADMIN', 'SITE_COORDINATOR', 'SUPERVISOR'] },
  { resource: 'permission', action: 'update', roles: ['ADMIN'] },
  { resource: 'permission', action: 'delete', roles: ['ADMIN'] },
  
  // Service Request management
  { resource: 'service-request', action: 'create', roles: ['ADMIN', 'SITE_COORDINATOR', 'SUPERVISOR', 'TENANT'] },
  { resource: 'service-request', action: 'read', roles: ['ADMIN', 'SITE_COORDINATOR', 'SUPERVISOR', 'TECHNICIAN', 'TENANT'] },
  { resource: 'service-request', action: 'update', roles: ['ADMIN', 'SITE_COORDINATOR', 'SUPERVISOR'] },
  { resource: 'service-request', action: 'delete', roles: ['ADMIN'] },
  { resource: 'service-request', action: 'change-status', roles: ['ADMIN', 'SITE_COORDINATOR', 'SUPERVISOR'] },
  
  // Report management
  { resource: 'report', action: 'create', roles: ['ADMIN', 'SITE_COORDINATOR', 'SUPERVISOR'] },
  { resource: 'report', action: 'read', roles: ['ADMIN', 'SITE_COORDINATOR', 'SUPERVISOR', 'TENANT'] },
  { resource: 'report', action: 'update', roles: ['ADMIN', 'SITE_COORDINATOR', 'SUPERVISOR'] },
  { resource: 'report', action: 'delete', roles: ['ADMIN'] },
  
  // Notification management
  { resource: 'notification', action: 'create', roles: ['ADMIN', 'SITE_COORDINATOR', 'SUPERVISOR'] },
  { resource: 'notification', action: 'read', roles: ['ADMIN', 'SITE_COORDINATOR', 'SUPERVISOR', 'TECHNICIAN', 'TENANT'] },
  { resource: 'notification', action: 'update', roles: ['ADMIN', 'SITE_COORDINATOR', 'SUPERVISOR'] },
  { resource: 'notification', action: 'delete', roles: ['ADMIN'] },
  
  // Announcement management
  { resource: 'announcement', action: 'create', roles: ['ADMIN'] },
  { resource: 'announcement', action: 'read', roles: ['ADMIN', 'SITE_COORDINATOR', 'SUPERVISOR', 'TECHNICIAN', 'TENANT'] },
  { resource: 'announcement', action: 'update', roles: ['ADMIN'] },
  { resource: 'announcement', action: 'delete', roles: ['ADMIN'] },
  { resource: 'announcement', action: 'publish', roles: ['ADMIN'] },
  
  // Hierarchy management
  { resource: 'hierarchy', action: 'create', roles: ['ADMIN'] },
  { resource: 'hierarchy', action: 'read', roles: ['ADMIN', 'SITE_COORDINATOR', 'SUPERVISOR', 'TENANT'] },
  { resource: 'hierarchy', action: 'update', roles: ['ADMIN'] },
  { resource: 'hierarchy', action: 'delete', roles: ['ADMIN'] },
];

// Define sample sites - 5 parent sites and 5 child sites
// Codes will be auto-generated: NYC001, LA001, CHI001, SF001, BOS001, etc.
const PARENT_SITES = [
  { name: 'New York Headquarters', isParent: true },
  { name: 'Los Angeles Main Office', isParent: true },
  { name: 'Chicago Central Hub', isParent: true },
  { name: 'San Francisco Corporate', isParent: true },
  { name: 'Boston Regional Headquarters', isParent: true },
];

const CHILD_SITES = [
  { name: 'New York Downtown Branch', isParent: false, parentIndex: 0 },
  { name: 'Los Angeles Westside Office', isParent: false, parentIndex: 1 },
  { name: 'Chicago North Warehouse', isParent: false, parentIndex: 2 },
  { name: 'San Francisco Peninsula Branch', isParent: false, parentIndex: 3 },
  { name: 'Boston Cambridge Office', isParent: false, parentIndex: 4 },
];

// Define sample service request templates
const SERVICE_REQUEST_TEMPLATES = [
  { title: 'AC Unit Not Cooling', category: 'HVAC', priority: 'high', description: 'Air conditioning unit in conference room is not cooling properly. Temperature remains high despite setting.' },
  { title: 'Leaky Faucet in Restroom', category: 'Plumbing', priority: 'medium', description: 'Faucet in second floor restroom is leaking continuously. Water waste concern.' },
  { title: 'Broken Light Fixture', category: 'Electrical', priority: 'low', description: 'Light fixture in hallway is flickering and needs replacement.' },
  { title: 'Elevator Making Strange Noise', category: 'Elevator', priority: 'urgent', description: 'Elevator on north side is making loud grinding noise. Safety concern.' },
  { title: 'Carpet Cleaning Required', category: 'Cleaning', priority: 'low', description: 'Carpet in reception area needs deep cleaning due to stains.' },
  { title: 'WiFi Connection Issues', category: 'IT', priority: 'high', description: 'Intermittent WiFi connectivity issues reported by multiple users.' },
  { title: 'Window Won\'t Close', category: 'Maintenance', priority: 'medium', description: 'Window in office 205 cannot be closed properly. Security concern.' },
  { title: 'Printer Paper Jam', category: 'IT', priority: 'low', description: 'Printer in copy room has persistent paper jam issue.' },
  { title: 'Heating System Not Working', category: 'HVAC', priority: 'high', description: 'Heating system in building B is not functioning. Cold weather concern.' },
  { title: 'Door Lock Malfunction', category: 'Security', priority: 'urgent', description: 'Main entrance door lock is not responding to key card.' },
  { title: 'Water Damage in Ceiling', category: 'Plumbing', priority: 'high', description: 'Water stains and damage visible on ceiling tiles in office 312.' },
  { title: 'Parking Lot Pothole', category: 'Maintenance', priority: 'medium', description: 'Large pothole in parking lot needs repair. Vehicle damage risk.' },
  { title: 'Fire Alarm Testing', category: 'Safety', priority: 'medium', description: 'Scheduled fire alarm system testing and inspection required.' },
  { title: 'Broken Chair', category: 'Furniture', priority: 'low', description: 'Office chair in room 108 has broken wheel and needs replacement.' },
  { title: 'Power Outlet Not Working', category: 'Electrical', priority: 'medium', description: 'Power outlet in conference room A is not providing electricity.' },
  { title: 'Garbage Disposal Clogged', category: 'Plumbing', priority: 'low', description: 'Kitchen garbage disposal is clogged and not functioning.' },
  { title: 'Security Camera Offline', category: 'Security', priority: 'high', description: 'Security camera in parking area is showing offline status.' },
  { title: 'Smoke Detector Beeping', category: 'Safety', priority: 'medium', description: 'Smoke detector in hallway is beeping continuously. Battery replacement needed.' },
  { title: 'Roof Leak', category: 'Maintenance', priority: 'urgent', description: 'Water leaking through roof during rain. Immediate attention required.' },
  { title: 'Projector Bulb Replacement', category: 'IT', priority: 'low', description: 'Projector in main conference room needs bulb replacement.' },
  { title: 'Handrail Loose', category: 'Safety', priority: 'high', description: 'Handrail on staircase is loose and poses safety hazard.' },
  { title: 'Pest Control Needed', category: 'Cleaning', priority: 'medium', description: 'Reports of pest activity in storage area. Inspection and treatment needed.' },
  { title: 'Broken Window Pane', category: 'Maintenance', priority: 'medium', description: 'Window pane in office 401 has crack and needs replacement.' },
  { title: 'Server Room Temperature High', category: 'HVAC', priority: 'urgent', description: 'Server room temperature is above safe operating levels. Critical issue.' },
  { title: 'Mailbox Lock Broken', category: 'Security', priority: 'low', description: 'Mailbox lock is broken and needs repair or replacement.' },
  { title: 'Bathroom Exhaust Fan Not Working', category: 'HVAC', priority: 'low', description: 'Exhaust fan in restroom is not functioning properly.' },
  { title: 'Cable Management Needed', category: 'IT', priority: 'low', description: 'Cable management required in server room for better organization.' },
  { title: 'Floor Tile Cracked', category: 'Maintenance', priority: 'low', description: 'Cracked floor tile in lobby area needs replacement.' },
  { title: 'Emergency Exit Sign Not Lit', category: 'Safety', priority: 'high', description: 'Emergency exit sign is not illuminated. Safety code violation.' },
  { title: 'Water Fountain Not Working', category: 'Plumbing', priority: 'medium', description: 'Water fountain on third floor is not dispensing water.' },
  { title: 'Network Switch Replacement', category: 'IT', priority: 'high', description: 'Network switch in IT closet needs replacement due to frequent disconnects.' },
  { title: 'Paint Touch-up Needed', category: 'Maintenance', priority: 'low', description: 'Wall paint in hallway needs touch-up due to scuff marks.' },
  { title: 'Door Closer Not Working', category: 'Maintenance', priority: 'low', description: 'Door closer on main entrance is not functioning properly.' },
  { title: 'Air Filter Replacement', category: 'HVAC', priority: 'medium', description: 'HVAC air filters need replacement. Scheduled maintenance.' },
  { title: 'Keyboard Replacement', category: 'IT', priority: 'low', description: 'Keyboard in computer lab needs replacement due to stuck keys.' },
  { title: 'Gutter Cleaning', category: 'Maintenance', priority: 'medium', description: 'Gutters are clogged with debris and need cleaning.' },
  { title: 'Intercom System Repair', category: 'IT', priority: 'medium', description: 'Intercom system is not working properly. Communication issue.' },
  { title: 'Ceiling Fan Installation', category: 'Electrical', priority: 'low', description: 'Install ceiling fan in break room as requested.' },
  { title: 'Drain Cleaning', category: 'Plumbing', priority: 'medium', description: 'Drain in kitchen sink is draining slowly. Needs cleaning.' },
  { title: 'Backup Generator Test', category: 'Electrical', priority: 'high', description: 'Scheduled backup generator testing and maintenance.' },
  { title: 'Carpet Replacement', category: 'Maintenance', priority: 'low', description: 'Worn carpet in high-traffic area needs replacement.' },
  { title: 'Phone System Upgrade', category: 'IT', priority: 'medium', description: 'Phone system upgrade required for better functionality.' },
  { title: 'Landscaping Maintenance', category: 'Maintenance', priority: 'low', description: 'Regular landscaping maintenance needed for front entrance.' },
  { title: 'Fire Extinguisher Inspection', category: 'Safety', priority: 'medium', description: 'Annual fire extinguisher inspection and certification required.' },
  { title: 'HVAC Duct Cleaning', category: 'HVAC', priority: 'medium', description: 'HVAC duct cleaning needed to improve air quality.' },
  { title: 'Window Blinds Repair', category: 'Maintenance', priority: 'low', description: 'Window blinds in office 203 are not functioning properly.' },
  { title: 'UPS Battery Replacement', category: 'Electrical', priority: 'high', description: 'UPS battery replacement needed for server room backup power.' },
  { title: 'Water Heater Maintenance', category: 'Plumbing', priority: 'medium', description: 'Water heater maintenance and inspection required.' },
  { title: 'Access Control System Update', category: 'Security', priority: 'high', description: 'Access control system firmware update needed.' },
  { title: 'Floor Waxing', category: 'Cleaning', priority: 'low', description: 'Floor waxing required for lobby and common areas.' },
  { title: 'Light Sensor Installation', category: 'Electrical', priority: 'low', description: 'Install motion sensor lights in storage areas for energy savings.' },
];

const STATUSES = ['PENDING', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'ON_HOLD'];
const PRIORITIES = ['low', 'medium', 'high', 'urgent'];

async function seed() {
  try {
    await dataSource.initialize();
    console.log('Database connected');

    const companyRepo = dataSource.getRepository(Company);
    const siteRepo = dataSource.getRepository(Site);
    const spaceCategoryRepo = dataSource.getRepository(SpaceCategory);
    const serviceRequestRepo = dataSource.getRepository(ServiceRequest);
    const workflowRepo = dataSource.getRepository(ServiceRequestWorkflow);
    const userRepo = dataSource.getRepository(User);
    const roleRepo = dataSource.getRepository(Role);
    const permissionRepo = dataSource.getRepository(Permission);
    const rolePermissionRepo = dataSource.getRepository(RolePermission);
    const userRoleRepo = dataSource.getRepository(UserRole);

    // Use production company ID (Villa Maintenance Company)
    const testCompanyId = 'eb75a65b-055f-4408-a58c-71d233443c17';
    let company = await companyRepo.findOne({ where: { companyId: testCompanyId } });
    
    if (!company) {
      company = companyRepo.create({
        companyId: testCompanyId,
        code: 'TEST001',
        name: 'Test Company',
      });
      company = await companyRepo.save(company);
      console.log('✓ Created test company:', company.id, 'with companyId:', testCompanyId);
    } else {
      console.log('✓ Test company already exists:', company.id, 'with companyId:', testCompanyId);
    }

    // Create default workflow for service requests
    console.log('\n⚙️  Creating default workflow...');
    let defaultWorkflow = await workflowRepo.findOne({
      where: { companyId: testCompanyId, category: IsNull() },
    });

    if (!defaultWorkflow) {
      defaultWorkflow = workflowRepo.create({
        companyId: testCompanyId,
        name: 'Default Workflow',
        category: null, // Global workflow for all categories
        statuses: [
          { code: 'open', label: 'Open', color: '#4caf50' },
          { code: 'in_progress', label: 'In Progress', color: '#2196f3' },
          { code: 'on_hold', label: 'On Hold', color: '#ff9800' },
          { code: 'completed', label: 'Completed', color: '#8bc34a' },
          { code: 'cancelled', label: 'Cancelled', color: '#f44336' },
        ],
        transitions: [
          { from: 'open', to: 'in_progress' },
          { from: 'open', to: 'cancelled' },
          { from: 'in_progress', to: 'on_hold' },
          { from: 'in_progress', to: 'completed' },
          { from: 'in_progress', to: 'cancelled' },
          { from: 'on_hold', to: 'in_progress' },
          { from: 'on_hold', to: 'cancelled' },
        ],
        slaRules: [
          { matcher: 'priority=low', slaHours: 48, warnBeforeHours: 12 },
          { matcher: 'priority=medium', slaHours: 24, warnBeforeHours: 6 },
          { matcher: 'priority=high', slaHours: 8, warnBeforeHours: 2 },
          { matcher: 'priority=urgent', slaHours: 2, warnBeforeHours: 0.5 },
        ],
      });
      defaultWorkflow = await workflowRepo.save(defaultWorkflow);
      console.log('✓ Created default workflow for all categories');
    } else {
      console.log('✓ Default workflow already exists');
    }

    // Helper function to extract base code from name (max 5 chars)
    const extractBaseCode = (name: string): string => {
      const letters = name.replace(/[^A-Za-z]/g, '').toUpperCase();
      if (letters.length < 3) {
        return 'SITE';
      }
      return letters.substring(0, Math.min(5, letters.length));
    };

    // Helper function to generate unique site code (max 5 chars, letters only)
    const generateSiteCode = async (baseCode: string): Promise<string> => {
      let code = baseCode;
      let suffix = '';

      // Try base code first
      let existingSite = await siteRepo.findOne({
        where: { code },
      });

      if (!existingSite) {
        return code;
      }

      // If base code exists, try appending letters (A, B, C, ...)
      const availableLength = 5 - baseCode.length;
      
      if (availableLength >= 1) {
        // Try single letter suffix first
        for (let i = 0; i < 26; i++) {
          suffix = String.fromCharCode(65 + i); // A-Z
          code = baseCode.substring(0, Math.min(4, baseCode.length)) + suffix;
          
          if (code.length <= 5) {
            existingSite = await siteRepo.findOne({
              where: { code },
            });
            
            if (!existingSite) {
              return code;
            }
          }
        }
      }

      // If still not unique, try with shorter base and longer suffix
      if (baseCode.length >= 4) {
        const shorterBase = baseCode.substring(0, baseCode.length - 1);
        for (let i = 0; i < 26; i++) {
          suffix = String.fromCharCode(65 + i); // A-Z
          code = shorterBase + suffix;
          
          if (code.length <= 5) {
            existingSite = await siteRepo.findOne({
              where: { code },
            });
            
            if (!existingSite) {
              return code;
            }
          }
        }
      }

      // Fallback: use first 2 chars + 3 letter suffix
      if (baseCode.length >= 2) {
        const shortBase = baseCode.substring(0, 2);
        for (let i = 0; i < 26 * 26; i++) {
          const first = String.fromCharCode(65 + Math.floor(i / 26)); // A-Z
          const second = String.fromCharCode(65 + (i % 26)); // A-Z
          suffix = first + second;
          code = shortBase + suffix;
          
          if (code.length <= 5) {
            existingSite = await siteRepo.findOne({
              where: { code },
            });
            
            if (!existingSite) {
              return code;
            }
          }
        }
      }

      // Last resort: generate random 5-letter code
      const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
      let attempts = 0;
      while (attempts < 1000) {
        code = '';
        for (let i = 0; i < 5; i++) {
          code += chars.charAt(Math.floor(Math.random() * chars.length));
        }
        
        existingSite = await siteRepo.findOne({
          where: { code },
        });
        
        if (!existingSite) {
          return code;
        }
        attempts++;
      }

      throw new Error('Unable to generate unique site code');
    };

    // Create parent sites first
    console.log('\n📍 Creating parent sites...');
    const parentSites: Site[] = [];
    for (const siteData of PARENT_SITES) {
      // Check if site with same name exists
      const existingSite = await siteRepo.findOne({
        where: { name: siteData.name },
      });

      if (!existingSite) {
        const baseCode = extractBaseCode(siteData.name);
        const code = await generateSiteCode(baseCode);
        const site = siteRepo.create({
          code,
          name: siteData.name,
          isParent: true,
        });
        const savedSite = await siteRepo.save(site);
        parentSites.push(savedSite);
        console.log(`✓ Created parent site: ${siteData.name} (${code})`);
      } else {
        parentSites.push(existingSite);
        console.log(`✓ Parent site already exists: ${siteData.name} (${existingSite.code})`);
      }
    }

    // Create child sites with parent references
    console.log('\n📍 Creating child sites...');
    for (const siteData of CHILD_SITES) {
      // Check if site with same name exists
      const existingSite = await siteRepo.findOne({
        where: { name: siteData.name },
      });

      if (!existingSite) {
        const parentSite = parentSites[siteData.parentIndex];
        if (!parentSite) {
          console.log(`⚠️  Skipping ${siteData.name}: Parent site not found`);
          continue;
        }

        const baseCode = extractBaseCode(siteData.name);
        const code = await generateSiteCode(baseCode);
        const site = siteRepo.create({
          code,
          name: siteData.name,
          isParent: false,
          parentSite: parentSite,
        });
        await siteRepo.save(site);
        console.log(`✓ Created child site: ${siteData.name} (${code}) → Parent: ${parentSite.name} (${parentSite.code})`);
      } else {
        console.log(`✓ Child site already exists: ${siteData.name} (${existingSite.code})`);
      }
    }

    // Create space categories (codes will be auto-generated)
    console.log('\n🏢 Creating space categories...');
    
    // Helper function to extract base code from name (max 5 chars, letters only)
    const extractBaseCodeFromCategoryName = (name: string): string => {
      const letters = name.replace(/[^A-Za-z]/g, '').toUpperCase();
      if (letters.length < 3) {
        return 'CAT';
      }
      return letters.substring(0, Math.min(5, letters.length));
    };

    // Helper function to generate unique space category code (max 5 chars, letters only)
    const generateSpaceCategoryCode = async (baseCode: string): Promise<string> => {
      let code = baseCode;
      let suffix = '';

      // Try base code first
      let existingCategory = await spaceCategoryRepo.findOne({
        where: { code },
      });

      if (!existingCategory) {
        return code;
      }

      // If base code exists, try appending letters (A, B, C, ...)
      const availableLength = 5 - baseCode.length;
      
      if (availableLength >= 1) {
        // Try single letter suffix first
        for (let i = 0; i < 26; i++) {
          suffix = String.fromCharCode(65 + i); // A-Z
          code = baseCode.substring(0, Math.min(4, baseCode.length)) + suffix;
          
          if (code.length <= 5) {
            existingCategory = await spaceCategoryRepo.findOne({
              where: { code },
            });
            
            if (!existingCategory) {
              return code;
            }
          }
        }
      }

      // If still not unique, try with shorter base and longer suffix
      if (baseCode.length >= 4) {
        const shorterBase = baseCode.substring(0, baseCode.length - 1);
        for (let i = 0; i < 26; i++) {
          suffix = String.fromCharCode(65 + i); // A-Z
          code = shorterBase + suffix;
          
          if (code.length <= 5) {
            existingCategory = await spaceCategoryRepo.findOne({
              where: { code },
            });
            
            if (!existingCategory) {
              return code;
            }
          }
        }
      }

      // Fallback: use first 2 chars + 3 letter suffix
      if (baseCode.length >= 2) {
        const shortBase = baseCode.substring(0, 2);
        for (let i = 0; i < 26 * 26; i++) {
          const first = String.fromCharCode(65 + Math.floor(i / 26)); // A-Z
          const second = String.fromCharCode(65 + (i % 26)); // A-Z
          suffix = first + second;
          code = shortBase + suffix;
          
          if (code.length <= 5) {
            existingCategory = await spaceCategoryRepo.findOne({
              where: { code },
            });
            
            if (!existingCategory) {
              return code;
            }
          }
        }
      }

      throw new Error(`Unable to generate unique code for base: ${baseCode}`);
    };

    // Define space categories (codes will be auto-generated)
    const SPACE_CATEGORIES = [
      { name: 'Office Space', description: 'General office and workspace areas' },
      { name: 'Meeting Rooms', description: 'Conference and meeting spaces' },
      { name: 'Common Areas', description: 'Shared common spaces' },
      { name: 'Storage', description: 'Storage and warehouse areas' },
      { name: 'Facility Services', description: 'Facility maintenance and service areas' },
      { name: 'Open Office', description: 'Open plan office space' },
      { name: 'Private Office', description: 'Private office rooms' },
      { name: 'Coworking Space', description: 'Shared coworking areas' },
      { name: 'Small Meeting Room', description: 'Small meeting rooms (2-4 people)' },
      { name: 'Medium Meeting Room', description: 'Medium meeting rooms (5-10 people)' },
      { name: 'Large Conference Room', description: 'Large conference rooms (10+ people)' },
      { name: 'Boardroom', description: 'Executive boardroom' },
      { name: 'Lobby', description: 'Building lobby area' },
      { name: 'Cafeteria', description: 'Cafeteria and dining area' },
      { name: 'Recreation Area', description: 'Recreation and break areas' },
      { name: 'Restrooms', description: 'Restroom facilities' },
      { name: 'Warehouse', description: 'Warehouse storage' },
      { name: 'Archive Room', description: 'Document archive storage' },
      { name: 'Supply Room', description: 'Office supply storage' },
      { name: 'Electrical Room', description: 'Electrical and utility room' },
      { name: 'Mechanical Room', description: 'HVAC and mechanical equipment room' },
      { name: 'IT Server Room', description: 'IT server and network room' },
      { name: 'Maintenance Room', description: 'Maintenance and janitorial storage' },
    ];

    // Create space categories
    for (const catData of SPACE_CATEGORIES) {
      // Check if category with same name exists
      const existingCategory = await spaceCategoryRepo.findOne({
        where: { name: catData.name },
      });

      if (!existingCategory) {
        const baseCode = extractBaseCodeFromCategoryName(catData.name);
        const code = await generateSpaceCategoryCode(baseCode);
        
        const category = spaceCategoryRepo.create({
          code,
          name: catData.name,
          description: catData.description,
          isActive: true,
        });
        await spaceCategoryRepo.save(category);
        console.log(`✓ Created space category: ${catData.name} (${code})`);
      } else {
        console.log(`✓ Space category already exists: ${catData.name} (${existingCategory.code})`);
      }
    }

    // Create all roles
    const rolesMap = new Map<string, Role>();
    
    // Create roles for USER_TYPES
    for (const userType of USER_TYPES) {
      let role = await roleRepo.findOne({
        where: { companyId: testCompanyId, name: userType.roleName },
      });

      if (!role) {
        role = roleRepo.create({
          companyId: testCompanyId,
          name: userType.roleName,
          hierarchyLevel: userType.hierarchyLevel,
          description: userType.description,
        });
        role = await roleRepo.save(role);
        console.log(`✓ Created role: ${userType.roleName} (level ${userType.hierarchyLevel})`);
      } else {
        console.log(`✓ Role already exists: ${userType.roleName}`);
      }
      rolesMap.set(userType.roleName, role);
    }
    
    // Create TENANT role
    let tenantRole = await roleRepo.findOne({
      where: { companyId: testCompanyId, name: TENANT_ROLE.roleName },
    });

    if (!tenantRole) {
      tenantRole = roleRepo.create({
        companyId: testCompanyId,
        name: TENANT_ROLE.roleName,
        hierarchyLevel: TENANT_ROLE.hierarchyLevel,
        description: TENANT_ROLE.description,
      });
      tenantRole = await roleRepo.save(tenantRole);
      console.log(`✓ Created role: ${TENANT_ROLE.roleName} (level ${TENANT_ROLE.hierarchyLevel})`);
    } else {
      console.log(`✓ Role already exists: ${TENANT_ROLE.roleName}`);
    }
    rolesMap.set(TENANT_ROLE.roleName, tenantRole);

    // Create all permissions
    const permissionsMap = new Map<string, Permission>();
    for (const perm of PERMISSIONS) {
      const key = `${perm.resource}:${perm.action}`;
      let permission = await permissionRepo.findOne({
        where: { companyId: testCompanyId, resource: perm.resource, action: perm.action },
      });

      if (!permission) {
        permission = permissionRepo.create({
          companyId: testCompanyId,
          resource: perm.resource,
          action: perm.action,
        });
        permission = await permissionRepo.save(permission);
        console.log(`✓ Created permission: ${key}`);
      }
      permissionsMap.set(key, permission);
    }

    // Assign permissions to roles
    for (const perm of PERMISSIONS) {
      const key = `${perm.resource}:${perm.action}`;
      const permission = permissionsMap.get(key);
      if (!permission) continue;

      for (const roleName of perm.roles) {
        const role = rolesMap.get(roleName);
        if (!role) continue;

        const existingRolePermission = await rolePermissionRepo.findOne({
          where: {
            companyId: testCompanyId,
            roleId: role.id,
            permissionId: permission.id,
          },
        });

        if (!existingRolePermission) {
          const rolePermission = rolePermissionRepo.create({
            companyId: testCompanyId,
            roleId: role.id,
            permissionId: permission.id,
          });
          await rolePermissionRepo.save(rolePermission);
          console.log(`✓ Assigned permission ${key} to ${roleName} role`);
        }
      }
    }

    // Create users for each role type
    const createdUsers: Array<{ user: User; roleName: string }> = [];
    const passwordHash = await bcrypt.hash('password123', 10);
    
    for (const userType of USER_TYPES) {
      const role = rolesMap.get(userType.roleName);
      if (!role) continue;

      let user = await userRepo.findOne({
        where: { companyId: testCompanyId, email: userType.user.email },
      });

      if (!user) {
        user = userRepo.create({
          companyId: testCompanyId,
          email: userType.user.email,
          passwordHash,
          firstName: userType.user.firstName,
          lastName: userType.user.lastName,
          status: UserStatus.ACTIVE,
          authProvider: AuthProvider.LOCAL,
        });
        user = await userRepo.save(user);
        console.log(`✓ Created user: ${userType.user.email} (${userType.roleName})`);
      } else {
        console.log(`✓ User already exists: ${userType.user.email}`);
      }

      // Assign role to user
      const existingUserRole = await userRoleRepo.findOne({
        where: {
          companyId: testCompanyId,
          userId: user.id,
          roleId: role.id,
        },
      });

      if (!existingUserRole) {
        const userRole = userRoleRepo.create({
          companyId: testCompanyId,
          userId: user.id,
          roleId: role.id,
        });
        await userRoleRepo.save(userRole);
        console.log(`✓ Assigned ${userType.roleName} role to ${userType.user.email}`);
      }

      createdUsers.push({ user, roleName: userType.roleName });
    }
    
    // Create 86 tenant users (villa1@tenant.com through villa86@tenant.com)
    console.log('\n👥 Creating 86 tenant users...');
    const tenantRoleForUsers = rolesMap.get(TENANT_ROLE.roleName);
    if (tenantRoleForUsers) {
      for (let villaNumber = 1; villaNumber <= 86; villaNumber++) {
        const email = `villa${villaNumber}@tenant.com`;
        let tenant = await userRepo.findOne({
          where: { companyId: testCompanyId, email },
        });

        if (!tenant) {
          tenant = userRepo.create({
            companyId: testCompanyId,
            email,
            passwordHash,
            firstName: 'Villa',
            lastName: `${villaNumber}`,
            villaNumber,
            status: UserStatus.ACTIVE,
            authProvider: AuthProvider.LOCAL,
          });
          tenant = await userRepo.save(tenant);
          
          if (villaNumber % 10 === 0) {
            console.log(`✓ Created ${villaNumber} tenant users...`);
          }
        } else {
          // Update villa number if it's missing or incorrect
          if (tenant.villaNumber !== villaNumber) {
            // Check if another user has this villa number
            const existingUser = await userRepo.findOne({
              where: { 
                companyId: testCompanyId, 
                villaNumber,
              },
            });
            
            if (existingUser && existingUser.id !== tenant.id) {
              // Clear the villa number from the other user
              existingUser.villaNumber = undefined;
              await userRepo.save(existingUser);
            }
            
            tenant.villaNumber = villaNumber;
            tenant = await userRepo.save(tenant);
            if (villaNumber === 1 || villaNumber === 86) {
              console.log(`✓ Updated villa number for ${email} to ${villaNumber}`);
            }
          }
        }

        // Assign TENANT role to user
        const existingTenantRole = await userRoleRepo.findOne({
          where: {
            companyId: testCompanyId,
            userId: tenant.id,
            roleId: tenantRoleForUsers.id,
          },
        });

        if (!existingTenantRole) {
          const userRole = userRoleRepo.create({
            companyId: testCompanyId,
            userId: tenant.id,
            roleId: tenantRoleForUsers.id,
          });
          await userRoleRepo.save(userRole);
        }
      }
      console.log(`✓ Created/verified 86 tenant users`);
    }

    // Get all sites for assigning to service requests
    const allSites = await siteRepo.find();

    // Create sample service requests
    console.log('\n📋 Creating sample service requests...');
    const existingRequestCount = await serviceRequestRepo.count({ where: { companyId: testCompanyId } });
    const requestsToCreate = 50;
    
    if (existingRequestCount >= requestsToCreate) {
      console.log(`✓ Service requests already exist (${existingRequestCount}). Skipping creation.`);
    } else {
      const requestsCreated = existingRequestCount;
      const remainingToCreate = requestsToCreate - requestsCreated;
      
      let createdCount = 0;
      let attemptNumber = requestsCreated + 1;
      
      while (createdCount < remainingToCreate && attemptNumber < 1000000) {
        const template = SERVICE_REQUEST_TEMPLATES[createdCount % SERVICE_REQUEST_TEMPLATES.length];
        const status = STATUSES[Math.floor(Math.random() * STATUSES.length)];
        const priority = template.priority || PRIORITIES[Math.floor(Math.random() * PRIORITIES.length)];
        const randomSite = allSites.length > 0 ? allSites[Math.floor(Math.random() * allSites.length)] : null;
        
        // Generate unique request number
        const requestNumber = `SR-${testCompanyId.substring(0, 4).toUpperCase()}-${String(attemptNumber).padStart(6, '0')}`;
        
        // Check if request number already exists
        const existingRequest = await serviceRequestRepo.findOne({
          where: { requestNumber },
        });
        
        if (!existingRequest) {
          // Generate random villa code (Villa 1-86)
          const randomVillaNumber = Math.floor(Math.random() * 86) + 1;
          const villaCode = `Villa ${randomVillaNumber}`;

          const serviceRequest = serviceRequestRepo.create({
            companyId: testCompanyId,
            requestNumber,
            title: template.title,
            description: template.description,
            category: template.category,
            status,
            priority,
            siteId: randomSite ? randomSite.id : null,
            parentRequestId: null,
            assignedTeamId: null,
            assignedTechnicianId: null,
            slaDueAt: null,
            isEscalated: priority === 'urgent' || Math.random() > 0.8,
            villaCode,
          });
          
          await serviceRequestRepo.save(serviceRequest);
          createdCount++;
          
          if (createdCount % 10 === 0) {
            console.log(`✓ Created ${createdCount} service requests...`);
          }
        }
        
        attemptNumber++;
      }
      console.log(`✓ Created ${createdCount} service requests`);
    }

    // Count created sites, space categories, and service requests
    const siteCount = await siteRepo.count();
    const spaceCategoryCount = await spaceCategoryRepo.count();
    const serviceRequestCount = await serviceRequestRepo.count({ where: { companyId: testCompanyId } });

    console.log('\n✅ Seed completed successfully!');
    console.log('\n📝 Test Credentials:');
    console.log('   Company ID:', testCompanyId);
    console.log(`   Sites Created: ${siteCount}`);
    console.log(`   Space Categories Created: ${spaceCategoryCount}`);
    console.log(`   Service Requests Created: ${serviceRequestCount}`);
    console.log('\n   User Accounts:');
    console.log('   - Admin: vivek.ellappan@helixsense.com / password123');
    console.log('   - Site Coordinator: coordinator@villa-maintenance.com / password123');
    console.log('   - Supervisor: supervisor@villa-maintenance.com / password123');
    console.log('   - Technician: technician@villa-maintenance.com / password123');
    console.log('   - Tenants: villa1@tenant.com through villa86@tenant.com / password123');
    console.log('\n🔑 To login, use:');
    console.log('   POST http://localhost:3000/api/v1/auth/login');
    console.log(`   Headers: x-company-id: ${testCompanyId}`);
    console.log('   Body: { "email": "<email>", "password": "password123" }');

    await dataSource.destroy();
  } catch (error) {
    console.error('❌ Seed failed:', error);
    await dataSource.destroy();
    process.exit(1);
  }
}

seed();

