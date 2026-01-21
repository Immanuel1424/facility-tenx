-- ========================================
-- CREATE ADMIN USER SCRIPT
-- ========================================
-- This script creates an admin user for a newly created company.
-- It is idempotent - safe to run multiple times.
--
-- Usage:
--   psql -U postgres -d facility_erp -f scripts/migrations/012-create-admin-user.sql
--
-- Customization:
--   Edit the variables below to customize the admin user details.
-- ========================================

DO $$
DECLARE
  -- ========================================
  -- CONFIGURATION: Edit these values
  -- ========================================
  company_code_var VARCHAR(100) := 'DEMO';  -- Company code (must match the company created)
  admin_email_var VARCHAR(255) := 'ubikaa.sree@helixsense.com';  -- Admin user email (required)
  admin_password_var VARCHAR(255) := 'password123';  -- Admin password (will be hashed)
  admin_first_name_var VARCHAR(100) := 'Ubikaa';  -- Admin first name
  admin_last_name_var VARCHAR(100) := 'Sree';  -- Admin last name
  admin_phone_var VARCHAR(20) := NULL;  -- Optional phone number
  
  -- Pre-hashed password for 'password123' (bcrypt, rounds=10)
  -- To generate a new hash, use: node -e "const bcrypt=require('bcrypt');bcrypt.hash('yourpassword',10).then(h=>console.log(h))"
  password_hash_var VARCHAR(255) := '$2b$10$VZah0ddFuMRrk0B.nlAyOOfT/z4hnbEGdL6NaD33axiytLjXrJnQy';
  
  -- Internal variables
  company_id_var UUID;
  user_id_var UUID;
  admin_role_id_var UUID;
  existing_user_id UUID;
  existing_role_id UUID;
  user_role_exists BOOLEAN;
BEGIN
  RAISE NOTICE '========================================';
  RAISE NOTICE '👤 CREATING ADMIN USER';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
  
  -- Validate required fields
  IF company_code_var IS NULL OR TRIM(company_code_var) = '' THEN
    RAISE EXCEPTION 'Company code is required and cannot be empty';
  END IF;
  
  IF admin_email_var IS NULL OR TRIM(admin_email_var) = '' THEN
    RAISE EXCEPTION 'Admin email is required and cannot be empty';
  END IF;
  
  -- Find company by code
  SELECT id INTO company_id_var
  FROM companies
  WHERE code = company_code_var;
  
  IF company_id_var IS NULL THEN
    RAISE EXCEPTION 'Company with code "%" not found. Please create the company first using 011-create-company.sql', company_code_var;
  END IF;
  
  RAISE NOTICE '✅ Found company: % (ID: %)', company_code_var, company_id_var;
  
  -- Use pre-hashed password (bcrypt hash for 'password123')
  -- Note: PostgreSQL's pgcrypto uses different format than bcrypt, so we use pre-hashed value
  -- To generate a new hash for a different password, use:
  --   node -e "const bcrypt=require('bcrypt');bcrypt.hash('yourpassword',10).then(h=>console.log(h))"
  -- Then replace the password_hash_var value above
  RAISE NOTICE '✅ Using pre-hashed password';
  
  -- Check if user already exists
  -- Note: users table uses "company_id" (quoted) as the actual column name
  SELECT id INTO existing_user_id
  FROM users
  WHERE "company_id" = company_id_var
    AND email = admin_email_var;
  
  IF existing_user_id IS NOT NULL THEN
    RAISE NOTICE '⚠️  User with email "%" already exists (ID: %)', admin_email_var, existing_user_id;
    RAISE NOTICE '✅ Using existing user';
    user_id_var := existing_user_id;
  ELSE
    -- Generate new UUID for user
    user_id_var := gen_random_uuid();
    
    -- Insert new admin user
    -- Note: Column names match actual database schema (mix of camelCase and snake_case)
    INSERT INTO users (
      id,
      "company_id",
      email,
      "passwordHash",
      "firstName",
      "lastName",
      phone_number,
      status,
      "authProvider",
      created_at,
      updated_at
    ) VALUES (
      user_id_var,
      company_id_var,
      admin_email_var,
      password_hash_var,
      admin_first_name_var,
      admin_last_name_var,
      admin_phone_var,
      'active'::users_status_enum,
      'local'::users_authprovider_enum,
      NOW(),
      NOW()
    );
    
    RAISE NOTICE '✅ Created admin user: % % (%)', admin_first_name_var, admin_last_name_var, admin_email_var;
    RAISE NOTICE '   User ID: %', user_id_var;
  END IF;
  
  -- Find or create ADMIN role
  SELECT id INTO existing_role_id
  FROM roles
  WHERE company_id = company_id_var
    AND name = 'ADMIN';
  
  IF existing_role_id IS NOT NULL THEN
    RAISE NOTICE '✅ Found existing ADMIN role (ID: %)', existing_role_id;
    admin_role_id_var := existing_role_id;
  ELSE
    -- Create ADMIN role
    admin_role_id_var := gen_random_uuid();
    
    INSERT INTO roles (
      id,
      company_id,
      name,
      description,
      hierarchy_level,
      created_at,
      updated_at
    ) VALUES (
      admin_role_id_var,
      company_id_var,
      'ADMIN',
      'Administrator with full system access',
      100,
      NOW(),
      NOW()
    );
    
    RAISE NOTICE '✅ Created ADMIN role (ID: %)', admin_role_id_var;
  END IF;
  
  -- Assign ADMIN role to user
  SELECT EXISTS(
    SELECT 1
    FROM user_roles
    WHERE company_id = company_id_var
      AND user_id = user_id_var
      AND role_id = admin_role_id_var
  ) INTO user_role_exists;
  
  IF user_role_exists THEN
    RAISE NOTICE '✅ User already has ADMIN role assigned';
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
      company_id_var,
      user_id_var,
      admin_role_id_var,
      NOW(),
      NOW()
    );
    
    RAISE NOTICE '✅ Assigned ADMIN role to user';
  END IF;
  
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ ADMIN USER CREATION COMPLETE';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'Company Code: %', company_code_var;
  RAISE NOTICE 'Company ID: %', company_id_var;
  RAISE NOTICE 'User Email: %', admin_email_var;
  RAISE NOTICE 'User ID: %', user_id_var;
  RAISE NOTICE 'User Name: % %', admin_first_name_var, admin_last_name_var;
  RAISE NOTICE 'Password: % (hashed)', admin_password_var;
  RAISE NOTICE 'Role: ADMIN (ID: %)', admin_role_id_var;
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
  RAISE NOTICE '📝 Next Steps:';
  RAISE NOTICE '   1. Assign permissions to ADMIN role (if needed)';
  RAISE NOTICE '   2. Test login with: % / %', admin_email_var, admin_password_var;
  RAISE NOTICE '========================================';
  
EXCEPTION
  WHEN unique_violation THEN
    RAISE EXCEPTION 'User with email "%" already exists for this company', admin_email_var;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'Error creating admin user: %', SQLERRM;
END $$;

