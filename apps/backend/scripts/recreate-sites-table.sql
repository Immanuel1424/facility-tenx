-- Drop and recreate sites table with updated structure

-- Step 1: Drop the table if it exists (CASCADE to remove foreign key constraints)
DROP TABLE IF EXISTS sites CASCADE;

-- Step 2: Create the sites table with all required columns and constraints
CREATE TABLE sites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(5) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    is_parent BOOLEAN NOT NULL DEFAULT true,
    parent_site_id UUID,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT sites_code_unique UNIQUE (code),
    CONSTRAINT FK_sites_parent_site FOREIGN KEY (parent_site_id) REFERENCES sites(id) ON DELETE SET NULL
);

-- Step 3: Create index on parent_site_id for better query performance
CREATE INDEX idx_sites_parent_site_id ON sites(parent_site_id);

-- Step 4: Create index on is_parent for filtering parent/child sites
CREATE INDEX idx_sites_is_parent ON sites(is_parent);

-- Step 5: Verify the table structure
-- \d sites

