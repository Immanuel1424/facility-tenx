-- ============================================================================
-- SEED NEW PERMISSIONS
-- ============================================================================
-- Adds permissions for new entities: villas, teams, holidays
-- Permissions are GLOBAL (no company_id) - shared across all companies
-- ============================================================================

BEGIN;

-- Insert permissions for Villas
INSERT INTO permissions (id, resource, action, description, category, display_order, created_at, updated_at)
VALUES 
  (gen_random_uuid(), 'villas', 'create', 'Create new villas', 'Villas', 1, now(), now()),
  (gen_random_uuid(), 'villas', 'read', 'View villas', 'Villas', 2, now(), now()),
  (gen_random_uuid(), 'villas', 'update', 'Update villa information', 'Villas', 3, now(), now()),
  (gen_random_uuid(), 'villas', 'delete', 'Delete villas', 'Villas', 4, now(), now())
ON CONFLICT (resource, action) DO NOTHING;

-- Insert permissions for Teams
INSERT INTO permissions (id, resource, action, description, category, display_order, created_at, updated_at)
VALUES 
  (gen_random_uuid(), 'teams', 'create', 'Create new teams', 'Teams', 1, now(), now()),
  (gen_random_uuid(), 'teams', 'read', 'View teams', 'Teams', 2, now(), now()),
  (gen_random_uuid(), 'teams', 'update', 'Update team information', 'Teams', 3, now(), now()),
  (gen_random_uuid(), 'teams', 'delete', 'Delete teams', 'Teams', 4, now(), now()),
  (gen_random_uuid(), 'teams', 'manage_members', 'Add/remove team members', 'Teams', 5, now(), now())
ON CONFLICT (resource, action) DO NOTHING;

-- Insert permissions for Holidays
INSERT INTO permissions (id, resource, action, description, category, display_order, created_at, updated_at)
VALUES 
  (gen_random_uuid(), 'holidays', 'create', 'Create holidays', 'Holidays', 1, now(), now()),
  (gen_random_uuid(), 'holidays', 'read', 'View holidays', 'Holidays', 2, now(), now()),
  (gen_random_uuid(), 'holidays', 'update', 'Update holidays', 'Holidays', 3, now(), now()),
  (gen_random_uuid(), 'holidays', 'delete', 'Delete holidays', 'Holidays', 4, now(), now())
ON CONFLICT (resource, action) DO NOTHING;

-- Update existing ticket permissions with new actions
INSERT INTO permissions (id, resource, action, description, category, display_order, created_at, updated_at)
VALUES 
  (gen_random_uuid(), 'tickets', 'escalate', 'Escalate tickets', 'Tickets', 10, now(), now()),
  (gen_random_uuid(), 'tickets', 'assign_team', 'Assign tickets to teams', 'Tickets', 11, now(), now()),
  (gen_random_uuid(), 'tickets', 'link', 'Link parent/child tickets', 'Tickets', 12, now(), now())
ON CONFLICT (resource, action) DO NOTHING;

COMMIT;

-- Print summary
DO $$
DECLARE
  perm_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO perm_count FROM permissions;
  RAISE NOTICE '============================================';
  RAISE NOTICE 'PERMISSIONS SEEDED';
  RAISE NOTICE '============================================';
  RAISE NOTICE 'Total permissions in database: %', perm_count;
  RAISE NOTICE '============================================';
END $$;

