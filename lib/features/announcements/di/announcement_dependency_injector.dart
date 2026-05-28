import '../../../../app/di.dart';
import '../data/datasources/announcement_remote_datasource.dart';
import '../data/datasources/comment_remote_datasource.dart';
import '../data/repositories/announcement_repository_impl.dart';
import '../data/repositories/comment_repository_impl.dart';
import '../domain/repositories/announcement_repository.dart';
import '../domain/repositories/comment_repository.dart';
import '../domain/usecases/get_announcements_usecase.dart';
import '../domain/usecases/get_announcement_by_id_usecase.dart';
import '../domain/usecases/get_announcements_by_priority_usecase.dart';
import '../domain/usecases/get_announcements_by_creator_usecase.dart';
import '../domain/usecases/create_announcement_usecase.dart';
import '../domain/usecases/update_announcement_usecase.dart';
import '../domain/usecases/delete_announcement_usecase.dart';
import '../domain/usecases/get_comments_usecase.dart';
import '../domain/usecases/create_comment_usecase.dart';
import '../domain/usecases/delete_comment_usecase.dart';
import '../presentation/bloc/announcement_bloc.dart';
import '../presentation/bloc/comment_bloc.dart';

void initAnnouncementDependencies() {
  // Datasources
  sl.registerLazySingleton<AnnouncementRemoteDataSource>(
    () => AnnouncementRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<CommentRemoteDataSource>(
    () => CommentRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<AnnouncementRepository>(
    () => AnnouncementRepositoryImpl(
      remoteDataSource: sl(),
      sharedPreferences: sl(),
    ),
  );
  sl.registerLazySingleton<CommentRepository>(
    () => CommentRepositoryImpl(remoteDataSource: sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => GetAnnouncementsUseCase(sl()));
  sl.registerLazySingleton(() => GetAnnouncementByIdUseCase(sl()));
  sl.registerLazySingleton(() => GetAnnouncementsByPriorityUseCase(sl()));
  sl.registerLazySingleton(() => GetAnnouncementsByCreatorUseCase(sl()));
  sl.registerLazySingleton(() => CreateAnnouncementUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAnnouncementUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAnnouncementUseCase(sl()));
  sl.registerLazySingleton(() => GetCommentsUseCase(sl()));
  sl.registerLazySingleton(() => CreateCommentUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCommentUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => AnnouncementBloc(
      getAnnouncementsUseCase: sl(),
      getAnnouncementByIdUseCase: sl(),
      getAnnouncementsByPriorityUseCase: sl(),
      getAnnouncementsByCreatorUseCase: sl(),
      createAnnouncementUseCase: sl(),
      updateAnnouncementUseCase: sl(),
      deleteAnnouncementUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => CommentBloc(
      getCommentsUseCase: sl(),
      createCommentUseCase: sl(),
      deleteCommentUseCase: sl(),
    ),
  );
}
