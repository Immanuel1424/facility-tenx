-- ============================================================================
-- UPDATE ADMIN EMAIL
-- ============================================================================
-- Updates the admin user email from admin@villa-maintenance.com 
-- to vivek.ellappan@helixsense.com
-- ============================================================================

BEGIN;

-- Check if new email already exists and handle accordingly
DO $$
DECLARE
  old_user_id UUID;
  new_user_id UUID;
  old_user_has_admin BOOLEAN;
  new_user_has_admin BOOLEAN;
  updated_count INTEGER;
BEGIN
  -- Find user with old email
  SELECT id INTO old_user_id
  FROM users
  WHERE email = 'admin@villa-maintenance.com'
    AND company_id = 'eb75a65b-055f-4408-a58c-71d233443c17';
  
  -- Find user with new email
  SELECT id INTO new_user_id
  FROM users
  WHERE email = 'vivek.ellappan@helixsense.com'
    AND company_id = 'eb75a65b-055f-4408-a58c-71d233443c17';
  
  -- Check if old user has ADMIN role
  IF old_user_id IS NOT NULL THEN
    SELECT EXISTS(
      SELECT 1 FROM user_roles ur
      JOIN roles r ON ur.role_id = r.id
      WHERE ur.user_id = old_user_id
        AND ur.company_id = 'eb75a65b-055f-4408-a58c-71d233443c17'
        AND r.name = 'ADMIN'
    ) INTO old_user_has_admin;
  END IF;
  
  -- Check if new user has ADMIN role
  IF new_user_id IS NOT NULL THEN
    SELECT EXISTS(
      SELECT 1 FROM user_roles ur
      JOIN roles r ON ur.role_id = r.id
      WHERE ur.user_id = new_user_id
        AND ur.company_id = 'eb75a65b-055f-4408-a58c-71d233443c17'
        AND r.name = 'ADMIN'
    ) INTO new_user_has_admin;
  END IF;
  
  -- If both exist and are different users
  IF old_user_id IS NOT NULL AND new_user_id IS NOT NULL AND old_user_id != new_user_id THEN
    -- If old user has admin role but new user doesn't, transfer admin role
    IF old_user_has_admin AND NOT new_user_has_admin THEN
      -- Get admin role ID
      DECLARE
        admin_role_id UUID;
      BEGIN
        SELECT id INTO admin_role_id
        FROM roles
        WHERE company_id = 'eb75a65b-055f-4408-a58c-71d233443c17'
          AND name = 'ADMIN';
        
        -- Remove admin role from old user
        DELETE FROM user_roles
        WHERE user_id = old_user_id
          AND role_id = admin_role_id
          AND company_id = 'eb75a65b-055f-4408-a58c-71d233443c17';
        
        -- Add admin role to new user
        INSERT INTO user_roles (id, company_id, user_id, role_id, created_at, updated_at)
        SELECT gen_random_uuid(), 'eb75a65b-055f-4408-a58c-71d233443c17', new_user_id, admin_role_id, now(), now()
        ON CONFLICT DO NOTHING;
        
        -- Update new user name
        UPDATE users 
        SET "firstName" = 'Vivek', "lastName" = 'Ellappan'
        WHERE id = new_user_id;
        
        -- Mark old user as deleted (soft delete)
        UPDATE users SET deleted_at = now() WHERE id = old_user_id;
        
        RAISE NOTICE '✅ Transferred ADMIN role from old user to new user. Old user soft-deleted.';
      END;
    ELSE
      -- Just update new user name and soft-delete old user
      UPDATE users 
      SET "firstName" = 'Vivek', "lastName" = 'Ellappan'
      WHERE id = new_user_id;
      
      UPDATE users SET deleted_at = now() WHERE id = old_user_id;
      RAISE NOTICE '✅ Updated new user name. Old user soft-deleted.';
    END IF;
  
  -- If only old user exists, update it
  ELSIF old_user_id IS NOT NULL AND new_user_id IS NULL THEN
    UPDATE users 
    SET 
      email = 'vivek.ellappan@helixsense.com',
      "firstName" = 'Vivek',
      "lastName" = 'Ellappan'
    WHERE id = old_user_id;
    
    RAISE NOTICE '✅ Updated admin user email to vivek.ellappan@helixsense.com';
  
  -- If only new user exists, just update name if needed
  ELSIF old_user_id IS NULL AND new_user_id IS NOT NULL THEN
    UPDATE users 
    SET 
      "firstName" = 'Vivek',
      "lastName" = 'Ellappan'
    WHERE id = new_user_id
      AND ("firstName" IS NULL OR "firstName" != 'Vivek' OR "lastName" IS NULL OR "lastName" != 'Ellappan');
    
    RAISE NOTICE '✅ Admin user with new email already exists. Updated name if needed.';
  
  -- If neither exists
  ELSE
    RAISE NOTICE 'ℹ️  No admin user found. Run seed script to create admin user.';
  END IF;
END $$;

COMMIT;

-- Verification query (run separately if needed)
-- SELECT email, first_name, last_name, status 
-- FROM users 
-- WHERE email = 'vivek.ellappan@helixsense.com' 
--   AND company_id = 'eb75a65b-055f-4408-a58c-71d233443c17';

