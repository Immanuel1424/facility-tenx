# Create Villa Types and User Roles SQL Script Guide

This guide explains how to use the SQL script to create villa type configurations and user roles for a company.

## 📋 Overview

The script `013-create-villa-types-and-roles.sql` creates:
- **5 User Roles**: ADMIN, SITE_COORDINATOR, SUPERVISOR, TECHNICIAN, TENANT
- **11 Villa Types**: Studio, 1BHK-5BHK, Penthouse, Duplex, Townhouse, Villa, Mansion

It is **idempotent** - safe to run multiple times.

## 🚀 Quick Start

### 1. Run the Script

```bash
cd apps/backend
psql -U postgres -d facility_erp -f scripts/migrations/013-create-villa-types-and-roles.sql
```

### 2. Customize Company ID (Optional)

Edit the script to target a specific company:

```sql
-- In the script, change this line:
target_company_id UUID := NULL;  -- Uses first company found

-- To:
target_company_id UUID := 'your-company-uuid-here';  -- Uses specific company
```

## 📝 Script Details

### User Roles Created

| Role Name | Description | Hierarchy Level |
|-----------|------------|-----------------|
| `ADMIN` | Administrator - Full access | 100 |
| `SITE_COORDINATOR` | Site Coordinator - View all, assign department, schedule | 80 |
| `SUPERVISOR` | Supervisor - Assign technicians, update work status | 60 |
| `TECHNICIAN` | Technician - Update assigned tickets, add work notes | 30 |
| `TENANT` | Tenant - Villa resident | 10 |

### Villa Types Created

| Villa Type | Display Name | Bedrooms | Floors | Area (sqm) | Order |
|------------|--------------|----------|--------|------------|-------|
| `Studio` | Studio Apartment | 1 | 1 | 35.0 | 0 |
| `1BHK` | 1 Bedroom Hall Kitchen | 1 | 1 | 60.0 | 1 |
| `2BHK` | 2 Bedroom Hall Kitchen | 2 | 1 | 95.0 | 2 |
| `3BHK` | 3 Bedroom Hall Kitchen | 3 | 1 | 140.0 | 3 |
| `4BHK` | 4 Bedroom Hall Kitchen | 4 | 1 | 200.0 | 4 |
| `5BHK` | 5 Bedroom Hall Kitchen | 5 | 1 | 275.0 | 5 |
| `Penthouse` | Penthouse | NULL | 1 | 300.0 | 6 |
| `Duplex` | Duplex Villa | NULL | 2 | 200.0 | 7 |
| `Townhouse` | Townhouse | NULL | 2 | 200.0 | 8 |
| `Villa` | Independent Villa | NULL | NULL | NULL | 9 |
| `Mansion` | Mansion | NULL | NULL | 450.0 | 10 |

**Note**: These values are based on Dubai Region Standards. You can customize them in the script if needed.

## 🔄 Idempotency

The script is **idempotent** - it checks if each role/villa type already exists:

- ✅ **If exists**: Uses the existing record (no error)
- ✅ **If not exists**: Creates a new record

This makes it safe to run multiple times.

## 📊 Example Output

```
========================================
🚀 CREATING VILLA TYPES AND USER ROLES
========================================

✅ Using existing company: eb75a65b-055f-4408-a58c-71d233443c17

📋 Creating User Roles...
  ✅ Created role: ADMIN (ID: ...)
  ✅ Created role: SITE_COORDINATOR (ID: ...)
  ...

🏠 Creating Villa Types...
  ✅ Created villa type: Studio - Studio Apartment
  ✅ Created villa type: 1BHK - 1 Bedroom Hall Kitchen
  ...

========================================
✅ VILLA TYPES AND ROLES CREATION COMPLETE
========================================
Company ID: eb75a65b-055f-4408-a58c-71d233443c17

Created/Verified:
  - 5 User Roles (ADMIN, SITE_COORDINATOR, SUPERVISOR, TECHNICIAN, TENANT)
  - 11 Villa Types (Studio, 1BHK-5BHK, Penthouse, Duplex, Townhouse, Villa, Mansion)
========================================
```

## 🔍 Verify Creation

