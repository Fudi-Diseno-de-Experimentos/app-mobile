import 'package:app_mobile/app/di.dart';
import 'package:app_mobile/features/analytics/data/datasources/analytics_remote_datasource.dart';
import 'package:app_mobile/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:app_mobile/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:app_mobile/features/analytics/domain/usecases/get_announcement_stats_usecase.dart';
import 'package:app_mobile/features/analytics/domain/usecases/get_announcement_viewers_usecase.dart';
import 'package:app_mobile/features/analytics/domain/usecases/get_event_stats_usecase.dart';
import 'package:app_mobile/features/analytics/domain/usecases/get_event_viewers_usecase.dart';
import 'package:app_mobile/features/analytics/domain/usecases/get_user_announcement_views_usecase.dart';
import 'package:app_mobile/features/analytics/domain/usecases/get_user_event_views_usecase.dart';
import 'package:app_mobile/features/analytics/domain/usecases/register_announcement_view_usecase.dart';
import 'package:app_mobile/features/analytics/domain/usecases/register_event_view_usecase.dart';
import 'package:app_mobile/features/analytics/domain/usecases/watch_analytics_updates_usecase.dart';
import 'package:app_mobile/features/analytics/presentation/bloc/analytics_bloc.dart';

void initAnalyticsDependencies() {
  // Datasource
  sl.registerLazySingleton<AnalyticsRemoteDataSource>(
    () => AnalyticsRemoteDataSourceImpl(sl(), sl()),
  );

  // Repository
  sl.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(remoteDataSource: sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => RegisterAnnouncementViewUseCase(sl()));
  sl.registerLazySingleton(() => RegisterEventViewUseCase(sl()));
  sl.registerLazySingleton(() => GetAnnouncementStatsUseCase(sl()));
  sl.registerLazySingleton(() => GetEventStatsUseCase(sl()));
  sl.registerLazySingleton(() => GetAnnouncementViewersUseCase(sl()));
  sl.registerLazySingleton(() => GetEventViewersUseCase(sl()));
  sl.registerLazySingleton(() => GetUserAnnouncementViewsUseCase(sl()));
  sl.registerLazySingleton(() => GetUserEventViewsUseCase(sl()));
  sl.registerLazySingleton(() => WatchAnalyticsUpdatesUseCase(sl()));

  // BLoC — factory: isolated instance per detail page and member profile page to avoid state collision.
  sl.registerFactory(
    () => AnalyticsBloc(
      registerAnnouncementViewUseCase: sl(),
      registerEventViewUseCase: sl(),
      getAnnouncementStatsUseCase: sl(),
      getEventStatsUseCase: sl(),
      getAnnouncementViewersUseCase: sl(),
      getEventViewersUseCase: sl(),
      getUserAnnouncementViewsUseCase: sl(),
      getUserEventViewsUseCase: sl(),
      watchAnalyticsUpdatesUseCase: sl(),
    ),
  );
}

