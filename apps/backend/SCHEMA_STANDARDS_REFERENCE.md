# PostgreSQL Schema Standards Reference

## Quick Reference Checklist

When creating or modifying database schemas, verify:

- [ ] Primary key is `uuid` with `gen_random_uuid()` default
- [ ] Table name is **singular** (e.g., `user`, not `users`)
- [ ] All timestamp columns use `timestamptz` (never `timestamp`)
- [ ] String columns use `text` (or `varchar(n)` only for codes/identifiers)
- [ ] Boolean columns use prefixes: `is_`, `has_`, or `can_`
- [ ] JSON columns use `jsonb` (never `json`)
- [ ] Standard columns exist: `id`, `created_at`, `updated_at`
- [ ] `updated_at` trigger exists and calls `update_modified_column()`
- [ ] All foreign keys have explicit indexes
- [ ] Column comments added for complex logic

---

## Naming Conventions

### Tables
```sql
-- ✅ Correct: Singular
CREATE TABLE user (...);
CREATE TABLE maintenance_ticket (...);
CREATE TABLE order_item (...);

-- ❌ Wrong: Plural
CREATE TABLE users (...);
CREATE TABLE maintenance_tickets (...);
CREATE TABLE order_items (...);
```

### Columns
```sql
-- ✅ Correct: snake_case
user_id, created_at, is_active, has_permission

-- ❌ Wrong: camelCase or PascalCase
userId, createdAt, isActive, HasPermission
```

### Boolean Columns
```sql
-- ✅ Correct: With prefix
is_active, has_permission, can_edit, is_deleted

-- ❌ Wrong: Without prefix
active, permission, edit, deleted
```

---

## Data Types

### Primary Keys
```sql
-- ✅ Correct
id uuid PRIMARY KEY DEFAULT gen_random_uuid()

-- ❌ Wrong
id serial PRIMARY KEY
id integer PRIMARY KEY
```

### Strings
```sql
-- ✅ Correct: Use text for variable-length content
description text,
notes text,
content text

-- ✅ Also OK: Use varchar(n) for codes/identifiers with business rules
code varchar(50) NOT NULL,
email varchar(255) NOT NULL,
phone_number varchar(20)

-- ❌ Wrong: Arbitrary varchar limits on content
description varchar(500),  -- Use text instead
notes varchar(1000),       -- Use text instead
```

### Timestamps
```sql
-- ✅ Correct: Always use timestamptz
created_at timestamptz NOT NULL DEFAULT now(),
updated_at timestamptz NOT NULL DEFAULT now(),
scheduled_at timestamptz,
completed_at timestamptz

-- ❌ Wrong: Never use timestamp (without timezone)
created_at timestamp NOT NULL DEFAULT now(),
updated_at timestamp NOT NULL DEFAULT now()
```

### JSON
```sql
-- ✅ Correct: Always use jsonb
metadata jsonb,
payload jsonb,
settings jsonb

-- ❌ Wrong: Never use json
metadata json,
payload json
```

### Money
```sql
-- ✅ Correct: Use numeric or integer (cents)
price numeric(10, 2),
amount_cents integer

-- ❌ Wrong: Never use money type
price money
```

---

## Standard Columns

Every table **must** have these three columns:

```sql
CREATE TABLE example (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  
  -- Your other columns here
  name text NOT NULL,
  ...
);
```

---

## updated_at Trigger

Every table **must** have a trigger to auto-update `updated_at`:

### Step 1: Create the Function (once per database)
```sql
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### Step 2: Add Trigger to Each Table
```sql
CREATE TRIGGER update_example_updated_at
  BEFORE UPDATE ON example
  FOR EACH ROW
  EXECUTE FUNCTION update_modified_column();
