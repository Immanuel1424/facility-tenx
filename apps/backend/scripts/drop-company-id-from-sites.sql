-- Migration script to remove company_id column from sites table
-- Run this script to clean up the sites table after removing company relationship

-- Step 1: Drop foreign key constraint if it exists (adjust constraint name if different)
ALTER TABLE sites DROP CONSTRAINT IF EXISTS sites_company_id_fkey;

-- Step 2: Drop the company_id column
ALTER TABLE sites DROP COLUMN IF EXISTS company_id;

-- Step 3: Verify the column is removed
-- SELECT column_name, data_type 
-- FROM information_schema.columns 
-- WHERE table_name = 'sites' AND column_name = 'company_id';
-- Should return no rows

