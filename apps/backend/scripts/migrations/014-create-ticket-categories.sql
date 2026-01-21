-- ========================================
-- CREATE TICKET CATEGORIES SCRIPT
-- ========================================
-- This script creates ticket categories for maintenance tickets
-- for a company in the database.
-- It is idempotent - safe to run multiple times.
--
-- Usage:
--   psql -U postgres -d facility_erp -f scripts/migrations/014-create-ticket-categories.sql
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
  category_id_var UUID;
  existing_category_id UUID;
BEGIN
  RAISE NOTICE '========================================';
  RAISE NOTICE '🚀 CREATING TICKET CATEGORIES';
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
  -- STEP 2: Create Ticket Categories
  -- ========================================
  RAISE NOTICE '';
  RAISE NOTICE '📋 Creating Ticket Categories...';
  
  -- Create Plumbing
  SELECT id INTO existing_category_id FROM ticket_categories WHERE company_id = company_id_var AND code = 'PLUMBING';
  IF existing_category_id IS NULL THEN
    INSERT INTO ticket_categories (id, company_id, code, name, description, parent_category_id, display_order, is_active, icon, color_code, default_sla_hours, created_at, updated_at)
    VALUES (gen_random_uuid(), company_id_var, 'PLUMBING', 'Plumbing', 'Plumbing related issues', NULL, 1, TRUE, 'plumbing', '#2196F3', 24, NOW(), NOW());
    RAISE NOTICE '  ✅ Created category: PLUMBING - Plumbing';
  ELSE
    RAISE NOTICE '  ⚠️  Category "PLUMBING" already exists';
  END IF;
  
  -- Create Electrical
  SELECT id INTO existing_category_id FROM ticket_categories WHERE company_id = company_id_var AND code = 'ELECTRICAL';
  IF existing_category_id IS NULL THEN
    INSERT INTO ticket_categories (id, company_id, code, name, description, parent_category_id, display_order, is_active, icon, color_code, default_sla_hours, created_at, updated_at)
    VALUES (gen_random_uuid(), company_id_var, 'ELECTRICAL', 'Electrical', 'Electrical related issues', NULL, 2, TRUE, 'electrical', '#FF9800', 24, NOW(), NOW());
    RAISE NOTICE '  ✅ Created category: ELECTRICAL - Electrical';
  ELSE
    RAISE NOTICE '  ⚠️  Category "ELECTRICAL" already exists';
  END IF;
  
  -- Create HVAC
  SELECT id INTO existing_category_id FROM ticket_categories WHERE company_id = company_id_var AND code = 'HVAC';
  IF existing_category_id IS NULL THEN
    INSERT INTO ticket_categories (id, company_id, code, name, description, parent_category_id, display_order, is_active, icon, color_code, default_sla_hours, created_at, updated_at)
    VALUES (gen_random_uuid(), company_id_var, 'HVAC', 'HVAC', 'Heating, ventilation, and air conditioning', NULL, 3, TRUE, 'hvac', '#4CAF50', 24, NOW(), NOW());
    RAISE NOTICE '  ✅ Created category: HVAC - HVAC';
  ELSE
    RAISE NOTICE '  ⚠️  Category "HVAC" already exists';
  END IF;
  
  -- Create Cleaning
  SELECT id INTO existing_category_id FROM ticket_categories WHERE company_id = company_id_var AND code = 'CLEANING';
  IF existing_category_id IS NULL THEN
    INSERT INTO ticket_categories (id, company_id, code, name, description, parent_category_id, display_order, is_active, icon, color_code, default_sla_hours, created_at, updated_at)
    VALUES (gen_random_uuid(), company_id_var, 'CLEANING', 'Cleaning', 'Cleaning and maintenance requests', NULL, 4, TRUE, 'cleaning', '#9C27B0', 48, NOW(), NOW());
    RAISE NOTICE '  ✅ Created category: CLEANING - Cleaning';
  ELSE
    RAISE NOTICE '  ⚠️  Category "CLEANING" already exists';
  END IF;
  
  -- Create Security
  SELECT id INTO existing_category_id FROM ticket_categories WHERE company_id = company_id_var AND code = 'SECURITY';
  IF existing_category_id IS NULL THEN
    INSERT INTO ticket_categories (id, company_id, code, name, description, parent_category_id, display_order, is_active, icon, color_code, default_sla_hours, created_at, updated_at)
    VALUES (gen_random_uuid(), company_id_var, 'SECURITY', 'Security', 'Security related issues', NULL, 5, TRUE, 'security', '#F44336', 12, NOW(), NOW());
    RAISE NOTICE '  ✅ Created category: SECURITY - Security';
  ELSE
    RAISE NOTICE '  ⚠️  Category "SECURITY" already exists';
  END IF;
  
  -- Create General Maintenance
  SELECT id INTO existing_category_id FROM ticket_categories WHERE company_id = company_id_var AND code = 'GENERAL';
  IF existing_category_id IS NULL THEN
    INSERT INTO ticket_categories (id, company_id, code, name, description, parent_category_id, display_order, is_active, icon, color_code, default_sla_hours, created_at, updated_at)
    VALUES (gen_random_uuid(), company_id_var, 'GENERAL', 'General Maintenance', 'General maintenance and repairs', NULL, 6, TRUE, 'maintenance', '#607D8B', 48, NOW(), NOW());
    RAISE NOTICE '  ✅ Created category: GENERAL - General Maintenance';
  ELSE
    RAISE NOTICE '  ⚠️  Category "GENERAL" already exists';
  END IF;
  
  -- Create Landscaping
  SELECT id INTO existing_category_id FROM ticket_categories WHERE company_id = company_id_var AND code = 'LANDSCAPING';
  IF existing_category_id IS NULL THEN
    INSERT INTO ticket_categories (id, company_id, code, name, description, parent_category_id, display_order, is_active, icon, color_code, default_sla_hours, created_at, updated_at)
    VALUES (gen_random_uuid(), company_id_var, 'LANDSCAPING', 'Landscaping', 'Landscaping and outdoor maintenance', NULL, 7, TRUE, 'landscaping', '#8BC34A', 72, NOW(), NOW());
    RAISE NOTICE '  ✅ Created category: LANDSCAPING - Landscaping';
  ELSE
    RAISE NOTICE '  ⚠️  Category "LANDSCAPING" already exists';
  END IF;
  
  -- Create Miscellaneous
  SELECT id INTO existing_category_id FROM ticket_categories WHERE company_id = company_id_var AND code = 'MISCELLANEOUS';
  IF existing_category_id IS NULL THEN
    INSERT INTO ticket_categories (id, company_id, code, name, description, parent_category_id, display_order, is_active, icon, color_code, default_sla_hours, created_at, updated_at)
    VALUES (gen_random_uuid(), company_id_var, 'MISCELLANEOUS', 'Miscellaneous', 'Miscellaneous related issues', NULL, 8, TRUE, 'misc', '#795548', 48, NOW(), NOW());
    RAISE NOTICE '  ✅ Created category: MISCELLANEOUS - Miscellaneous';
  ELSE
    RAISE NOTICE '  ⚠️  Category "MISCELLANEOUS" already exists';
  END IF;
  
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ TICKET CATEGORIES CREATION COMPLETE';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'Company ID: %', company_id_var;
  RAISE NOTICE 'Company Code: %', company_code_var;
  RAISE NOTICE 'Company Name: %', company_name_var;
  RAISE NOTICE '';
  RAISE NOTICE 'Created/Verified:';
  RAISE NOTICE '  - 8 Ticket Categories (Plumbing, Electrical, HVAC, Cleaning, Security, General, Landscaping, Miscellaneous)';
  RAISE NOTICE '========================================';
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE EXCEPTION 'Error creating ticket categories: %', SQLERRM;
END $$;

