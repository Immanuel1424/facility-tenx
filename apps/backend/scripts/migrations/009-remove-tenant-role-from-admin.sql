-- Migration: Remove TENANT role from admin user
-- Date: 2025-01-14
-- Description: Admin user should only have ADMIN role, not TENANT role

DO $$
DECLARE
  admin_email TEXT := 'vivek.ellappan@helixsense.com';
  company_id_val UUID := 'eb75a65b-055f-4408-a58c-71d233443c17';
  admin_user_id UUID;
  tenant_role_id UUID;
BEGIN
  -- Find the admin user
  SELECT id INTO admin_user_id
  FROM users
  WHERE email = admin_email
    AND company_id = company_id_val
    AND deleted_at IS NULL;

  IF admin_user_id IS NULL THEN
    RAISE NOTICE 'Admin user not found: %', admin_email;
    RETURN;
  END IF;

  -- Find the TENANT role
  SELECT id INTO tenant_role_id
  FROM roles
  WHERE name = 'TENANT'
    AND company_id = company_id_val;

  IF tenant_role_id IS NULL THEN
    RAISE NOTICE 'TENANT role not found for company: %', company_id_val;
    RETURN;
  END IF;

  -- Remove TENANT role from admin user
  DELETE FROM user_roles
  WHERE user_id = admin_user_id
    AND role_id = tenant_role_id
    AND company_id = company_id_val;

  IF FOUND THEN
    RAISE NOTICE 'Removed TENANT role from admin user: %', admin_email;
  ELSE
    RAISE NOTICE 'TENANT role was not assigned to admin user: %', admin_email;
  END IF;

END $$;

