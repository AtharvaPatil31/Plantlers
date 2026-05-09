import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
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
  final SupabaseClient _supabase;

  AuthRemoteDataSourceImpl({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;
  final Dio _dio;
  final FirebaseAuth _firebaseAuth;

  AuthRemoteDataSourceImpl({
    required Dio dio,
    FirebaseAuth? firebaseAuth,
  })  : _dio = dio,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // ── Email / Password ──────────────────────────────────────────────────────

  // ── Email / Password Login ────────────────────────────────────────────────
  @override
  Future<AuthModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user    = response.user;
      final session = response.session;

      if (user == null || session == null) {
        throw const ServerException(message: 'Login failed. Please try again.');
      }

      return AuthModel(
        id:           user.id,
        email:        user.email ?? email,
        name:         user.userMetadata?['name'] as String?,
        avatarUrl:    user.userMetadata?['avatar_url'] as String?,
        accessToken:  session.accessToken,
        refreshToken: session.refreshToken ?? '',
      );
    } on AuthException catch (e) {
      throw ServerException(message: _mapAuthError(e.message));
    } catch (e) {
      if (e is ServerException) rethrow;
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
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'name': name.trim()},
      );

      final user    = response.user;
      final session = response.session;

      if (user == null) {
        throw const ServerException(
            message: 'Registration failed. Please try again.');
      }

      // If email confirmation is OFF in Supabase → session is available immediately
      // If email confirmation is ON  → session is null, user must confirm email first
      if (session == null) {
        throw const ServerException(
          message:
              'Account created! Please check your email and confirm your account before logging in.',
        );
      }

      return AuthModel(
        id:           user.id,
        email:        user.email ?? email,
        name:         name.trim(),
        avatarUrl:    null,
        accessToken:  session.accessToken,
        refreshToken: session.refreshToken ?? '',
      );
    } on AuthException catch (e) {
      throw ServerException(message: _mapAuthError(e.message));
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Registration failed: $e');
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  @override
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      throw ServerException(message: e.message);
    }
  }

  // ── Forgot password ───────────────────────────────────────────────────────
  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email.trim());
    } on AuthException catch (e) {
      throw ServerException(message: e.message);
      await _dio.post(ApiConstants.forgotPassword, data: {'email': email});
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] as String? ?? e.message ?? 'Failed to send OTP.',
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
      await _supabase.auth.verifyOTP(
        email: email.trim(),
        token: otp,
        type: OtpType.recovery,
      await _dio.post(ApiConstants.verifyOtp, data: {'email': email, 'otp': otp});
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] as String? ?? e.message ?? 'OTP verification failed.',
        statusCode: e.response?.statusCode,
      );
    } on AuthException catch (e) {
      throw ServerException(message: _mapAuthError(e.message));
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
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw ServerException(message: _mapAuthError(e.message));
    }
  }

  // ── Google Sign-In ────────────────────────────────────────────────────────
  @override
  Future<GoogleAuthModel> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.plantlers://login-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      // Wait for the auth state change after the deep link redirect
      AuthState? oauthResult;
      try {
        oauthResult = await _supabase.auth.onAuthStateChange
            .where((e) =>
                e.event == AuthChangeEvent.signedIn ||
                e.event == AuthChangeEvent.tokenRefreshed)
            .timeout(
              const Duration(seconds: 60),
              onTimeout: (sink) => sink.close(),
            )
            .first;
      } on StateError {
        throw const ServerException(
            message: 'Google sign-in timed out. Please try again.');
      }

      final session = oauthResult?.session;
      final user    = oauthResult?.session?.user;

      if (user == null || session == null) {
        throw const ServerException(message: 'Google sign-in failed.');
      }

      return GoogleAuthModel(
        id:           user.id,
        email:        user.email ?? '',
        displayName:  user.userMetadata?['full_name'] as String? ??
                      user.userMetadata?['name'] as String?,
        photoUrl:     user.userMetadata?['avatar_url'] as String?,
        idToken:      session.accessToken,
        refreshToken: session.refreshToken ?? '',
      );
    } on AuthException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      if (e is ServerException) rethrow;
      final msg = e.toString();
      if (msg.contains('canceled') || msg.contains('cancelled')) {
        throw const ServerException(message: 'Google sign-in was cancelled.');
      }
      throw ServerException(message: 'Google sign-in failed: $e');
    }
  }

  @override
  Future<void> signOutGoogle() async => logout();

  // ── Map Supabase errors to readable messages ──────────────────────────────
  String _mapAuthError(String message) {
    final m = message.toLowerCase();
    if (m.contains('invalid login credentials') ||
        m.contains('invalid email or password')) {
      return 'Invalid email or password.';
    }
    if (m.contains('email already registered') ||
        m.contains('already been registered') ||
        m.contains('user already registered')) {
      return 'An account with this email already exists.';
    }
    if (m.contains('email not confirmed')) {
      return 'Please confirm your email before logging in.';
    }
    if (m.contains('token has expired') || m.contains('otp expired')) {
      return 'OTP has expired. Please request a new one.';
    }
    if (m.contains('token is invalid') || m.contains('otp is invalid')) {
      return 'Invalid OTP. Please try again.';
    }
    if (m.contains('password should be at least')) {
      return 'Password must be at least 6 characters.';
    }
    return message;
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
