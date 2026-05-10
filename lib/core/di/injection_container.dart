import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../router/app_router.dart';
import '../services/storage_service.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/domain/usecases/google_sign_in_usecase.dart';
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
import '../../features/home/domain/usecases/get_search_suggestions_usecase.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';

import '../../features/explore/data/datasources/explore_local_datasource.dart';
import '../../features/explore/data/repositories/explore_repository_impl.dart';
import '../../features/explore/domain/repositories/explore_repository.dart';
import '../../features/explore/domain/usecases/get_explore_data_usecase.dart';
import '../../features/explore/domain/usecases/filter_explore_usecase.dart';
import '../../features/explore/presentation/bloc/explore_bloc.dart';

import '../../features/cart/data/datasources/cart_local_datasource.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/domain/usecases/cart_usecases.dart';
import '../../features/cart/presentation/bloc/cart_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── External ─────────────────────────────────────────────────────────────
  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPrefs);
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // ── Core ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<StorageService>(
    () => StorageService(
      secureStorage: sl<FlutterSecureStorage>(),
      prefs: sl<SharedPreferences>(),
    ),
  );
  sl.registerLazySingleton<GoRouter>(
    () => createRouter(storageService: sl<StorageService>()),
  );

  // ── Features ─────────────────────────────────────────────────────────────
  _initSplash();
  _initOnboarding();
  _initAuth();
  _initHome();
  _initExplore();
  _initCart();
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
  // Supabase-backed remote datasource — no Dio, no Node.js
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(storageService: sl<StorageService>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource:  sl<AuthLocalDataSource>(),
    ),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => VerifyOtpUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GoogleSignInUseCase(sl<AuthRepository>()));
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase:        sl<LoginUseCase>(),
      logoutUseCase:       sl<LogoutUseCase>(),
      registerUseCase:     sl<RegisterUseCase>(),
      googleSignInUseCase: sl<GoogleSignInUseCase>(),
    ),
  );
  sl.registerFactory(
    () => ForgotPasswordBloc(
      forgotPasswordUseCase: sl<ForgotPasswordUseCase>(),
      verifyOtpUseCase:      sl<VerifyOtpUseCase>(),
      resetPasswordUseCase:  sl<ResetPasswordUseCase>(),
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
  sl.registerLazySingleton(
    () => GetSearchSuggestionsUseCase(sl<HomeRepository>()),
  );
  sl.registerFactory(
    () => HomeBloc(
      getPlantsUseCase:      sl<GetPlantsUseCase>(),
      filterPlantsUseCase:   sl<FilterPlantsUseCase>(),
      searchPlantsUseCase:   sl<SearchPlantsUseCase>(),
      getSuggestionsUseCase: sl<GetSearchSuggestionsUseCase>(),
    ),
  );
}

void _initExplore() {
  sl.registerLazySingleton<ExploreLocalDataSource>(
    () => ExploreLocalDataSourceImpl(
      homeDataSource: sl<HomeLocalDataSource>(),
    ),
  );
  sl.registerLazySingleton<ExploreRepository>(
    () => ExploreRepositoryImpl(dataSource: sl<ExploreLocalDataSource>()),
  );
  sl.registerLazySingleton(
    () => GetExploreDataUseCase(sl<ExploreRepository>()),
  );
  sl.registerLazySingleton(
    () => FilterExploreByCategoryUseCase(sl<ExploreRepository>()),
  );
  sl.registerLazySingleton(
    () => SearchExploreUseCase(sl<ExploreRepository>()),
  );
  sl.registerLazySingleton(
    () => GetPlantsByCareLevelUseCase(sl<ExploreRepository>()),
  );
  sl.registerLazySingleton(
    () => GetPlantsByRoomUseCase(sl<ExploreRepository>()),
  );
  sl.registerFactory(
    () => ExploreBloc(
      getExploreData:   sl<GetExploreDataUseCase>(),
      filterByCategory: sl<FilterExploreByCategoryUseCase>(),
      searchPlants:     sl<SearchExploreUseCase>(),
      getByLevel:       sl<GetPlantsByCareLevelUseCase>(),
      getByRoom:        sl<GetPlantsByRoomUseCase>(),
    ),
  );
}

void _initCart() {
  sl.registerLazySingleton<CartLocalDataSource>(
    () => CartLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(
      cartDataSource: sl<CartLocalDataSource>(),
      homeDataSource: sl<HomeLocalDataSource>(),
    ),
  );
  sl.registerLazySingleton(() => GetCartUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(() => AddToCartUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(() => RemoveFromCartUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(() => UpdateCartQtyUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(() => ApplyPromoUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(() => RemovePromoUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(() => ClearCartUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(
      () => GetCartSuggestionsUseCase(sl<CartRepository>()));
  sl.registerFactory(
    () => CartBloc(
      getCart:        sl<GetCartUseCase>(),
      addItem:        sl<AddToCartUseCase>(),
      removeItem:     sl<RemoveFromCartUseCase>(),
      updateQty:      sl<UpdateCartQtyUseCase>(),
      applyPromo:     sl<ApplyPromoUseCase>(),
      removePromo:    sl<RemovePromoUseCase>(),
      clearCart:      sl<ClearCartUseCase>(),
      getSuggestions: sl<GetCartSuggestionsUseCase>(),
    ),
  );
}
