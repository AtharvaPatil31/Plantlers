import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_datasource.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource _localDataSource;

  OnboardingRepositoryImpl({required OnboardingLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<Either<Failure, void>> completeOnboarding() async {
    try {
      await _localDataSource.markOnboardingComplete();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> isOnboardingComplete() async {
    try {
      return Right(_localDataSource.isOnboardingComplete());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }
}
