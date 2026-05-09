const { Pool } = require('pg');

// Single connection pool — reused across all requests
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false, // Required for Supabase
  },
  max: 10,                  // max pool size
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 5000,
});

// Test connection on startup
pool.connect((err, client, release) => {
  if (err) {
    console.error('❌ Supabase connection failed:', err.message);
    process.exit(1);
  }
  release();
  console.log('✅ Supabase (PostgreSQL) connected');
});

/**
 * Run a parameterized query.
 * Usage: db.query('SELECT * FROM users WHERE id = $1', [userId])
 */
const query = (text, params) => pool.query(text, params);

/**
 * Get a client for transactions.
 * Usage: const client = await db.getClient(); try { await client.query(...) }
 */
const getClient = () => pool.connect();

module.exports = { query, getClient, pool };
