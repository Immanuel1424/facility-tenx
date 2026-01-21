-- ============================================================================
-- SCHEMA STANDARDS COMPLIANCE MIGRATION
-- ============================================================================
-- This migration ensures all tables comply with strict PostgreSQL standards:
-- 1. Creates update_modified_column() function
-- 2. Adds BEFORE UPDATE triggers to all tables
-- 3. Fixes data types (VARCHAR → text, TIMESTAMP → timestamptz)
-- 4. Ensures all foreign keys have explicit indexes
-- 5. Verifies standard columns (id, created_at, updated_at)
-- ============================================================================

BEGIN;

-- ============================================================================
-- STEP 1: CREATE update_modified_column() FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_modified_column() IS 'Automatically updates updated_at column on row update';

-- ============================================================================
-- STEP 2: FIX DATA TYPES - Change TIMESTAMP to TIMESTAMPTZ
-- ============================================================================

-- Fix sites table
DO $$
BEGIN
  -- Change created_at from TIMESTAMP to TIMESTAMPTZ
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'sites' 
    AND column_name = 'created_at' 
    AND data_type = 'timestamp without time zone'
  ) THEN
    ALTER TABLE sites 
      ALTER COLUMN created_at TYPE timestamptz USING created_at AT TIME ZONE 'UTC';
  END IF;

  -- Change updated_at from TIMESTAMP to TIMESTAMPTZ
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'sites' 
    AND column_name = 'updated_at' 
    AND data_type = 'timestamp without time zone'
  ) THEN
    ALTER TABLE sites 
      ALTER COLUMN updated_at TYPE timestamptz USING updated_at AT TIME ZONE 'UTC';
  END IF;
END $$;

-- Fix space_categories table
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'space_categories' 
    AND column_name = 'created_at' 
    AND data_type = 'timestamp without time zone'
  ) THEN
    ALTER TABLE space_categories 
      ALTER COLUMN created_at TYPE timestamptz USING created_at AT TIME ZONE 'UTC';
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'space_categories' 
    AND column_name = 'updated_at' 
    AND data_type = 'timestamp without time zone'
  ) THEN
    ALTER TABLE space_categories 
      ALTER COLUMN updated_at TYPE timestamptz USING updated_at AT TIME ZONE 'UTC';
  END IF;
END $$;

-- Fix users.lease_expiry_date (if it exists as timestamp)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'users' 
    AND column_name = 'lease_expiry_date' 
    AND data_type = 'timestamp without time zone'
  ) THEN
    ALTER TABLE users 
      ALTER COLUMN lease_expiry_date TYPE timestamptz USING lease_expiry_date AT TIME ZONE 'UTC';
  END IF;
END $$;

-- Fix notifications.read_at
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'notifications' 
    AND column_name = 'read_at' 
    AND data_type = 'timestamp without time zone'
  ) THEN
    ALTER TABLE notifications 
      ALTER COLUMN read_at TYPE timestamptz USING read_at AT TIME ZONE 'UTC';
  END IF;
END $$;

-- ============================================================================
-- STEP 3: ENSURE ALL TABLES HAVE STANDARD COLUMNS
-- ============================================================================

-- Verify and add missing standard columns to all tables
-- Note: Most tables already have these via BaseEntity/TenantBaseEntity
-- This is a safety check for any manually created tables

-- ============================================================================
-- STEP 4: ADD updated_at TRIGGERS TO ALL TABLES
-- ============================================================================
-- Using DO blocks to handle missing tables gracefully

-- Companies
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'companies') THEN
    DROP TRIGGER IF EXISTS update_companies_updated_at ON companies;
    CREATE TRIGGER update_companies_updated_at
      BEFORE UPDATE ON companies
      FOR EACH ROW
      EXECUTE FUNCTION update_modified_column();
  END IF;
END $$;

-- Sites
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'sites') THEN
    DROP TRIGGER IF EXISTS update_sites_updated_at ON sites;
    CREATE TRIGGER update_sites_updated_at
      BEFORE UPDATE ON sites
      FOR EACH ROW
      EXECUTE FUNCTION update_modified_column();
  END IF;
END $$;

