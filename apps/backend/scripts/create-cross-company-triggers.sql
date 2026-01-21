-- =====================================================
-- Cross-Company Data Integrity Triggers
-- Prevents cross-company data access at database level
-- =====================================================

-- Drop existing triggers if they exist
DROP TRIGGER IF EXISTS trg_maintenance_ticket_company_check ON maintenance_tickets;
DROP TRIGGER IF EXISTS trg_ticket_comment_company_check ON ticket_comments;
DROP TRIGGER IF EXISTS trg_ticket_attachment_company_check ON ticket_attachments;
DROP TRIGGER IF EXISTS trg_ticket_status_history_company_check ON ticket_status_history;
DROP TRIGGER IF EXISTS trg_ticket_sla_company_check ON ticket_sla;

-- Drop existing functions if they exist
DROP FUNCTION IF EXISTS fn_check_ticket_company_integrity();
DROP FUNCTION IF EXISTS fn_check_comment_company_integrity();
DROP FUNCTION IF EXISTS fn_check_attachment_company_integrity();
DROP FUNCTION IF EXISTS fn_check_status_history_company_integrity();
DROP FUNCTION IF EXISTS fn_check_ticket_sla_company_integrity();

-- =====================================================
-- 1. Maintenance Tickets Trigger
-- =====================================================
CREATE OR REPLACE FUNCTION fn_check_ticket_company_integrity()
RETURNS TRIGGER AS $$
DECLARE
  v_user_company_id UUID;
  v_dept_company_id UUID;
  v_cat_company_id UUID;
BEGIN
  -- Check created_by user belongs to same company
  IF NEW.created_by IS NOT NULL THEN
    SELECT company_id INTO v_user_company_id FROM users WHERE id = NEW.created_by;
    IF v_user_company_id IS NULL OR v_user_company_id != NEW.company_id THEN
      RAISE EXCEPTION 'Cross-company violation: created_by user does not belong to ticket company'
        USING ERRCODE = '23503';
    END IF;
  END IF;

  -- Check department belongs to same company
  IF NEW.department_id IS NOT NULL THEN
    SELECT company_id INTO v_dept_company_id FROM departments WHERE id = NEW.department_id;
    IF v_dept_company_id IS NULL OR v_dept_company_id != NEW.company_id THEN
      RAISE EXCEPTION 'Cross-company violation: department does not belong to ticket company'
        USING ERRCODE = '23503';
    END IF;
  END IF;

  -- Check category belongs to same company
  IF NEW.category_id IS NOT NULL THEN
    SELECT company_id INTO v_cat_company_id FROM ticket_categories WHERE id = NEW.category_id;
    IF v_cat_company_id IS NULL OR v_cat_company_id != NEW.company_id THEN
      RAISE EXCEPTION 'Cross-company violation: category does not belong to ticket company'
        USING ERRCODE = '23503';
    END IF;
  END IF;

  -- Check assigned_technician belongs to same company
  IF NEW.assigned_technician_id IS NOT NULL THEN
    SELECT company_id INTO v_user_company_id FROM users WHERE id = NEW.assigned_technician_id;
    IF v_user_company_id IS NULL OR v_user_company_id != NEW.company_id THEN
      RAISE EXCEPTION 'Cross-company violation: assigned_technician does not belong to ticket company'
        USING ERRCODE = '23503';
    END IF;
  END IF;

  -- Check assigned_supervisor belongs to same company
  IF NEW.assigned_supervisor_id IS NOT NULL THEN
    SELECT company_id INTO v_user_company_id FROM users WHERE id = NEW.assigned_supervisor_id;
    IF v_user_company_id IS NULL OR v_user_company_id != NEW.company_id THEN
      RAISE EXCEPTION 'Cross-company violation: assigned_supervisor does not belong to ticket company'
        USING ERRCODE = '23503';
    END IF;
  END IF;

  -- Check assigned_by belongs to same company
  IF NEW.assigned_by IS NOT NULL THEN
    SELECT company_id INTO v_user_company_id FROM users WHERE id = NEW.assigned_by;
    IF v_user_company_id IS NULL OR v_user_company_id != NEW.company_id THEN
      RAISE EXCEPTION 'Cross-company violation: assigned_by user does not belong to ticket company'
        USING ERRCODE = '23503';
    END IF;
  END IF;

  -- Check acknowledged_by belongs to same company
  IF NEW.acknowledged_by IS NOT NULL THEN
    SELECT company_id INTO v_user_company_id FROM users WHERE id = NEW.acknowledged_by;
    IF v_user_company_id IS NULL OR v_user_company_id != NEW.company_id THEN
      RAISE EXCEPTION 'Cross-company violation: acknowledged_by user does not belong to ticket company'
        USING ERRCODE = '23503';
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_maintenance_ticket_company_check
  BEFORE INSERT OR UPDATE ON maintenance_tickets
  FOR EACH ROW
  EXECUTE FUNCTION fn_check_ticket_company_integrity();

-- =====================================================
-- 2. Ticket Comments Trigger
-- =====================================================
CREATE OR REPLACE FUNCTION fn_check_comment_company_integrity()
RETURNS TRIGGER AS $$
DECLARE
  v_ticket_company_id UUID;
  v_user_company_id UUID;
