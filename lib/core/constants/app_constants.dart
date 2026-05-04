class AppConstants {
  AppConstants._();

  static const String appName = 'Plantlers';
  static const String appVersion = '1.0.0';

  // Shared Preferences Keys
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyAuthToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyOnboardingDone = 'onboarding_done';

  // Timeouts
  static const int connectTimeoutMs = 30000;
  static const int receiveTimeoutMs = 30000;
}
