-- ============================================================================
-- ESCALATION HISTORY: CREATE ESCALATION_HISTORY TABLE
-- ============================================================================
-- This migration creates the escalation_history table to track all escalations
-- (automatic and manual) for maintenance tickets.
-- ============================================================================

BEGIN;

-- Create escalation_history table
CREATE TABLE IF NOT EXISTS escalation_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL,
  ticket_id UUID NOT NULL REFERENCES maintenance_tickets(id) ON DELETE CASCADE,
  escalation_level INT NOT NULL CHECK (escalation_level >= 1 AND escalation_level <= 3),
  escalated_from_role VARCHAR(50),
  escalated_to_role VARCHAR(50),
  reason TEXT,
  escalated_by UUID REFERENCES users(id) ON DELETE SET NULL,
  escalated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  is_automatic BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT fk_escalation_history_company FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_escalation_history_company_ticket 
  ON escalation_history(company_id, ticket_id);
  
CREATE INDEX IF NOT EXISTS idx_escalation_history_company_role 
  ON escalation_history(company_id, escalated_to_role);
  
CREATE INDEX IF NOT EXISTS idx_escalation_history_escalated_at 
  ON escalation_history(company_id, escalated_at DESC);
  
CREATE INDEX IF NOT EXISTS idx_escalation_history_ticket_id 
  ON escalation_history(ticket_id);
  
CREATE INDEX IF NOT EXISTS idx_escalation_history_escalated_by 
  ON escalation_history(company_id, escalated_by) WHERE escalated_by IS NOT NULL;

-- Add trigger to auto-update updated_at
CREATE OR REPLACE FUNCTION update_escalation_history_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_escalation_history_updated_at
    BEFORE UPDATE ON escalation_history
    FOR EACH ROW
    EXECUTE FUNCTION update_escalation_history_updated_at();

-- Add comments for documentation
COMMENT ON TABLE escalation_history IS 'Tracks all escalations (automatic and manual) for maintenance tickets';
COMMENT ON COLUMN escalation_history.escalation_level IS 'Escalation level: 1=SUPERVISOR, 2=SITE_COORDINATOR, 3=ADMIN';
COMMENT ON COLUMN escalation_history.escalated_from_role IS 'Role from which ticket was escalated (NULL for initial escalation)';
COMMENT ON COLUMN escalation_history.escalated_to_role IS 'Role to which ticket was escalated';
COMMENT ON COLUMN escalation_history.is_automatic IS 'true if automatic escalation based on SLA, false if manual escalation';
COMMENT ON COLUMN escalation_history.escalated_by IS 'User ID who escalated the ticket (NULL for automatic escalations)';

COMMIT;
