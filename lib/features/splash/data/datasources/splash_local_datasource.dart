import '../../../../core/services/storage_service.dart';

abstract class SplashLocalDataSource {
  bool isOnboardingComplete();
  bool isUserLoggedIn();
}

class SplashLocalDataSourceImpl implements SplashLocalDataSource {
  final StorageService _storageService;

  SplashLocalDataSourceImpl({required StorageService storageService})
      : _storageService = storageService;

  @override
  bool isOnboardingComplete() => _storageService.isOnboardingDone;

  @override
  bool isUserLoggedIn() => _storageService.isLoggedIn;
}
