/**
 * Migration script — creates all tables in Supabase (PostgreSQL).
 *
 * Run ONCE after setting up your Supabase project:
 *   node src/scripts/migrate.js
 */

require('dotenv').config({ path: require('path').resolve(__dirname, '../../.env') });
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false },
});

const SQL = `
-- ── Enable UUID extension ─────────────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ── Users table ───────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
  id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  name             VARCHAR(100) NOT NULL,
  email            VARCHAR(255) NOT NULL UNIQUE,
  password_hash    TEXT,                          -- NULL for Google-only accounts
  avatar_url       TEXT,
  google_id        VARCHAR(255) UNIQUE,           -- NULL for local accounts
  auth_provider    VARCHAR(20)  NOT NULL DEFAULT 'local' CHECK (auth_provider IN ('local','google')),
  reset_otp        VARCHAR(6),
  reset_otp_expiry TIMESTAMPTZ,
  is_active        BOOLEAN      NOT NULL DEFAULT true,
  created_at       TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_email     ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_google_id ON users(google_id);

-- ── Refresh tokens table ──────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS refresh_tokens (
  id         BIGSERIAL   PRIMARY KEY,
  user_id    UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token      TEXT        NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user_id ON refresh_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_token   ON refresh_tokens(token);

-- ── Plants table ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS plants (
  id          UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  name        VARCHAR(255) NOT NULL,
  subtitle    VARCHAR(255),
  tag         VARCHAR(100),
  price_inr   NUMERIC(10,2) NOT NULL CHECK (price_inr >= 0),
  image_url   TEXT         NOT NULL,
  categories  TEXT[]       NOT NULL DEFAULT '{}',
  description TEXT         NOT NULL DEFAULT '',
  stock       INTEGER      NOT NULL DEFAULT 0 CHECK (stock >= 0),
  is_active   BOOLEAN      NOT NULL DEFAULT true,
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_plants_categories ON plants USING GIN(categories);
`;

const migrate = async () => {
  const client = await pool.connect();
  try {
    console.log('🔄 Running migrations...');
    await client.query(SQL);
    console.log('✅ All tables created successfully!\n');
    console.log('Tables created:');
    console.log('  • users');
    console.log('  • refresh_tokens');
    console.log('  • plants');
    console.log('\nRun "npm run seed" next to populate sample plants.');
  } catch (err) {
    console.error('❌ Migration failed:', err.message);
    process.exit(1);
  } finally {
    client.release();
    await pool.end();
  }
};

migrate();
