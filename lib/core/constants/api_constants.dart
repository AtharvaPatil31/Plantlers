class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.plantlers.com/v1';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyOtp = '/auth/verify-otp';

  // User
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile/update';
}
