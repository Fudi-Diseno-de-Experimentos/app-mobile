import 'package:app_mobile/app/di.dart';
import 'package:app_mobile/features/company/data/datasources/company_remote_datasource.dart';
import 'package:app_mobile/features/company/data/datasources/space_remote_datasource.dart';
import 'package:app_mobile/features/company/data/repositories/company_repository_impl.dart';
import 'package:app_mobile/features/company/data/repositories/space_repository_impl.dart';
import 'package:app_mobile/features/company/domain/repositories/company_repository.dart';
import 'package:app_mobile/features/company/domain/repositories/space_repository.dart';
import 'package:app_mobile/features/company/domain/usecases/create_company_usecase.dart';
import 'package:app_mobile/features/company/domain/usecases/create_space_usecase.dart';
import 'package:app_mobile/features/company/domain/usecases/delete_space_usecase.dart';
import 'package:app_mobile/features/company/domain/usecases/get_company_by_user_id_usecase.dart';
import 'package:app_mobile/features/company/domain/usecases/get_company_usecase.dart';
import 'package:app_mobile/features/company/domain/usecases/get_spaces_usecase.dart';
import 'package:app_mobile/features/company/domain/usecases/update_company_usecase.dart';
import 'package:app_mobile/features/company/domain/usecases/update_space_usecase.dart';
import 'package:app_mobile/features/company/presentation/bloc/company_bloc.dart';
import 'package:app_mobile/features/company/presentation/bloc/space_bloc.dart';

void initCompanyDependencies() {
  // Datasources
  sl.registerLazySingleton<CompanyRemoteDataSource>(
    () => CompanyRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<SpaceRemoteDataSource>(
    () => SpaceRemoteDataSourceImpl(apiClient: sl()),
  );

  // Repositories
  sl.registerLazySingleton<CompanyRepository>(
    () => CompanyRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<SpaceRepository>(
    () => SpaceRepositoryImpl(remoteDataSource: sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => CreateCompanyUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCompanyUseCase(sl()));
  sl.registerLazySingleton(() => GetCompanyByUserIdUseCase(sl()));
  sl.registerLazySingleton(() => GetCompanyUseCase(sl()));
  sl.registerLazySingleton(() => GetSpacesUseCase(sl()));
  sl.registerLazySingleton(() => CreateSpaceUseCase(sl()));
  sl.registerLazySingleton(() => UpdateSpaceUseCase(sl()));
  sl.registerLazySingleton(() => DeleteSpaceUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => CompanyBloc(
      createCompanyUseCase: sl(),
      updateCompanyUseCase: sl(),
      getCompanyByUserIdUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => SpaceBloc(
      getSpacesUseCase: sl(),
      createSpaceUseCase: sl(),
      updateSpaceUseCase: sl(),
      deleteSpaceUseCase: sl(),
    ),
  );
}