BEGIN
  -- Check ticket belongs to same company
  SELECT company_id INTO v_ticket_company_id FROM maintenance_tickets WHERE id = NEW.ticket_id;
  IF v_ticket_company_id IS NULL OR v_ticket_company_id != NEW.company_id THEN
    RAISE EXCEPTION 'Cross-company violation: ticket does not belong to comment company'
      USING ERRCODE = '23503';
  END IF;

  -- Check created_by user belongs to same company (if not null - system comments may not have a user)
  IF NEW.created_by_id IS NOT NULL THEN
    SELECT company_id INTO v_user_company_id FROM users WHERE id = NEW.created_by_id;
    IF v_user_company_id IS NULL OR v_user_company_id != NEW.company_id THEN
      RAISE EXCEPTION 'Cross-company violation: comment creator does not belong to comment company'
        USING ERRCODE = '23503';
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_ticket_comment_company_check
  BEFORE INSERT OR UPDATE ON ticket_comments
  FOR EACH ROW
  EXECUTE FUNCTION fn_check_comment_company_integrity();

-- =====================================================
-- 3. Ticket Attachments Trigger
-- =====================================================
CREATE OR REPLACE FUNCTION fn_check_attachment_company_integrity()
RETURNS TRIGGER AS $$
DECLARE
  v_ticket_company_id UUID;
  v_user_company_id UUID;
BEGIN
  -- Check ticket belongs to same company
  SELECT company_id INTO v_ticket_company_id FROM maintenance_tickets WHERE id = NEW.ticket_id;
  IF v_ticket_company_id IS NULL OR v_ticket_company_id != NEW.company_id THEN
    RAISE EXCEPTION 'Cross-company violation: ticket does not belong to attachment company'
      USING ERRCODE = '23503';
  END IF;

  -- Check uploaded_by user belongs to same company
  IF NEW.uploaded_by_id IS NOT NULL THEN
    SELECT company_id INTO v_user_company_id FROM users WHERE id = NEW.uploaded_by_id;
    IF v_user_company_id IS NULL OR v_user_company_id != NEW.company_id THEN
      RAISE EXCEPTION 'Cross-company violation: attachment uploader does not belong to attachment company'
        USING ERRCODE = '23503';
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_ticket_attachment_company_check
  BEFORE INSERT OR UPDATE ON ticket_attachments
  FOR EACH ROW
  EXECUTE FUNCTION fn_check_attachment_company_integrity();

-- =====================================================
-- 4. Ticket Status History Trigger
-- =====================================================
CREATE OR REPLACE FUNCTION fn_check_status_history_company_integrity()
RETURNS TRIGGER AS $$
DECLARE
  v_ticket_company_id UUID;
  v_user_company_id UUID;
BEGIN
  -- Check ticket belongs to same company
  SELECT company_id INTO v_ticket_company_id FROM maintenance_tickets WHERE id = NEW.ticket_id;
  IF v_ticket_company_id IS NULL OR v_ticket_company_id != NEW.company_id THEN
    RAISE EXCEPTION 'Cross-company violation: ticket does not belong to status history company'
      USING ERRCODE = '23503';
  END IF;

  -- Check changed_by user belongs to same company
  IF NEW.changed_by IS NOT NULL THEN
    SELECT company_id INTO v_user_company_id FROM users WHERE id = NEW.changed_by;
    IF v_user_company_id IS NULL OR v_user_company_id != NEW.company_id THEN
      RAISE EXCEPTION 'Cross-company violation: status changer does not belong to history company'
        USING ERRCODE = '23503';
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_ticket_status_history_company_check
  BEFORE INSERT OR UPDATE ON ticket_status_history
  FOR EACH ROW
  EXECUTE FUNCTION fn_check_status_history_company_integrity();

-- =====================================================
-- 5. Ticket SLA Trigger
-- =====================================================
CREATE OR REPLACE FUNCTION fn_check_ticket_sla_company_integrity()
RETURNS TRIGGER AS $$
DECLARE
  v_ticket_company_id UUID;
  v_sla_config_company_id UUID;
BEGIN
  -- Check ticket belongs to same company
  SELECT company_id INTO v_ticket_company_id FROM maintenance_tickets WHERE id = NEW.ticket_id;
  IF v_ticket_company_id IS NULL OR v_ticket_company_id != NEW.company_id THEN
    RAISE EXCEPTION 'Cross-company violation: ticket does not belong to SLA company'
      USING ERRCODE = '23503';
  END IF;

  -- Check SLA configuration belongs to same company
  IF NEW.sla_configuration_id IS NOT NULL THEN
    SELECT company_id INTO v_sla_config_company_id FROM sla_configurations WHERE id = NEW.sla_configuration_id;
    IF v_sla_config_company_id IS NULL OR v_sla_config_company_id != NEW.company_id THEN
      RAISE EXCEPTION 'Cross-company violation: SLA configuration does not belong to SLA company'
        USING ERRCODE = '23503';
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_ticket_sla_company_check
  BEFORE INSERT OR UPDATE ON ticket_sla
  FOR EACH ROW
  EXECUTE FUNCTION fn_check_ticket_sla_company_integrity();

-- =====================================================
-- Verify triggers are created
-- =====================================================
SELECT 
  tgname as trigger_name,
  tgrelid::regclass as table_name,
  tgenabled as enabled
FROM pg_trigger 
WHERE tgname LIKE 'trg_%company_check'
ORDER BY tgrelid::regclass::text;

COMMENT ON FUNCTION fn_check_ticket_company_integrity() IS 'Enforces cross-company data integrity for maintenance_tickets';
COMMENT ON FUNCTION fn_check_comment_company_integrity() IS 'Enforces cross-company data integrity for ticket_comments';
COMMENT ON FUNCTION fn_check_attachment_company_integrity() IS 'Enforces cross-company data integrity for ticket_attachments';
COMMENT ON FUNCTION fn_check_status_history_company_integrity() IS 'Enforces cross-company data integrity for ticket_status_history';
COMMENT ON FUNCTION fn_check_ticket_sla_company_integrity() IS 'Enforces cross-company data integrity for ticket_sla';

