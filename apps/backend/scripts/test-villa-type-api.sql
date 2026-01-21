-- SQL Test Script for Villa Type Auto-Fill
-- This tests the database-level functionality

-- Test 1: Verify villa type configurations exist
SELECT 
  'Test 1: Villa Type Configurations' as test_name,
  COUNT(*) as config_count
FROM villa_type_configs
WHERE company_id = 'eb75a65b-055f-4408-a58c-71d233443c17'
  AND is_active = true;

-- Test 2: Check specific configuration (1BHK)
SELECT 
  'Test 2: 1BHK Configuration' as test_name,
  villa_type,
  default_bedroom_count,
  default_floor_count,
  default_area_sqm
FROM villa_type_configs
WHERE company_id = 'eb75a65b-055f-4408-a58c-71d233443c17'
  AND villa_type = '1BHK';

-- Test 3: Simulate villa creation with auto-fill
-- (This would normally be done by the backend service)
SELECT 
  'Test 3: Expected Auto-Fill Values for 1BHK' as test_name,
  villa_type,
  default_bedroom_count as expected_bedroom_count,
  default_floor_count as expected_floor_count,
  default_area_sqm as expected_area_sqm
FROM villa_type_configs
WHERE company_id = 'eb75a65b-055f-4408-a58c-71d233443c17'
  AND villa_type = '1BHK';

-- Test 4: Check Duplex (should have floor_count=2, no bedroom_count)
SELECT 
  'Test 4: Duplex Configuration' as test_name,
  villa_type,
  default_bedroom_count,
  default_floor_count,
  default_area_sqm
FROM villa_type_configs
WHERE company_id = 'eb75a65b-055f-4408-a58c-71d233443c17'
  AND villa_type = 'Duplex';

-- Test 5: Check Penthouse (should have no defaults)
SELECT 
  'Test 5: Penthouse Configuration (No Defaults)' as test_name,
  villa_type,
  default_bedroom_count,
  default_floor_count,
  default_area_sqm
FROM villa_type_configs
WHERE company_id = 'eb75a65b-055f-4408-a58c-71d233443c17'
  AND villa_type = 'Penthouse';

