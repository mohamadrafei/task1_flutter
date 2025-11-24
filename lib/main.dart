import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:job_management_system/features/admin/data/datasources/AdminRemoteDataSource.dart';
import 'package:job_management_system/features/admin/data/repositories/jobs_repository_impl.dart';
import 'package:job_management_system/features/admin/domain/repositories/jobs_repository.dart';
import 'package:job_management_system/features/admin/domain/usecases/get_my_jobs_usecase.dart';
import 'package:job_management_system/features/admin/domain/usecases/get_my_today_jobs_usecase.dart';
import 'package:job_management_system/features/technician/domain/usecases/update_job_status_usecase.dart';
import 'package:job_management_system/features/technician/domain/usecases/upload_job_photo_usecase.dart';

import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';

import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';

import 'features/admin/data/datasources/jobs_remote_data_source.dart';

final sl = GetIt.instance;

/// Dependency injection setup
Future<void> setupLocator() async {
  // CORE
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage());
  sl.registerLazySingleton<http.Client>(() => http.Client());

  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      baseUrl: 'http://localhost:8080/api',
      httpClient: sl<http.Client>(),
      tokenStorage: sl<TokenStorage>(),
    ),
  );

  // DATA SOURCES
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(sl<ApiClient>()),
  );
 sl.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSource(sl<ApiClient>()),
  );
  sl.registerLazySingleton<JobsRemoteDataSource>(
    () => JobsRemoteDataSource(sl<ApiClient>()),
  );

  // REPOSITORIES
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      tokenStorage: sl<TokenStorage>(),
    ),
  );

  sl.registerLazySingleton<JobsRepository>(
    () => JobsRepositoryImpl(
      remoteDataSource: sl<JobsRemoteDataSource>(),
    ),
  );

  // USE CASES
  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<GetMyTodayJobsUseCase>(
  () => GetMyTodayJobsUseCase(sl<JobsRepository>()),
);
sl.registerLazySingleton<GetMyJobsUseCase>(
  () => GetMyJobsUseCase(sl<JobsRepository>()),
);
sl.registerLazySingleton<UpdateJobStatusUseCase>(
  () => UpdateJobStatusUseCase(sl<JobsRepository>()),
);
sl.registerLazySingleton<UploadJobPhotoUseCase>(
  () => UploadJobPhotoUseCase(sl<JobsRepository>()),
);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  runApp(const FieldServiceApp());
}

class FieldServiceApp extends StatelessWidget {
  const FieldServiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(sl<LoginUseCase>()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Field Service',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.blue,
        ),
        home: const LoginPage(),
      ),
    );
  }
}
