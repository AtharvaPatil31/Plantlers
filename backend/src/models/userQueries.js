const db = require('../config/db');
const bcrypt = require('bcryptjs');

// ── Find user by email ────────────────────────────────────────────────────────
const findByEmail = async (email) => {
  const { rows } = await db.query(
    'SELECT * FROM users WHERE email = $1 LIMIT 1',
    [email.toLowerCase()]
  );
  return rows[0] || null;
};

// ── Find user by ID ───────────────────────────────────────────────────────────
const findById = async (id) => {
  const { rows } = await db.query(
    'SELECT id, name, email, avatar_url, auth_provider, is_active, created_at FROM users WHERE id = $1 LIMIT 1',
    [id]
  );
  return rows[0] || null;
};

// ── Find user by Google ID ────────────────────────────────────────────────────
const findByGoogleId = async (googleId) => {
  const { rows } = await db.query(
    'SELECT * FROM users WHERE google_id = $1 LIMIT 1',
    [googleId]
  );
  return rows[0] || null;
};

// ── Find user by email OR google_id ──────────────────────────────────────────
const findByEmailOrGoogleId = async (email, googleId) => {
  const { rows } = await db.query(
    'SELECT * FROM users WHERE email = $1 OR google_id = $2 LIMIT 1',
    [email.toLowerCase(), googleId]
  );
  return rows[0] || null;
};

// ── Create local user ─────────────────────────────────────────────────────────
const createLocal = async ({ name, email, password }) => {
  const hashedPassword = await bcrypt.hash(password, 12);
  const { rows } = await db.query(
    `INSERT INTO users (name, email, password_hash, auth_provider)
     VALUES ($1, $2, $3, 'local')
     RETURNING id, name, email, avatar_url, auth_provider, is_active, created_at`,
    [name.trim(), email.toLowerCase(), hashedPassword]
  );
  return rows[0];
};

// ── Create Google OAuth user ──────────────────────────────────────────────────
const createGoogle = async ({ name, email, googleId, avatarUrl }) => {
  const { rows } = await db.query(
    `INSERT INTO users (name, email, google_id, avatar_url, auth_provider)
     VALUES ($1, $2, $3, $4, 'google')
     RETURNING id, name, email, avatar_url, auth_provider, is_active, created_at`,
    [name.trim(), email.toLowerCase(), googleId, avatarUrl || null]
  );
  return rows[0];
};

// ── Link Google to existing email/password account ───────────────────────────
const linkGoogle = async (userId, googleId, avatarUrl) => {
  const { rows } = await db.query(
    `UPDATE users
     SET google_id = $1,
         auth_provider = 'google',
         avatar_url = COALESCE(avatar_url, $2),
         updated_at = NOW()
     WHERE id = $3
     RETURNING id, name, email, avatar_url, auth_provider, is_active, created_at`,
    [googleId, avatarUrl || null, userId]
  );
  return rows[0];
};

// ── Compare password ──────────────────────────────────────────────────────────
const comparePassword = async (plainPassword, passwordHash) => {
  return bcrypt.compare(plainPassword, passwordHash);
};

// ── Update profile ────────────────────────────────────────────────────────────
const updateProfile = async (userId, updates) => {
  const fields = [];
  const values = [];
  let idx = 1;

  if (updates.name !== undefined) {
    fields.push(`name = $${idx++}`);
    values.push(updates.name.trim());
  }
  if (updates.avatarUrl !== undefined) {
    fields.push(`avatar_url = $${idx++}`);
    values.push(updates.avatarUrl);
  }

  if (fields.length === 0) return null;

  fields.push(`updated_at = NOW()`);
  values.push(userId);

  const { rows } = await db.query(
    `UPDATE users SET ${fields.join(', ')} WHERE id = $${idx}
     RETURNING id, name, email, avatar_url, auth_provider, created_at`,
    values
  );
  return rows[0] || null;
};

// ── Soft-delete account ───────────────────────────────────────────────────────
const deactivate = async (userId) => {
  await db.query(
    `UPDATE users SET is_active = false, updated_at = NOW() WHERE id = $1`,
    [userId]
  );
};

// ── OTP: save reset OTP ───────────────────────────────────────────────────────
const saveResetOtp = async (userId, otp, expiryDate) => {
  await db.query(
    `UPDATE users SET reset_otp = $1, reset_otp_expiry = $2, updated_at = NOW() WHERE id = $3`,
    [otp, expiryDate, userId]
  );
};

// ── OTP: clear reset OTP ──────────────────────────────────────────────────────
const clearResetOtp = async (userId) => {
  await db.query(
    `UPDATE users SET reset_otp = NULL, reset_otp_expiry = NULL, updated_at = NOW() WHERE id = $1`,
    [userId]
  );
};

// ── Update password ───────────────────────────────────────────────────────────
const updatePassword = async (userId, newPassword) => {
  const hashedPassword = await bcrypt.hash(newPassword, 12);
  await db.query(
    `UPDATE users SET password_hash = $1, reset_otp = NULL, reset_otp_expiry = NULL, updated_at = NOW() WHERE id = $2`,
    [hashedPassword, userId]
  );
};

// ── Refresh tokens ────────────────────────────────────────────────────────────
const addRefreshToken = async (userId, token) => {
  // Keep only last 5 tokens per user (multi-device support)
  await db.query(
    `INSERT INTO refresh_tokens (user_id, token) VALUES ($1, $2)`,
    [userId, token]
  );
  // Prune old tokens — keep newest 5
  await db.query(
    `DELETE FROM refresh_tokens
     WHERE user_id = $1
       AND id NOT IN (
         SELECT id FROM refresh_tokens
         WHERE user_id = $1
         ORDER BY created_at DESC
         LIMIT 5
       )`,
    [userId]
  );
};

const findRefreshToken = async (token) => {
  const { rows } = await db.query(
    `SELECT rt.*, u.id as user_id, u.is_active
     FROM refresh_tokens rt
     JOIN users u ON u.id = rt.user_id
     WHERE rt.token = $1 LIMIT 1`,
    [token]
  );
  return rows[0] || null;
};

const deleteRefreshToken = async (token) => {
  await db.query('DELETE FROM refresh_tokens WHERE token = $1', [token]);
};

const deleteAllRefreshTokens = async (userId) => {
  await db.query('DELETE FROM refresh_tokens WHERE user_id = $1', [userId]);
};

// ── Safe user object (no sensitive fields) ────────────────────────────────────
const toSafeObject = (user) => ({
  id: user.id,
  name: user.name,
  email: user.email,
  avatar_url: user.avatar_url,
  auth_provider: user.auth_provider,
  created_at: user.created_at,
});

module.exports = {
  findByEmail,
  findById,
  findByGoogleId,
  findByEmailOrGoogleId,
  createLocal,
  createGoogle,
  linkGoogle,
  comparePassword,
  updateProfile,
  deactivate,
  saveResetOtp,
  clearResetOtp,
  updatePassword,
  addRefreshToken,
  findRefreshToken,
  deleteRefreshToken,
  deleteAllRefreshTokens,
  toSafeObject,
};
