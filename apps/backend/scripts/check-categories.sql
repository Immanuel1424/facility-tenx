-- Quick SQL script to check if PLUMBING category exists
-- Run this in your PostgreSQL database to verify categories

-- Check all ticket categories
SELECT 
  tc.id,
  tc.code,
  tc.name,
  tc.is_active,
  tc.company_id,
  c.name as company_name
FROM ticket_categories tc
LEFT JOIN companies c ON tc.company_id = c.id
ORDER BY tc.company_id, tc.code;

-- Check specifically for PLUMBING category
SELECT 
  tc.id,
  tc.code,
  tc.name,
  tc.is_active,
  tc.company_id,
  c.name as company_name,
  CASE 
    WHEN tc.is_active = true THEN '✅ Active'
    ELSE '❌ Inactive'
  END as status
FROM ticket_categories tc
LEFT JOIN companies c ON tc.company_id = c.id
WHERE UPPER(tc.code) = 'PLUMBING' OR UPPER(tc.name) = 'PLUMBING';

-- Count categories per company
SELECT 
  c.id as company_id,
  c.name as company_name,
  COUNT(tc.id) as category_count,
  COUNT(CASE WHEN tc.is_active = true THEN 1 END) as active_count
FROM companies c
LEFT JOIN ticket_categories tc ON c.id = tc.company_id
GROUP BY c.id, c.name
ORDER BY c.name;

