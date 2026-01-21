-- ============================================================================
-- ADD MISSING FOREIGN KEY INDEXES
-- ============================================================================
-- This migration adds indexes to foreign keys that were missing explicit indexes
-- Based on database performance analysis
-- ============================================================================

BEGIN;

-- ============================================================================
-- Issue 1: notification_deliveries.notificationId
-- ============================================================================
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'notification_deliveries' 
    AND column_name = 'notificationId'
  ) THEN
    CREATE INDEX IF NOT EXISTS idx_notification_deliveries_notification_id 
      ON notification_deliveries(company_id, "notificationId") 
      WHERE "notificationId" IS NOT NULL;
  END IF;
END $$;

-- ============================================================================
-- Issue 2: roles.parent_role_id
-- ============================================================================
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'roles' 
    AND column_name = 'parent_role_id'
  ) THEN
    CREATE INDEX IF NOT EXISTS idx_roles_parent_role_id 
      ON roles(company_id, parent_role_id) 
      WHERE parent_role_id IS NOT NULL;
  END IF;
END $$;

-- ============================================================================
-- Issue 3: spaces.siteId (check both snake_case and camelCase)
-- ============================================================================
DO $$
BEGIN
  -- Check for snake_case
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'spaces' 
    AND column_name = 'site_id'
  ) THEN
    CREATE INDEX IF NOT EXISTS idx_spaces_site_id 
      ON spaces(company_id, site_id) 
      WHERE site_id IS NOT NULL;
  END IF;
  
  -- Check for camelCase
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'spaces' 
    AND column_name = 'siteId'
  ) THEN
    CREATE INDEX IF NOT EXISTS idx_spaces_siteId 
      ON spaces(company_id, "siteId") 
      WHERE "siteId" IS NOT NULL;
  END IF;
END $$;

-- ============================================================================
-- Issue 4: spaces.spaceCategoryId (check both snake_case and camelCase)
-- ============================================================================
DO $$
BEGIN
  -- Check for snake_case
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'spaces' 
    AND column_name = 'space_category_id'
  ) THEN
    CREATE INDEX IF NOT EXISTS idx_spaces_space_category_id 
      ON spaces(company_id, space_category_id) 
      WHERE space_category_id IS NOT NULL;
  END IF;
  
  -- Check for camelCase
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'spaces' 
    AND column_name = 'spaceCategoryId'
  ) THEN
    CREATE INDEX IF NOT EXISTS idx_spaces_spaceCategoryId 
      ON spaces(company_id, "spaceCategoryId") 
      WHERE "spaceCategoryId" IS NOT NULL;
  END IF;
END $$;

-- ============================================================================
-- Issue 5: ticket_sla.sla_configuration_id
-- ============================================================================
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'ticket_sla' 
    AND column_name = 'sla_configuration_id'
  ) THEN
    CREATE INDEX IF NOT EXISTS idx_ticket_sla_configuration_id 
      ON ticket_sla(company_id, sla_configuration_id) 
      WHERE sla_configuration_id IS NOT NULL;
  END IF;
  
  -- Check for camelCase
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'ticket_sla' 
    AND column_name = 'slaConfigurationId'
  ) THEN
    CREATE INDEX IF NOT EXISTS idx_ticket_sla_slaConfigurationId 
      ON ticket_sla(company_id, "slaConfigurationId") 
      WHERE "slaConfigurationId" IS NOT NULL;
  END IF;
END $$;

COMMIT;

-- ============================================================================
-- SUMMARY
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE '============================================';
  RAISE NOTICE 'MISSING FK INDEXES MIGRATION COMPLETE';
  RAISE NOTICE '============================================';
  RAISE NOTICE 'Added indexes for:';
  RAISE NOTICE '  - notification_deliveries.notificationId';
  RAISE NOTICE '  - roles.parent_role_id';
  RAISE NOTICE '  - spaces.site_id / siteId';
  RAISE NOTICE '  - spaces.space_category_id / spaceCategoryId';
  RAISE NOTICE '  - ticket_sla.sla_configuration_id';
  RAISE NOTICE '============================================';
END $$;

