-- SQL Migration: Add Company Scope Constraints
-- This script adds constraints and triggers to prevent cross-company data violations

-- 1. Function to validate company_id matches for foreign key relationships
CREATE OR REPLACE FUNCTION validate_company_scope()
RETURNS TRIGGER AS $$
BEGIN
  -- Validate maintenance_tickets.created_by belongs to same company
  IF TG_TABLE_NAME = 'maintenance_tickets' AND NEW.created_by IS NOT NULL THEN
    IF NOT EXISTS (
      SELECT 1 FROM users u 
      WHERE u.id = NEW.created_by 
      AND u.company_id = NEW.company_id
    ) THEN
      RAISE EXCEPTION 'Cross company is not allowed: created_by user does not belong to ticket company';
    END IF;
  END IF;

  -- Validate maintenance_tickets.department_id belongs to same company
  IF TG_TABLE_NAME = 'maintenance_tickets' AND NEW.department_id IS NOT NULL THEN
    IF NOT EXISTS (
      SELECT 1 FROM departments d 
      WHERE d.id = NEW.department_id 
      AND d.company_id = NEW.company_id
    ) THEN
      RAISE EXCEPTION 'Cross company is not allowed: department does not belong to ticket company';
    END IF;
  END IF;

  -- Validate maintenance_tickets.category_id belongs to same company
  IF TG_TABLE_NAME = 'maintenance_tickets' AND NEW.category_id IS NOT NULL THEN
    IF NOT EXISTS (
      SELECT 1 FROM ticket_categories c 
      WHERE c.id = NEW.category_id 
      AND c.company_id = NEW.company_id
    ) THEN
      RAISE EXCEPTION 'Cross company is not allowed: category does not belong to ticket company';
    END IF;
  END IF;

  -- Validate maintenance_tickets assigned users belong to same company
  IF TG_TABLE_NAME = 'maintenance_tickets' THEN
    IF NEW.assigned_technician_id IS NOT NULL AND NOT EXISTS (
      SELECT 1 FROM users u 
      WHERE u.id = NEW.assigned_technician_id 
      AND u.company_id = NEW.company_id
    ) THEN
      RAISE EXCEPTION 'Cross company is not allowed: assigned_technician does not belong to ticket company';
    END IF;

    IF NEW.assigned_supervisor_id IS NOT NULL AND NOT EXISTS (
      SELECT 1 FROM users u 
      WHERE u.id = NEW.assigned_supervisor_id 
      AND u.company_id = NEW.company_id
    ) THEN
      RAISE EXCEPTION 'Cross company is not allowed: assigned_supervisor does not belong to ticket company';
    END IF;

    IF NEW.assigned_by IS NOT NULL AND NOT EXISTS (
      SELECT 1 FROM users u 
      WHERE u.id = NEW.assigned_by 
      AND u.company_id = NEW.company_id
    ) THEN
      RAISE EXCEPTION 'Cross company is not allowed: assigned_by user does not belong to ticket company';
    END IF;

    IF NEW.acknowledged_by IS NOT NULL AND NOT EXISTS (
      SELECT 1 FROM users u 
      WHERE u.id = NEW.acknowledged_by 
      AND u.company_id = NEW.company_id
    ) THEN
      RAISE EXCEPTION 'Cross company is not allowed: acknowledged_by user does not belong to ticket company';
    END IF;
  END IF;

  -- Validate ticket_comments
  IF TG_TABLE_NAME = 'ticket_comments' THEN
    -- Validate comment belongs to ticket with same company_id
    IF NOT EXISTS (
      SELECT 1 FROM maintenance_tickets t 
      WHERE t.id = NEW.ticket_id 
      AND t.company_id = NEW.company_id
    ) THEN
      RAISE EXCEPTION 'Cross company is not allowed: ticket does not belong to comment company';
    END IF;

    -- Validate comment creator belongs to same company
    IF NOT EXISTS (
      SELECT 1 FROM users u 
      WHERE u.id = NEW.created_by_id 
      AND u.company_id = NEW.company_id
    ) THEN
      RAISE EXCEPTION 'Cross company is not allowed: comment creator does not belong to comment company';
    END IF;
  END IF;

  -- Validate ticket_attachments
  IF TG_TABLE_NAME = 'ticket_attachments' THEN
    -- Validate attachment belongs to ticket with same company_id
    IF NOT EXISTS (
      SELECT 1 FROM maintenance_tickets t 
      WHERE t.id = NEW.ticket_id 
      AND t.company_id = NEW.company_id
    ) THEN
      RAISE EXCEPTION 'Cross company is not allowed: ticket does not belong to attachment company';
    END IF;

    -- Validate attachment uploader belongs to same company
    IF NOT EXISTS (
      SELECT 1 FROM users u 
      WHERE u.id = NEW.uploaded_by_id 
      AND u.company_id = NEW.company_id
    ) THEN
      RAISE EXCEPTION 'Cross company is not allowed: attachment uploader does not belong to attachment company';
    END IF;
  END IF;

  -- Validate ticket_status_history
  IF TG_TABLE_NAME = 'ticket_status_history' THEN
    -- Validate history belongs to ticket with same company_id
    IF NOT EXISTS (
      SELECT 1 FROM maintenance_tickets t 
      WHERE t.id = NEW.ticket_id 
      AND t.company_id = NEW.company_id
    ) THEN
      RAISE EXCEPTION 'Cross company is not allowed: ticket does not belong to status history company';
    END IF;

    -- Validate history changer belongs to same company
    IF NEW.changed_by IS NOT NULL AND NOT EXISTS (
      SELECT 1 FROM users u 
      WHERE u.id = NEW.changed_by 
      AND u.company_id = NEW.company_id
    ) THEN
      RAISE EXCEPTION 'Cross company is not allowed: status history changer does not belong to history company';
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Create triggers for INSERT and UPDATE operations
DROP TRIGGER IF EXISTS trigger_validate_company_scope_maintenance_tickets ON maintenance_tickets;
CREATE TRIGGER trigger_validate_company_scope_maintenance_tickets
  BEFORE INSERT OR UPDATE ON maintenance_tickets
  FOR EACH ROW
  EXECUTE FUNCTION validate_company_scope();

