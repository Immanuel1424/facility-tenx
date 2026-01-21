-- ============================================================================
-- ADD UPDATED_AT COLUMN TO ANNOUNCEMENT_READS TABLE
-- ============================================================================
-- This migration adds the missing updated_at column to announcement_reads
-- table to match the TenantBaseEntity requirements.
-- ============================================================================

BEGIN;

-- Add updated_at column if it doesn't exist
ALTER TABLE announcement_reads
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT now();

-- Create or replace the trigger function (reuse existing if available)
CREATE OR REPLACE FUNCTION update_announcement_reads_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to auto-update updated_at on row updates
DROP TRIGGER IF EXISTS trigger_update_announcement_reads_updated_at ON announcement_reads;

CREATE TRIGGER trigger_update_announcement_reads_updated_at
  BEFORE UPDATE ON announcement_reads
  FOR EACH ROW
  EXECUTE FUNCTION update_announcement_reads_updated_at();

COMMIT;

