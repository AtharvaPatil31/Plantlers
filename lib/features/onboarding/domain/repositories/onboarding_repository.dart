import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class OnboardingRepository {
  Future<Either<Failure, void>> completeOnboarding();
  Future<Either<Failure, bool>> isOnboardingComplete(); // async — consistent API
}
