-- Add deleted_at column to users table
-- This column is used to distinguish deleted users from inactive users
-- Deleted users (deleted_at IS NOT NULL) are excluded from user lists
-- Inactive users (status = 'inactive', deleted_at IS NULL) are shown in lists

ALTER TABLE users 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP NULL;

-- Add index for better query performance when filtering out deleted users
CREATE INDEX IF NOT EXISTS idx_users_deleted_at ON users(deleted_at) WHERE deleted_at IS NULL;

-- Comment on column
COMMENT ON COLUMN users.deleted_at IS 'Timestamp when user was soft-deleted. NULL means user is not deleted. Used to distinguish deleted users from inactive users.';

