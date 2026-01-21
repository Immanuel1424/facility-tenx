-- Seed script for villa type configurations
-- Dubai Region Standards for Alosool Group (www.alosoolgroup.com)
-- Replace 'YOUR_COMPANY_ID' with your actual company UUID
-- Or use a query to get the company ID first

-- Example: Get company ID (uncomment and run first to get your company ID)
-- SELECT id, name FROM companies;

-- Insert default villa type configurations based on Dubai/UAE standards
-- Sizes are typical for Dubai residential properties
-- Adjust the company_id and values as needed

INSERT INTO villa_type_configs (
  company_id,
  villa_type,
  display_name,
  default_bedroom_count,
  default_floor_count,
  default_area_sqm,
  display_order,
  is_active
) VALUES
  -- Replace 'YOUR_COMPANY_ID' with actual company UUID
  -- Studio and 1BHK (Entry Level)
  ('YOUR_COMPANY_ID', 'Studio', 'Studio Apartment', 1, 1, 35.0, 0, true),
  ('YOUR_COMPANY_ID', '1BHK', '1 Bedroom Hall Kitchen', 1, 1, 60.0, 1, true),
  
  -- 2BHK and 3BHK (Mid-Range)
  ('YOUR_COMPANY_ID', '2BHK', '2 Bedroom Hall Kitchen', 2, 1, 95.0, 2, true),
  ('YOUR_COMPANY_ID', '3BHK', '3 Bedroom Hall Kitchen', 3, 1, 140.0, 3, true),
  
  -- 4BHK and 5BHK (Luxury)
  ('YOUR_COMPANY_ID', '4BHK', '4 Bedroom Hall Kitchen', 4, 1, 200.0, 4, true),
  ('YOUR_COMPANY_ID', '5BHK', '5 Bedroom Hall Kitchen', 5, 1, 275.0, 5, true),
  
  -- Premium Types
  ('YOUR_COMPANY_ID', 'Penthouse', 'Penthouse', NULL, 1, 300.0, 6, true),
  ('YOUR_COMPANY_ID', 'Duplex', 'Duplex Villa', NULL, 2, 200.0, 7, true),
  ('YOUR_COMPANY_ID', 'Townhouse', 'Townhouse', NULL, 2, 200.0, 8, true),
  
  -- Independent Properties
  ('YOUR_COMPANY_ID', 'Villa', 'Independent Villa', NULL, NULL, NULL, 9, true),
  ('YOUR_COMPANY_ID', 'Mansion', 'Mansion', NULL, NULL, 450.0, 10, true)
ON CONFLICT (company_id, villa_type) DO NOTHING;

-- Verify the insert
SELECT 
  villa_type,
  display_name,
  default_bedroom_count,
  default_floor_count,
  default_area_sqm,
  display_order,
  is_active
FROM villa_type_configs
WHERE company_id = 'YOUR_COMPANY_ID'
ORDER BY display_order;

