# Super Admin Setup Guide

## Overview

The Super Admin system provides system-wide administration capabilities across all companies. The Super Admin user belongs to a special "SYSTEM" company and has the `SUPER_ADMIN` role, which grants elevated privileges to manage companies, users, and system configuration.

## Architecture

### SYSTEM Company

- **Company Code**: `SYSTEM`
- **Company Name**: `System Administration`
- **Purpose**: Reserved company for Super Admin users
- **Visibility**: Not shown in public company lookup (for security)

### SUPER_ADMIN Role

- **Hierarchy Level**: 1000 (highest)
- **Permissions**: Full system access across all companies
- **Bypass**: Can bypass standard tenant scoping requirements

## Setup

### 1. Run the SQL Script

Execute the migration script to create the SYSTEM company and Super Admin user:

```bash
psql -U postgres -d facility_erp -f scripts/migrations/015-create-system-company-and-super-admin.sql
```

### 2. Default Credentials

After running the script, the Super Admin user is created with:

- **Email**: `superadmin@system.local`
- **Password**: `SuperAdmin@2025!`
- **Company Code**: `SYSTEM`
- **Role**: `SUPER_ADMIN`

⚠️ **IMPORTANT**: Change the default password immediately after first login!

### 3. Login Process

1. Navigate to the company selection page
2. Enter company code: `SYSTEM`
3. Click Continue
4. Enter Super Admin credentials:
   - Email: `superadmin@system.local`
   - Password: `SuperAdmin@2025!`
5. Click Login

## Features

### Super Admin Capabilities

1. **Company Management**

   - Create new companies
   - View all companies
   - Update company details
   - Manage company settings

2. **Cross-Company Access**

   - Access data from any company
   - Bypass tenant scoping restrictions
   - View system-wide reports and analytics

3. **User Management**

   - Create users in any company
   - Assign roles across companies
   - Reset passwords for any user
   - Manage user permissions

4. **System Configuration**
   - Configure system-wide settings
   - Manage roles and permissions
   - Configure notification rules
   - Access audit logs

### Security Features

1. **Tenant Guard Bypass**

   - Super Admin can access endpoints without `x-company-id` header
   - Company ID is automatically resolved from JWT token

2. **Public Lookup Exclusion**

   - SYSTEM company is not shown in public company lookup
   - Only users who know the code can access it

3. **Role-Based Access Control**
   - Super Admin role is checked at API level
   - Database queries respect Super Admin privileges

## Implementation Details

### Backend Changes

1. **SuperAdminService** (`src/shared/services/super-admin.service.ts`)

   - Detects Super Admin users
   - Provides helper methods for Super Admin checks

2. **TenantGuard** (`src/shared/guards/tenant.guard.ts`)

   - Allows Super Admin to bypass company requirement
   - Automatically sets company ID from JWT token

3. **AuthController** (`src/modules/auth/controllers/auth.controller.ts`)

   - Accepts company code "SYSTEM" in addition to UUID
   - Resolves company code to UUID for authentication

4. **PublicLookupController** (`src/modules/tenant/public-lookup.controller.ts`)
   - Filters out SYSTEM company from public lookup

### Frontend Changes

1. **CompanySelectionPage** (`lib/src/features/auth/presentation/pages/company_selection_page.dart`)
   - Special handling for "SYSTEM" company code
   - Bypasses public lookup validation for SYSTEM

## Security Considerations

1. **Password Security**

   - Use strong passwords for Super Admin accounts
   - Enable two-factor authentication (if available)
   - Rotate passwords regularly

2. **Access Control**

   - Limit Super Admin accounts to essential personnel only
   - Monitor Super Admin activity through audit logs
   - Implement session timeout for Super Admin sessions

3. **Network Security**

   - Restrict Super Admin access to specific IP addresses (if possible)
   - Use VPN or secure network connections
   - Monitor for suspicious login attempts

4. **Audit Logging**
   - All Super Admin actions should be logged
   - Review audit logs regularly
   - Alert on unusual Super Admin activity

## Troubleshooting

### Cannot Login with SYSTEM Code

1. Verify the SQL script ran successfully
2. Check that SYSTEM company exists:
   ```sql
   SELECT * FROM companies WHERE code = 'SYSTEM';
   ```
3. Verify Super Admin user exists:
   ```sql
   SELECT u.*, r.name as role_name
   FROM users u
   JOIN user_roles ur ON u.id = ur.user_id
   JOIN roles r ON ur.role_id = r.id
   WHERE u.email = 'superadmin@system.local' AND r.name = 'SUPER_ADMIN';
   ```

### Access Denied Errors

1. Verify user has SUPER_ADMIN role:

   ```sql
   SELECT r.name FROM roles r
   JOIN user_roles ur ON r.id = ur.role_id
   JOIN users u ON ur.user_id = u.id
   WHERE u.email = 'superadmin@system.local';
   ```

2. Check JWT token contains SUPER_ADMIN role
3. Verify TenantGuard is allowing Super Admin bypass

### Company Not Found

1. Verify SYSTEM company exists in database
2. Check company code is exactly "SYSTEM" (case-sensitive in some contexts)
3. Verify backend is resolving company code correctly

## Best Practices

1. **Account Management**

   - Create separate Super Admin accounts for each administrator
   - Use individual email addresses (not shared accounts)
   - Regularly review and remove unused Super Admin accounts

2. **Role Assignment**

   - Only assign SUPER_ADMIN role to trusted personnel
   - Document who has Super Admin access
   - Review Super Admin access quarterly

3. **Monitoring**

   - Set up alerts for Super Admin logins
   - Monitor Super Admin API usage
   - Review audit logs for Super Admin actions

4. **Backup and Recovery**
   - Keep backup of Super Admin credentials in secure location
   - Document recovery procedures
   - Test Super Admin access recovery process

## Related Files

- SQL Script: `scripts/migrations/015-create-system-company-and-super-admin.sql`
- SuperAdminService: `src/shared/services/super-admin.service.ts`
- TenantGuard: `src/shared/guards/tenant.guard.ts`
- AuthController: `src/modules/auth/controllers/auth.controller.ts`
- PublicLookupController: `src/modules/tenant/public-lookup.controller.ts`
- CompanySelectionPage: `lib/src/features/auth/presentation/pages/company_selection_page.dart`

## Support

For issues or questions about Super Admin setup, contact the development team or refer to the main project documentation.
