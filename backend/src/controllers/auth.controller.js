const { OAuth2Client } = require('google-auth-library');
const User = require('../models/userQueries');
const { signAccessToken, signRefreshToken, verifyRefreshToken } = require('../utils/jwt');
const { sendOtpEmail } = require('../utils/email');

const googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

// ── Helper: build auth response + store refresh token ────────────────────────
const buildAuthResponse = async (user) => {
  const accessToken  = signAccessToken(user.id);
  const refreshToken = signRefreshToken(user.id);

  await User.addRefreshToken(user.id, refreshToken);

  return {
    access_token:  accessToken,
    refresh_token: refreshToken,
    id:            user.id,
    email:         user.email,
    name:          user.name,
    avatar_url:    user.avatar_url,
  };
};

// ── POST /auth/register ───────────────────────────────────────────────────────
exports.register = async (req, res) => {
  try {
    const { name, email, password } = req.body;

    const existing = await User.findByEmail(email);
    if (existing) {
      return res.status(409).json({ message: 'An account with this email already exists.' });
    }

    const user = await User.createLocal({ name, email, password });
    const response = await buildAuthResponse(user);

    return res.status(201).json(response);
  } catch (error) {
    console.error('Register error:', error);
    return res.status(500).json({ message: 'Registration failed. Please try again.' });
  }
};

// ── POST /auth/login ──────────────────────────────────────────────────────────
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Fetch full row including password_hash
    const user = await User.findByEmail(email);

    if (!user || !user.password_hash) {
      return res.status(401).json({ message: 'Invalid email or password.' });
    }

    const isMatch = await User.comparePassword(password, user.password_hash);
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid email or password.' });
    }

    if (!user.is_active) {
      return res.status(403).json({ message: 'Account is deactivated.' });
    }

    const response = await buildAuthResponse(user);
    return res.status(200).json(response);
  } catch (error) {
    console.error('Login error:', error);
    return res.status(500).json({ message: 'Login failed. Please try again.' });
  }
};

// ── POST /auth/google ─────────────────────────────────────────────────────────
// Flutter sends Google idToken → we verify it → return our own JWT
exports.googleSignIn = async (req, res) => {
  try {
    const { id_token } = req.body;

    // 1. Verify the Google idToken
    const ticket = await googleClient.verifyIdToken({
      idToken:  id_token,
      audience: process.env.GOOGLE_CLIENT_ID,
    });

    const payload = ticket.getPayload();
    const { sub: googleId, email, name, picture } = payload;

    if (!email) {
      return res.status(400).json({ message: 'Could not retrieve email from Google.' });
    }

    // 2. Find existing user by googleId OR email
    let user = await User.findByEmailOrGoogleId(email, googleId);

    if (!user) {
      // New user — create Google account
      user = await User.createGoogle({
        name: name || email.split('@')[0],
        email,
        googleId,
        avatarUrl: picture || null,
      });
    } else if (!user.google_id) {
      // Existing email/password user — link Google to their account
      user = await User.linkGoogle(user.id, googleId, picture);
    }

    const response = await buildAuthResponse(user);
    return res.status(200).json(response);
  } catch (error) {
    console.error('Google sign-in error:', error);
    if (error.message?.includes('Token used too late')) {
      return res.status(401).json({ message: 'Google token expired. Please try again.' });
    }
    return res.status(401).json({ message: 'Google sign-in failed.' });
  }
};

// ── POST /auth/refresh ────────────────────────────────────────────────────────
exports.refreshToken = async (req, res) => {
  try {
    const { refresh_token } = req.body;
    if (!refresh_token) {
      return res.status(400).json({ message: 'Refresh token is required.' });
    }

    // Verify JWT signature + expiry
    const decoded = verifyRefreshToken(refresh_token);

    // Check token exists in DB (not revoked)
    const tokenRow = await User.findRefreshToken(refresh_token);
    if (!tokenRow || !tokenRow.is_active) {
      return res.status(401).json({ message: 'Invalid refresh token.' });
    }

    // Rotate: delete old, issue new
    await User.deleteRefreshToken(refresh_token);

    const user = await User.findById(decoded.sub);
    if (!user) return res.status(401).json({ message: 'User not found.' });

    const response = await buildAuthResponse(user);
    return res.status(200).json(response);
  } catch (error) {
    return res.status(401).json({ message: 'Invalid or expired refresh token.' });
  }
};

// ── POST /auth/logout ─────────────────────────────────────────────────────────
exports.logout = async (req, res) => {
  try {
    const { refresh_token } = req.body;
    if (refresh_token) {
      await User.deleteRefreshToken(refresh_token);
    }
    return res.status(200).json({ message: 'Logged out successfully.' });
  } catch (error) {
    return res.status(500).json({ message: 'Logout failed.' });
  }
};

// ── POST /auth/forgot-password ────────────────────────────────────────────────
exports.forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;

    const user = await User.findByEmail(email);

    // Always return 200 — don't reveal if email exists (security)
    if (!user || user.auth_provider === 'google') {
      return res.status(200).json({ message: 'If this email exists, an OTP has been sent.' });
    }

    const otp    = Math.floor(100000 + Math.random() * 900000).toString();
    const expiry = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    await User.saveResetOtp(user.id, otp, expiry);
    await sendOtpEmail(user.email, otp);

    return res.status(200).json({ message: 'If this email exists, an OTP has been sent.' });
  } catch (error) {
    console.error('Forgot password error:', error);
    return res.status(500).json({ message: 'Failed to send OTP.' });
  }
};

// ── POST /auth/verify-otp ─────────────────────────────────────────────────────
exports.verifyOtp = async (req, res) => {
  try {
    const { email, otp } = req.body;

    // Fetch full row including otp fields
    const { rows } = await require('../config/db').query(
      'SELECT id, reset_otp, reset_otp_expiry FROM users WHERE email = $1 LIMIT 1',
      [email.toLowerCase()]
    );
    const user = rows[0];

    if (!user || !user.reset_otp || !user.reset_otp_expiry) {
      return res.status(400).json({ message: 'Invalid or expired OTP.' });
    }
    if (user.reset_otp !== otp) {
      return res.status(400).json({ message: 'Invalid OTP.' });
    }
    if (new Date(user.reset_otp_expiry) < new Date()) {
      return res.status(400).json({ message: 'OTP has expired. Please request a new one.' });
    }

    return res.status(200).json({ message: 'OTP verified successfully.' });
  } catch (error) {
    return res.status(500).json({ message: 'OTP verification failed.' });
  }
};

// ── POST /auth/reset-password ─────────────────────────────────────────────────
exports.resetPassword = async (req, res) => {
  try {
    const { email, otp, new_password } = req.body;

    const { rows } = await require('../config/db').query(
      'SELECT id, reset_otp, reset_otp_expiry FROM users WHERE email = $1 LIMIT 1',
      [email.toLowerCase()]
    );
    const user = rows[0];

    if (!user || user.reset_otp !== otp || new Date(user.reset_otp_expiry) < new Date()) {
      return res.status(400).json({ message: 'Invalid or expired OTP.' });
    }

    await User.updatePassword(user.id, new_password);
    // Invalidate all refresh tokens — force re-login everywhere
    await User.deleteAllRefreshTokens(user.id);

    return res.status(200).json({ message: 'Password reset successfully.' });
  } catch (error) {
    return res.status(500).json({ message: 'Password reset failed.' });
  }
};
