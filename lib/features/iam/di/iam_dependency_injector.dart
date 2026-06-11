import 'package:app_mobile/app/di.dart';
import 'package:app_mobile/features/iam/data/datasources/iam_remote_datasource.dart';
import 'package:app_mobile/features/iam/data/repositories/iam_repository_impl.dart';
import 'package:app_mobile/features/iam/domain/repositories/iam_repository.dart';
import 'package:app_mobile/features/iam/domain/usecases/join_company_usecase.dart';
import 'package:app_mobile/features/iam/domain/usecases/sign_in_usecase.dart';
import 'package:app_mobile/features/iam/domain/usecases/sign_out_usecase.dart';
import 'package:app_mobile/features/iam/domain/usecases/sign_up_usecase.dart';
import 'package:app_mobile/features/iam/presentation/bloc/iam_bloc.dart';

void initIamDependencies() {
  // Datasources
  sl.registerLazySingleton<IamRemoteDataSource>(
    () => IamRemoteDataSourceImpl(apiClient: sl()),
  );

  // Repositories
  sl.registerLazySingleton<IamRepository>(
    () => IamRepositoryImpl(remoteDataSource: sl(), tokenStore: sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => JoinCompanyUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => IamBloc(
      signInUseCase: sl(),
      signUpUseCase: sl(),
      joinCompanyUseCase: sl(),
      signOutUseCase: sl(),
    ),
  );
}
