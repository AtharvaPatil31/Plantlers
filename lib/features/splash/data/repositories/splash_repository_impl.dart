import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/splash_repository.dart';
import '../datasources/splash_local_datasource.dart';

class SplashRepositoryImpl implements SplashRepository {
  final SplashLocalDataSource _localDataSource;

  SplashRepositoryImpl({required SplashLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<Either<Failure, bool>> isOnboardingComplete() async {
    try {
      return Right(_localDataSource.isOnboardingComplete());
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isUserLoggedIn() async {
    try {
      return Right(_localDataSource.isUserLoggedIn());
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
