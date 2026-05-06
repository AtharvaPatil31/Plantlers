import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../router/app_router.dart';
import '../services/storage_service.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/forgot_password_bloc.dart';

import '../../features/onboarding/data/datasources/onboarding_local_datasource.dart';
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import '../../features/onboarding/presentation/bloc/onboarding_bloc.dart';

import '../../features/splash/data/datasources/splash_local_datasource.dart';
import '../../features/splash/data/repositories/splash_repository_impl.dart';
import '../../features/splash/domain/repositories/splash_repository.dart';
import '../../features/splash/domain/usecases/get_app_launch_route_usecase.dart';

import '../../features/home/data/datasources/home_local_datasource.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_plants_usecase.dart';
import '../../features/home/domain/usecases/filter_plants_usecase.dart';
import '../../features/home/domain/usecases/search_plants_usecase.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── External ─────────────────────────────────────────────────────────────
  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPrefs);
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // ── Core ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<StorageService>(
    () => StorageService(
      secureStorage: sl<FlutterSecureStorage>(),
      prefs: sl<SharedPreferences>(),
    ),
  );
  sl.registerLazySingleton<DioClient>(
    () => DioClient(storageService: sl<StorageService>()),
  );
  sl.registerLazySingleton<Dio>(() => sl<DioClient>().dio);
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectivity: sl<Connectivity>()),
  );
  sl.registerLazySingleton<GoRouter>(
    () => createRouter(storageService: sl<StorageService>()),
  );

  // ── Features ─────────────────────────────────────────────────────────────
  _initSplash();
  _initOnboarding();
  _initAuth();
  _initHome();
}

void _initSplash() {
  sl.registerLazySingleton<SplashLocalDataSource>(
    () => SplashLocalDataSourceImpl(storageService: sl<StorageService>()),
  );
  sl.registerLazySingleton<SplashRepository>(
    () => SplashRepositoryImpl(localDataSource: sl<SplashLocalDataSource>()),
  );
  sl.registerLazySingleton(
    () => GetAppLaunchRouteUseCase(sl<SplashRepository>()),
  );
}

void _initOnboarding() {
  sl.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSourceImpl(storageService: sl<StorageService>()),
  );
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(
      localDataSource: sl<OnboardingLocalDataSource>(),
    ),
  );
  sl.registerLazySingleton(
    () => CompleteOnboardingUseCase(sl<OnboardingRepository>()),
  );
  sl.registerFactory(
    () => OnboardingBloc(
      completeOnboardingUseCase: sl<CompleteOnboardingUseCase>(),
    ),
  );
}

void _initAuth() {
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(storageService: sl<StorageService>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => VerifyOtpUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl<AuthRepository>()));
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl<LoginUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
      registerUseCase: sl<RegisterUseCase>(),
    ),
  );
  sl.registerFactory(
    () => ForgotPasswordBloc(
      forgotPasswordUseCase: sl<ForgotPasswordUseCase>(),
      verifyOtpUseCase: sl<VerifyOtpUseCase>(),
      resetPasswordUseCase: sl<ResetPasswordUseCase>(),
    ),
  );
}

void _initHome() {
  sl.registerLazySingleton<HomeLocalDataSource>(
    () => HomeLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(localDataSource: sl<HomeLocalDataSource>()),
  );
  sl.registerLazySingleton(() => GetPlantsUseCase(sl<HomeRepository>()));
  sl.registerLazySingleton(() => FilterPlantsUseCase(sl<HomeRepository>()));
  sl.registerLazySingleton(() => SearchPlantsUseCase(sl<HomeRepository>()));
  sl.registerFactory(
    () => HomeBloc(
      getPlantsUseCase: sl<GetPlantsUseCase>(),
      filterPlantsUseCase: sl<FilterPlantsUseCase>(),
      searchPlantsUseCase: sl<SearchPlantsUseCase>(),
    ),
  );
}
