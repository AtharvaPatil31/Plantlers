import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/storage_service.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheAuthData({
    required String userId,
    required String accessToken,
    required String refreshToken,
  });
  Future<void> clearAuthData();
  bool get isLoggedIn;
  String? get cachedUserId;
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final StorageService _storageService;

  AuthLocalDataSourceImpl({required StorageService storageService})
      : _storageService = storageService;

  @override
  Future<void> cacheAuthData({
    required String userId,
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await Future.wait([
        _storageService.saveAuthToken(accessToken),
        _storageService.saveRefreshToken(refreshToken),
        _storageService.saveUserId(userId),
        _storageService.setLoggedIn(true),
      ]);
    } catch (e) {
      throw CacheException(message: 'Failed to cache auth data: $e');
    }
  }

  @override
  Future<void> clearAuthData() async {
    try {
      await _storageService.clearAll();
    } catch (e) {
      throw CacheException(message: 'Failed to clear auth data: $e');
    }
  }

  @override
  bool get isLoggedIn => _storageService.isLoggedIn;

  @override
  String? get cachedUserId => _storageService.userId;
}
