import 'package:app_mobile/app/di.dart';
import 'package:app_mobile/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:app_mobile/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:app_mobile/features/notifications/domain/repositories/notification_repository.dart';
import 'package:app_mobile/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:app_mobile/features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:app_mobile/features/notifications/presentation/bloc/notification_bloc.dart';

void initNotificationDependencies() {
  // Data Sources
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(apiClient: sl()),
  );

  // Repositories
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => MarkNotificationAsReadUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => NotificationBloc(
      getNotificationsUseCase: sl(),
      markNotificationAsReadUseCase: sl(),
    ),
  );
}