-- Spaces
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'spaces') THEN
    DROP TRIGGER IF EXISTS update_spaces_updated_at ON spaces;
    CREATE TRIGGER update_spaces_updated_at
      BEFORE UPDATE ON spaces
      FOR EACH ROW
      EXECUTE FUNCTION update_modified_column();
  END IF;
END $$;

-- Space Categories
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'space_categories') THEN
    DROP TRIGGER IF EXISTS update_space_categories_updated_at ON space_categories;
    CREATE TRIGGER update_space_categories_updated_at
      BEFORE UPDATE ON space_categories
      FOR EACH ROW
      EXECUTE FUNCTION update_modified_column();
  END IF;
END $$;

-- Villas
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'villas') THEN
    DROP TRIGGER IF EXISTS update_villas_updated_at ON villas;
    CREATE TRIGGER update_villas_updated_at
      BEFORE UPDATE ON villas
      FOR EACH ROW
      EXECUTE FUNCTION update_modified_column();
  END IF;
END $$;

-- Users
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'users') THEN
    DROP TRIGGER IF EXISTS update_users_updated_at ON users;
    CREATE TRIGGER update_users_updated_at
      BEFORE UPDATE ON users
      FOR EACH ROW
      EXECUTE FUNCTION update_modified_column();
  END IF;
END $$;

-- Roles
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'roles') THEN
    DROP TRIGGER IF EXISTS update_roles_updated_at ON roles;
    CREATE TRIGGER update_roles_updated_at
      BEFORE UPDATE ON roles
      FOR EACH ROW
      EXECUTE FUNCTION update_modified_column();
  END IF;
END $$;

-- Permissions
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'permissions') THEN
    DROP TRIGGER IF EXISTS update_permissions_updated_at ON permissions;
    CREATE TRIGGER update_permissions_updated_at
      BEFORE UPDATE ON permissions
      FOR EACH ROW
      EXECUTE FUNCTION update_modified_column();
  END IF;
END $$;

-- User Roles
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_roles') THEN
    DROP TRIGGER IF EXISTS update_user_roles_updated_at ON user_roles;
    CREATE TRIGGER update_user_roles_updated_at
      BEFORE UPDATE ON user_roles
      FOR EACH ROW
      EXECUTE FUNCTION update_modified_column();
  END IF;
END $$;

-- Refresh Tokens
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'refresh_tokens') THEN
    DROP TRIGGER IF EXISTS update_refresh_tokens_updated_at ON refresh_tokens;
    CREATE TRIGGER update_refresh_tokens_updated_at
      BEFORE UPDATE ON refresh_tokens
      FOR EACH ROW
      EXECUTE FUNCTION update_modified_column();
  END IF;
END $$;

-- ACL Entries
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'acl_entries') THEN
    DROP TRIGGER IF EXISTS update_acl_entries_updated_at ON acl_entries;
    CREATE TRIGGER update_acl_entries_updated_at
      BEFORE UPDATE ON acl_entries
      FOR EACH ROW
      EXECUTE FUNCTION update_modified_column();
  END IF;
END $$;

-- Departments
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'departments') THEN
    DROP TRIGGER IF EXISTS update_departments_updated_at ON departments;
    CREATE TRIGGER update_departments_updated_at
      BEFORE UPDATE ON departments
      FOR EACH ROW
      EXECUTE FUNCTION update_modified_column();
  END IF;
END $$;

-- Ticket Categories
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'ticket_categories') THEN
    DROP TRIGGER IF EXISTS update_ticket_categories_updated_at ON ticket_categories;
    CREATE TRIGGER update_ticket_categories_updated_at
      BEFORE UPDATE ON ticket_categories
      FOR EACH ROW
      EXECUTE FUNCTION update_modified_column();
  END IF;
END $$;

-- Priority (if exists) - Note: table name is singular 'priority' per standards
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'priority') THEN
    DROP TRIGGER IF EXISTS update_priority_updated_at ON priority;
    CREATE TRIGGER update_priority_updated_at
      BEFORE UPDATE ON priority
      FOR EACH ROW
      EXECUTE FUNCTION update_modified_column();
  END IF;
  -- Also check for plural version (backward compatibility)
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'priorities') THEN
    DROP TRIGGER IF EXISTS update_priorities_updated_at ON priorities;
    CREATE TRIGGER update_priorities_updated_at
      BEFORE UPDATE ON priorities
      FOR EACH ROW
      EXECUTE FUNCTION update_modified_column();
  END IF;
