-- JM Services: sign-up with a phone number only. The email becomes optional (it stays unique when present:
-- PostgreSQL allows several NULL values under a unique constraint). Run once on the production database.
ALTER TABLE users ALTER COLUMN email DROP NOT NULL;

-- Phone numbers are compared digit by digit at sign-in.
CREATE INDEX IF NOT EXISTS idx_users_telephone_digits ON users ((regexp_replace(telephone, '[^0-9]', '', 'g')));
