import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/storage_service.dart';

abstract class OnboardingLocalDataSource {
  Future<void> markOnboardingComplete();
  bool isOnboardingComplete();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  final StorageService _storageService;

  OnboardingLocalDataSourceImpl({required StorageService storageService})
      : _storageService = storageService;

  @override
  Future<void> markOnboardingComplete() async {
    try {
      await _storageService.setOnboardingDone(true);
    } catch (e) {
      throw CacheException(message: 'Failed to mark onboarding complete: $e');
    }
  }

  @override
  bool isOnboardingComplete() {
    return _storageService.isOnboardingDone;
  }
}
