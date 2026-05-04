import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Handles both secure (tokens) and non-sensitive (prefs) local storage.
class StorageService {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  StorageService({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences prefs,
  })  : _secureStorage = secureStorage,
        _prefs = prefs;

  // ── Secure storage (tokens) ──────────────────────────────────────────────

  Future<void> saveAuthToken(String token) =>
      _secureStorage.write(key: AppConstants.keyAuthToken, value: token);

  Future<String?> getAuthToken() =>
      _secureStorage.read(key: AppConstants.keyAuthToken);

  Future<void> saveRefreshToken(String token) =>
      _secureStorage.write(key: AppConstants.keyRefreshToken, value: token);

  Future<String?> getRefreshToken() =>
      _secureStorage.read(key: AppConstants.keyRefreshToken);

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: AppConstants.keyAuthToken);
    await _secureStorage.delete(key: AppConstants.keyRefreshToken);
  }

  // ── Shared preferences ───────────────────────────────────────────────────

  Future<void> setLoggedIn(bool value) =>
      _prefs.setBool(AppConstants.keyIsLoggedIn, value);

  bool get isLoggedIn => _prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;

  Future<void> setOnboardingDone(bool value) =>
      _prefs.setBool(AppConstants.keyOnboardingDone, value);

  bool get isOnboardingDone =>
      _prefs.getBool(AppConstants.keyOnboardingDone) ?? false;

  Future<void> saveUserId(String id) =>
      _prefs.setString(AppConstants.keyUserId, id);

  String? get userId => _prefs.getString(AppConstants.keyUserId);

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs.clear();
  }
}
