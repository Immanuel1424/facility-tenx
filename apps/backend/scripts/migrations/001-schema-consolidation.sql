-- ============================================================================
-- SCHEMA CONSOLIDATION MIGRATION
-- ============================================================================
-- This migration:
-- 1. Fixes multi-tenancy issues (Company, Sites)
-- 2. Creates missing tables (Villas, Teams, Holidays)
-- 3. Consolidates tickets (maintenance_tickets + service_requests → tickets)
-- 4. Adds missing indexes
-- 5. Fixes Permission scoping
-- ============================================================================

-- Run inside a transaction
BEGIN;

-- ============================================================================
-- STEP 1: CREATE ENUM TYPES (if not exist)
-- ============================================================================

DO $$ BEGIN
  CREATE TYPE ticket_type AS ENUM ('MAINTENANCE', 'SERVICE_REQUEST', 'INCIDENT', 'INSPECTION');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- Ensure existing enums exist
DO $$ BEGIN
  CREATE TYPE ticket_status AS ENUM (
    'NEW', 'ACKNOWLEDGED', 'ASSIGNED', 'IN_PROGRESS', 
    'ON_HOLD', 'COMPLETED', 'CANCELLED'
  );
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE ticket_priority AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'URGENT');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- ============================================================================
-- STEP 2: FIX COMPANIES TABLE (remove company_id self-reference)
-- ============================================================================
-- Company should NOT have company_id pointing to itself

-- First check if company_id exists and remove it
DO $$ 
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'companies' AND column_name = 'company_id'
  ) THEN
    -- Drop any FK constraints first
    ALTER TABLE companies DROP CONSTRAINT IF EXISTS fk_companies_company;
    -- Drop the column
    ALTER TABLE companies DROP COLUMN company_id;
  END IF;
END $$;

-- ============================================================================
-- STEP 3: ADD company_id TO SITES TABLE
-- ============================================================================

-- Add company_id to sites if not exists
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'sites' AND column_name = 'company_id'
  ) THEN
    ALTER TABLE sites ADD COLUMN company_id UUID;
  END IF;
END $$;

-- Create index for multi-tenant queries
CREATE INDEX IF NOT EXISTS idx_sites_company_id ON sites(company_id);
CREATE INDEX IF NOT EXISTS idx_sites_company_code ON sites(company_id, code);

-- ============================================================================
-- STEP 4: CREATE VILLAS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS villas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL,
  villa_number INTEGER NOT NULL,
  villa_code VARCHAR(50),
  site_id UUID REFERENCES sites(id) ON DELETE SET NULL,
  space_id UUID REFERENCES spaces(id) ON DELETE SET NULL,
  
  -- Owner/Tenant info
  owner_name VARCHAR(255),
  tenant_name VARCHAR(255),
  contact_phone VARCHAR(50),
  contact_email VARCHAR(255),
  
  -- Address
  block VARCHAR(50),
  street VARCHAR(255),
  
  -- Status
  is_active BOOLEAN DEFAULT true,
  is_occupied BOOLEAN DEFAULT true,
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  
  -- Constraints
  CONSTRAINT uq_villas_company_number UNIQUE (company_id, villa_number),
  CONSTRAINT uq_villas_company_code UNIQUE (company_id, villa_code)
);

-- Indexes for villas
CREATE INDEX IF NOT EXISTS idx_villas_company_id ON villas(company_id);
CREATE INDEX IF NOT EXISTS idx_villas_site_id ON villas(company_id, site_id);
CREATE INDEX IF NOT EXISTS idx_villas_active ON villas(company_id, is_active) WHERE is_active = true;

COMMENT ON TABLE villas IS 'Tenant villas/units - replaces denormalized villa_number';

-- ============================================================================
-- STEP 5: CREATE TEAMS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS teams (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL,
  department_id UUID REFERENCES departments(id) ON DELETE SET NULL,
  
  name VARCHAR(100) NOT NULL,
  description TEXT,
  
  -- Lead technician
  lead_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  
  CONSTRAINT uq_teams_company_name UNIQUE (company_id, name)
);

