import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

/// Domain contract — returns plain strings, no infrastructure knowledge.
abstract class SplashRepository {
  Future<Either<Failure, bool>> isOnboardingComplete();
  Future<Either<Failure, bool>> isUserLoggedIn();
}
