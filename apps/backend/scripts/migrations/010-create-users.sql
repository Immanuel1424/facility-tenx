-- ============================================================================
-- CREATE USERS SCRIPT
-- ============================================================================
-- This script creates admin, tenant, and technician users with all required
-- details. It can be run on the server to set up users.
--
-- USAGE:
--   psql -U postgres -d facility_erp -f scripts/migrations/010-create-users.sql
--
-- CONFIGURATION:
--   Edit the variables in the DO $$ block below to customize:
--   - Company ID (or set to NULL to use existing company)
--   - User emails, names, and roles
--   - Password (default: password123)
-- ============================================================================

BEGIN;

-- ============================================================================
-- CONFIGURATION SECTION
-- ============================================================================
-- Edit these values to customize the script
-- ============================================================================

DO $$
DECLARE
  -- Company Configuration
  -- Set to NULL to use existing company, or provide a UUID
  target_company_id UUID := NULL; -- Example: 'eb75a65b-055f-4408-a58c-71d233443c17'
  
  -- Password hash for 'password123' (bcrypt rounds=10)
  -- To generate a new hash, use: node -e "const bcrypt=require('bcrypt');bcrypt.hash('password123',10).then(h=>console.log(h))"
  default_password_hash TEXT := '$2b$10$AST14qKnFA2s4TrGzcQYD.aNfI6fwXN.SUQWBLWMJNcF7qo/0stHS';
  
  -- Variables
  company_id_var UUID;
  admin_role_id UUID;
  tenant_role_id UUID;
  technician_role_id UUID;
  site_coordinator_role_id UUID;
  supervisor_role_id UUID;
  user_id_var UUID;
  role_id_var UUID;
