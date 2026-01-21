DO $$
DECLARE
  v_system_company_id uuid;
  v_super_admin_user_id uuid;
BEGIN
  RAISE NOTICE '=== RESETTING TENANT DATA, KEEPING SYSTEM COMPANY ===';

  -- 1) Locate SYSTEM company
  SELECT id
  INTO v_system_company_id
  FROM companies
  WHERE code = 'SYSTEM';

  IF v_system_company_id IS NULL THEN
    RAISE EXCEPTION 'SYSTEM company (code = SYSTEM) not found. Aborting reset.';
  END IF;

  RAISE NOTICE 'SYSTEM company id = %', v_system_company_id;

  -- 2) Locate SUPER_ADMIN user (optional safety)
  SELECT id
  INTO v_super_admin_user_id
  FROM users
  WHERE company_id = v_system_company_id
    AND email = 'superadmin@system.local';

  RAISE NOTICE 'SUPER_ADMIN user id = %', v_super_admin_user_id;

  ---------------------------------------------------------------------------
  -- IMPORTANT: Delete child records first, then parents.
  -- Comment out blocks for tables that don't exist in your schema.
  ---------------------------------------------------------------------------

  -- User-site links
  RAISE NOTICE 'Deleting from user_sites...';
  DELETE FROM user_sites
  WHERE company_id <> v_system_company_id;

  -- Sites
  RAISE NOTICE 'Deleting from sites...';
  DELETE FROM sites
  WHERE company_id <> v_system_company_id;

  -- Space hierarchy (if used)
  BEGIN
    RAISE NOTICE 'Deleting from spaces...';
    DELETE FROM spaces
    WHERE company_id <> v_system_company_id;
  EXCEPTION WHEN undefined_table THEN
    RAISE NOTICE 'Table spaces does not exist, skipping.';
  END;

  BEGIN
    RAISE NOTICE 'Deleting from space_categories...';
    -- space_categories is not company-scoped in this schema, so delete all
    DELETE FROM space_categories;
  EXCEPTION WHEN undefined_table THEN
    RAISE NOTICE 'Table space_categories does not exist, skipping.';
  END;

  -- Departments (if present)
  BEGIN
    RAISE NOTICE 'Deleting from departments...';
    DELETE FROM departments
    WHERE company_id <> v_system_company_id;
  EXCEPTION WHEN undefined_table THEN
    RAISE NOTICE 'Table departments does not exist, skipping.';
  END;

  -- Villas / assets (if present)
  BEGIN
    RAISE NOTICE 'Deleting from villas...';
    DELETE FROM villas
    WHERE company_id <> v_system_company_id;
  EXCEPTION WHEN undefined_table THEN
    RAISE NOTICE 'Table villas does not exist, skipping.';
  END;

  -- Tickets / complaints (if present)
  BEGIN
    RAISE NOTICE 'Deleting from maintenance_tickets...';
    DELETE FROM maintenance_tickets
    WHERE company_id <> v_system_company_id;
  EXCEPTION WHEN undefined_table THEN
    RAISE NOTICE 'Table maintenance_tickets does not exist, skipping.';
  END;

  BEGIN
    RAISE NOTICE 'Deleting from tenant_tickets...';
    DELETE FROM tenant_tickets
    WHERE company_id <> v_system_company_id;
  EXCEPTION WHEN undefined_table THEN
    RAISE NOTICE 'Table tenant_tickets does not exist, skipping.';
  END;

  -- Announcements, notifications, etc. (if company-scoped)
  BEGIN
    RAISE NOTICE 'Deleting from announcements...';
    DELETE FROM announcements
    WHERE company_id <> v_system_company_id;
  EXCEPTION WHEN undefined_table THEN
    RAISE NOTICE 'Table announcements does not exist, skipping.';
  END;

  BEGIN
    RAISE NOTICE 'Deleting from notifications...';
    DELETE FROM notifications
    WHERE company_id <> v_system_company_id;
  EXCEPTION WHEN undefined_table THEN
    RAISE NOTICE 'Table notifications does not exist, skipping.';
  END;

  -- Roles: keep SYSTEM roles, especially SUPER_ADMIN
  RAISE NOTICE 'Deleting from roles...';
  DELETE FROM roles
  WHERE company_id <> v_system_company_id;

  -- Users: keep SYSTEM SUPER_ADMIN user
  RAISE NOTICE 'Deleting from users...';
  DELETE FROM users
  WHERE company_id <> v_system_company_id;

  -- Ensure super admin stays on SYSTEM company
  IF v_super_admin_user_id IS NOT NULL THEN
    UPDATE users
    SET company_id = v_system_company_id
    WHERE id = v_super_admin_user_id;
  END IF;

  -- Finally, delete all non-SYSTEM companies
  RAISE NOTICE 'Deleting non-SYSTEM companies...';
  DELETE FROM companies
  WHERE id <> v_system_company_id;

  RAISE NOTICE '=== RESET COMPLETE. Only SYSTEM company and its core data remain. ===';
END $$;
