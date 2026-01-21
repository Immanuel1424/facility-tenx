-- ============================================================================
-- ANNOUNCEMENTS MODULE: ANNOUNCEMENTS AND ANNOUNCEMENT_READS TABLES
-- ============================================================================
-- This migration creates tables for the announcement system:
-- 1. announcements: Stores announcements created by admins
-- 2. announcement_reads: Tracks which users have read which announcements
-- ============================================================================

BEGIN;

-- ============================================================================
-- CREATE ENUM TYPES
-- ============================================================================

DO $$ BEGIN
  CREATE TYPE announcement_category AS ENUM ('maintenance', 'emergency', 'general', 'info');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE announcement_priority AS ENUM ('low', 'medium', 'high', 'urgent');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE announcement_target_audience AS ENUM ('all', 'roles');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- ============================================================================
-- CREATE ANNOUNCEMENTS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS announcements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL,
  created_by_user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  category announcement_category NOT NULL DEFAULT 'general',
  priority announcement_priority NOT NULL DEFAULT 'medium',
  target_audience announcement_target_audience NOT NULL,
  target_roles JSONB, -- Array of role names if target_audience = 'roles'
  scheduled_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  is_published BOOLEAN DEFAULT false,
  published_at TIMESTAMPTZ,
  metadata JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ
);

-- ============================================================================
-- CREATE ANNOUNCEMENT_READS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS announcement_reads (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL,
  announcement_id UUID NOT NULL REFERENCES announcements(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  read_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  
  -- Ensure one read record per user per announcement
  CONSTRAINT uq_announcement_reads_company_announcement_user 
    UNIQUE (company_id, announcement_id, user_id)
);

-- ============================================================================
-- CREATE INDEXES
-- ============================================================================

-- Announcements indexes
CREATE INDEX IF NOT EXISTS idx_announcements_company 
  ON announcements(company_id);

CREATE INDEX IF NOT EXISTS idx_announcements_published 
  ON announcements(company_id, is_published, expires_at) 
  WHERE is_published = true;

CREATE INDEX IF NOT EXISTS idx_announcements_scheduled 
  ON announcements(company_id, scheduled_at) 
  WHERE scheduled_at IS NOT NULL AND is_published = false;

CREATE INDEX IF NOT EXISTS idx_announcements_category 
  ON announcements(company_id, category);

CREATE INDEX IF NOT EXISTS idx_announcements_priority 
  ON announcements(company_id, priority);

-- Announcement reads indexes
CREATE INDEX IF NOT EXISTS idx_announcement_reads_user 
  ON announcement_reads(company_id, user_id);

CREATE INDEX IF NOT EXISTS idx_announcement_reads_announcement 
  ON announcement_reads(announcement_id);

-- ============================================================================
-- CREATE TRIGGER FOR UPDATED_AT
-- ============================================================================

CREATE OR REPLACE FUNCTION update_announcements_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_announcements_updated_at
  BEFORE UPDATE ON announcements
  FOR EACH ROW
  EXECUTE FUNCTION update_announcements_updated_at();

COMMIT;

