# Create Users SQL Script Guide

## Overview

The `010-create-users.sql` script creates admin, tenant, and technician users with all required details. This script can be run directly on the server to set up users without requiring Node.js or TypeScript.

## Features

- ✅ Creates/verifies company (uses existing or creates default)
- ✅ Creates all required roles (ADMIN, TENANT, TECHNICIAN_1, TECHNICIAN_2, SITE_COORDINATOR, SUPERVISOR)
- ✅ Creates users with complete details (email, name, password hash, status)
- ✅ Assigns roles to users
- ✅ Idempotent (safe to run multiple times)
- ✅ Handles existing users gracefully

## Usage

### Basic Usage

```bash
# Run the script
psql -U postgres -d facility_erp -f apps/backend/scripts/migrations/010-create-users.sql
```

### With Custom Database Connection

```bash
# Set environment variables
export PGHOST=localhost
export PGPORT=5432
export PGUSER=postgres
export PGDATABASE=facility_erp

# Run the script
psql -f apps/backend/scripts/migrations/010-create-users.sql
```

### With Password

```bash
PGPASSWORD=your_password psql -U postgres -d facility_erp -f apps/backend/scripts/migrations/010-create-users.sql
```

## Created Users

The script creates the following users (all with password: `password123`):

| Email                  | Role             | Name                   | Description        |
| ---------------------- | ---------------- | ---------------------- | ------------------ |
| `admin@tenx.com`       | ADMIN            | System Administrator   | Full system access |
| `tenant@tenx.com`      | TENANT           | John Tenant            | Villa resident     |
| `technician@tenx.com`  | TECHNICIAN       | John Technician        | Technician         |
| `coordinator@tenx.com` | SITE_COORDINATOR | Site Coordinator       | Site coordinator   |
| `supervisor@tenx.com`  | SUPERVISOR       | Maintenance Supervisor | Supervisor         |

## Customization

To customize the script, edit the `DO $$` block in `010-create-users.sql`:

### Change Company ID

```sql
target_company_id UUID := 'your-company-uuid-here';
```

Or set to `NULL` to use the first existing company or create a default one.

### Change Password Hash

To use a different password, generate a new bcrypt hash:

```bash
# Using Node.js
node -e "const bcrypt=require('bcrypt');bcrypt.hash('yourpassword',10).then(h=>console.log(h))"

# Or using Python
python3 -c "import bcrypt; print(bcrypt.hashpw(b'yourpassword', bcrypt.gensalt(rounds=10)).decode())"
```

Then update in the script:

```sql
default_password_hash TEXT := 'your-generated-hash-here';
```

### Add More Users

To add more users, follow the pattern in the script:

```sql
-- Create user
SELECT id INTO user_id_var
FROM users
WHERE company_id = company_id_var AND email = 'newuser@example.com' AND deleted_at IS NULL;

IF user_id_var IS NULL THEN
  INSERT INTO users (
    id, company_id, email, "passwordHash", "firstName", "lastName",
    status, "authProvider", created_at, updated_at
  )
  VALUES (
    gen_random_uuid(),
    company_id_var,
    'newuser@example.com',
    default_password_hash,
    'First',
    'Last',
    'ACTIVE',
    'LOCAL',
    now(),
    now()
  )
  RETURNING id INTO user_id_var;
END IF;

-- Assign role
IF NOT EXISTS (
  SELECT 1 FROM user_roles
  WHERE company_id = company_id_var AND user_id = user_id_var AND role_id = role_id_var
) THEN
  INSERT INTO user_roles (id, company_id, user_id, role_id, created_at, updated_at)
  VALUES (gen_random_uuid(), company_id_var, user_id_var, role_id_var, now(), now());
END IF;
```

## Verification

After running the script, verify the users were created:

```sql
-- View all users with their roles
SELECT
  u.email,
  u."firstName" || ' ' || u."lastName" AS name,
  u.status,
  STRING_AGG(r.name, ', ' ORDER BY r.name) AS roles
FROM users u
LEFT JOIN user_roles ur ON u.id = ur.user_id AND u.company_id = ur.company_id
LEFT JOIN roles r ON ur.role_id = r.id AND ur.company_id = r.company_id
WHERE u.email IN (
  'admin@tenx.com',
  'tenant@tenx.com',
  'technician@tenx.com',
  'coordinator@tenx.com',
  'supervisor@tenx.com'
)
  AND u.deleted_at IS NULL
GROUP BY u.id, u.email, u."firstName", u."lastName", u.status
ORDER BY u.email;
```

## Troubleshooting

### Error: Company does not exist

If you specified a `target_company_id` that doesn't exist, either:

1. Set `target_company_id := NULL` to use existing company
2. Create the company first
3. Use an existing company ID

### Error: Duplicate key violation

The script is idempotent and handles existing users. If you see duplicate key errors, it means:

- A user with the same email exists but is soft-deleted (`deleted_at IS NOT NULL`)
- Check and restore or permanently delete the user first

### Password not working

Verify the password hash is correct:

1. Check the hash in the script matches the expected password
2. Regenerate the hash if needed (see "Change Password Hash" above)
3. Ensure bcrypt is being used (not plain text)

## PostgreSQL 12 Compatibility

For PostgreSQL 12, replace `gen_random_uuid()` with `uuid_generate_v4()`:

```sql
-- Before (PostgreSQL 13+)
gen_random_uuid()

-- After (PostgreSQL 12)
uuid_generate_v4()
```

Make sure the `uuid-ossp` extension is installed:

```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

## Security Notes

⚠️ **Important Security Considerations:**

1. **Password Hash**: The default password is `password123`. **Change this in production!**
2. **Script Location**: Store this script securely and restrict access
3. **Database Access**: Use least-privilege database users
4. **Audit Trail**: The script creates users with proper timestamps for auditing
5. **Soft Delete**: Users are soft-deleted (not permanently removed) to maintain data integrity

## Related Scripts

- `create-company-with-users.ts` - TypeScript version with more features
- `seed.ts` - Comprehensive seeding script
- `003-seed-permissions.sql` - Permissions setup
