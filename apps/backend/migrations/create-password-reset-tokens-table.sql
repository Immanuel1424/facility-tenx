-- Create password_reset_tokens table for forgot password flow
CREATE TABLE IF NOT EXISTS password_reset_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL,
  user_id UUID NOT NULL,
  email VARCHAR(255) NOT NULL,
  otp VARCHAR(6) NOT NULL,
  token TEXT NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  used_at TIMESTAMP NULL,
  attempts INT NOT NULL DEFAULT 0,
  ip_address VARCHAR(255) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_password_reset_tokens_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_company_user ON password_reset_tokens(company_id, user_id);
CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_company_email ON password_reset_tokens(company_id, email);
CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_company_token ON password_reset_tokens(company_id, token);
CREATE UNIQUE INDEX IF NOT EXISTS idx_password_reset_tokens_company_token_unique ON password_reset_tokens(company_id, token) WHERE used_at IS NULL;

-- Add comment
COMMENT ON TABLE password_reset_tokens IS 'Stores password reset tokens and OTPs for forgot password flow';

