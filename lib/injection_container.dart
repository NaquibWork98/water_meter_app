import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/network_info.dart';

// Authentication
import 'features/authentication/data/datasources/auth_local_data_source.dart';
import 'features/authentication/data/datasources/auth_remote_data_source.dart';
import 'features/authentication/data/repositories/auth_repository_impl.dart';
import 'features/authentication/domain/repositories/auth_repository.dart';
import 'features/authentication/domain/usecases/get_current_user.dart';
import 'features/authentication/domain/usecases/login.dart';
import 'features/authentication/domain/usecases/logout.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';

// Meter Reading
import 'features/meter_reading/data/datasources/meter_local_data_source.dart';
import 'features/meter_reading/data/datasources/meter_remote_data_source.dart';
import 'features/meter_reading/data/datasources/ocr_data_source.dart';
import 'features/meter_reading/data/repositories/meter_repository_impl.dart';
import 'features/meter_reading/domain/repositories/meter_repository.dart';
import 'features/meter_reading/domain/usecases/extract_reading_ocr.dart';
import 'features/meter_reading/domain/usecases/get_all_tenants.dart';
import 'features/meter_reading/domain/usecases/get_reading_history.dart';
import 'features/meter_reading/domain/usecases/scan_qr_code.dart';
import 'features/meter_reading/domain/usecases/submit_reading.dart';
import 'features/meter_reading/presentation/bloc/meter_reading_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! ========================================
  //! Features - Authentication
  //! ========================================

  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      login: sl(),
      logout: sl(),
      getCurrentUser: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => Logout(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Data sources
  sl.registerLazySingleton<MeterRemoteDataSource>(
    () => MeterRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<MeterLocalDataSource>(
    () => MeterLocalDataSourceImpl(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<OCRDataSource>(
    () => OCRDataSourceImpl(),
  );

  //! ========================================
  //! Features - Meter Reading
  //! ========================================

  // Bloc
  sl.registerFactory(
    () => MeterReadingBloc(
      scanQRCode: sl(),
      extractReadingOCR: sl(),
      submitReading: sl(),
      getReadingHistory: sl(),
      getAllTenants: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => ScanQRCode(sl()));
  sl.registerLazySingleton(() => ExtractReadingOCR(sl()));
  sl.registerLazySingleton(() => SubmitReading(sl()));
  sl.registerLazySingleton(() => GetReadingHistory(sl()));
  sl.registerLazySingleton(() => GetAllTenants(sl()));

  // Repository - Only OCR data source for now
  sl.registerLazySingleton<MeterRepository>(
    () => MeterRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
      ocrDataSource: sl(),
    ),
  );
  
  //! ========================================
  //! Core
  //! ========================================

  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );

  //! ========================================
  //! External Dependencies
  //! ========================================

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker());
}