import 'package:app_mobile/app/di.dart';
import 'package:app_mobile/features/company/data/datasources/company_remote_datasource.dart';
import 'package:app_mobile/features/company/data/repositories/company_repository_impl.dart';
import 'package:app_mobile/features/company/domain/repositories/company_repository.dart';
import 'package:app_mobile/features/company/domain/usecases/create_company_usecase.dart';
import 'package:app_mobile/features/company/domain/usecases/get_company_by_user_id_usecase.dart';
import 'package:app_mobile/features/company/domain/usecases/get_company_usecase.dart';
import 'package:app_mobile/features/company/domain/usecases/update_company_usecase.dart';
import 'package:app_mobile/features/company/presentation/bloc/company_bloc.dart';

void initCompanyDependencies() {
  // Datasources
  sl.registerLazySingleton<CompanyRemoteDataSource>(
    () => CompanyRemoteDataSourceImpl(apiClient: sl()),
  );

  // Repositories
  sl.registerLazySingleton<CompanyRepository>(
    () => CompanyRepositoryImpl(remoteDataSource: sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => CreateCompanyUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCompanyUseCase(sl()));
  sl.registerLazySingleton(() => GetCompanyByUserIdUseCase(sl()));
  sl.registerLazySingleton(() => GetCompanyUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => CompanyBloc(
      createCompanyUseCase: sl(),
      updateCompanyUseCase: sl(),
      getCompanyByUserIdUseCase: sl(),
    ),
  );
}
