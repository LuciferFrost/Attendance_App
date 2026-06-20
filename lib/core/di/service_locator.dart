import 'package:demo4/core/config/app_environment.dart';
import 'package:demo4/core/network/api_client.dart';
import 'package:demo4/core/network/network_info.dart';
import 'package:demo4/core/services/analytics_service.dart';
import 'package:demo4/core/services/firebase_service.dart';
import 'package:demo4/core/services/notification_service.dart';
import 'package:demo4/core/storage/local_storage_service.dart';
import 'package:demo4/core/storage/secure_storage_service.dart';
import 'package:demo4/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:demo4/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:demo4/features/auth/domain/repositories/auth_repository.dart';
import 'package:demo4/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:demo4/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:demo4/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> configureDependencies(AppEnvironment environment) async {
  if (sl.isRegistered<AppEnvironment>()) return;

  final preferences = await SharedPreferences.getInstance();

  sl
    ..registerSingleton(environment)
    ..registerLazySingleton(Logger.new)
    ..registerSingleton(preferences)
    ..registerLazySingleton(SecureStorageService.new)
    ..registerLazySingleton(() => LocalStorageService(sl()))
    ..registerLazySingleton(NetworkInfo.new)
    ..registerLazySingleton(() => ApiClient(environment, sl(), sl()))
    ..registerLazySingleton(AnalyticsService.new)
    ..registerLazySingleton(() => FirebaseService(environment, sl()))
    ..registerLazySingleton(() => NotificationService(sl()))
    ..registerLazySingleton(() => AuthRemoteDataSource(sl()))
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl(), sl()),
    )
    ..registerLazySingleton(() => DashboardRemoteDataSource(sl()))
    ..registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl(sl()),
    );
}
