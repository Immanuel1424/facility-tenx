-- Change villa_number column in maintenance_tickets table from integer to varchar
-- This allows villa numbers to be alphanumeric (e.g., "101A", "V-101", etc.)

-- Step 1: Add a temporary column with varchar type
ALTER TABLE "maintenance_tickets" ADD COLUMN IF NOT EXISTS "villa_number_temp" VARCHAR(50);

-- Step 2: Convert existing integer values to strings
UPDATE "maintenance_tickets" 
SET "villa_number_temp" = CAST("villa_number" AS VARCHAR)
WHERE "villa_number" IS NOT NULL;

-- Step 3: Drop the old integer column
ALTER TABLE "maintenance_tickets" DROP COLUMN IF EXISTS "villa_number";

-- Step 4: Rename the temporary column to the original name
ALTER TABLE "maintenance_tickets" RENAME COLUMN "villa_number_temp" TO "villa_number";

-- Step 5: Recreate the index (it was dropped when we removed the column)
CREATE INDEX IF NOT EXISTS "IDX_maintenance_tickets_company_id_villa_number" 
ON "maintenance_tickets" ("company_id", "villa_number");
