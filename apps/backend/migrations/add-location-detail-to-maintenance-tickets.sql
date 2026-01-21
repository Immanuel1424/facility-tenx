ALTER TABLE maintenance_tickets
ADD COLUMN IF NOT EXISTS location_detail VARCHAR(255) NULL;