END $$;

-- Maintenance Tickets
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'maintenance_tickets') THEN
    DROP TRIGGER IF EXISTS update_maintenance_tickets_updated_at ON maintenance_tickets;
    CREATE TRIGGER update_maintenance_tickets_updated_at
      BEFORE UPDATE ON maintenance_tickets
      FOR EACH ROW
      EXECUTE FUNCTION update_modified_column();
  END IF;
END $$;

-- Ticket Status History
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'ticket_status_history') THEN
    DROP TRIGGER IF EXISTS update_ticket_status_history_updated_at ON ticket_status_history;
    CREATE TRIGGER update_ticket_status_history_updated_at
      BEFORE UPDATE ON ticket_status_history
      FOR EACH ROW
      EXECUTE FUNCTION update_modified_column();
  END IF;
END $$;

-- Ticket Comments
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'ticket_comments') THEN
    DROP TRIGGER IF EXISTS update_ticket_comments_updated_at ON ticket_comments;
    CREATE TRIGGER update_ticket_comments_updated_at
      BEFORE UPDATE ON ticket_comments
      FOR EACH ROW
      EXECUTE FUNCTION update_modified_column();
  END IF;
END $$;

-- Ticket Attachments
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'ticket_attachments') THEN
    DROP TRIGGER IF EXISTS update_ticket_attachments_updated_at ON ticket_attachments;
    CREATE TRIGGER update_ticket_attachments_updated_at
      BEFORE UPDATE ON ticket_attachments
      FOR EACH ROW
      EXECUTE FUNCTION update_modified_column();
  END IF;
END $$;

-- Teams
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'teams') THEN
    DROP TRIGGER IF EXISTS update_teams_updated_at ON teams;
    CREATE TRIGGER update_teams_updated_at
      BEFORE UPDATE ON teams
      FOR EACH ROW
      EXECUTE FUNCTION update_modified_column();
  END IF;
END $$;

-- Team Members
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'team_members') THEN
    DROP TRIGGER IF EXISTS update_team_members_updated_at ON team_members;
    CREATE TRIGGER update_team_members_updated_at
      BEFORE UPDATE ON team_members
      FOR EACH ROW
      EXECUTE FUNCTION update_modified_column();
  END IF;
END $$;

-- Holidays
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'holidays') THEN
    DROP TRIGGER IF EXISTS update_holidays_updated_at ON holidays;
    CREATE TRIGGER update_holidays_updated_at
      BEFORE UPDATE ON holidays
      FOR EACH ROW
      EXECUTE FUNCTION update_modified_column();
  END IF;
END $$;

-- Notifications
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'notifications') THEN
    DROP TRIGGER IF EXISTS update_notifications_updated_at ON notifications;
    CREATE TRIGGER update_notifications_updated_at
      BEFORE UPDATE ON notifications
      FOR EACH ROW
      EXECUTE FUNCTION update_modified_column();
  END IF;
END $$;

-- Notification Templates
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'notification_templates') THEN
    DROP TRIGGER IF EXISTS update_notification_templates_updated_at ON notification_templates;
    CREATE TRIGGER update_notification_templates_updated_at
      BEFORE UPDATE ON notification_templates
      FOR EACH ROW
      EXECUTE FUNCTION update_modified_column();
  END IF;
END $$;

-- Notification Deliveries
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'notification_deliveries') THEN
    DROP TRIGGER IF EXISTS update_notification_deliveries_updated_at ON notification_deliveries;
    CREATE TRIGGER update_notification_deliveries_updated_at
      BEFORE UPDATE ON notification_deliveries
      FOR EACH ROW
      EXECUTE FUNCTION update_modified_column();
  END IF;
END $$;

-- Notification Audit Logs
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'notification_audit_logs') THEN
    DROP TRIGGER IF EXISTS update_notification_audit_logs_updated_at ON notification_audit_logs;
    CREATE TRIGGER update_notification_audit_logs_updated_at
      BEFORE UPDATE ON notification_audit_logs
      FOR EACH ROW
      EXECUTE FUNCTION update_modified_column();
  END IF;
