-- Add hierarchy level and parent category to space_categories table

-- Step 1: Add hierarchy_level column
ALTER TABLE space_categories ADD COLUMN IF NOT EXISTS hierarchy_level INT NOT NULL DEFAULT 0;

-- Step 2: Add parent_category_id column
ALTER TABLE space_categories ADD COLUMN IF NOT EXISTS parent_category_id UUID;

-- Step 3: Add foreign key constraint
ALTER TABLE space_categories 
  ADD CONSTRAINT FK_space_categories_parent_category 
  FOREIGN KEY (parent_category_id) 
  REFERENCES space_categories(id) 
  ON DELETE SET NULL;

-- Step 4: Create index on parent_category_id for better query performance
CREATE INDEX IF NOT EXISTS idx_space_categories_parent_category_id ON space_categories(parent_category_id);

-- Step 5: Create index on hierarchy_level for filtering and sorting
CREATE INDEX IF NOT EXISTS idx_space_categories_hierarchy_level ON space_categories(hierarchy_level);

-- Step 6: Verify the changes
-- \d space_categories

