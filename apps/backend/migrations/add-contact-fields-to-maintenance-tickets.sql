-- Migration: Add contact fields to maintenance_tickets table
-- Date: 2025-12-19

ALTER TABLE maintenance_tickets
ADD COLUMN IF NOT EXISTS contact_number VARCHAR(50) NULL,
ADD COLUMN IF NOT EXISTS alternate_contact VARCHAR(50) NULL,
ADD COLUMN IF NOT EXISTS preferred_time VARCHAR(255) NULL;

-- Add indexes if needed for querying
CREATE INDEX IF NOT EXISTS idx_maintenance_tickets_contact_number 
ON maintenance_tickets(contact_number) 
WHERE contact_number IS NOT NULL;

