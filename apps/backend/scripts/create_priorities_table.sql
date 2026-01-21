-- Create Priorities Table with Color Codes
-- This allows tenant-specific priority customization and centralized color management

BEGIN;

-- Step 1: Create priorities table
CREATE TABLE IF NOT EXISTS priorities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL,
  code VARCHAR(50) NOT NULL, -- LOW, MEDIUM, HIGH, URGENT
  name VARCHAR(100) NOT NULL, -- Display name
  description TEXT,
  
  -- Visual Configuration
  color_code VARCHAR(7) NOT NULL, -- Hex color code (e.g., #FF5722)
  icon_name VARCHAR(50), -- Material icon name (e.g., 'priority_high')
  
  -- Business Rules
  display_order INT NOT NULL DEFAULT 0, -- Order in dropdowns/lists
  default_sla_hours INT, -- Default SLA in hours for this priority
  escalation_hours INT, -- Hours before auto-escalation
  
  -- Status
  is_active BOOLEAN NOT NULL DEFAULT true,
  is_system BOOLEAN NOT NULL DEFAULT false, -- System priorities cannot be deleted
  
  -- Metadata
  created_at TIMESTAMP NOT NULL DEFAULT now(),
  updated_at TIMESTAMP NOT NULL DEFAULT now(),
  
  -- Constraints
  CONSTRAINT uq_priorities_company_code UNIQUE (company_id, code),
  CONSTRAINT chk_priorities_color_format CHECK (color_code ~ '^#[0-9A-Fa-f]{6}$')
);

-- Step 2: Create indexes
CREATE INDEX idx_priorities_company_id ON priorities(company_id);
CREATE INDEX idx_priorities_active ON priorities(company_id, is_active) WHERE is_active = true;
CREATE INDEX idx_priorities_display_order ON priorities(company_id, display_order);

-- Step 3: Add foreign key to maintenance_tickets
-- First, we need to add priority_id column (keeping priority enum for backward compatibility)
ALTER TABLE maintenance_tickets 
ADD COLUMN IF NOT EXISTS priority_id UUID;

-- Add foreign key constraint
ALTER TABLE maintenance_tickets
ADD CONSTRAINT fk_tickets_priority 
FOREIGN KEY (priority_id) REFERENCES priorities(id) ON DELETE SET NULL;

-- Create index for priority_id
CREATE INDEX IF NOT EXISTS idx_tickets_priority_id ON maintenance_tickets(company_id, priority_id);

-- Step 4: Seed default priorities for existing companies
DO $$
DECLARE
  company_record RECORD;
BEGIN
  FOR company_record IN SELECT id FROM companies LOOP
    -- Insert default priorities if they don't exist
    INSERT INTO priorities (
      company_id, code, name, description, color_code, icon_name, 
      display_order, default_sla_hours, escalation_hours, is_system, is_active
    ) VALUES
      (
        company_record.id, 'LOW', 'Low', 'Low priority - can be handled during regular business hours',
        '#4CAF50', 'arrow_downward', 1, 72, 96, true, true
      ),
      (
        company_record.id, 'MEDIUM', 'Medium', 'Medium priority - should be addressed within business hours',
        '#2196F3', 'remove', 2, 48, 72, true, true
      ),
      (
        company_record.id, 'HIGH', 'High', 'High priority - requires prompt attention',
        '#FF9800', 'arrow_upward', 3, 24, 48, true, true
      ),
      (
        company_record.id, 'URGENT', 'Urgent', 'Urgent priority - requires immediate attention',
        '#F44336', 'priority_high', 4, 4, 8, true, true
      )
    ON CONFLICT (company_id, code) DO NOTHING;
  END LOOP;
END $$;

-- Step 5: Migrate existing tickets to use priority_id
-- Map enum values to priority records
UPDATE maintenance_tickets mt
SET priority_id = p.id
FROM priorities p
WHERE p.company_id = mt.company_id
  AND p.code = UPPER(mt.priority::text)
  AND mt.priority_id IS NULL;

-- Step 6: Create a view for easy querying (includes both enum and table)
CREATE OR REPLACE VIEW ticket_priorities AS
SELECT 
  mt.id as ticket_id,
  mt.ticket_number,
  mt.priority as priority_enum, -- Keep for backward compatibility
  p.id as priority_id,
  p.code as priority_code,
  p.name as priority_name,
  p.color_code,
  p.icon_name,
  p.display_order,
  p.default_sla_hours,
  p.escalation_hours
FROM maintenance_tickets mt
LEFT JOIN priorities p ON p.id = mt.priority_id AND p.company_id = mt.company_id;

-- Step 7: Add helpful comments
COMMENT ON TABLE priorities IS 'Priority levels with visual configuration (colors, icons) and business rules (SLA, escalation). Supports tenant-specific customization.';
COMMENT ON COLUMN priorities.code IS 'Unique code per company (LOW, MEDIUM, HIGH, URGENT). Used for mapping from enum.';
COMMENT ON COLUMN priorities.color_code IS 'Hex color code for UI display (e.g., #FF5722)';
COMMENT ON COLUMN priorities.icon_name IS 'Material Design icon name for UI display';
COMMENT ON COLUMN priorities.default_sla_hours IS 'Default SLA time in hours for tickets with this priority';
COMMENT ON COLUMN priorities.escalation_hours IS 'Hours before auto-escalation for this priority';
COMMENT ON COLUMN priorities.is_system IS 'System priorities cannot be deleted, only deactivated';

COMMIT;

-- Verification queries
SELECT 
  company_id,
  code,
  name,
  color_code,
  icon_name,
  display_order,
  default_sla_hours,
  is_system
FROM priorities
ORDER BY company_id, display_order;

SELECT 
  COUNT(*) as total_tickets,
  COUNT(priority_id) as tickets_with_priority_id,
  COUNT(*) - COUNT(priority_id) as tickets_without_priority_id
FROM maintenance_tickets;

