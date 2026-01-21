-- Change villa_number column from integer to varchar
-- This allows villa numbers to be alphanumeric (e.g., "101A", "V-101", etc.)

-- Step 1: Add a temporary column with varchar type
ALTER TABLE "villas" ADD COLUMN IF NOT EXISTS "villa_number_temp" VARCHAR(50);

-- Step 2: Convert existing integer values to strings
UPDATE "villas" SET "villa_number_temp" = CAST("villa_number" AS VARCHAR);

-- Step 3: Drop the old integer column
ALTER TABLE "villas" DROP COLUMN IF EXISTS "villa_number";

-- Step 4: Rename the temporary column to the original name
ALTER TABLE "villas" RENAME COLUMN "villa_number_temp" TO "villa_number";

-- Step 5: Add NOT NULL constraint back
ALTER TABLE "villas" ALTER COLUMN "villa_number" SET NOT NULL;

-- Step 6: Recreate the unique index (it was dropped when we removed the column)
CREATE UNIQUE INDEX IF NOT EXISTS "IDX_villas_company_id_villa_number" 
ON "villas" ("company_id", "villa_number");

