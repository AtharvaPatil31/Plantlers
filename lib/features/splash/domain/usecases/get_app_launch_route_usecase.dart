import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/splash_repository.dart';

/// Returns the initial route string.
/// Domain layer — no StorageService, no AppRoutes import.
/// Route strings are plain constants, not infrastructure.
class GetAppLaunchRouteUseCase extends UseCase<String, NoParams> {
  final SplashRepository _repository;

  GetAppLaunchRouteUseCase(this._repository);

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    try {
      final onboardingResult = await _repository.isOnboardingComplete();
      final isOnboarded = onboardingResult.getOrElse(() => false);

      if (!isOnboarded) return const Right('/onboarding');

      final loginResult = await _repository.isUserLoggedIn();
      final isLoggedIn = loginResult.getOrElse(() => false);

      return Right(isLoggedIn ? '/home' : '/login');
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
