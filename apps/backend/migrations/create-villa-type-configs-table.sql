-- Create villa_type_configs table for configurable villa type defaults
-- This allows admins to configure default bedroom count, floor count, and area
-- for each villa type per company, enabling faster data entry

CREATE TABLE IF NOT EXISTS villa_type_configs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL,
  villa_type VARCHAR(50) NOT NULL,
  display_name VARCHAR(255) NULL,
  default_bedroom_count INT NULL,
  default_floor_count INT NULL,
  default_area_sqm DECIMAL(10, 2) NULL,
  display_order INT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  metadata JSONB NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT fk_villa_type_configs_company 
    FOREIGN KEY (company_id) 
    REFERENCES companies(id) 
    ON DELETE CASCADE
);

-- Create unique index: one config per villa type per company
CREATE UNIQUE INDEX IF NOT EXISTS idx_villa_type_configs_company_type 
  ON villa_type_configs(company_id, villa_type);

-- Create index for active configs (for faster lookups)
CREATE INDEX IF NOT EXISTS idx_villa_type_configs_company_active 
  ON villa_type_configs(company_id, is_active);

-- Create index for display order (for sorted queries)
CREATE INDEX IF NOT EXISTS idx_villa_type_configs_company_order 
  ON villa_type_configs(company_id, display_order);

-- Add comments for documentation
COMMENT ON TABLE villa_type_configs IS 'Configurable defaults for villa types per company. Enables faster data entry by auto-filling bedroom count, floor count, and area based on villa type.';
COMMENT ON COLUMN villa_type_configs.villa_type IS 'Villa type code (e.g., 1BHK, 2BHK, Studio, Duplex). Must be unique per company.';
COMMENT ON COLUMN villa_type_configs.display_name IS 'Optional display name for the villa type (e.g., "1 Bedroom Hall Kitchen").';
COMMENT ON COLUMN villa_type_configs.default_bedroom_count IS 'Default bedroom count. Auto-filled when creating a villa with this type.';
COMMENT ON COLUMN villa_type_configs.default_floor_count IS 'Default floor count. Auto-filled when creating a villa with this type.';
COMMENT ON COLUMN villa_type_configs.default_area_sqm IS 'Default area in square meters. Auto-filled when creating a villa with this type.';
COMMENT ON COLUMN villa_type_configs.display_order IS 'Display order for dropdowns/lists. Lower numbers appear first.';
COMMENT ON COLUMN villa_type_configs.is_active IS 'Whether this configuration is active. Inactive configs won''t appear in dropdowns.';
COMMENT ON COLUMN villa_type_configs.metadata IS 'Additional metadata (JSONB). Can store custom fields like description, amenities, etc.';

-- Create trigger to auto-update updated_at
CREATE OR REPLACE FUNCTION update_villa_type_configs_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_villa_type_configs_updated_at
  BEFORE UPDATE ON villa_type_configs
  FOR EACH ROW
  EXECUTE FUNCTION update_villa_type_configs_updated_at();

