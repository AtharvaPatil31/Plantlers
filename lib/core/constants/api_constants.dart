class ApiConstants {
  ApiConstants._();

  // ── Base URL ───────────────────────────────────────────────────────────────
  // Development: your local machine IP (not localhost — Android can't reach it)
  // Run `ipconfig` on Windows → use your IPv4 address e.g. 192.168.1.5
  static const String baseUrl = 'http://192.168.1.5:3000/v1';

  // Production (update when deployed to Railway/Render):
  // static const String baseUrl = 'https://plantlers-api.railway.app/v1';

  // ── Auth ───────────────────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String googleSignIn = '/auth/google'; // ← your backend, not Firebase

  // ── User ───────────────────────────────────────────────────────────────────
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile/update';

  // ── Plants ─────────────────────────────────────────────────────────────────
  static const String plants = '/plants';
}