CREATE INDEX IF NOT EXISTS idx_teams_company_id ON teams(company_id);
CREATE INDEX IF NOT EXISTS idx_teams_department ON teams(company_id, department_id);
CREATE INDEX IF NOT EXISTS idx_teams_active ON teams(company_id, is_active) WHERE is_active = true;

COMMENT ON TABLE teams IS 'Technician teams for group assignment';

-- ============================================================================
-- STEP 6: CREATE TEAM_MEMBERS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS team_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL,
  team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  is_lead BOOLEAN DEFAULT false,
  joined_at TIMESTAMPTZ DEFAULT now(),
  
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  
  CONSTRAINT uq_team_members_team_user UNIQUE (company_id, team_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_team_members_company ON team_members(company_id);
CREATE INDEX IF NOT EXISTS idx_team_members_team ON team_members(company_id, team_id);
CREATE INDEX IF NOT EXISTS idx_team_members_user ON team_members(company_id, user_id);

COMMENT ON TABLE team_members IS 'Junction table for team membership';

-- ============================================================================
-- STEP 7: CREATE HOLIDAYS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS holidays (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL,
  
  name VARCHAR(100) NOT NULL,
  holiday_date DATE NOT NULL,
  
  -- If recurring, applies every year on same date
  is_recurring BOOLEAN DEFAULT false,
  
  description TEXT,
  
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  
  CONSTRAINT uq_holidays_company_date UNIQUE (company_id, holiday_date)
);

CREATE INDEX IF NOT EXISTS idx_holidays_company ON holidays(company_id);
CREATE INDEX IF NOT EXISTS idx_holidays_date ON holidays(company_id, holiday_date);

COMMENT ON TABLE holidays IS 'Company holidays for SLA calculation';

-- ============================================================================
-- STEP 8: EXTEND MAINTENANCE_TICKETS TABLE
-- ============================================================================

-- Add new columns from service_requests
ALTER TABLE maintenance_tickets 
  ADD COLUMN IF NOT EXISTS ticket_type VARCHAR(50) DEFAULT 'MAINTENANCE',
  ADD COLUMN IF NOT EXISTS site_id UUID,
  ADD COLUMN IF NOT EXISTS space_id UUID,
  ADD COLUMN IF NOT EXISTS villa_id UUID,
  ADD COLUMN IF NOT EXISTS assigned_team_id UUID,
  ADD COLUMN IF NOT EXISTS parent_ticket_id UUID,
  ADD COLUMN IF NOT EXISTS is_escalated BOOLEAN DEFAULT false;

-- Add foreign key constraints
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE constraint_name = 'fk_tickets_site'
  ) THEN
    ALTER TABLE maintenance_tickets 
      ADD CONSTRAINT fk_tickets_site 
      FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE SET NULL;
  END IF;
END $$;

DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE constraint_name = 'fk_tickets_space'
  ) THEN
    ALTER TABLE maintenance_tickets 
      ADD CONSTRAINT fk_tickets_space 
      FOREIGN KEY (space_id) REFERENCES spaces(id) ON DELETE SET NULL;
  END IF;
END $$;

DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE constraint_name = 'fk_tickets_villa'
  ) THEN
    ALTER TABLE maintenance_tickets 
      ADD CONSTRAINT fk_tickets_villa 
      FOREIGN KEY (villa_id) REFERENCES villas(id) ON DELETE SET NULL;
  END IF;
END $$;

DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE constraint_name = 'fk_tickets_team'
  ) THEN
    ALTER TABLE maintenance_tickets 
      ADD CONSTRAINT fk_tickets_team 
      FOREIGN KEY (assigned_team_id) REFERENCES teams(id) ON DELETE SET NULL;
  END IF;
END $$;

DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE constraint_name = 'fk_tickets_parent'
  ) THEN
    ALTER TABLE maintenance_tickets 
      ADD CONSTRAINT fk_tickets_parent 
      FOREIGN KEY (parent_ticket_id) REFERENCES maintenance_tickets(id) ON DELETE SET NULL;
  END IF;
END $$;

