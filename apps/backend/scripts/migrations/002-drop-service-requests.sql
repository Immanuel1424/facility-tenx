-- ============================================================================
-- DROP SERVICE_REQUESTS TABLES
-- ============================================================================
-- Run this migration AFTER confirming no data needs to be preserved.
-- This migration deletes all service_request tables permanently.
-- ============================================================================

BEGIN;

-- Drop tables in correct order (children first, then parents)
DROP TABLE IF EXISTS service_request_status_transitions CASCADE;
DROP TABLE IF EXISTS service_requests CASCADE;
DROP TABLE IF EXISTS service_request_workflows CASCADE;
DROP TABLE IF EXISTS issue_sub_categories CASCADE;

-- Verify cleanup
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_name = 'service_requests'
  ) THEN
    RAISE NOTICE 'SUCCESS: service_requests table dropped';
  ELSE
    RAISE WARNING 'FAILED: service_requests table still exists';
  END IF;
END $$;

COMMIT;

-- Print summary
DO $$
BEGIN
  RAISE NOTICE '============================================';
  RAISE NOTICE 'SERVICE_REQUESTS TABLES DROPPED';
  RAISE NOTICE '============================================';
  RAISE NOTICE 'Dropped: service_request_status_transitions';
  RAISE NOTICE 'Dropped: service_requests';
  RAISE NOTICE 'Dropped: service_request_workflows';
  RAISE NOTICE 'Dropped: issue_sub_categories';
  RAISE NOTICE '============================================';
END $$;

