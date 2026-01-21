-- ========================================
-- CREATE SYSTEM COMPANY AND SUPER ADMIN SCRIPT
-- ========================================
-- This script creates the SYSTEM company and Super Admin user
-- for system-wide administration.
-- It is idempotent - safe to run multiple times.
--
-- Usage:
--   psql -U postgres -d facility_erp -f scripts/migrations/015-create-system-company-and-super-admin.sql
--
-- Default Credentials:
--   Email: superadmin@system.local
--   Password: SuperAdmin@2025!
--   Company Code: SYSTEM
-- ========================================

DO $$
DECLARE
  -- Configuration
  system_company_code VARCHAR(100) := 'SYSTEM';
  system_company_name VARCHAR(255) := 'System Administration';
  super_admin_email VARCHAR(255) := 'superadmin@system.local';
  super_admin_password_hash VARCHAR(255) := '$2b$10$OKihApIjCWv9pkuNRIFZu.7BSb2xBATiYwtE1eurj.ERH1pOvIj1e'; -- SuperAdmin@2025!
  super_admin_first_name VARCHAR(100) := 'Super';
  super_admin_last_name VARCHAR(100) := 'Administrator';
  
  -- Internal variables
  system_company_id UUID;
  existing_company_id UUID;
  super_admin_role_id UUID;
  existing_role_id UUID;
  super_admin_user_id UUID;
  existing_user_id UUID;
  existing_user_role_id UUID;
BEGIN
  RAISE NOTICE '========================================';
  RAISE NOTICE '🚀 CREATING SYSTEM COMPANY AND SUPER ADMIN';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
  
  -- ========================================
  -- STEP 1: Create SYSTEM Company
  -- ========================================
  RAISE NOTICE '📋 Creating SYSTEM Company...';
  
  SELECT id INTO existing_company_id
  FROM companies
  WHERE code = system_company_code;
  
  IF existing_company_id IS NOT NULL THEN
    RAISE NOTICE '  ⚠️  SYSTEM company already exists (ID: %)', existing_company_id;
    system_company_id := existing_company_id;
  ELSE
    system_company_id := gen_random_uuid();
    
    INSERT INTO companies (
      id,
      code,
      name,
      description,
      logo_url,
      timezone,
      currency,
      is_active,
      created_at,
      updated_at
    ) VALUES (
      system_company_id,
      system_company_code,
      system_company_name,
      'System Administration Company - Reserved for Super Admin access',
      NULL,
      'UTC',
      'USD',
      TRUE,
      NOW(),
      NOW()
    );
    
    RAISE NOTICE '  ✅ Created SYSTEM company (ID: %)', system_company_id;
  END IF;
  
  -- ========================================
  -- STEP 2: Create SUPER_ADMIN Role
  -- ========================================
  RAISE NOTICE '';
  RAISE NOTICE '📋 Creating SUPER_ADMIN Role...';
  
  SELECT id INTO existing_role_id
  FROM roles
  WHERE company_id = system_company_id
    AND name = 'SUPER_ADMIN';
  
  IF existing_role_id IS NOT NULL THEN
    RAISE NOTICE '  ⚠️  SUPER_ADMIN role already exists (ID: %)', existing_role_id;
    super_admin_role_id := existing_role_id;
  ELSE
    super_admin_role_id := gen_random_uuid();
    
    INSERT INTO roles (
      id,
      company_id,
      name,
      description,
      hierarchy_level,
      parent_role_id,
      created_at,
      updated_at
    ) VALUES (
      super_admin_role_id,
      system_company_id,
      'SUPER_ADMIN',
      'Super Administrator - Full system access across all companies',
      1000,
      NULL,
      NOW(),
      NOW()
    );
    
    RAISE NOTICE '  ✅ Created SUPER_ADMIN role (ID: %)', super_admin_role_id;
  END IF;
  
  -- ========================================
  -- STEP 3: Create Super Admin User
  -- ========================================
  RAISE NOTICE '';
  RAISE NOTICE '📋 Creating Super Admin User...';
  
  SELECT id INTO existing_user_id
  FROM users
  WHERE company_id = system_company_id
    AND email = super_admin_email
    AND deleted_at IS NULL;
  
  IF existing_user_id IS NOT NULL THEN
    RAISE NOTICE '  ⚠️  Super Admin user already exists (ID: %)', existing_user_id;
    super_admin_user_id := existing_user_id;
    
    -- Update password hash if user exists (in case password changed)
    UPDATE users
    SET "passwordHash" = super_admin_password_hash,
        updated_at = NOW()
    WHERE id = super_admin_user_id;
    RAISE NOTICE '  ✅ Updated Super Admin password hash';
  ELSE
    super_admin_user_id := gen_random_uuid();
    
    INSERT INTO users (
      id,
      company_id,
      email,
      "passwordHash",
      "firstName",
      "lastName",
      status,
      "authProvider",
      created_at,
      updated_at
    ) VALUES (
      super_admin_user_id,
      system_company_id,
      super_admin_email,
      super_admin_password_hash,
      super_admin_first_name,
      super_admin_last_name,
      'active',
      'local',
      NOW(),
      NOW()
    );
    
    RAISE NOTICE '  ✅ Created Super Admin user (ID: %)', super_admin_user_id;
  END IF;
  
  -- ========================================
  -- STEP 4: Assign SUPER_ADMIN Role to User
  -- ========================================
  RAISE NOTICE '';
  RAISE NOTICE '📋 Assigning SUPER_ADMIN Role...';
  
  SELECT id INTO existing_user_role_id
  FROM user_roles
  WHERE company_id = system_company_id
    AND user_id = super_admin_user_id
    AND role_id = super_admin_role_id;
  
  IF existing_user_role_id IS NOT NULL THEN
    RAISE NOTICE '  ⚠️  SUPER_ADMIN role already assigned to user';
  ELSE
    INSERT INTO user_roles (
      id,
      company_id,
      user_id,
      role_id,
      created_at,
      updated_at
    ) VALUES (
      gen_random_uuid(),
      system_company_id,
      super_admin_user_id,
      super_admin_role_id,
      NOW(),
      NOW()
    );
    
    RAISE NOTICE '  ✅ Assigned SUPER_ADMIN role to Super Admin user';
  END IF;
  
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ SYSTEM COMPANY AND SUPER ADMIN CREATION COMPLETE';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'System Company ID: %', system_company_id;
  RAISE NOTICE 'System Company Code: %', system_company_code;
  RAISE NOTICE 'System Company Name: %', system_company_name;
  RAISE NOTICE '';
  RAISE NOTICE 'Super Admin User:';
  RAISE NOTICE '  Email: %', super_admin_email;
  RAISE NOTICE '  Password: SuperAdmin@2025!';
  RAISE NOTICE '  User ID: %', super_admin_user_id;
  RAISE NOTICE '  Role: SUPER_ADMIN';
  RAISE NOTICE '';
  RAISE NOTICE '⚠️  IMPORTANT: Change the default password after first login!';
  RAISE NOTICE '========================================';
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE EXCEPTION 'Error creating SYSTEM company and Super Admin: %', SQLERRM;
END $$;