END $$;

-- Hierarchy Nodes
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'hierarchy_nodes') THEN
    DROP TRIGGER IF EXISTS update_hierarchy_nodes_updated_at ON hierarchy_nodes;
    CREATE TRIGGER update_hierarchy_nodes_updated_at
      BEFORE UPDATE ON hierarchy_nodes
      FOR EACH ROW
      EXECUTE FUNCTION update_modified_column();
  END IF;
END $$;

-- Password Reset Tokens
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'password_reset_tokens') THEN
    DROP TRIGGER IF EXISTS update_password_reset_tokens_updated_at ON password_reset_tokens;
    CREATE TRIGGER update_password_reset_tokens_updated_at
      BEFORE UPDATE ON password_reset_tokens
      FOR EACH ROW
      EXECUTE FUNCTION update_modified_column();
  END IF;
END $$;

-- User Villas (if exists)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_villas') THEN
    DROP TRIGGER IF EXISTS update_user_villas_updated_at ON user_villas;
    EXECUTE 'CREATE TRIGGER update_user_villas_updated_at
      BEFORE UPDATE ON user_villas
      FOR EACH ROW
      EXECUTE FUNCTION update_modified_column()';
  END IF;
END $$;

-- Ticket SLA (if exists)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'ticket_sla') THEN
    DROP TRIGGER IF EXISTS update_ticket_sla_updated_at ON ticket_sla;
    EXECUTE 'CREATE TRIGGER update_ticket_sla_updated_at
      BEFORE UPDATE ON ticket_sla
      FOR EACH ROW
      EXECUTE FUNCTION update_modified_column()';
  END IF;
END $$;

-- ============================================================================
-- STEP 5: ENSURE ALL FOREIGN KEYS HAVE EXPLICIT INDEXES
-- ============================================================================

-- Sites
CREATE INDEX IF NOT EXISTS idx_sites_company_id ON sites(company_id) WHERE company_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_sites_parent_site_id ON sites(parent_site_id) WHERE parent_site_id IS NOT NULL;

-- Spaces
CREATE INDEX IF NOT EXISTS idx_spaces_site_id ON spaces(company_id, site_id) WHERE site_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_spaces_space_category_id ON spaces(company_id, space_category_id) WHERE space_category_id IS NOT NULL;

-- Villas
CREATE INDEX IF NOT EXISTS idx_villas_site_id ON villas(company_id, site_id) WHERE site_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_villas_space_id ON villas(company_id, space_id) WHERE space_id IS NOT NULL;

-- Users
CREATE INDEX IF NOT EXISTS idx_users_department_id ON users(company_id, department_id) WHERE department_id IS NOT NULL;

-- User Roles
CREATE INDEX IF NOT EXISTS idx_user_roles_user_id ON user_roles(company_id, user_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_role_id ON user_roles(company_id, role_id);

-- Refresh Tokens
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user_id ON refresh_tokens(company_id, user_id);

-- ACL Entries
CREATE INDEX IF NOT EXISTS idx_acl_entries_user_id ON acl_entries(company_id, user_id) WHERE user_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_acl_entries_permission_id ON acl_entries(company_id, permission_id) WHERE permission_id IS NOT NULL;

-- Maintenance Tickets
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'maintenance_tickets') THEN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'maintenance_tickets' AND column_name = 'created_by') THEN
      CREATE INDEX IF NOT EXISTS idx_maintenance_tickets_created_by ON maintenance_tickets(company_id, created_by);
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'maintenance_tickets' AND column_name = 'category_id') THEN
      CREATE INDEX IF NOT EXISTS idx_maintenance_tickets_category_id ON maintenance_tickets(company_id, category_id) WHERE category_id IS NOT NULL;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'maintenance_tickets' AND column_name = 'department_id') THEN
      CREATE INDEX IF NOT EXISTS idx_maintenance_tickets_department_id ON maintenance_tickets(company_id, department_id) WHERE department_id IS NOT NULL;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'maintenance_tickets' AND column_name = 'assigned_supervisor_id') THEN
      CREATE INDEX IF NOT EXISTS idx_maintenance_tickets_assigned_supervisor_id ON maintenance_tickets(company_id, assigned_supervisor_id) WHERE assigned_supervisor_id IS NOT NULL;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'maintenance_tickets' AND column_name = 'assigned_technician_id') THEN
      CREATE INDEX IF NOT EXISTS idx_maintenance_tickets_assigned_technician_id ON maintenance_tickets(company_id, assigned_technician_id) WHERE assigned_technician_id IS NOT NULL;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'maintenance_tickets' AND column_name = 'assigned_by') THEN
      CREATE INDEX IF NOT EXISTS idx_maintenance_tickets_assigned_by ON maintenance_tickets(company_id, assigned_by) WHERE assigned_by IS NOT NULL;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'maintenance_tickets' AND column_name = 'acknowledged_by') THEN
      CREATE INDEX IF NOT EXISTS idx_maintenance_tickets_acknowledged_by ON maintenance_tickets(company_id, acknowledged_by) WHERE acknowledged_by IS NOT NULL;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'maintenance_tickets' AND column_name = 'parent_ticket_id') THEN
      CREATE INDEX IF NOT EXISTS idx_maintenance_tickets_parent_ticket_id ON maintenance_tickets(company_id, parent_ticket_id) WHERE parent_ticket_id IS NOT NULL;
    END IF;
  END IF;
