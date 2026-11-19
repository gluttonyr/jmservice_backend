-- Bookmaker step before the operator, for deposits and withdrawals.
-- Rows are seeded at startup by BookmakerService (1XBET available, 1WIN and MELBET "bientôt").

DO $$ BEGIN
  CREATE TYPE bookmakers_integration_enum AS ENUM ('SERVCUL');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS bookmakers (
  id SERIAL PRIMARY KEY,
  "trackingId" varchar NOT NULL UNIQUE,
  "createdAt" timestamp NOT NULL DEFAULT now(),
  "updatedAt" timestamp NOT NULL DEFAULT now(),
  created_by varchar(100),
  updated_by varchar(100),
  code varchar(30) NOT NULL UNIQUE,
  nom varchar(100) NOT NULL,
  image_url varchar(255),
  integration bookmakers_integration_enum,
  active boolean NOT NULL DEFAULT true,
  ordre integer NOT NULL DEFAULT 0
);

-- Existing transactions and those sent by apps without the bookmaker step are 1XBET.
ALTER TABLE transactions
  ADD COLUMN IF NOT EXISTS bookmaker varchar(30) NOT NULL DEFAULT '1XBET';
