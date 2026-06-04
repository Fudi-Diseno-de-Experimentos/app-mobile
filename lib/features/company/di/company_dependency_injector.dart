import 'package:get_it/get_it.dart';
import '../data/datasources/company_remote_datasource.dart';
import '../data/repositories/company_repository_impl.dart';
import '../domain/repositories/company_repository.dart';
import '../domain/usecases/create_company_usecase.dart';
import '../domain/usecases/update_company_usecase.dart';
import '../domain/usecases/get_company_by_user_id_usecase.dart';
import '../domain/usecases/get_company_usecase.dart';
import '../presentation/bloc/company_bloc.dart';

final sl = GetIt.instance;

void initCompanyDependencies() {
  if (!sl.isRegistered<CompanyRemoteDataSource>()) {
    sl.registerLazySingleton<CompanyRemoteDataSource>(
      () => CompanyRemoteDataSourceImpl(apiClient: sl()),
    );
  }

  if (!sl.isRegistered<CompanyRepository>()) {
    sl.registerLazySingleton<CompanyRepository>(
      () => CompanyRepositoryImpl(remoteDataSource: sl()),
    );
  }

  if (!sl.isRegistered<CreateCompanyUseCase>()) {
    sl.registerLazySingleton(() => CreateCompanyUseCase(sl()));
  }
  if (!sl.isRegistered<UpdateCompanyUseCase>()) {
    sl.registerLazySingleton(() => UpdateCompanyUseCase(sl()));
  }
  if (!sl.isRegistered<GetCompanyByUserIdUseCase>()) {
    sl.registerLazySingleton(() => GetCompanyByUserIdUseCase(sl()));
  }
  if (!sl.isRegistered<GetCompanyUseCase>()) {
    sl.registerLazySingleton(() => GetCompanyUseCase(sl()));
  }

  if (!sl.isRegistered<CompanyBloc>()) {
    sl.registerFactory(
      () => CompanyBloc(
        createCompanyUseCase: sl(),
        updateCompanyUseCase: sl(),
        getCompanyByUserIdUseCase: sl(),
      ),
    );
  }
}
