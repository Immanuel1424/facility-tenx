-- Create space_categories table

CREATE TABLE IF NOT EXISTS space_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT space_categories_code_unique UNIQUE (code)
);

-- Create index on code for faster lookups
CREATE INDEX IF NOT EXISTS idx_space_categories_code ON space_categories(code);

-- Create index on is_active for filtering active/inactive categories
CREATE INDEX IF NOT EXISTS idx_space_categories_is_active ON space_categories(is_active);

-- Verify the table structure
-- \d space_categories

