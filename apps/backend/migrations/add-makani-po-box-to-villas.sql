-- Migration: Add MAKANI number and P.O. Box columns to villas table
-- Date: 2025-01-14
-- Description: Adds MAKANI number and P.O. Box fields for UAE address standards
-- MAKANI is the UAE's official addressing system providing unique location numbers

-- Add makani_number column
ALTER TABLE villas
ADD COLUMN IF NOT EXISTS makani_number VARCHAR(50) NULL;

-- Add po_box column
ALTER TABLE villas
ADD COLUMN IF NOT EXISTS po_box VARCHAR(50) NULL;

-- Add comments for documentation
COMMENT ON COLUMN villas.makani_number IS 'MAKANI number - UAE official addressing system unique location identifier';
COMMENT ON COLUMN villas.po_box IS 'P.O. Box number for postal delivery in UAE';

