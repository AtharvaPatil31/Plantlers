const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');
const { protect } = require('../middleware/auth.middleware');
const { validate, rules } = require('../middleware/validate');

// ── Public routes ─────────────────────────────────────────────────────────────
router.post('/register',        validate(rules.register),        authController.register);
router.post('/login',           validate(rules.login),           authController.login);
router.post('/google',          validate(rules.google),          authController.googleSignIn);
router.post('/refresh',                                          authController.refreshToken);
router.post('/forgot-password', validate(rules.forgotPassword),  authController.forgotPassword);
router.post('/verify-otp',      validate(rules.verifyOtp),       authController.verifyOtp);
router.post('/reset-password',  validate(rules.resetPassword),   authController.resetPassword);

// ── Protected routes ──────────────────────────────────────────────────────────
router.post('/logout', protect, authController.logout);

module.exports = router;