BEGIN
  -- ============================================================================
  -- STEP 1: GET OR CREATE COMPANY
  -- ============================================================================
  
  IF target_company_id IS NULL THEN
    -- Use the first company found, or create a default one
    SELECT id INTO company_id_var FROM companies LIMIT 1;
    
    IF company_id_var IS NULL THEN
      -- Create default company
      INSERT INTO companies (id, code, name, description, timezone, currency, created_at, updated_at)
      VALUES (
        gen_random_uuid(),
        'DEFAULT',
        'Default Company',
        'Default company created by user setup script',
        'UTC',
        'USD',
        now(),
        now()
      )
      RETURNING id INTO company_id_var;
      
      RAISE NOTICE '✅ Created default company: %', company_id_var;
    ELSE
      RAISE NOTICE '✅ Using existing company: %', company_id_var;
    END IF;
  ELSE
    company_id_var := target_company_id;
    
    -- Verify company exists
    IF NOT EXISTS (SELECT 1 FROM companies WHERE id = company_id_var) THEN
      RAISE EXCEPTION 'Company with ID % does not exist', company_id_var;
    END IF;
    
    RAISE NOTICE '✅ Using specified company: %', company_id_var;
  END IF;

  -- ============================================================================
  -- STEP 2: CREATE ROLES (if they don't exist)
  -- ============================================================================
  
  -- ADMIN Role
  SELECT id INTO admin_role_id
  FROM roles
  WHERE company_id = company_id_var AND name = 'ADMIN';
  
  IF admin_role_id IS NULL THEN
    INSERT INTO roles (id, company_id, name, description, hierarchy_level, created_at, updated_at)
    VALUES (gen_random_uuid(), company_id_var, 'ADMIN', 'Administrator - Full system access', 100, now(), now())
    RETURNING id INTO admin_role_id;
    RAISE NOTICE '✅ Created ADMIN role';
  ELSE
    RAISE NOTICE '✅ ADMIN role already exists';
  END IF;
  
  -- TENANT Role
  SELECT id INTO tenant_role_id
  FROM roles
  WHERE company_id = company_id_var AND name = 'TENANT';
  
  IF tenant_role_id IS NULL THEN
    INSERT INTO roles (id, company_id, name, description, hierarchy_level, created_at, updated_at)
    VALUES (gen_random_uuid(), company_id_var, 'TENANT', 'Tenant - Villa resident', 10, now(), now())
    RETURNING id INTO tenant_role_id;
    RAISE NOTICE '✅ Created TENANT role';
  ELSE
    RAISE NOTICE '✅ TENANT role already exists';
  END IF;
  
  -- TECHNICIAN Role
  DECLARE
    technician_role_id UUID;
  BEGIN
    SELECT id INTO technician_role_id
    FROM roles
    WHERE company_id = company_id_var AND name = 'TECHNICIAN';
    
    IF technician_role_id IS NULL THEN
      INSERT INTO roles (id, company_id, name, description, hierarchy_level, created_at, updated_at)
      VALUES (gen_random_uuid(), company_id_var, 'TECHNICIAN', 'Technician - Update assigned tickets, add work notes', 30, now(), now())
      RETURNING id INTO technician_role_id;
      RAISE NOTICE '✅ Created TECHNICIAN role';
    ELSE
      RAISE NOTICE '✅ TECHNICIAN role already exists';
    END IF;
  END;
  
  -- SITE_COORDINATOR Role
  SELECT id INTO site_coordinator_role_id
  FROM roles
  WHERE company_id = company_id_var AND name = 'SITE_COORDINATOR';
  
  IF site_coordinator_role_id IS NULL THEN
    INSERT INTO roles (id, company_id, name, description, hierarchy_level, created_at, updated_at)
    VALUES (gen_random_uuid(), company_id_var, 'SITE_COORDINATOR', 'Site Coordinator - View all, assign department, schedule', 80, now(), now())
    RETURNING id INTO site_coordinator_role_id;
    RAISE NOTICE '✅ Created SITE_COORDINATOR role';
  ELSE
    RAISE NOTICE '✅ SITE_COORDINATOR role already exists';
  END IF;
  
  -- SUPERVISOR Role
  SELECT id INTO supervisor_role_id
  FROM roles
  WHERE company_id = company_id_var AND name = 'SUPERVISOR';
  
  IF supervisor_role_id IS NULL THEN
    INSERT INTO roles (id, company_id, name, description, hierarchy_level, created_at, updated_at)
    VALUES (gen_random_uuid(), company_id_var, 'SUPERVISOR', 'Supervisor - Assign technicians, update work status', 60, now(), now())
    RETURNING id INTO supervisor_role_id;
    RAISE NOTICE '✅ Created SUPERVISOR role';
  ELSE
    RAISE NOTICE '✅ SUPERVISOR role already exists';
  END IF;

  -- ============================================================================
  -- STEP 3: CREATE ADMIN USER
  -- ============================================================================
  
  SELECT id INTO user_id_var
  FROM users
  WHERE company_id = company_id_var AND email = 'admin@tenx.com' AND deleted_at IS NULL;
  
  IF user_id_var IS NULL THEN
    INSERT INTO users (
      id, company_id, email, "passwordHash", "firstName", "lastName", 
      status, "authProvider", created_at, updated_at
    )
    VALUES (
      gen_random_uuid(),
      company_id_var,
      'admin@tenx.com',
      default_password_hash,
      'System',
      'Administrator',
      'active',
      'local',
      now(),
      now()
    )
    RETURNING id INTO user_id_var;
    
    RAISE NOTICE '✅ Created admin user: admin@tenx.com';
  ELSE
    RAISE NOTICE '✅ Admin user already exists: admin@tenx.com';
  END IF;
  
  -- Assign ADMIN role
  IF NOT EXISTS (
    SELECT 1 FROM user_roles
    WHERE company_id = company_id_var AND user_id = user_id_var AND role_id = admin_role_id
  ) THEN
    INSERT INTO user_roles (id, company_id, user_id, role_id, created_at, updated_at)
    VALUES (gen_random_uuid(), company_id_var, user_id_var, admin_role_id, now(), now());
    RAISE NOTICE '✅ Assigned ADMIN role to admin user';
  END IF;
  
  -- Remove TENANT role if admin has it (admin should not be tenant)
  DELETE FROM user_roles
  WHERE company_id = company_id_var 
    AND user_id = user_id_var 
    AND role_id = tenant_role_id;
  
  -- ============================================================================
  -- STEP 4: CREATE TENANT USER
  -- ============================================================================
  
  SELECT id INTO user_id_var
  FROM users
  WHERE company_id = company_id_var AND email = 'tenant@tenx.com' AND deleted_at IS NULL;
  
  IF user_id_var IS NULL THEN
    -- Find an available villa number (start from 100 to avoid conflicts)
    DECLARE
      available_villa_number TEXT;
      max_villa_num INTEGER;
    BEGIN
      -- Get max numeric villa number
      SELECT COALESCE(MAX(villa_number::INTEGER), 0) INTO max_villa_num
      FROM users
      WHERE company_id = company_id_var 
        AND villa_number IS NOT NULL 
        AND villa_number ~ '^[0-9]+$';
      
      -- Start from max + 1, or 100 if no villas exist
      available_villa_number := (GREATEST(max_villa_num, 99) + 1)::TEXT;
      
      -- If villa number is taken, find next available
      WHILE EXISTS (
        SELECT 1 FROM users 
        WHERE company_id = company_id_var 
          AND villa_number = available_villa_number
      ) LOOP
        available_villa_number := (available_villa_number::INTEGER + 1)::TEXT;
      END LOOP;
      
      INSERT INTO users (
        id, company_id, email, "passwordHash", "firstName", "lastName", 
        villa_number, status, "authProvider", created_at, updated_at
      )
      VALUES (
        gen_random_uuid(),
        company_id_var,
        'tenant@tenx.com',
        default_password_hash,
        'John',
        'Tenant',
        available_villa_number,
        'active',
        'local',
        now(),
        now()
      )
      RETURNING id INTO user_id_var;
      
      RAISE NOTICE '✅ Created tenant user: tenant@tenx.com (Villa #%)', available_villa_number;
    END;
  ELSE
    RAISE NOTICE '✅ Tenant user already exists: tenant@tenx.com';
  END IF;
  
  -- Assign TENANT role
  IF NOT EXISTS (
    SELECT 1 FROM user_roles
    WHERE company_id = company_id_var AND user_id = user_id_var AND role_id = tenant_role_id
  ) THEN
    INSERT INTO user_roles (id, company_id, user_id, role_id, created_at, updated_at)
    VALUES (gen_random_uuid(), company_id_var, user_id_var, tenant_role_id, now(), now());
    RAISE NOTICE '✅ Assigned TENANT role to tenant user';
  END IF;

  -- ============================================================================
  -- STEP 5: CREATE TECHNICIAN USER
  -- ============================================================================
  
  SELECT id INTO technician_role_id
  FROM roles
  WHERE company_id = company_id_var AND name = 'TECHNICIAN';
  
  IF technician_role_id IS NULL THEN
    INSERT INTO roles (id, company_id, name, description, hierarchy_level, created_at, updated_at)
    VALUES (gen_random_uuid(), company_id_var, 'TECHNICIAN', 'Technician - Update assigned tickets, add work notes', 30, now(), now())
    RETURNING id INTO technician_role_id;
    RAISE NOTICE '✅ Created TECHNICIAN role';
  ELSE
    RAISE NOTICE '✅ TECHNICIAN role already exists';
  END IF;
  
  SELECT id INTO user_id_var
  FROM users
  WHERE company_id = company_id_var AND email = 'technician@tenx.com' AND deleted_at IS NULL;
  
  IF user_id_var IS NULL THEN
    INSERT INTO users (
      id, company_id, email, "passwordHash", "firstName", "lastName", 
      status, "authProvider", created_at, updated_at
    )
    VALUES (
      gen_random_uuid(),
      company_id_var,
      'technician@tenx.com',
      default_password_hash,
      'John',
      'Technician',
      'active',
      'local',
      now(),
      now()
    )
    RETURNING id INTO user_id_var;
    
    RAISE NOTICE '✅ Created technician user: technician@tenx.com';
  ELSE
    RAISE NOTICE '✅ Technician user already exists: technician@tenx.com';
  END IF;
  
  -- Assign TECHNICIAN role
  IF NOT EXISTS (
    SELECT 1 FROM user_roles
    WHERE company_id = company_id_var AND user_id = user_id_var AND role_id = technician_role_id
  ) THEN
    INSERT INTO user_roles (id, company_id, user_id, role_id, created_at, updated_at)
    VALUES (gen_random_uuid(), company_id_var, user_id_var, technician_role_id, now(), now());
    RAISE NOTICE '✅ Assigned TECHNICIAN role to technician user';
  END IF;

  -- ============================================================================
  -- STEP 7: CREATE SITE_COORDINATOR USER
  -- ============================================================================
  
  SELECT id INTO user_id_var
  FROM users
  WHERE company_id = company_id_var AND email = 'coordinator@tenx.com' AND deleted_at IS NULL;
  
  IF user_id_var IS NULL THEN
    INSERT INTO users (
      id, company_id, email, "passwordHash", "firstName", "lastName", 
      status, "authProvider", created_at, updated_at
    )
    VALUES (
      gen_random_uuid(),
      company_id_var,
      'coordinator@tenx.com',
      default_password_hash,
      'Site',
      'Coordinator',
      'active',
      'local',
      now(),
      now()
    )
    RETURNING id INTO user_id_var;
    
    RAISE NOTICE '✅ Created coordinator user: coordinator@tenx.com';
  ELSE
    RAISE NOTICE '✅ Coordinator user already exists: coordinator@tenx.com';
  END IF;
  
  -- Assign SITE_COORDINATOR role
  IF NOT EXISTS (
    SELECT 1 FROM user_roles
    WHERE company_id = company_id_var AND user_id = user_id_var AND role_id = site_coordinator_role_id
  ) THEN
    INSERT INTO user_roles (id, company_id, user_id, role_id, created_at, updated_at)
    VALUES (gen_random_uuid(), company_id_var, user_id_var, site_coordinator_role_id, now(), now());
    RAISE NOTICE '✅ Assigned SITE_COORDINATOR role to coordinator user';
  END IF;

  -- ============================================================================
  -- STEP 8: CREATE SUPERVISOR USER
  -- ============================================================================
  
  SELECT id INTO user_id_var
  FROM users
  WHERE company_id = company_id_var AND email = 'supervisor@tenx.com' AND deleted_at IS NULL;
  
  IF user_id_var IS NULL THEN
    INSERT INTO users (
      id, company_id, email, "passwordHash", "firstName", "lastName", 
      status, "authProvider", created_at, updated_at
    )
    VALUES (
      gen_random_uuid(),
      company_id_var,
      'supervisor@tenx.com',
      default_password_hash,
      'Maintenance',
      'Supervisor',
      'active',
      'local',
      now(),
      now()
    )
    RETURNING id INTO user_id_var;
    
    RAISE NOTICE '✅ Created supervisor user: supervisor@tenx.com';
  ELSE
    RAISE NOTICE '✅ Supervisor user already exists: supervisor@tenx.com';
  END IF;
  
  -- Assign SUPERVISOR role
  IF NOT EXISTS (
    SELECT 1 FROM user_roles
    WHERE company_id = company_id_var AND user_id = user_id_var AND role_id = supervisor_role_id
  ) THEN
    INSERT INTO user_roles (id, company_id, user_id, role_id, created_at, updated_at)
    VALUES (gen_random_uuid(), company_id_var, user_id_var, supervisor_role_id, now(), now());
    RAISE NOTICE '✅ Assigned SUPERVISOR role to supervisor user';
  END IF;

  -- ============================================================================
  -- SUMMARY
  -- ============================================================================
  
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ USER CREATION COMPLETE';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'Company ID: %', company_id_var;
  RAISE NOTICE '';
  RAISE NOTICE 'Created/Verified Users:';
  RAISE NOTICE '  - Admin: admin@tenx.com / password123';
  RAISE NOTICE '  - Tenant: tenant@tenx.com / password123';
  RAISE NOTICE '  - Technician: technician@tenx.com / password123';
  RAISE NOTICE '  - Coordinator: coordinator@tenx.com / password123';
  RAISE NOTICE '  - Supervisor: supervisor@tenx.com / password123';
  RAISE NOTICE '';
  RAISE NOTICE 'All users have password: password123';
  RAISE NOTICE '========================================';

END $$;

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES (Optional - run separately if needed)
-- ============================================================================

-- View all created users with their roles
-- SELECT 
--   u.email,
--   u."firstName" || ' ' || u."lastName" AS name,
--   u.status,
--   STRING_AGG(r.name, ', ' ORDER BY r.name) AS roles
-- FROM users u
-- LEFT JOIN user_roles ur ON u.id = ur.user_id AND u.company_id = ur.company_id
-- LEFT JOIN roles r ON ur.role_id = r.id AND ur.company_id = r.company_id
-- WHERE u.email IN (
--   'admin@tenx.com',
--   'tenant@tenx.com',
--   'technician@tenx.com',
--   'coordinator@tenx.com',
--   'supervisor@tenx.com'
-- )
--   AND u.deleted_at IS NULL
-- GROUP BY u.id, u.email, u."firstName", u."lastName", u.status
-- ORDER BY u.email;

