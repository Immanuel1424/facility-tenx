-- ============================================================================
-- FCM PUSH NOTIFICATIONS: USER_DEVICES TABLE
-- ============================================================================
-- This migration creates a table to store FCM (Firebase Cloud Messaging) tokens
-- for push notifications. Each user can have multiple devices (web, mobile, etc.)
-- ============================================================================

BEGIN;

-- CREATE USER_DEVICES TABLE
CREATE TABLE IF NOT EXISTS user_devices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  fcm_token TEXT NOT NULL,
  platform VARCHAR(20) NOT NULL CHECK (platform IN ('web', 'android', 'ios')),
  device_info JSONB, -- Optional: browser, OS, user agent, etc.
  is_active BOOLEAN DEFAULT true,
  last_used_at TIMESTAMPTZ DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  -- Ensure one token per user per device (user can have multiple devices)
  CONSTRAINT uq_user_devices_user_token UNIQUE (user_id, fcm_token)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_user_devices_company_user
  ON user_devices(company_id, user_id);

CREATE INDEX IF NOT EXISTS idx_user_devices_user_active
  ON user_devices(user_id, is_active) WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_user_devices_fcm_token
  ON user_devices(fcm_token);

-- Trigger to auto-update updated_at
CREATE OR REPLACE FUNCTION update_user_devices_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_user_devices_updated_at
  BEFORE UPDATE ON user_devices
  FOR EACH ROW
  EXECUTE FUNCTION update_user_devices_updated_at();

COMMIT;

