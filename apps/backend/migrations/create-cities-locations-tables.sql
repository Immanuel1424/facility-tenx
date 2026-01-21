-- Migration: Create cities and locations tables for UAE address standards
-- Date: 2025-01-14
-- Description: Creates reference tables for cities and locations (areas) in UAE
-- These are used for dropdowns in villa address forms

-- Create cities table
CREATE TABLE IF NOT EXISTS cities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  code VARCHAR(10) NULL,
  emirate VARCHAR(50) NULL,
  display_order INT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT uq_cities_name UNIQUE (name)
);

-- Create locations table (areas/neighborhoods within cities)
CREATE TABLE IF NOT EXISTS locations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  city_id UUID NOT NULL,
  name VARCHAR(100) NOT NULL,
  code VARCHAR(10) NULL,
  display_order INT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT fk_locations_city 
    FOREIGN KEY (city_id) 
    REFERENCES cities(id) 
    ON DELETE CASCADE,
  CONSTRAINT uq_locations_city_name UNIQUE (city_id, name)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_cities_active ON cities(is_active);
CREATE INDEX IF NOT EXISTS idx_cities_display_order ON cities(display_order);
CREATE INDEX IF NOT EXISTS idx_locations_city ON locations(city_id);
CREATE INDEX IF NOT EXISTS idx_locations_active ON locations(is_active);
CREATE INDEX IF NOT EXISTS idx_locations_display_order ON locations(display_order);

-- Add comments
COMMENT ON TABLE cities IS 'Reference table for UAE cities. Used in address dropdowns.';
COMMENT ON TABLE locations IS 'Reference table for locations/areas within cities. Used in address dropdowns.';
COMMENT ON COLUMN cities.emirate IS 'Emirate name (Dubai, Abu Dhabi, Sharjah, etc.)';
COMMENT ON COLUMN locations.city_id IS 'Foreign key to cities table';

-- Create trigger to auto-update updated_at
CREATE OR REPLACE FUNCTION update_cities_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_cities_updated_at
  BEFORE UPDATE ON cities
  FOR EACH ROW
  EXECUTE FUNCTION update_cities_updated_at();

CREATE OR REPLACE FUNCTION update_locations_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_locations_updated_at
  BEFORE UPDATE ON locations
  FOR EACH ROW
  EXECUTE FUNCTION update_locations_updated_at();