DROP TRIGGER IF EXISTS trigger_validate_company_scope_ticket_comments ON ticket_comments;
CREATE TRIGGER trigger_validate_company_scope_ticket_comments
  BEFORE INSERT OR UPDATE ON ticket_comments
  FOR EACH ROW
  EXECUTE FUNCTION validate_company_scope();

DROP TRIGGER IF EXISTS trigger_validate_company_scope_ticket_attachments ON ticket_attachments;
CREATE TRIGGER trigger_validate_company_scope_ticket_attachments
  BEFORE INSERT OR UPDATE ON ticket_attachments
  FOR EACH ROW
  EXECUTE FUNCTION validate_company_scope();

DROP TRIGGER IF EXISTS trigger_validate_company_scope_ticket_status_history ON ticket_status_history;
CREATE TRIGGER trigger_validate_company_scope_ticket_status_history
  BEFORE INSERT OR UPDATE ON ticket_status_history
  FOR EACH ROW
  EXECUTE FUNCTION validate_company_scope();

-- 3. Add indexes for better query performance on company_id + foreign key combinations
CREATE INDEX IF NOT EXISTS idx_maintenance_tickets_company_created_by 
  ON maintenance_tickets(company_id, created_by) 
  WHERE created_by IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_maintenance_tickets_company_department 
  ON maintenance_tickets(company_id, department_id) 
  WHERE department_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_maintenance_tickets_company_category 
  ON maintenance_tickets(company_id, category_id) 
  WHERE category_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_ticket_comments_company_ticket 
  ON ticket_comments(company_id, ticket_id);

CREATE INDEX IF NOT EXISTS idx_ticket_comments_company_user 
  ON ticket_comments(company_id, created_by_id);

CREATE INDEX IF NOT EXISTS idx_ticket_attachments_company_ticket 
  ON ticket_attachments(company_id, ticket_id);

CREATE INDEX IF NOT EXISTS idx_ticket_attachments_company_user 
  ON ticket_attachments(company_id, uploaded_by_id);

CREATE INDEX IF NOT EXISTS idx_ticket_status_history_company_ticket 
  ON ticket_status_history(company_id, ticket_id);

-- 4. Add comments for documentation
COMMENT ON FUNCTION validate_company_scope() IS 
  'Validates that all foreign key relationships maintain company_id consistency to prevent cross-company data access';

COMMENT ON TRIGGER trigger_validate_company_scope_maintenance_tickets ON maintenance_tickets IS 
  'Ensures maintenance tickets and their related entities belong to the same company';

COMMENT ON TRIGGER trigger_validate_company_scope_ticket_comments ON ticket_comments IS 
  'Ensures ticket comments belong to tickets and users in the same company';

COMMENT ON TRIGGER trigger_validate_company_scope_ticket_attachments ON ticket_attachments IS 
  'Ensures ticket attachments belong to tickets and users in the same company';

COMMENT ON TRIGGER trigger_validate_company_scope_ticket_status_history ON ticket_status_history IS 
  'Ensures ticket status history belongs to tickets and users in the same company';

