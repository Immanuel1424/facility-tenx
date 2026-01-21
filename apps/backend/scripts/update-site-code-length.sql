-- Update site code column to max 5 characters

-- Step 1: Check if there are any codes longer than 5 characters
-- SELECT code, LENGTH(code) FROM sites WHERE LENGTH(code) > 5;

-- Step 2: Alter the column to max 5 characters
ALTER TABLE sites ALTER COLUMN code TYPE VARCHAR(5);

-- Step 3: Verify the change
-- \d sites