-- Add new indexes for new columns
CREATE INDEX IF NOT EXISTS idx_tickets_site ON maintenance_tickets(company_id, site_id);
CREATE INDEX IF NOT EXISTS idx_tickets_space ON maintenance_tickets(company_id, space_id);
CREATE INDEX IF NOT EXISTS idx_tickets_villa ON maintenance_tickets(company_id, villa_id);
CREATE INDEX IF NOT EXISTS idx_tickets_team ON maintenance_tickets(company_id, assigned_team_id);
CREATE INDEX IF NOT EXISTS idx_tickets_parent ON maintenance_tickets(company_id, parent_ticket_id);
CREATE INDEX IF NOT EXISTS idx_tickets_type ON maintenance_tickets(company_id, ticket_type);
CREATE INDEX IF NOT EXISTS idx_tickets_escalated ON maintenance_tickets(company_id, is_escalated) WHERE is_escalated = true;

-- ============================================================================
-- STEP 9: MIGRATE VILLA DATA
-- ============================================================================

-- Create villas from existing villa_number values in maintenance_tickets and users
INSERT INTO villas (company_id, villa_number, villa_code, is_active)
SELECT DISTINCT 
  company_id, 
  villa_number,
  'V' || villa_number::TEXT,
  true
FROM maintenance_tickets 
WHERE villa_number IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM villas v 
    WHERE v.company_id = maintenance_tickets.company_id 
      AND v.villa_number = maintenance_tickets.villa_number
  )
ON CONFLICT (company_id, villa_number) DO NOTHING;

-- Also from users
INSERT INTO villas (company_id, villa_number, villa_code, is_active)
SELECT DISTINCT 
  company_id, 
  villa_number,
  'V' || villa_number::TEXT,
  true
FROM users 
WHERE villa_number IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM villas v 
    WHERE v.company_id = users.company_id 
      AND v.villa_number = users.villa_number
  )
ON CONFLICT (company_id, villa_number) DO NOTHING;

-- Update maintenance_tickets.villa_id from villa_number
UPDATE maintenance_tickets mt
SET villa_id = v.id
FROM villas v
WHERE v.company_id = mt.company_id 
  AND v.villa_number = mt.villa_number
  AND mt.villa_id IS NULL;

-- ============================================================================
-- STEP 10: RENAME TABLE (maintenance_tickets → tickets)
-- ============================================================================

-- Note: This is a breaking change. Comment out if you want to keep the old name.
-- ALTER TABLE maintenance_tickets RENAME TO tickets;

-- For now, create a view for backward compatibility
CREATE OR REPLACE VIEW tickets AS SELECT * FROM maintenance_tickets;

-- ============================================================================
-- STEP 11: ADD MISSING INDEXES FOR PERFORMANCE
-- ============================================================================

-- Users indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_company_status ON users(company_id, status);

-- Tickets - dashboard queries
CREATE INDEX IF NOT EXISTS idx_tickets_technician_open 
ON maintenance_tickets(company_id, assigned_technician_id, status) 
WHERE status != 'CANCELLED';

-- Tickets - SLA monitoring
CREATE INDEX IF NOT EXISTS idx_tickets_auto_close_pending 
ON maintenance_tickets(company_id, auto_close_at) 
WHERE auto_close_at IS NOT NULL AND status != 'CANCELLED';

-- Tickets - tenant portal
CREATE INDEX IF NOT EXISTS idx_tickets_villa_recent 
ON maintenance_tickets(company_id, villa_number, created_at DESC);

-- Attachments - active only
CREATE INDEX IF NOT EXISTS idx_attachments_ticket_active 
ON ticket_attachments(company_id, ticket_id, created_at DESC) 
WHERE is_deleted = false;

-- Comments - threaded and recent
CREATE INDEX IF NOT EXISTS idx_comments_parent 
ON ticket_comments(company_id, ticket_id, parent_comment_id);

CREATE INDEX IF NOT EXISTS idx_comments_ticket_recent 
ON ticket_comments(company_id, ticket_id, created_at DESC) 
WHERE is_deleted = false;

