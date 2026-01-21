-- ========================================
-- CREATE COMPANY SCRIPT
-- ========================================
-- This script creates a new company in the database.
-- It is idempotent - safe to run multiple times.
--
-- Usage:
--   psql -U postgres -d facility_erp -f scripts/migrations/011-create-company.sql
--
-- Customization:
--   Edit the variables below to customize the company details.
-- ========================================

DO $$
DECLARE
  -- ========================================
  -- CONFIGURATION: Edit these values
  -- ========================================
  company_code_var VARCHAR(100) := 'ALOS';  -- Unique company code (required)
  company_name_var VARCHAR(255) := 'Villa Maintenance Company';  -- Company name (required)
  company_description_var TEXT := NULL;  -- Optional description
  company_logo_url_var VARCHAR(255) := NULL;  -- Optional logo URL
  company_timezone_var VARCHAR(100) := 'Asia/Dubai';  -- Optional timezone (default: Asia/Dubai)
  company_currency_var VARCHAR(10) := 'AED';  -- Optional currency code (default: AED)
  company_is_active_var BOOLEAN := TRUE;  -- Active status (default: true)
  
  -- Internal variables
  company_id_var UUID;
  existing_company_id UUID;
BEGIN
  RAISE NOTICE '========================================';
  RAISE NOTICE '🚀 CREATING COMPANY';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
  
  -- Validate required fields
  IF company_code_var IS NULL OR TRIM(company_code_var) = '' THEN
    RAISE EXCEPTION 'Company code is required and cannot be empty';
  END IF;
  
  IF company_name_var IS NULL OR TRIM(company_name_var) = '' THEN
    RAISE EXCEPTION 'Company name is required and cannot be empty';
  END IF;
  
  -- Check if company with this code already exists
  SELECT id INTO existing_company_id
  FROM companies
  WHERE code = company_code_var;
  
  IF existing_company_id IS NOT NULL THEN
    RAISE NOTICE '⚠️  Company with code "%" already exists (ID: %)', company_code_var, existing_company_id;
    RAISE NOTICE '✅ Using existing company';
    company_id_var := existing_company_id;
  ELSE
    -- Generate new UUID for company
    company_id_var := gen_random_uuid();
    
    -- Insert new company
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
      company_id_var,
      company_code_var,
      company_name_var,
      company_description_var,
      company_logo_url_var,
      company_timezone_var,
      company_currency_var,
      company_is_active_var,
      NOW(),
      NOW()
    );
    
    RAISE NOTICE '✅ Created company: % (Code: %)', company_name_var, company_code_var;
    RAISE NOTICE '   Company ID: %', company_id_var;
  END IF;
  
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ COMPANY CREATION COMPLETE';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'Company ID: %', company_id_var;
  RAISE NOTICE 'Company Code: %', company_code_var;
  RAISE NOTICE 'Company Name: %', company_name_var;
  RAISE NOTICE 'Timezone: %', COALESCE(company_timezone_var, 'Not set');
  RAISE NOTICE 'Currency: %', COALESCE(company_currency_var, 'Not set');
  RAISE NOTICE 'Active: %', company_is_active_var;
  RAISE NOTICE '========================================';
  
EXCEPTION
  WHEN unique_violation THEN
    RAISE EXCEPTION 'Company with code "%" already exists', company_code_var;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'Error creating company: %', SQLERRM;
END $$;

