# Create Company SQL Script Guide

This guide explains how to use the SQL script to create a new company in the database.

## 📋 Overview

The script `011-create-company.sql` creates a new company with all necessary details. It is **idempotent** - safe to run multiple times.

## 🚀 Quick Start

### 1. Run the Script

```bash
cd apps/backend
psql -U postgres -d facility_erp -f scripts/migrations/011-create-company.sql
```

### 2. Customize Company Details

Edit the variables at the top of the script:

```sql
company_code_var VARCHAR(100) := 'ALOS';  -- Unique company code (required)
company_name_var VARCHAR(255) := 'Villa Maintenance Company';  -- Company name (required)
company_description_var TEXT := NULL;  -- Optional description
company_logo_url_var VARCHAR(255) := NULL;  -- Optional logo URL
company_timezone_var VARCHAR(100) := 'Asia/Dubai';  -- Optional timezone
company_currency_var VARCHAR(10) := 'AED';  -- Optional currency code
company_is_active_var BOOLEAN := TRUE;  -- Active status
```

## 📝 Script Details

### Required Fields

- **`code`**: Unique company code (max 100 characters)
  - Must be unique across all companies
  - Example: `'ALOS'`, `'TENX'`, `'ACME'`
  
- **`name`**: Company name (max 255 characters)
  - Example: `'Villa Maintenance Company'`

### Optional Fields

- **`description`**: Company description (text)
- **`logo_url`**: URL to company logo (max 255 characters)
- **`timezone`**: Company timezone (max 100 characters)
  - Default: `'Asia/Dubai'`
  - Examples: `'UTC'`, `'America/New_York'`, `'Europe/London'`
- **`currency`**: Currency code (max 10 characters)
  - Default: `'AED'`
  - Examples: `'USD'`, `'EUR'`, `'GBP'`
- **`is_active`**: Whether company is active (boolean)
  - Default: `TRUE`

### Auto-Generated Fields

- **`id`**: UUID (auto-generated)
- **`created_at`**: Timestamp (auto-generated)
- **`updated_at`**: Timestamp (auto-generated)

## 🔄 Idempotency

The script is **idempotent** - it checks if a company with the same code already exists:

- ✅ **If exists**: Uses the existing company (no error)
- ✅ **If not exists**: Creates a new company

This makes it safe to run multiple times.

## 📊 Example Output

```
========================================
🚀 CREATING COMPANY
========================================

✅ Created company: Villa Maintenance Company (Code: ALOS)
   Company ID: eb75a65b-055f-4408-a58c-71d233443c17

========================================
✅ COMPANY CREATION COMPLETE
========================================
Company ID: eb75a65b-055f-4408-a58c-71d233443c17
Company Code: ALOS
Company Name: Villa Maintenance Company
Timezone: Asia/Dubai
Currency: AED
Active: true
========================================
```

## 🔍 Verify Company Creation

After running the script, verify the company was created:

```sql
-- View all companies
SELECT 
  id,
  code,
  name,
  timezone,
  currency,
  is_active,
  created_at
FROM companies
WHERE deleted_at IS NULL
ORDER BY created_at DESC;
```

## 🛠️ Common Use Cases

### Create a New Company

1. Edit the script variables with your company details
2. Run the script
3. Note the generated Company ID for use in other scripts

### Update Existing Company

If you need to update an existing company, use SQL directly:

```sql
UPDATE companies
SET 
  name = 'New Company Name',
  description = 'Updated description',
  timezone = 'UTC',
  currency = 'USD',
  updated_at = NOW()
WHERE code = 'ALOS'
  AND deleted_at IS NULL;
```

### Create Multiple Companies

To create multiple companies, you can:

1. **Option 1**: Run the script multiple times with different values
2. **Option 2**: Create a batch script with multiple `DO` blocks
3. **Option 3**: Use the TypeScript script: `create-company-with-users.ts`

## ⚠️ Important Notes

1. **Unique Code**: Company code must be unique. If you try to create a company with an existing code, the script will use the existing company.

2. **Company Deletion**: Companies are hard-deleted (no soft delete). If you need to remove a company, delete it directly or use CASCADE delete.

3. **Foreign Keys**: Once a company is created, it can be referenced by:
   - Sites
   - Users
   - Roles
   - Permissions
   - Maintenance Tickets
   - And other tenant-scoped entities

4. **Company Code Format**: 
   - Recommended: Uppercase letters (e.g., `'ALOS'`, `'TENX'`)
   - Max length: 100 characters
   - Must be unique

## 🔗 Related Scripts

- `010-create-users.sql` - Create users for a company
- `create-company-with-users.ts` - Create company with all roles and users
- `seed.ts` - Comprehensive seeding script

## 📚 Database Schema

The `companies` table structure:

```sql
CREATE TABLE companies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(100) NOT NULL UNIQUE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  logo_url VARCHAR(255),
  timezone VARCHAR(100),
  currency VARCHAR(10),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

## 🐛 Troubleshooting

### Error: "Company with code 'X' already exists"

**Solution**: The company already exists. The script will use the existing company. If you want to create a new company, use a different code.

### Error: "Company code is required and cannot be empty"

**Solution**: Make sure `company_code_var` is set to a non-empty value in the script.

### Error: "Company name is required and cannot be empty"

**Solution**: Make sure `company_name_var` is set to a non-empty value in the script.

### Error: "unique constraint violation"

**Solution**: A company with this code already exists. Check the database:

```sql
SELECT * FROM companies WHERE code = 'YOUR_CODE';
```

If you need to delete an existing company (use with caution - this will cascade delete related data):

```sql
DELETE FROM companies WHERE code = 'YOUR_CODE';
```

## 📞 Support

If you encounter issues:
1. Check the script output for error messages
2. Verify database connection and permissions
3. Ensure PostgreSQL extensions (`uuid-ossp`, `pgcrypto`) are installed
4. Check the database logs for detailed error information
