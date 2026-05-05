import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_client.dart';
import '../../core/network/auth_interceptor.dart';
import '../features/iam/data/datasources/iam_remote_datasource.dart';
import '../features/iam/data/repositories/iam_repository_impl.dart';
import '../features/iam/domain/repositories/iam_repository.dart';
import '../features/iam/domain/usecases/join_company_usecase.dart';
import '../features/iam/domain/usecases/sign_in_usecase.dart';
import '../features/iam/domain/usecases/sign_up_usecase.dart';
import '../features/iam/presentation/bloc/iam_bloc.dart';
import '../features/profile/di/profile_dependency_injector.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Dio());

  // Core
  sl.registerLazySingleton(() => AuthInterceptor(sharedPreferences: sl()));
  sl.registerLazySingleton(() {
    final apiClient = ApiClient(dio: sl());
    apiClient.addAuthInterceptor(sl());
    return apiClient;
  });

  // Features - IAM
  // Datasources
  sl.registerLazySingleton<IamRemoteDataSource>(
    () => IamRemoteDataSourceImpl(apiClient: sl()),
  );

  // Repositories
  sl.registerLazySingleton<IamRepository>(
    () => IamRepositoryImpl(remoteDataSource: sl(), sharedPreferences: sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => JoinCompanyUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => IamBloc(
      signInUseCase: sl(),
      signUpUseCase: sl(),
      joinCompanyUseCase: sl(),
    ),
  );

  // Initialize other features
  initProfileDependencies();
}
