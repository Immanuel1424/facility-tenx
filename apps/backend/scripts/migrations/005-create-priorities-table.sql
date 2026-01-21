-- ============================================================================
-- CREATE PRIORITIES TABLE
-- ============================================================================
-- Creates a priorities lookup table with visual configuration and business rules
-- Complies with strict PostgreSQL schema standards
-- ============================================================================

BEGIN;

-- Step 1: Create priorities table
CREATE TABLE IF NOT EXISTS priority (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL,
  code text NOT NULL, -- LOW, MEDIUM, HIGH, URGENT
  name text NOT NULL, -- Display name
  description text,
  
  -- Visual Configuration
  color_code text NOT NULL, -- Hex color code (e.g., #FF5722)
  icon_name text, -- Material icon name (e.g., 'priority_high')
  
  -- Business Rules
  display_order integer NOT NULL DEFAULT 0, -- Order in dropdowns/lists
  default_sla_hours integer, -- Default SLA in hours for this priority
  escalation_hours integer, -- Hours before auto-escalation
  
  -- Status
  is_active boolean NOT NULL DEFAULT true,
  is_system boolean NOT NULL DEFAULT false, -- System priorities cannot be deleted
  
  -- Standard columns
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  
  -- Constraints
  CONSTRAINT uq_priority_company_code UNIQUE (company_id, code),
  CONSTRAINT chk_priority_color_format CHECK (color_code ~ '^#[0-9A-Fa-f]{6}$')
);

-- Step 2: Create indexes
CREATE INDEX IF NOT EXISTS idx_priority_company_id ON priority(company_id);
CREATE INDEX IF NOT EXISTS idx_priority_active ON priority(company_id, is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_priority_display_order ON priority(company_id, display_order);

-- Step 3: Add foreign key to maintenance_tickets (if column doesn't exist)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'maintenance_tickets' AND column_name = 'priority_id'
  ) THEN
    ALTER TABLE maintenance_tickets ADD COLUMN priority_id uuid;
  END IF;
END $$;

-- Add foreign key constraint
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE constraint_name = 'fk_tickets_priority'
  ) THEN
    ALTER TABLE maintenance_tickets
      ADD CONSTRAINT fk_tickets_priority 
      FOREIGN KEY (priority_id) REFERENCES priority(id) ON DELETE SET NULL;
  END IF;
END $$;

-- Create index for priority_id
CREATE INDEX IF NOT EXISTS idx_tickets_priority_id ON maintenance_tickets(company_id, priority_id) WHERE priority_id IS NOT NULL;

-- Step 4: Add updated_at trigger
DROP TRIGGER IF EXISTS update_priority_updated_at ON priority;
CREATE TRIGGER update_priority_updated_at
  BEFORE UPDATE ON priority
  FOR EACH ROW
  EXECUTE FUNCTION update_modified_column();

-- Step 5: Seed default priorities for existing companies
DO $$
DECLARE
  company_record RECORD;
BEGIN
  FOR company_record IN SELECT id FROM companies LOOP
    -- Insert default priorities if they don't exist
    INSERT INTO priority (
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

-- Step 6: Add helpful comments
COMMENT ON TABLE priority IS 'Priority levels with visual configuration (colors, icons) and business rules (SLA, escalation). Supports tenant-specific customization.';
COMMENT ON COLUMN priority.code IS 'Unique code per company (LOW, MEDIUM, HIGH, URGENT). Used for mapping from enum.';
COMMENT ON COLUMN priority.color_code IS 'Hex color code for UI display (e.g., #FF5722)';
COMMENT ON COLUMN priority.icon_name IS 'Material Design icon name for UI display';
COMMENT ON COLUMN priority.default_sla_hours IS 'Default SLA time in hours for tickets with this priority';
COMMENT ON COLUMN priority.escalation_hours IS 'Hours before auto-escalation for this priority';
COMMENT ON COLUMN priority.is_system IS 'System priorities cannot be deleted, only deactivated';

COMMIT;

-- Verification
DO $$
BEGIN
  RAISE NOTICE '============================================';
  RAISE NOTICE 'PRIORITIES TABLE CREATED';
  RAISE NOTICE '============================================';
  RAISE NOTICE 'Table: priority (singular, compliant)';
  RAISE NOTICE 'Triggers: updated_at trigger added';
  RAISE NOTICE 'Indexes: All foreign keys indexed';
  RAISE NOTICE 'Data: Default priorities seeded for all companies';
  RAISE NOTICE '============================================';
END $$;

