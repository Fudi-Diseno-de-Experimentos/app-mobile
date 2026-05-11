import '../../../../app/di.dart';
import '../data/datasources/event_remote_datasource.dart';
import '../data/repositories/event_repository_impl.dart';
import '../domain/repositories/event_repository.dart';
import '../domain/usecases/get_events_usecase.dart';
import '../domain/usecases/create_event_usecase.dart';
import '../presentation/bloc/event_bloc.dart';

void initEventDependencies() {
  // Datasources
  sl.registerLazySingleton<EventRemoteDataSource>(
    () => EventRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<EventRepository>(
    () => EventRepositoryImpl(remoteDataSource: sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => GetEventsUseCase(sl()));
  sl.registerLazySingleton(() => CreateEventUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => EventBloc(
      getEventsUseCase: sl(),
      createEventUseCase: sl(),
    ),
  );
}