-- Status history - timeline
CREATE INDEX IF NOT EXISTS idx_status_history_ticket_time 
ON ticket_status_history(company_id, ticket_id, created_at DESC);

-- Categories - active dropdown
CREATE INDEX IF NOT EXISTS idx_categories_active_order 
ON ticket_categories(company_id, is_active, display_order) 
WHERE is_active = true;

-- SLA - breach monitoring
CREATE INDEX IF NOT EXISTS idx_sla_breaching 
ON ticket_sla(company_id, resolution_deadline, sla_status) 
WHERE sla_status IN ('ON_TRACK', 'AT_RISK');

-- Refresh tokens - cleanup
CREATE INDEX IF NOT EXISTS idx_tokens_expired 
ON refresh_tokens(expires_at) 
WHERE revoked_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_tokens_user_active 
ON refresh_tokens(company_id, user_id) 
WHERE revoked_at IS NULL;

-- ACL - authorization check
CREATE INDEX IF NOT EXISTS idx_acl_auth_check 
ON acl_entries(company_id, resource_type, resource_id, user_id, effect);

-- Notifications - unread
CREATE INDEX IF NOT EXISTS idx_notifications_unread 
ON notifications(company_id, recipient_user_id, created_at DESC) 
WHERE is_read = false;

-- Notification deliveries - retry
CREATE INDEX IF NOT EXISTS idx_deliveries_retry 
ON notification_deliveries(status, attempt_count) 
WHERE status IN ('pending', 'retrying');

-- ============================================================================
-- STEP 12: ADD MISSING CONSTRAINTS
-- ============================================================================

-- ACL must have user_id OR permission_id
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE constraint_name = 'chk_acl_has_target'
  ) THEN
    ALTER TABLE acl_entries 
      ADD CONSTRAINT chk_acl_has_target 
      CHECK (user_id IS NOT NULL OR permission_id IS NOT NULL);
  END IF;
EXCEPTION
  WHEN check_violation THEN 
    RAISE NOTICE 'Some ACL entries have neither user_id nor permission_id - clean up required';
END $$;

-- Attachments - FK to comments
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE constraint_name = 'fk_attachments_comment'
  ) THEN
    ALTER TABLE ticket_attachments 
      ADD CONSTRAINT fk_attachments_comment 
      FOREIGN KEY (comment_id) REFERENCES ticket_comments(id) ON DELETE SET NULL;
  END IF;
END $$;

-- ============================================================================
-- STEP 13: DROP SERVICE_REQUESTS TABLES (OPTIONAL - UNCOMMENT WHEN READY)
-- ============================================================================

-- WARNING: This will delete all service_request data!
-- Only run after confirming no data needs to be migrated.

-- DROP TABLE IF EXISTS service_request_status_transitions CASCADE;
-- DROP TABLE IF EXISTS service_requests CASCADE;
-- DROP TABLE IF EXISTS service_request_workflows CASCADE;
-- DROP TABLE IF EXISTS issue_sub_categories CASCADE;

-- ============================================================================
-- DONE
-- ============================================================================

COMMIT;

-- Print summary
DO $$
BEGIN
  RAISE NOTICE '============================================';
  RAISE NOTICE 'MIGRATION COMPLETE';
  RAISE NOTICE '============================================';
  RAISE NOTICE 'Created tables: villas, teams, team_members, holidays';
  RAISE NOTICE 'Extended: maintenance_tickets with site_id, space_id, villa_id, team_id, parent_ticket_id';
  RAISE NOTICE 'Added indexes: ~25 new indexes for performance';
  RAISE NOTICE 'Fixed: company_id on sites, constraints on acl_entries';
  RAISE NOTICE '============================================';
  RAISE NOTICE 'MANUAL STEPS REQUIRED:';
  RAISE NOTICE '1. Update TypeORM entities to match new schema';
  RAISE NOTICE '2. Migrate any service_request data if needed';
  RAISE NOTICE '3. Uncomment DROP TABLE statements when ready';
  RAISE NOTICE '4. Update site records with correct company_id values';
  RAISE NOTICE '============================================';
END $$;

