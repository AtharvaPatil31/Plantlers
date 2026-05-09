import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/storage_service.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import 'app_routes.dart';

GoRouter createRouter({required StorageService storageService}) {
  final authNotifier = _SupabaseAuthNotifier();

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final location = state.uri.toString();

      // Splash handles its own navigation — never redirect it
      if (location == AppRoutes.splash) return null;

      // Onboarding: let it through unconditionally
      if (location == AppRoutes.onboarding) return null;

      // ── Onboarding guard ────────────────────────────────────────────────
      if (!storageService.isOnboardingDone) return AppRoutes.onboarding;

      // ── Auth guard — Supabase session is the ONLY source of truth ───────
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null && !_isSessionExpired(session);

      final isOnAuthScreen = location == AppRoutes.login ||
          location == AppRoutes.signup ||
          location == AppRoutes.forgotPassword;

      // Not logged in and trying to access protected route → login
      if (!isLoggedIn && !isOnAuthScreen) return AppRoutes.login;

      // Logged in and on auth screen → go home
      if (isLoggedIn && isOnAuthScreen) return AppRoutes.home;

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splashName,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRoutes.onboardingName,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.loginName,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: AppRoutes.signupName,
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: AppRoutes.forgotPasswordName,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: AppRoutes.homeName,
        builder: (context, state) => const HomePage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.uri}')),
    ),
  );
}

/// Returns true if the session's access token is expired.
bool _isSessionExpired(Session session) {
  final expiresAt = session.expiresAt;
  if (expiresAt == null) return false;
  // expiresAt is Unix timestamp in seconds
  final expiry = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
  return DateTime.now().isAfter(expiry);
}

// ── Notifier: triggers GoRouter redirect on every Supabase auth event ─────────
class _SupabaseAuthNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthState> _sub;

  _SupabaseAuthNotifier() {
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      // signedIn, signedOut, tokenRefreshed, userUpdated, passwordRecovery
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
