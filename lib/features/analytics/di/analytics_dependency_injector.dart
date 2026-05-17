import '../../../app/di.dart';
import '../data/datasources/analytics_remote_datasource.dart';
import '../data/repositories/analytics_repository_impl.dart';
import '../domain/repositories/analytics_repository.dart';
import '../domain/usecases/register_announcement_view_usecase.dart';
import '../domain/usecases/register_event_view_usecase.dart';
import '../presentation/bloc/analytics_bloc.dart';

void initAnalyticsDependencies() {
  // Datasource
  sl.registerLazySingleton<AnalyticsRemoteDataSource>(
    () => AnalyticsRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(remoteDataSource: sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => RegisterAnnouncementViewUseCase(sl()));
  sl.registerLazySingleton(() => RegisterEventViewUseCase(sl()));

  // BLoC — singleton: telemetry sink shared app-wide, invoked directly via sl.
  sl.registerLazySingleton(
    () => AnalyticsBloc(
      registerAnnouncementViewUseCase: sl(),
      registerEventViewUseCase: sl(),
    ),
  );
}
