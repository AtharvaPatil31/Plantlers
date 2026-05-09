const validator = require('validator');

/**
 * Lightweight request body validator.
 * Returns 400 with the first validation error found.
 *
 * Usage:
 *   router.post('/register', validate(registerRules), authController.register);
 */

const validate = (rules) => (req, res, next) => {
  for (const [field, checks] of Object.entries(rules)) {
    const value = req.body[field];

    for (const check of checks) {
      const error = check(value, field);
      if (error) {
        return res.status(400).json({ message: error });
      }
    }
  }
  next();
};

// ── Reusable rule factories ───────────────────────────────────────────────────

const required = (field) => (value) =>
  value === undefined || value === null || String(value).trim() === ''
    ? `${field} is required.`
    : null;

const isEmail = (value, field) =>
  value && !validator.isEmail(String(value)) ? `${field} must be a valid email.` : null;

const minLength = (min) => (value, field) =>
  value && String(value).length < min
    ? `${field} must be at least ${min} characters.`
    : null;

const maxLength = (max) => (value, field) =>
  value && String(value).length > max
    ? `${field} cannot exceed ${max} characters.`
    : null;

const isStrongPassword = (value, field) => {
  if (!value) return null;
  const ok =
    value.length >= 8 &&
    /[A-Z]/.test(value) &&
    /[0-9]/.test(value);
  return ok
    ? null
    : `${field} must be at least 8 characters with one uppercase letter and one number.`;
};

// ── Validation rule sets ──────────────────────────────────────────────────────

const registerRules = {
  name: [required('Name'), maxLength(100)],
  email: [required('Email'), isEmail],
  password: [required('Password'), minLength(8), isStrongPassword],
};

const loginRules = {
  email: [required('Email'), isEmail],
  password: [required('Password')],
};

const forgotPasswordRules = {
  email: [required('Email'), isEmail],
};

const verifyOtpRules = {
  email: [required('Email'), isEmail],
  otp: [required('OTP'), minLength(6), maxLength(6)],
};

const resetPasswordRules = {
  email: [required('Email'), isEmail],
  otp: [required('OTP')],
  new_password: [required('new_password'), minLength(8), isStrongPassword],
};

const googleRules = {
  id_token: [required('id_token')],
};

const updateProfileRules = {
  name: [maxLength(100)],
};

module.exports = {
  validate,
  rules: {
    register: registerRules,
    login: loginRules,
    forgotPassword: forgotPasswordRules,
    verifyOtp: verifyOtpRules,
    resetPassword: resetPasswordRules,
    google: googleRules,
    updateProfile: updateProfileRules,
  },
};
