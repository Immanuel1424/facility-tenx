-- ========================================
-- CREATE VILLA TYPES AND USER ROLES SCRIPT
-- ========================================
-- This script creates villa type configurations and user roles
-- for a company in the database.
-- It is idempotent - safe to run multiple times.
--
-- Usage:
--   psql -U postgres -d facility_erp -f scripts/migrations/013-create-villa-types-and-roles.sql
--
-- Customization:
--   Edit the target_company_code variable below to target a specific company.
--   Set to NULL to use the first company found.
--   Examples: 'ALOS', 'TENX', NULL
-- ========================================

DO $$
DECLARE
  -- ========================================
  -- CONFIGURATION: Edit these values
  -- ========================================
  -- Set to a specific company code (e.g., 'ALOS'), or NULL to use the first company found
  -- Examples: 'ALOS', 'TENX', NULL
  target_company_code VARCHAR(100) := NULL;
  
  -- Internal variables
  company_id_var UUID;
  company_code_var VARCHAR(100);
  company_name_var VARCHAR(255);
  role_id_var UUID;
  existing_role_id UUID;
  existing_villa_type_id UUID;
  role_record RECORD;
BEGIN
  RAISE NOTICE '========================================';
  RAISE NOTICE '🚀 CREATING VILLA TYPES AND USER ROLES';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
  
  -- ========================================
  -- STEP 1: Get or use company by code
  -- ========================================
  IF target_company_code IS NOT NULL AND TRIM(target_company_code) != '' THEN
    -- Find company by code
    SELECT id, code, name INTO company_id_var, company_code_var, company_name_var
    FROM companies
    WHERE code = target_company_code;
    
    IF company_id_var IS NULL THEN
      RAISE EXCEPTION 'Company with code "%" does not exist', target_company_code;
    END IF;
    
    RAISE NOTICE '✅ Using specified company: % (Code: %, Name: %)', company_id_var, company_code_var, company_name_var;
  ELSE
    -- Use first company found
    SELECT id, code, name INTO company_id_var, company_code_var, company_name_var
    FROM companies
    ORDER BY created_at ASC
    LIMIT 1;
    
    IF company_id_var IS NULL THEN
      RAISE EXCEPTION 'No companies found. Please create a company first.';
    END IF;
    
    RAISE NOTICE '✅ Using existing company: % (Code: %, Name: %)', company_id_var, company_code_var, company_name_var;
  END IF;
  
  -- ========================================
  -- STEP 2: Create User Roles
  -- ========================================
  RAISE NOTICE '';
  RAISE NOTICE '📋 Creating User Roles...';
  
  -- Define roles to create
  FOR role_record IN
    SELECT * FROM (VALUES
      ('ADMIN', 'Administrator - Full access', 100),
      ('SITE_COORDINATOR', 'Site Coordinator - View all, assign department, schedule', 80),
      ('SUPERVISOR', 'Supervisor - Assign technicians, update work status', 60),
      ('TECHNICIAN', 'Technician - Update assigned tickets, add work notes', 30),
      ('TENANT', 'Tenant - Villa resident', 10)
    ) AS t(name, description, hierarchy_level)
  LOOP
    -- Check if role already exists
    SELECT id INTO existing_role_id
    FROM roles
    WHERE company_id = company_id_var
      AND name = role_record.name;
    
    IF existing_role_id IS NOT NULL THEN
      RAISE NOTICE '  ⚠️  Role "%" already exists (ID: %)', role_record.name, existing_role_id;
    ELSE
      -- Create new role
      role_id_var := gen_random_uuid();
      
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
        role_id_var,
        company_id_var,
        role_record.name,
        role_record.description,
        role_record.hierarchy_level,
        NULL,
        NOW(),
        NOW()
      );
      
      RAISE NOTICE '  ✅ Created role: % (ID: %)', role_record.name, role_id_var;
    END IF;
  END LOOP;
  
  -- ========================================
  -- STEP 3: Create Villa Types
  -- ========================================
  RAISE NOTICE '';
  RAISE NOTICE '🏠 Creating Villa Types...';
  
  -- Define villa types to create (Dubai Region Standards)
  -- Create Studio
  SELECT id INTO existing_villa_type_id FROM villa_type_configs WHERE company_id = company_id_var AND villa_type = 'Studio';
  IF existing_villa_type_id IS NULL THEN
    INSERT INTO villa_type_configs (id, company_id, villa_type, display_name, default_bedroom_count, default_floor_count, default_area_sqm, display_order, is_active, created_at, updated_at)
    VALUES (gen_random_uuid(), company_id_var, 'Studio', 'Studio Apartment', 1, 1, 35.0, 0, TRUE, NOW(), NOW());
    RAISE NOTICE '  ✅ Created villa type: Studio - Studio Apartment';
  ELSE
    RAISE NOTICE '  ⚠️  Villa type "Studio" already exists';
  END IF;
  
  -- Create 1BHK
  SELECT id INTO existing_villa_type_id FROM villa_type_configs WHERE company_id = company_id_var AND villa_type = '1BHK';
  IF existing_villa_type_id IS NULL THEN
    INSERT INTO villa_type_configs (id, company_id, villa_type, display_name, default_bedroom_count, default_floor_count, default_area_sqm, display_order, is_active, created_at, updated_at)
    VALUES (gen_random_uuid(), company_id_var, '1BHK', '1 Bedroom Hall Kitchen', 1, 1, 60.0, 1, TRUE, NOW(), NOW());
    RAISE NOTICE '  ✅ Created villa type: 1BHK - 1 Bedroom Hall Kitchen';
  ELSE
    RAISE NOTICE '  ⚠️  Villa type "1BHK" already exists';
  END IF;
  
  -- Create 2BHK
  SELECT id INTO existing_villa_type_id FROM villa_type_configs WHERE company_id = company_id_var AND villa_type = '2BHK';
  IF existing_villa_type_id IS NULL THEN
    INSERT INTO villa_type_configs (id, company_id, villa_type, display_name, default_bedroom_count, default_floor_count, default_area_sqm, display_order, is_active, created_at, updated_at)
    VALUES (gen_random_uuid(), company_id_var, '2BHK', '2 Bedroom Hall Kitchen', 2, 1, 95.0, 2, TRUE, NOW(), NOW());
    RAISE NOTICE '  ✅ Created villa type: 2BHK - 2 Bedroom Hall Kitchen';
  ELSE
    RAISE NOTICE '  ⚠️  Villa type "2BHK" already exists';
  END IF;
  
  -- Create 3BHK
  SELECT id INTO existing_villa_type_id FROM villa_type_configs WHERE company_id = company_id_var AND villa_type = '3BHK';
  IF existing_villa_type_id IS NULL THEN
    INSERT INTO villa_type_configs (id, company_id, villa_type, display_name, default_bedroom_count, default_floor_count, default_area_sqm, display_order, is_active, created_at, updated_at)
    VALUES (gen_random_uuid(), company_id_var, '3BHK', '3 Bedroom Hall Kitchen', 3, 1, 140.0, 3, TRUE, NOW(), NOW());
    RAISE NOTICE '  ✅ Created villa type: 3BHK - 3 Bedroom Hall Kitchen';
  ELSE
    RAISE NOTICE '  ⚠️  Villa type "3BHK" already exists';
  END IF;
  
  -- Create 4BHK
  SELECT id INTO existing_villa_type_id FROM villa_type_configs WHERE company_id = company_id_var AND villa_type = '4BHK';
  IF existing_villa_type_id IS NULL THEN
    INSERT INTO villa_type_configs (id, company_id, villa_type, display_name, default_bedroom_count, default_floor_count, default_area_sqm, display_order, is_active, created_at, updated_at)
    VALUES (gen_random_uuid(), company_id_var, '4BHK', '4 Bedroom Hall Kitchen', 4, 1, 200.0, 4, TRUE, NOW(), NOW());
    RAISE NOTICE '  ✅ Created villa type: 4BHK - 4 Bedroom Hall Kitchen';
  ELSE
    RAISE NOTICE '  ⚠️  Villa type "4BHK" already exists';
  END IF;
  
  -- Create 5BHK
  SELECT id INTO existing_villa_type_id FROM villa_type_configs WHERE company_id = company_id_var AND villa_type = '5BHK';
  IF existing_villa_type_id IS NULL THEN
    INSERT INTO villa_type_configs (id, company_id, villa_type, display_name, default_bedroom_count, default_floor_count, default_area_sqm, display_order, is_active, created_at, updated_at)
    VALUES (gen_random_uuid(), company_id_var, '5BHK', '5 Bedroom Hall Kitchen', 5, 1, 275.0, 5, TRUE, NOW(), NOW());
    RAISE NOTICE '  ✅ Created villa type: 5BHK - 5 Bedroom Hall Kitchen';
  ELSE
    RAISE NOTICE '  ⚠️  Villa type "5BHK" already exists';
  END IF;
  
  -- Create Penthouse
  SELECT id INTO existing_villa_type_id FROM villa_type_configs WHERE company_id = company_id_var AND villa_type = 'Penthouse';
  IF existing_villa_type_id IS NULL THEN
    INSERT INTO villa_type_configs (id, company_id, villa_type, display_name, default_bedroom_count, default_floor_count, default_area_sqm, display_order, is_active, created_at, updated_at)
    VALUES (gen_random_uuid(), company_id_var, 'Penthouse', 'Penthouse', NULL, 1, 300.0, 6, TRUE, NOW(), NOW());
    RAISE NOTICE '  ✅ Created villa type: Penthouse - Penthouse';
  ELSE
    RAISE NOTICE '  ⚠️  Villa type "Penthouse" already exists';
  END IF;
  
  -- Create Duplex
  SELECT id INTO existing_villa_type_id FROM villa_type_configs WHERE company_id = company_id_var AND villa_type = 'Duplex';
  IF existing_villa_type_id IS NULL THEN
    INSERT INTO villa_type_configs (id, company_id, villa_type, display_name, default_bedroom_count, default_floor_count, default_area_sqm, display_order, is_active, created_at, updated_at)
    VALUES (gen_random_uuid(), company_id_var, 'Duplex', 'Duplex Villa', NULL, 2, 200.0, 7, TRUE, NOW(), NOW());
    RAISE NOTICE '  ✅ Created villa type: Duplex - Duplex Villa';
  ELSE
    RAISE NOTICE '  ⚠️  Villa type "Duplex" already exists';
  END IF;
  
  -- Create Townhouse
  SELECT id INTO existing_villa_type_id FROM villa_type_configs WHERE company_id = company_id_var AND villa_type = 'Townhouse';
  IF existing_villa_type_id IS NULL THEN
    INSERT INTO villa_type_configs (id, company_id, villa_type, display_name, default_bedroom_count, default_floor_count, default_area_sqm, display_order, is_active, created_at, updated_at)
    VALUES (gen_random_uuid(), company_id_var, 'Townhouse', 'Townhouse', NULL, 2, 200.0, 8, TRUE, NOW(), NOW());
    RAISE NOTICE '  ✅ Created villa type: Townhouse - Townhouse';
  ELSE
    RAISE NOTICE '  ⚠️  Villa type "Townhouse" already exists';
  END IF;
  
  -- Create Villa
  SELECT id INTO existing_villa_type_id FROM villa_type_configs WHERE company_id = company_id_var AND villa_type = 'Villa';
  IF existing_villa_type_id IS NULL THEN
    INSERT INTO villa_type_configs (id, company_id, villa_type, display_name, default_bedroom_count, default_floor_count, default_area_sqm, display_order, is_active, created_at, updated_at)
    VALUES (gen_random_uuid(), company_id_var, 'Villa', 'Independent Villa', NULL, NULL, NULL, 9, TRUE, NOW(), NOW());
    RAISE NOTICE '  ✅ Created villa type: Villa - Independent Villa';
  ELSE
    RAISE NOTICE '  ⚠️  Villa type "Villa" already exists';
  END IF;
  
  -- Create Mansion
  SELECT id INTO existing_villa_type_id FROM villa_type_configs WHERE company_id = company_id_var AND villa_type = 'Mansion';
  IF existing_villa_type_id IS NULL THEN
    INSERT INTO villa_type_configs (id, company_id, villa_type, display_name, default_bedroom_count, default_floor_count, default_area_sqm, display_order, is_active, created_at, updated_at)
    VALUES (gen_random_uuid(), company_id_var, 'Mansion', 'Mansion', NULL, NULL, 450.0, 10, TRUE, NOW(), NOW());
    RAISE NOTICE '  ✅ Created villa type: Mansion - Mansion';
  ELSE
    RAISE NOTICE '  ⚠️  Villa type "Mansion" already exists';
  END IF;
  
  RAISE NOTICE '';
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ VILLA TYPES AND ROLES CREATION COMPLETE';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'Company ID: %', company_id_var;
  RAISE NOTICE 'Company Code: %', company_code_var;
  RAISE NOTICE 'Company Name: %', company_name_var;
  RAISE NOTICE '';
  RAISE NOTICE 'Created/Verified:';
  RAISE NOTICE '  - 5 User Roles (ADMIN, SITE_COORDINATOR, SUPERVISOR, TECHNICIAN, TENANT)';
  RAISE NOTICE '  - 11 Villa Types (Studio, 1BHK-5BHK, Penthouse, Duplex, Townhouse, Villa, Mansion)';
  RAISE NOTICE '========================================';
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE EXCEPTION 'Error creating villa types and roles: %', SQLERRM;
END $$;

