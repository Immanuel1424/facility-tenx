-- Migration: 016-create-user-sites-table.sql
-- Description: Create user_sites junction table for many-to-many relationship between users and sites
--              Optionally add site_id to roles table for site-specific roles

-- Create user_sites junction table
CREATE TABLE IF NOT EXISTS user_sites (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id uuid NOT NULL,
    user_id uuid NOT NULL,
    site_id uuid NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT fk_user_sites_company FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    CONSTRAINT fk_user_sites_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_user_sites_site FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE CASCADE,
    CONSTRAINT uk_user_sites_company_user_site UNIQUE (company_id, user_id, site_id)
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_user_sites_company_user ON user_sites(company_id, user_id);
CREATE INDEX IF NOT EXISTS idx_user_sites_company_site ON user_sites(company_id, site_id);
CREATE INDEX IF NOT EXISTS idx_user_sites_user_id ON user_sites(user_id);
CREATE INDEX IF NOT EXISTS idx_user_sites_site_id ON user_sites(site_id);

-- Add trigger to auto-update updated_at
CREATE OR REPLACE FUNCTION update_user_sites_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_user_sites_updated_at
    BEFORE UPDATE ON user_sites
    FOR EACH ROW
    EXECUTE FUNCTION update_user_sites_updated_at();

-- Optional: Add site_id to roles table for site-specific roles
-- This allows roles to be scoped to a specific site within a company
-- If site_id is NULL, the role is company-wide
ALTER TABLE roles
ADD COLUMN IF NOT EXISTS site_id uuid;

-- Add foreign key constraint for site_id
ALTER TABLE roles
ADD CONSTRAINT IF NOT EXISTS fk_roles_site 
    FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE CASCADE;

-- Create index for site_id
CREATE INDEX IF NOT EXISTS idx_roles_site_id ON roles(site_id);

-- Update unique constraint on roles to allow same role name for different sites
-- Drop existing unique constraint if it exists
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'roles_company_id_name_key'
    ) THEN
        ALTER TABLE roles DROP CONSTRAINT roles_company_id_name_key;
    END IF;
END $$;

-- Create new unique constraint that includes site_id (NULL for company-wide roles)
-- This allows: same role name for different sites, but unique per company+site combination
CREATE UNIQUE INDEX IF NOT EXISTS idx_roles_company_site_name 
    ON roles(company_id, COALESCE(site_id, '00000000-0000-0000-0000-000000000000'::uuid), name);

-- Add comment to document the change
COMMENT ON COLUMN roles.site_id IS 'Optional site ID for site-specific roles. NULL means company-wide role.';
COMMENT ON TABLE user_sites IS 'Junction table for many-to-many relationship between users and sites within a company.';