```

**Naming Convention:** `update_<table_name>_updated_at`

---

## Foreign Keys & Indexes

### Rule: Every Foreign Key Must Have an Explicit Index

```sql
-- ✅ Correct: FK with explicit index
CREATE TABLE order_item (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid NOT NULL REFERENCES "order"(id),
  product_id uuid NOT NULL REFERENCES product(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Index the foreign keys
CREATE INDEX idx_order_item_order_id ON order_item(order_id);
CREATE INDEX idx_order_item_product_id ON order_item(product_id);
```

### Multi-Tenant Tables
For tables with `company_id` (multi-tenant), include it in the index:

```sql
-- ✅ Correct: Composite index with company_id
CREATE INDEX idx_order_item_order_id ON order_item(company_id, order_id);
CREATE INDEX idx_order_item_product_id ON order_item(company_id, product_id);
```

**Why:** Postgres does NOT automatically index foreign keys. You must do it explicitly.

---

## Complete Example

```sql
-- ============================================================================
-- Example: Creating a compliant table
-- ============================================================================

-- Step 1: Create the table with standard columns
CREATE TABLE maintenance_ticket (
  -- Standard columns (REQUIRED)
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  
  -- Business columns
  ticket_number text NOT NULL,
  title text NOT NULL,
  description text,
  
  -- Foreign keys
  created_by uuid NOT NULL REFERENCES "user"(id),
  assigned_technician_id uuid REFERENCES "user"(id),
  category_id uuid REFERENCES ticket_category(id),
  
  -- Booleans with prefix
  is_escalated boolean DEFAULT false,
  is_resolved boolean DEFAULT false,
  
  -- Timestamps (always timestamptz)
  scheduled_at timestamptz,
  completed_at timestamptz,
  
  -- JSON (always jsonb)
  metadata jsonb,
  
  -- Constraints
  CONSTRAINT uq_ticket_number UNIQUE (ticket_number)
);

-- Step 2: Index all foreign keys
CREATE INDEX idx_maintenance_ticket_created_by ON maintenance_ticket(created_by);
CREATE INDEX idx_maintenance_ticket_assigned_technician_id 
  ON maintenance_ticket(assigned_technician_id) 
  WHERE assigned_technician_id IS NOT NULL;
CREATE INDEX idx_maintenance_ticket_category_id 
  ON maintenance_ticket(category_id) 
  WHERE category_id IS NOT NULL;

-- Step 3: Add the updated_at trigger
CREATE TRIGGER update_maintenance_ticket_updated_at
  BEFORE UPDATE ON maintenance_ticket
  FOR EACH ROW
  EXECUTE FUNCTION update_modified_column();

-- Step 4: Add comments for clarity
COMMENT ON TABLE maintenance_ticket IS 'Maintenance work orders from tenants';
COMMENT ON COLUMN maintenance_ticket.is_escalated IS 'True if ticket has been escalated to supervisor';
COMMENT ON COLUMN maintenance_ticket.metadata IS 'Additional flexible data (JSON)';
```

---

## Enums vs Reference Tables

### Use ENUMs for:
- Static, immutable values
- Examples: `days_of_week`, `cardinal_directions`, `boolean_like_states`

```sql
CREATE TYPE ticket_status AS ENUM ('NEW', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED');
```

### Use Reference Tables for:
- Anything that might expand
- User-managed data
- Examples: `order_status`, `user_role`, `ticket_category`

```sql
CREATE TABLE ticket_category (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  name text NOT NULL,
  is_active boolean DEFAULT true
);
```

---

## Soft Deletes

If soft-delete is required, add `deleted_at`:

```sql
CREATE TABLE example (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz,  -- NULL = active, NOT NULL = deleted
  
  name text NOT NULL,
  ...
);

-- Partial unique index (ensures uniqueness only for active records)
CREATE UNIQUE INDEX idx_example_name_active 
  ON example(name) 
  WHERE deleted_at IS NULL;

-- Index for filtering active records
CREATE INDEX idx_example_active 
  ON example(deleted_at) 
  WHERE deleted_at IS NULL;
```

---

## Performance Tips

### Partial Indexes
Use partial indexes for filtered queries:

```sql
-- Only index active records
CREATE INDEX idx_tickets_active 
  ON maintenance_ticket(status) 
  WHERE status NOT IN ('CANCELLED', 'CLOSED');

-- Only index non-null values
CREATE INDEX idx_tickets_technician 
  ON maintenance_ticket(assigned_technician_id) 
  WHERE assigned_technician_id IS NOT NULL;
```

### GIN Indexes for JSONB
If you query JSONB columns frequently:

```sql
CREATE INDEX idx_tickets_metadata_gin 
  ON maintenance_ticket USING GIN (metadata);
```

---

## Common Mistakes

### ❌ Mistake 1: Forgetting the Trigger
```sql
CREATE TABLE example (
  updated_at timestamptz NOT NULL DEFAULT now()
);
-- Missing: No trigger to update updated_at!
```

### ❌ Mistake 2: Using timestamp Instead of timestamptz
```sql
created_at timestamp NOT NULL DEFAULT now()  -- Wrong!
-- Should be: created_at timestamptz NOT NULL DEFAULT now()
```

### ❌ Mistake 3: Not Indexing Foreign Keys
```sql
CREATE TABLE order_item (
  order_id uuid REFERENCES "order"(id)  -- No index!
);
-- Missing: CREATE INDEX idx_order_item_order_id ON order_item(order_id);
```

### ❌ Mistake 4: Using json Instead of jsonb
```sql
metadata json  -- Wrong!
-- Should be: metadata jsonb
```

---

## Verification Script

Run this after creating tables to verify compliance:

```sql
-- Check all tables have updated_at triggers
SELECT 
  t.table_name,
  CASE WHEN EXISTS (
    SELECT 1 FROM information_schema.triggers tr
    WHERE tr.table_name = t.table_name
    AND tr.trigger_name LIKE '%updated_at%'
  ) THEN '✅' ELSE '❌ MISSING TRIGGER' END as trigger_status
FROM information_schema.tables t
WHERE t.table_schema = 'public'
AND t.table_type = 'BASE TABLE'
ORDER BY t.table_name;

-- Check all foreign keys have indexes
SELECT
  tc.table_name,
  kcu.column_name,
  CASE WHEN EXISTS (
    SELECT 1 FROM pg_indexes pi
    WHERE pi.tablename = tc.table_name
    AND pi.indexdef LIKE '%' || kcu.column_name || '%'
  ) THEN '✅' ELSE '❌ MISSING INDEX' END as index_status
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
ORDER BY tc.table_name, kcu.column_name;
```

---

**Last Updated:** 2025-01-14  
**Maintained By:** Elite PostgreSQL Database Architect

