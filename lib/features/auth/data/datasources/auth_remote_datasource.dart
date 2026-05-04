import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/auth_model.dart';
import '../models/google_auth_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> login({required String email, required String password});
  Future<AuthModel> register({
    required String email,
    required String password,
    required String name,
  });
  Future<void> logout();
  Future<void> forgotPassword({required String email});
  Future<void> verifyOtp({required String email, required String otp});
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });
  Future<GoogleAuthModel> signInWithGoogle();
  Future<void> signOutGoogle();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;
  final FirebaseAuth _firebaseAuth;

  AuthRemoteDataSourceImpl({
    required Dio dio,
    FirebaseAuth? firebaseAuth,
  })  : _dio = dio,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // ── Email / Password ──────────────────────────────────────────────────────

  @override
  Future<AuthModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      return AuthModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] as String? ?? e.message ?? 'Login failed.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<AuthModel> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {'email': email, 'password': password, 'name': name},
      );
      return AuthModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] as String? ?? e.message ?? 'Registration failed.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] as String? ?? e.message ?? 'Logout failed.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await _dio.post(ApiConstants.forgotPassword, data: {'email': email});
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] as String? ?? e.message ?? 'Failed to send OTP.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> verifyOtp({required String email, required String otp}) async {
    try {
      await _dio.post(ApiConstants.verifyOtp, data: {'email': email, 'otp': otp});
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] as String? ?? e.message ?? 'OTP verification failed.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      await _dio.post(
        ApiConstants.resetPassword,
        data: {'email': email, 'otp': otp, 'new_password': newPassword},
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] as String? ?? e.message ?? 'Password reset failed.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // ── Google Sign-In ────────────────────────────────────────────────────────

  @override
  Future<GoogleAuthModel> signInWithGoogle() async {
    try {
      // Triggers the native Android account picker (no browser redirect)
      final googleUser = await GoogleSignIn.instance.authenticate();

      // googleUser.authentication holds the idToken (OpenID Connect)
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw const ServerException(message: 'Failed to get Google ID token.');
      }

      // Sign in to Firebase using the idToken
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw const ServerException(message: 'Firebase sign-in returned no user.');
      }

      final firebaseIdToken = await user.getIdToken();

      return GoogleAuthModel(
        id: user.uid,
        email: user.email ?? googleUser.email,
        displayName: user.displayName ?? googleUser.displayName,
        photoUrl: user.photoURL ?? googleUser.photoUrl,
        idToken: firebaseIdToken ?? idToken,
      );
    } on ServerException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'canceled' || e.code == 'sign_in_canceled') {
        throw const ServerException(message: 'Google sign-in was cancelled.');
      }
      throw ServerException(
        message: e.message ?? 'Firebase authentication failed.',
        statusCode: int.tryParse(e.code),
      );
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('canceled') || msg.contains('cancelled')) {
        throw const ServerException(message: 'Google sign-in was cancelled.');
      }
      throw ServerException(message: 'Google sign-in failed: $e');
    }
  }

  @override
  Future<void> signOutGoogle() async {
    try {
      await Future.wait([
        GoogleSignIn.instance.signOut(),
        _firebaseAuth.signOut(),
      ]);
    } catch (e) {
      throw ServerException(message: 'Sign-out failed: $e');
    }
  }
}
