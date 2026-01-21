-- Migration: Add metadata columns to villas table
-- Date: 2025-12-19
-- Description: Adds floor_count, bedroom_count, area_sqm, and metadata columns to villas table

ALTER TABLE villas
ADD COLUMN IF NOT EXISTS floor_count INTEGER NULL,
ADD COLUMN IF NOT EXISTS bedroom_count INTEGER NULL,
ADD COLUMN IF NOT EXISTS area_sqm DECIMAL(10, 2) NULL,
ADD COLUMN IF NOT EXISTS metadata JSONB NULL;

-- Add indexes if needed for querying
CREATE INDEX IF NOT EXISTS idx_villas_floor_count 
ON villas(company_id, floor_count) 
WHERE floor_count IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_villas_bedroom_count 
ON villas(company_id, bedroom_count) 
WHERE bedroom_count IS NOT NULL;

