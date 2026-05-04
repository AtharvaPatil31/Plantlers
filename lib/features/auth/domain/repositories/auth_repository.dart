import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_entity.dart';

/// Abstract contract — domain layer owns this, data layer implements it.
abstract class AuthRepository {
  Future<Either<Failure, AuthEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthEntity>> register({
    required String email,
    required String password,
    required String name,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, AuthEntity>> getCurrentUser();

  /// Sends OTP to the given email for password reset.
  Future<Either<Failure, void>> forgotPassword({required String email});

  /// Verifies the OTP entered by the user.
  Future<Either<Failure, void>> verifyOtp({
    required String email,
    required String otp,
  });

  /// Resets the password after OTP verification.
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });
}
