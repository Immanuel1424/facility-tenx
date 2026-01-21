-- Migration: Delete maintenance tickets where category_id is NULL
-- Date: 2025-01-14
-- Description: Removes all maintenance tickets that have NULL or empty category_id

-- First, let's check how many tickets will be affected
-- Uncomment the following lines to preview before deletion:
-- SELECT COUNT(*) as tickets_to_delete
-- FROM maintenance_tickets
-- WHERE category_id IS NULL;

-- Handle child tickets: Set parent_ticket_id to NULL for child tickets whose parent will be deleted
UPDATE maintenance_tickets
SET parent_ticket_id = NULL
WHERE parent_ticket_id IN (
  SELECT id 
  FROM maintenance_tickets 
  WHERE category_id IS NULL
);

-- Delete tickets where category_id is NULL
-- Note: Related records (status_history, comments, attachments) will be cascade deleted
-- due to cascade: true in the entity relationships
DELETE FROM maintenance_tickets
WHERE category_id IS NULL;

-- Optional: Verify deletion (uncomment to run after migration)
-- SELECT COUNT(*) as remaining_tickets_with_null_category
-- FROM maintenance_tickets
-- WHERE category_id IS NULL;

