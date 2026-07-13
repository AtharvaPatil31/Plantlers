const { OAuth2Client } = require('google-auth-library');
const { User, RefreshToken } = require('../models');
const { signAccessToken, signRefreshToken, verifyRefreshToken } = require('../utils/jwt');
const { sendOtpEmail } = require('../utils/email');

const googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

// ── Helper: build auth response + store refresh token ────────────────────────
const buildAuthResponse = async (user) => {
  const accessToken  = signAccessToken(user._id);
  const refreshToken = signRefreshToken(user._id);

  await RefreshToken.addToken(user._id, refreshToken);

  return {
    access_token:  accessToken,
    refresh_token: refreshToken,
    id:            user._id,
    email:         user.email,
    name:          user.name,
    avatar_url:    user.avatarUrl,
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

    const user = await User.create({
      name,
      email,
      passwordHash: password,
      authProvider: 'local'
    });

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

    // Fetch user including password hash
    const user = await User.findOne({ email: email.toLowerCase() }).select('+passwordHash');

    if (!user || !user.passwordHash) {
      return res.status(401).json({ message: 'Invalid email or password.' });
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid email or password.' });
    }

    if (!user.isActive) {
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
      user = await User.create({
        name: name || email.split('@')[0],
        email,
        googleId,
        avatarUrl: picture || null,
        authProvider: 'google'
      });
    } else if (!user.googleId) {
      // Existing email/password user — link Google to their account
      user.googleId = googleId;
      user.authProvider = 'google';
      if (picture && !user.avatarUrl) {
        user.avatarUrl = picture;
      }
      await user.save();
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
    const tokenDoc = await RefreshToken.findWithUser(refresh_token);
    if (!tokenDoc || !tokenDoc.userId.isActive) {
      return res.status(401).json({ message: 'Invalid refresh token.' });
    }

    // Rotate: delete old, issue new
    await RefreshToken.deleteOne({ token: refresh_token });

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
      await RefreshToken.deleteOne({ token: refresh_token });
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
    if (!user || user.authProvider === 'google') {
      return res.status(200).json({ message: 'If this email exists, an OTP has been sent.' });
    }

    const otp    = Math.floor(100000 + Math.random() * 900000).toString();
    const expiry = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    user.resetOtp = otp;
    user.resetOtpExpiry = expiry;
    await user.save();

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

    const user = await User.findOne({ 
      email: email.toLowerCase(),
      resetOtp: { $ne: null },
      resetOtpExpiry: { $ne: null }
    }).select('+resetOtp +resetOtpExpiry');

    if (!user || !user.resetOtp || !user.resetOtpExpiry) {
      return res.status(400).json({ message: 'Invalid or expired OTP.' });
    }
    if (user.resetOtp !== otp) {
      return res.status(400).json({ message: 'Invalid OTP.' });
    }
    if (new Date(user.resetOtpExpiry) < new Date()) {
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

    const user = await User.findOne({ 
      email: email.toLowerCase() 
    }).select('+resetOtp +resetOtpExpiry');

    if (!user || user.resetOtp !== otp || new Date(user.resetOtpExpiry) < new Date()) {
      return res.status(400).json({ message: 'Invalid or expired OTP.' });
    }

    // Update password and clear OTP fields
    user.passwordHash = new_password; // Will be hashed by pre-save middleware
    user.resetOtp = null;
    user.resetOtpExpiry = null;
    await user.save();

    // Invalidate all refresh tokens — force re-login everywhere
    await RefreshToken.deleteMany({ userId: user._id });

    return res.status(200).json({ message: 'Password reset successfully.' });
  } catch (error) {
    return res.status(500).json({ message: 'Password reset failed.' });
  }
};
