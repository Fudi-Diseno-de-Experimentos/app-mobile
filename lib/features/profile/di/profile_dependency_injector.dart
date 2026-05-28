import 'package:get_it/get_it.dart';
import '../data/datasources/profile_remote_datasource.dart';
import '../data/repositories/profile_repository_impl.dart';
import '../domain/repositories/profile_repository.dart';
import '../domain/usecases/get_company_members_usecase.dart';
import '../domain/usecases/get_profile_usecase.dart';
import '../domain/usecases/update_profile_usecase.dart';
import '../presentation/bloc/profile_bloc.dart';

final sl = GetIt.instance;

void initProfileDependencies() {
  // Data sources
  if (!sl.isRegistered<ProfileRemoteDataSource>()) {
    sl.registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(apiClient: sl()),
    );
  }

  // Repositories
  if (!sl.isRegistered<ProfileRepository>()) {
    sl.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(
        remoteDataSource: sl(),
        sharedPreferences: sl(),
      ),
    );
  }

  // Use cases
  if (!sl.isRegistered<GetProfileUseCase>()) {
    sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  }
  if (!sl.isRegistered<UpdateProfileUseCase>()) {
    sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  }
  if (!sl.isRegistered<GetCompanyMembersUseCase>()) {
    sl.registerLazySingleton(() => GetCompanyMembersUseCase(sl()));
  }

  // Blocs
  if (!sl.isRegistered<ProfileBloc>()) {
    sl.registerFactory(
      () => ProfileBloc(getProfileUseCase: sl(), updateProfileUseCase: sl()),
    );
  }
}
