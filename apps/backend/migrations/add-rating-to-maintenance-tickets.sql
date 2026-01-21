-- ============================================================================
-- TICKET RATING: ADD RATING COLUMNS TO MAINTENANCE_TICKETS TABLE
-- ============================================================================
-- This migration adds rating fields to maintenance_tickets table to allow
-- tenants to rate closed tickets (1-5 stars) with optional comments.
-- ============================================================================

BEGIN;

-- Add rating columns
ALTER TABLE maintenance_tickets
  ADD COLUMN IF NOT EXISTS rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  ADD COLUMN IF NOT EXISTS rating_comment TEXT,
  ADD COLUMN IF NOT EXISTS rated_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS rated_by UUID REFERENCES users(id) ON DELETE SET NULL;

-- Add index for rating queries (find tickets by rating)
CREATE INDEX IF NOT EXISTS idx_maintenance_tickets_rating
  ON maintenance_tickets(company_id, rating) WHERE rating IS NOT NULL;

-- Add index for rated_by queries (find tickets rated by user)
CREATE INDEX IF NOT EXISTS idx_maintenance_tickets_rated_by
  ON maintenance_tickets(company_id, rated_by) WHERE rated_by IS NOT NULL;

COMMIT;

