import 'package:app_mobile/app/di.dart';
import 'package:app_mobile/features/events/data/datasources/event_remote_datasource.dart';
import 'package:app_mobile/features/events/data/repositories/event_repository_impl.dart';
import 'package:app_mobile/features/events/domain/repositories/event_repository.dart';
import 'package:app_mobile/features/events/domain/usecases/create_event_usecase.dart';
import 'package:app_mobile/features/events/domain/usecases/delete_event_usecase.dart';
import 'package:app_mobile/features/events/domain/usecases/get_events_usecase.dart';
import 'package:app_mobile/features/events/domain/usecases/update_event_usecase.dart';
import 'package:app_mobile/features/events/presentation/bloc/event_bloc.dart';

void initEventDependencies() {
  // Datasources
  sl.registerLazySingleton<EventRemoteDataSource>(
    () => EventRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<EventRepository>(
    () => EventRepositoryImpl(
      remoteDataSource: sl(),
      sharedPreferences: sl(),
    ),
  );

  // UseCases
  sl.registerLazySingleton(() => GetEventsUseCase(sl()));
  sl.registerLazySingleton(() => CreateEventUseCase(sl()));
  sl.registerLazySingleton(() => UpdateEventUseCase(sl()));
  sl.registerLazySingleton(() => DeleteEventUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => EventBloc(
      getEventsUseCase: sl(),
      createEventUseCase: sl(),
      updateEventUseCase: sl(),
      deleteEventUseCase: sl(),
      getCompanyMembersUseCase: sl(),
    ),
  );
}