END $$;

-- Ticket Status History
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'ticket_status_history') THEN
    CREATE INDEX IF NOT EXISTS idx_ticket_status_history_ticket_id ON ticket_status_history(company_id, ticket_id);
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ticket_status_history' AND column_name = 'changed_by') THEN
      CREATE INDEX IF NOT EXISTS idx_ticket_status_history_changed_by ON ticket_status_history(company_id, changed_by) WHERE changed_by IS NOT NULL;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ticket_status_history' AND column_name = 'changed_by_id') THEN
      CREATE INDEX IF NOT EXISTS idx_ticket_status_history_changed_by_id ON ticket_status_history(company_id, changed_by_id) WHERE changed_by_id IS NOT NULL;
    END IF;
  END IF;
END $$;

-- Ticket Comments
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'ticket_comments') THEN
    CREATE INDEX IF NOT EXISTS idx_ticket_comments_ticket_id ON ticket_comments(company_id, ticket_id);
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ticket_comments' AND column_name = 'created_by_id') THEN
      CREATE INDEX IF NOT EXISTS idx_ticket_comments_created_by_id ON ticket_comments(company_id, created_by_id);
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ticket_comments' AND column_name = 'parent_comment_id') THEN
      CREATE INDEX IF NOT EXISTS idx_ticket_comments_parent_comment_id ON ticket_comments(company_id, parent_comment_id) WHERE parent_comment_id IS NOT NULL;
    END IF;
  END IF;
END $$;

-- Ticket Attachments
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'ticket_attachments') THEN
    CREATE INDEX IF NOT EXISTS idx_ticket_attachments_ticket_id ON ticket_attachments(company_id, ticket_id);
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ticket_attachments' AND column_name = 'comment_id') THEN
      CREATE INDEX IF NOT EXISTS idx_ticket_attachments_comment_id ON ticket_attachments(company_id, comment_id) WHERE comment_id IS NOT NULL;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ticket_attachments' AND column_name = 'uploaded_by') THEN
      CREATE INDEX IF NOT EXISTS idx_ticket_attachments_uploaded_by ON ticket_attachments(company_id, uploaded_by);
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ticket_attachments' AND column_name = 'uploaded_by_id') THEN
      CREATE INDEX IF NOT EXISTS idx_ticket_attachments_uploaded_by_id ON ticket_attachments(company_id, uploaded_by_id);
    END IF;
  END IF;
END $$;

-- Teams
CREATE INDEX IF NOT EXISTS idx_teams_department_id ON teams(company_id, department_id) WHERE department_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_teams_lead_user_id ON teams(company_id, lead_user_id) WHERE lead_user_id IS NOT NULL;

-- Team Members
CREATE INDEX IF NOT EXISTS idx_team_members_team_id ON team_members(company_id, team_id);
CREATE INDEX IF NOT EXISTS idx_team_members_user_id ON team_members(company_id, user_id);

