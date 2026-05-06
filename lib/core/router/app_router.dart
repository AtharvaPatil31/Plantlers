import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/storage_service.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import 'app_routes.dart';

GoRouter createRouter({required StorageService storageService}) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: kDebugMode,
    // Redirect only guards protected routes — splash handles its own navigation
    redirect: (context, state) {
      final location = state.uri.toString();

      // Let splash and onboarding through unconditionally
      if (location == AppRoutes.splash || location == AppRoutes.onboarding) {
        return null;
      }

      final isLoggedIn = storageService.isLoggedIn;
      final isOnboardingDone = storageService.isOnboardingDone;

      // Not onboarded → onboarding
      if (!isOnboardingDone) return AppRoutes.onboarding;

      final isOnAuthScreen = location == AppRoutes.login ||
          location == AppRoutes.signup ||
          location == AppRoutes.forgotPassword;

      // Onboarded but not logged in → login (unless already on auth screen)
      if (!isLoggedIn && !isOnAuthScreen) return AppRoutes.login;

      // Logged in but on auth screen → home
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
      body: Center(
        child: Text('Route not found: ${state.uri}'),
      ),
    ),
  );
}
