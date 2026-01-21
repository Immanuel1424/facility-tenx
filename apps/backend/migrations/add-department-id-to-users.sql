-- Migration: Add department_id column to users table
-- Date: 2025-12-19
-- Description: Adds department_id field to support department assignment for internal users

ALTER TABLE users
ADD COLUMN IF NOT EXISTS department_id UUID NULL;

-- Add index for querying users by department
CREATE INDEX IF NOT EXISTS idx_users_department_id 
ON users(company_id, department_id) 
WHERE department_id IS NOT NULL;

-- Add foreign key constraint (optional, if departments table exists)
-- Uncomment if you want referential integrity
-- ALTER TABLE users
-- ADD CONSTRAINT fk_users_department 
-- FOREIGN KEY (department_id) REFERENCES departments(id) 
-- ON DELETE SET NULL;

