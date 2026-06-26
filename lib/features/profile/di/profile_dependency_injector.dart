import 'package:app_mobile/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:app_mobile/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:app_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:app_mobile/features/profile/domain/usecases/assign_company_to_user_usecase.dart';
import 'package:app_mobile/features/profile/domain/usecases/get_company_members_usecase.dart';
import 'package:app_mobile/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:app_mobile/features/profile/domain/usecases/get_profiles_without_company_usecase.dart';
import 'package:app_mobile/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:get_it/get_it.dart';

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
  if (!sl.isRegistered<GetProfilesWithoutCompanyUseCase>()) {
    sl.registerLazySingleton(() => GetProfilesWithoutCompanyUseCase(sl()));
  }
  if (!sl.isRegistered<AssignCompanyToUserUseCase>()) {
    sl.registerLazySingleton(() => AssignCompanyToUserUseCase(sl()));
  }

  // Blocs
  if (!sl.isRegistered<ProfileBloc>()) {
    sl.registerFactory(
      () => ProfileBloc(getProfileUseCase: sl(), updateProfileUseCase: sl()),
    );
  }
}
