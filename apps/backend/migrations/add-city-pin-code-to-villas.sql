-- Migration: Add city and pin_code columns to villas table
-- Date: 2025-01-14
-- Description: Adds city and pin_code fields to the villas table for address information

-- Add city column
ALTER TABLE villas
ADD COLUMN IF NOT EXISTS city VARCHAR(100) NULL;

-- Add pin_code column
ALTER TABLE villas
ADD COLUMN IF NOT EXISTS pin_code VARCHAR(20) NULL;

-- Add comment for documentation
COMMENT ON COLUMN villas.city IS 'City name for the villa address';
COMMENT ON COLUMN villas.pin_code IS 'Postal/PIN code for the villa address';

