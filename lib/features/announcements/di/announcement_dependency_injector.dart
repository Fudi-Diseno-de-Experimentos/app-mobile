import '../../../../app/di.dart';
import '../data/datasources/announcement_remote_datasource.dart';
import '../data/repositories/announcement_repository_impl.dart';
import '../domain/repositories/announcement_repository.dart';
import '../domain/usecases/get_announcements_usecase.dart';
import '../presentation/bloc/announcement_bloc.dart';

void initAnnouncementDependencies() {
  // Datasources
  sl.registerLazySingleton<AnnouncementRemoteDataSource>(
    () => AnnouncementRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<AnnouncementRepository>(
    () => AnnouncementRepositoryImpl(remoteDataSource: sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => GetAnnouncementsUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => AnnouncementBloc(getAnnouncementsUseCase: sl()),
  );
}