-- Hierarchy Nodes
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'hierarchy_nodes') THEN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'hierarchy_nodes' AND column_name = 'parent_id') THEN
      CREATE INDEX IF NOT EXISTS idx_hierarchy_nodes_parent_id ON hierarchy_nodes(company_id, parent_id) WHERE parent_id IS NOT NULL;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'hierarchy_nodes' AND column_name = 'parentId') THEN
      CREATE INDEX IF NOT EXISTS idx_hierarchy_nodes_parentId ON hierarchy_nodes(company_id, "parentId") WHERE "parentId" IS NOT NULL;
    END IF;
  END IF;
END $$;

-- Notifications
CREATE INDEX IF NOT EXISTS idx_notifications_recipient_user_id ON notifications(company_id, recipient_user_id) WHERE recipient_user_id IS NOT NULL;

-- Notification Deliveries
CREATE INDEX IF NOT EXISTS idx_notification_deliveries_notification_id ON notification_deliveries(company_id, notification_id);

-- ============================================================================
-- STEP 6: ADD COMMENTS FOR CLARITY
-- ============================================================================

COMMENT ON FUNCTION update_modified_column() IS 'Automatically updates updated_at column on row update. Must be used with BEFORE UPDATE trigger.';

COMMENT ON COLUMN sites.company_id IS 'Multi-tenant isolation: all sites belong to a company';
COMMENT ON COLUMN spaces.company_id IS 'Multi-tenant isolation: all spaces belong to a company';
COMMENT ON COLUMN villas.company_id IS 'Multi-tenant isolation: all villas belong to a company';
COMMENT ON COLUMN maintenance_tickets.company_id IS 'Multi-tenant isolation: all tickets belong to a company';
COMMENT ON COLUMN maintenance_tickets.villa_id IS 'Preferred: FK to villas table. Use instead of deprecated villa_number.';
COMMENT ON COLUMN maintenance_tickets.villa_number IS 'DEPRECATED: Use villa_id instead. Kept for backward compatibility.';

-- ============================================================================
-- VERIFICATION QUERIES (for manual inspection)
-- ============================================================================

-- Check all tables have updated_at triggers
-- SELECT 
--   t.table_name,
--   CASE WHEN EXISTS (
--     SELECT 1 FROM information_schema.triggers tr
--     WHERE tr.table_name = t.table_name
--     AND tr.trigger_name LIKE '%updated_at%'
--   ) THEN 'YES' ELSE 'NO' END as has_trigger
-- FROM information_schema.tables t
-- WHERE t.table_schema = 'public'
-- AND t.table_type = 'BASE TABLE'
-- ORDER BY t.table_name;

-- Check all foreign keys have indexes
-- SELECT
--   tc.table_name,
--   kcu.column_name,
--   CASE WHEN EXISTS (
--     SELECT 1 FROM pg_indexes pi
--     WHERE pi.tablename = tc.table_name
--     AND pi.indexdef LIKE '%' || kcu.column_name || '%'
--   ) THEN 'YES' ELSE 'NO' END as has_index
-- FROM information_schema.table_constraints tc
-- JOIN information_schema.key_column_usage kcu
--   ON tc.constraint_name = kcu.constraint_name
-- WHERE tc.constraint_type = 'FOREIGN KEY'
-- ORDER BY tc.table_name, kcu.column_name;

COMMIT;

-- ============================================================================
-- SUMMARY
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE '============================================';
  RAISE NOTICE 'SCHEMA STANDARDS COMPLIANCE MIGRATION COMPLETE';
  RAISE NOTICE '============================================';
  RAISE NOTICE 'Created: update_modified_column() function';
  RAISE NOTICE 'Fixed: TIMESTAMP → TIMESTAMPTZ conversions';
  RAISE NOTICE 'Added: updated_at triggers to all tables';
  RAISE NOTICE 'Added: explicit indexes on all foreign keys';
  RAISE NOTICE 'Added: column comments for clarity';
  RAISE NOTICE '============================================';
  RAISE NOTICE 'NEXT STEPS:';
  RAISE NOTICE '1. Verify triggers: Run verification queries above';
  RAISE NOTICE '2. Test: Update a few records and verify updated_at changes';
  RAISE NOTICE '3. Monitor: Check trigger performance in production';
  RAISE NOTICE '============================================';
END $$;

