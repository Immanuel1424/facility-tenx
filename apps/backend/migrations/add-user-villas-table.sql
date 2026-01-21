-- ============================================================================
-- MULTI-VILLA SUPPORT: USER_VILLAS TABLE
-- ============================================================================
-- This migration creates a junction table between users and villas so that
-- a single tenant user can be associated with multiple villas. It also
-- backfills data from existing users.villa_number using the villas table.
-- ============================================================================

BEGIN;

-- STEP 1: CREATE USER_VILLAS TABLE
CREATE TABLE IF NOT EXISTS user_villas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  villa_id UUID NOT NULL REFERENCES villas(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),

  CONSTRAINT uq_user_villas_company_user_villa UNIQUE (company_id, user_id, villa_id)
);

-- Helpful indexes for common queries
CREATE INDEX IF NOT EXISTS idx_user_villas_company_user
  ON user_villas(company_id, user_id);

CREATE INDEX IF NOT EXISTS idx_user_villas_company_villa
  ON user_villas(company_id, villa_id);

-- STEP 2: BACKFILL FROM EXISTING users.villa_number
INSERT INTO user_villas (company_id, user_id, villa_id)
SELECT DISTINCT
  u.company_id,
  u.id AS user_id,
  v.id AS villa_id
FROM users u
JOIN villas v
  ON v.company_id = u.company_id
 AND v.villa_number = u.villa_number
WHERE u.villa_number IS NOT NULL
  AND NOT EXISTS (
    SELECT 1
    FROM user_villas uv
    WHERE uv.company_id = u.company_id
      AND uv.user_id = u.id
      AND uv.villa_id = v.id
  );

COMMIT;


