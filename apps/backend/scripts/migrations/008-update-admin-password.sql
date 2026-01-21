-- ============================================================================
-- UPDATE ADMIN PASSWORD
-- ============================================================================
-- Updates the password hash for the admin user to ensure it matches password123
-- ============================================================================

BEGIN;

-- Update password hash for admin user
-- This hash is for 'password123' generated with bcrypt rounds=10
-- Note: bcrypt generates different hashes each time, but all validate the same password
UPDATE users 
SET "passwordHash" = '$2b$10$AST14qKnFA2s4TrGzcQYD.aNfI6fwXN.SUQWBLWMJNcF7qo/0stHS'
WHERE 
  email = 'vivek.ellappan@helixsense.com'
  AND company_id = 'eb75a65b-055f-4408-a58c-71d233443c17'
  AND deleted_at IS NULL;

-- Verify the update
DO $$
DECLARE
  updated_count INTEGER;
BEGIN
  GET DIAGNOSTICS updated_count = ROW_COUNT;
  
  IF updated_count > 0 THEN
    RAISE NOTICE '✅ Updated password hash for admin user (vivek.ellappan@helixsense.com)';
  ELSE
    RAISE NOTICE 'ℹ️  No admin user found or already updated.';
  END IF;
END $$;

COMMIT;

