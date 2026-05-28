import '../../../app/di.dart';
import '../../profile/domain/usecases/get_company_members_usecase.dart';
import '../data/datasources/chat_archive_store.dart';
import '../data/datasources/chat_remote_datasource.dart';
import '../data/datasources/chat_socket_datasource.dart';
import '../data/repositories/chat_repository_impl.dart';
import '../domain/repositories/chat_repository.dart';
import '../domain/usecases/create_group_usecase.dart';
import '../domain/usecases/delete_message_usecase.dart';
import '../domain/usecases/disconnect_chat_usecase.dart';
import '../domain/usecases/edit_message_usecase.dart';
import '../domain/usecases/get_conversation_messages_usecase.dart';
import '../domain/usecases/get_group_messages_usecase.dart';
import '../domain/usecases/get_my_conversations_usecase.dart';
import '../domain/usecases/get_my_groups_usecase.dart';
import '../domain/usecases/send_message_usecase.dart';
import '../domain/usecases/start_conversation_usecase.dart';
import '../domain/usecases/update_group_usecase.dart';
import '../domain/usecases/watch_messages_usecase.dart';
import '../presentation/bloc/chat_bloc.dart';
import '../presentation/bloc/message_bloc.dart';

void initChatDependencies() {
  // Datasources
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ChatSocketDataSource>(
    () => ChatSocketDataSourceImpl(sl()),
  );
  sl.registerLazySingleton(() => ChatArchiveStore(sl()));

  // Repository
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      remoteDataSource: sl(),
      socketDataSource: sl(),
      sharedPreferences: sl(),
    ),
  );

  // UseCases
  sl.registerLazySingleton(() => GetMyGroupsUseCase(sl()));
  sl.registerLazySingleton(() => GetMyConversationsUseCase(sl()));
  sl.registerLazySingleton(() => StartConversationUseCase(sl()));
  sl.registerLazySingleton(() => CreateGroupUseCase(sl()));
  sl.registerLazySingleton(() => UpdateGroupUseCase(sl()));
  sl.registerLazySingleton(() => GetGroupMessagesUseCase(sl()));
  sl.registerLazySingleton(() => GetConversationMessagesUseCase(sl()));
  sl.registerLazySingleton(() => WatchMessagesUseCase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => EditMessageUseCase(sl()));
  sl.registerLazySingleton(() => DeleteMessageUseCase(sl()));
  sl.registerLazySingleton(() => DisconnectChatUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => ChatBloc(
      getMyGroupsUseCase: sl(),
      getMyConversationsUseCase: sl(),
      startConversationUseCase: sl(),
      getCompanyMembersUseCase: sl<GetCompanyMembersUseCase>(),
      createGroupUseCase: sl(),
      updateGroupUseCase: sl(),
      archiveStore: sl(),
    ),
  );
  sl.registerFactory(
    () => MessageBloc(
      getGroupMessagesUseCase: sl(),
      getConversationMessagesUseCase: sl(),
      watchMessagesUseCase: sl(),
      sendMessageUseCase: sl(),
      editMessageUseCase: sl(),
      deleteMessageUseCase: sl(),
      getCompanyMembersUseCase: sl<GetCompanyMembersUseCase>(),
      disconnectChatUseCase: sl(),
    ),
  );
}
