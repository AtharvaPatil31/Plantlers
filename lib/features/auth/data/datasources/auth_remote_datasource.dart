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
  Future<void> logout({required String refreshToken});
  Future<void> forgotPassword({required String email});
  Future<void> verifyOtp({required String email, required String otp});
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });
  Future<GoogleAuthModel> signInWithGoogle();
  Future<void> signOutGoogle();
  Future<AuthModel> refreshToken({required String refreshToken});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl({
    required Dio dio,
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _dio = dio,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  // ── Email / Password Login ────────────────────────────────────────────────
  @override
  Future<AuthModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      return AuthModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] as String? ?? 
                 e.message ?? 
                 'Login failed. Please try again.',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: 'Login failed: $e');
    }
  }

  // ── Email / Password Register ─────────────────────────────────────────────
  @override
  Future<AuthModel> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'email': email.trim(),
          'password': password,
          'name': name.trim(),
        },
      );

      return AuthModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] as String? ?? 
                 e.message ?? 
                 'Registration failed. Please try again.',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: 'Registration failed: $e');
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  @override
  Future<void> logout({required String refreshToken}) async {
    try {
      await _dio.post(
        ApiConstants.logout,
        data: {'refresh_token': refreshToken},
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] as String? ?? 
                 e.message ?? 
                 'Logout failed.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // ── Forgot password ───────────────────────────────────────────────────────
  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await _dio.post(
        ApiConstants.forgotPassword,
        data: {'email': email.trim()},
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] as String? ?? 
                 e.message ?? 
                 'Failed to send OTP.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // ── Verify OTP ────────────────────────────────────────────────────────────
  @override
  Future<void> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      await _dio.post(
        ApiConstants.verifyOtp,
        data: {
          'email': email.trim(),
          'otp': otp,
        },
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] as String? ?? 
                 e.message ?? 
                 'OTP verification failed.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // ── Reset password ────────────────────────────────────────────────────────
  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      await _dio.post(
        ApiConstants.resetPassword,
        data: {
          'email': email.trim(),
          'otp': otp,
          'new_password': newPassword,
        },
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] as String? ?? 
                 e.message ?? 
                 'Password reset failed.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // ── Refresh Token ─────────────────────────────────────────────────────────
  @override
  Future<AuthModel> refreshToken({required String refreshToken}) async {
    try {
      final response = await _dio.post(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      return AuthModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] as String? ?? 
                 e.message ?? 
                 'Session expired. Please login again.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // ── Google Sign-In ────────────────────────────────────────────────────────
  @override
  Future<GoogleAuthModel> signInWithGoogle() async {
    try {
      // 1. Trigger Google Sign-In flow (native Android picker)
      final googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw const ServerException(message: 'Google sign-in was cancelled.');
      }

      // 2. Get authentication details
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw const ServerException(message: 'Failed to get Google ID token.');
      }

      // 3. Sign in to Firebase using the credential
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw const ServerException(message: 'Firebase sign-in returned no user.');
      }

      // 4. Get Firebase ID token (fresh token for backend verification)
      final firebaseIdToken = await user.getIdToken();

      if (firebaseIdToken == null) {
        throw const ServerException(message: 'Failed to get Firebase token.');
      }

      // 5. Send Firebase ID token to your backend for verification
      final response = await _dio.post(
        ApiConstants.googleSignIn,
        data: {'id_token': firebaseIdToken},
      );

      // 6. Return Google auth model with backend's response
      return GoogleAuthModel.fromJson(response.data);
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
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] as String? ?? 
                 e.message ?? 
                 'Google sign-in failed.',
        statusCode: e.response?.statusCode,
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
        _googleSignIn.signOut(),
        _firebaseAuth.signOut(),
      ]);
    } catch (e) {
      throw ServerException(message: 'Sign-out failed: $e');
    }
  }
}

