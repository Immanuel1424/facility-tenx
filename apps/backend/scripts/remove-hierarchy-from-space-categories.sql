-- Remove hierarchy columns from space_categories table

-- Step 1: Drop foreign key constraint
ALTER TABLE space_categories 
  DROP CONSTRAINT IF EXISTS FK_space_categories_parent_category;

ALTER TABLE space_categories 
  DROP CONSTRAINT IF EXISTS fk_space_categories_parent_category;

-- Step 2: Drop indexes
DROP INDEX IF EXISTS idx_space_categories_parent_category_id;
DROP INDEX IF EXISTS idx_space_categories_hierarchy_level;

-- Step 3: Drop columns
ALTER TABLE space_categories DROP COLUMN IF EXISTS parent_category_id;
ALTER TABLE space_categories DROP COLUMN IF EXISTS hierarchy_level;

-- Step 4: Alter code column to VARCHAR(5) to match site code constraints
ALTER TABLE space_categories ALTER COLUMN code TYPE VARCHAR(5);

-- Step 5: Verify the changes
-- \d space_categories

