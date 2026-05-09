import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/entities/google_auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource  _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource  localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource  = localDataSource;

  // ── Login ─────────────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, AuthEntity>> login({
    required String email,
    required String password,
  }) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final model = await _remoteDataSource.login(
        email: email,
        password: password,
      );
      await _localDataSource.cacheAuthData(
        userId:       model.id,
        accessToken:  model.accessToken,
        refreshToken: model.refreshToken,
      );
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  // ── Register ──────────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, AuthEntity>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final model = await _remoteDataSource.register(
        email:    email,
        password: password,
        name:     name,
      );
      await _localDataSource.cacheAuthData(
        userId:       model.id,
        accessToken:  model.accessToken,
        refreshToken: model.refreshToken,
      );
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
      await _localDataSource.clearAuthData();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  // ── Get current user (from Supabase session) ──────────────────────────────
  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        return const Left(UnauthorizedFailure());
      }
      return Right(AuthEntity(
        id:        user.id,
        email:     user.email ?? '',
        name:      user.userMetadata?['name'] as String?,
        avatarUrl: user.userMetadata?['avatar_url'] as String?,
      ));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
    return const Left(UnknownFailure(message: 'getCurrentUser not implemented yet.'));
  }

  // ── Forgot password ───────────────────────────────────────────────────────
  @override
  Future<Either<Failure, void>> forgotPassword({required String email}) async {
    try {
      await _remoteDataSource.forgotPassword(email: email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  // ── Verify OTP ────────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, void>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      await _remoteDataSource.verifyOtp(email: email, otp: otp);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  // ── Reset password ────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.resetPassword(
        email:       email,
        otp:         otp,
        newPassword: newPassword,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  // ── Google Sign-In ────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, GoogleAuthEntity>> signInWithGoogle() async {
    try {
      final model = await _remoteDataSource.signInWithGoogle();
      await _localDataSource.cacheAuthData(
        userId:       model.id,
        accessToken:  model.idToken,
        refreshToken: model.refreshToken,
      );
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  // ── Google Sign-Out ───────────────────────────────────────────────────────
  @override
  Future<Either<Failure, void>> signOutGoogle() async {
    try {
      await _remoteDataSource.signOutGoogle();
      await _localDataSource.clearAuthData();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, GoogleAuthEntity>> signInWithGoogle() async {
    try {
      final model = await _remoteDataSource.signInWithGoogle();
      // Cache user as logged in after Google sign-in
      await _localDataSource.cacheAuthData(
        userId: model.id,
        accessToken: model.idToken,
        refreshToken: model.idToken, // Firebase handles refresh internally
      );
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> signOutGoogle() async {
    try {
      await _remoteDataSource.signOutGoogle();
      await _localDataSource.clearAuthData();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
