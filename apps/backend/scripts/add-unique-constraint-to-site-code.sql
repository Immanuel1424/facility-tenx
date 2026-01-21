-- Migration script to add unique constraint to site code
-- Run this script to ensure site codes are unique

-- Step 1: Check for duplicate codes (if any exist, you'll need to fix them first)
-- SELECT code, COUNT(*) 
-- FROM sites 
-- GROUP BY code 
-- HAVING COUNT(*) > 1;

-- Step 2: Add unique constraint to code column
ALTER TABLE sites ADD CONSTRAINT sites_code_unique UNIQUE (code);

-- Step 3: Verify the constraint was added
-- SELECT constraint_name, constraint_type 
-- FROM information_schema.table_constraints 
-- WHERE table_name = 'sites' AND constraint_name = 'sites_code_unique';