After running the script, verify the data was created:

### Check Roles

```sql
-- View all roles for a company
SELECT 
  id,
  name,
  description,
  hierarchy_level,
  created_at
FROM roles
WHERE company_id = 'your-company-id'
ORDER BY hierarchy_level DESC;
```

### Check Villa Types

```sql
-- View all villa types for a company
SELECT 
  id,
  villa_type,
  display_name,
  default_bedroom_count,
  default_floor_count,
  default_area_sqm,
  display_order,
  is_active
FROM villa_type_configs
WHERE company_id = 'your-company-id'
ORDER BY display_order ASC;
```

## 🛠️ Common Use Cases

### Create for Specific Company

1. Find your company ID:
   ```sql
   SELECT id, code, name FROM companies;
   ```

2. Edit the script and set:
   ```sql
   target_company_id UUID := 'your-company-uuid-here';
   ```

3. Run the script

### Create for New Company

1. First create the company using `011-create-company.sql`
2. Note the company ID from the output
3. Edit `013-create-villa-types-and-roles.sql` and set `target_company_id`
4. Run the script

### Customize Villa Types

Edit the villa type creation sections in the script to change:
- Default bedroom count
- Default floor count
- Default area (sqm)
- Display order
- Display name

Example:
```sql
-- Change 1BHK default area from 60.0 to 65.0
INSERT INTO villa_type_configs (..., default_area_sqm, ...)
VALUES (..., 65.0, ...);
```

## ⚠️ Important Notes

1. **Company Required**: A company must exist before running this script. Use `011-create-company.sql` first if needed.

2. **Company-Scoped**: Both roles and villa types are company-scoped. Each company has its own set.

3. **Unique Constraints**:
   - Roles: `(company_id, name)` must be unique
   - Villa Types: `(company_id, villa_type)` must be unique

4. **Hierarchy Levels**: Roles have hierarchy levels (higher = more permissions). The script sets:
   - ADMIN: 100 (highest)
   - SITE_COORDINATOR: 80
   - SUPERVISOR: 60
   - TECHNICIAN: 30
   - TENANT: 10 (lowest)

5. **Villa Type Defaults**: These defaults are used when creating new villas. They can be overridden per villa.

## 🔗 Related Scripts

- `011-create-company.sql` - Create a new company
- `010-create-users.sql` - Create users with roles
- `seed-villa-type-configs.ts` - TypeScript version (requires COMPANY_ID env var)

## 📚 Database Schema

### Roles Table

```sql
CREATE TABLE roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  hierarchy_level INTEGER NOT NULL DEFAULT 0,
  parent_role_id UUID,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  UNIQUE(company_id, name)
);
```

### Villa Type Configs Table

```sql
CREATE TABLE villa_type_configs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL,
  villa_type VARCHAR(50) NOT NULL,
  display_name VARCHAR(255),
  default_bedroom_count INTEGER,
  default_floor_count INTEGER,
  default_area_sqm NUMERIC(10,2),
  display_order INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  metadata JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(company_id, villa_type)
);
```

## 🐛 Troubleshooting

### Error: "No companies found"

**Solution**: Create a company first using `011-create-company.sql`.

### Error: "Company with ID X does not exist"

**Solution**: Verify the company ID is correct:
```sql
SELECT id, code, name FROM companies WHERE id = 'your-company-id';
```

### Roles/Villa Types Already Exist

**Solution**: This is normal! The script is idempotent and will skip existing records. No action needed.

### Want to Update Existing Records

**Solution**: Update directly via SQL:
```sql
-- Update a villa type
UPDATE villa_type_configs
SET default_area_sqm = 65.0
WHERE company_id = 'your-company-id'
  AND villa_type = '1BHK';

-- Update a role description
UPDATE roles
SET description = 'New description'
WHERE company_id = 'your-company-id'
  AND name = 'TECHNICIAN';
```

## 📞 Support

If you encounter issues:
1. Check the script output for error messages
2. Verify database connection and permissions
3. Ensure PostgreSQL extensions (`uuid-ossp`, `pgcrypto`) are installed
4. Check the database logs for detailed error information

