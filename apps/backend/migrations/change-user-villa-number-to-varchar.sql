-- Change villa_number and villa_numbers columns in users table from integer to varchar/string array
-- This allows villa numbers to be alphanumeric (e.g., "101A", "V-101", etc.)

-- Step 1: Add temporary columns with varchar/string array types
ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "villa_number_temp" VARCHAR(50);
ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "villa_numbers_temp" JSONB;

-- Step 2: Convert existing integer values to strings
UPDATE "users" 
SET "villa_number_temp" = CAST("villa_number" AS VARCHAR)
WHERE "villa_number" IS NOT NULL;

-- Step 3: Convert existing integer array values to string arrays
UPDATE "users"
SET "villa_numbers_temp" = (
  SELECT jsonb_agg(elem::text)
  FROM jsonb_array_elements("villa_numbers") AS elem
)
WHERE "villa_numbers" IS NOT NULL;

-- Step 4: Drop the old columns
ALTER TABLE "users" DROP COLUMN IF EXISTS "villa_number";
ALTER TABLE "users" DROP COLUMN IF EXISTS "villa_numbers";

-- Step 5: Rename the temporary columns to the original names
ALTER TABLE "users" RENAME COLUMN "villa_number_temp" TO "villa_number";
ALTER TABLE "users" RENAME COLUMN "villa_numbers_temp" TO "villa_numbers";

-- Step 6: Recreate the unique index (it was dropped when we removed the column)
CREATE UNIQUE INDEX IF NOT EXISTS "IDX_users_company_id_villa_number" 
ON "users" ("company_id", "villa_number")
WHERE "villa_number" IS NOT NULL;

