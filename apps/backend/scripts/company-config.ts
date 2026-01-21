/**
 * Company Configuration File
 * 
 * Update this file with your company details and user information.
 * Then run: npm run create:company
 */

export interface CompanyConfig {
  name: string;
  code?: string; // Optional - will be auto-generated if not provided
  description?: string;
  timezone?: string;
  currency?: string;
}

export interface UserConfig {
  email: string;
  firstName: string;
  lastName: string;
  role: 'ADMIN' | 'SITE_COORDINATOR' | 'SUPERVISOR' | 'TECHNICIAN' | 'TENANT';
}

export interface CreateCompanyConfig {
  company: CompanyConfig;
  users: UserConfig[];
}

// ==================== UPDATE THIS SECTION ====================

export const companyConfig: CreateCompanyConfig = {
  company: {
    name: 'My Company',
    code: 'MYCOMP', // Optional - leave undefined to auto-generate
    description: 'A facility management company',
    timezone: 'UTC',
    currency: 'USD',
  },
  users: [
    {
      email: 'admin@mycompany.com',
      firstName: 'Admin',
      lastName: 'User',
      role: 'ADMIN',
    },
    {
      email: 'coordinator@mycompany.com',
      firstName: 'Site',
      lastName: 'Coordinator',
      role: 'SITE_COORDINATOR',
    },
    {
      email: 'supervisor@mycompany.com',
      firstName: 'Maintenance',
      lastName: 'Supervisor',
      role: 'SUPERVISOR',
    },
    {
      email: 'technician@mycompany.com',
      firstName: 'John',
      lastName: 'Technician',
      role: 'TECHNICIAN',
    },
    {
      email: 'tenant@mycompany.com',
      firstName: 'Tenant',
      lastName: 'User',
      role: 'TENANT',
    },
  ],
};

// ==================== END OF CONFIGURATION ====================

