import 'package:app_mobile/app/di.dart';
import 'package:app_mobile/core/auth/token_store.dart';
import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/analytics/domain/entities/analytics_update_entity.dart';
import 'package:app_mobile/features/analytics/domain/entities/content_stats_entity.dart';
import 'package:app_mobile/features/analytics/domain/entities/user_announcement_view_entity.dart';
import 'package:app_mobile/features/analytics/domain/entities/user_event_view_entity.dart';
import 'package:app_mobile/features/analytics/domain/entities/view_registration_entity.dart';
import 'package:app_mobile/features/analytics/domain/entities/viewer_entity.dart';
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
import 'package:app_mobile/features/announcements/domain/entities/announcement_entity.dart';
import 'package:app_mobile/features/announcements/domain/entities/comment_entity.dart';
import 'package:app_mobile/features/announcements/domain/repositories/announcement_repository.dart';
import 'package:app_mobile/features/announcements/domain/repositories/comment_repository.dart';
import 'package:app_mobile/features/announcements/domain/usecases/create_announcement_usecase.dart';
import 'package:app_mobile/features/announcements/domain/usecases/create_comment_usecase.dart';
import 'package:app_mobile/features/announcements/domain/usecases/delete_announcement_usecase.dart';
import 'package:app_mobile/features/announcements/domain/usecases/delete_comment_usecase.dart';
import 'package:app_mobile/features/announcements/domain/usecases/get_announcement_by_id_usecase.dart';
import 'package:app_mobile/features/announcements/domain/usecases/get_announcements_by_creator_usecase.dart';
import 'package:app_mobile/features/announcements/domain/usecases/get_announcements_by_priority_usecase.dart';
import 'package:app_mobile/features/announcements/domain/usecases/get_announcements_usecase.dart';
import 'package:app_mobile/features/announcements/domain/usecases/get_comments_usecase.dart';
import 'package:app_mobile/features/announcements/domain/usecases/update_announcement_usecase.dart';
import 'package:app_mobile/features/chat/domain/entities/group_entity.dart';
import 'package:app_mobile/features/chat/domain/repositories/chat_repository.dart';
import 'package:app_mobile/features/chat/domain/usecases/get_my_groups_usecase.dart';
import 'package:app_mobile/features/company/domain/entities/company_entity.dart';
import 'package:app_mobile/features/company/domain/entities/space_entity.dart';
import 'package:app_mobile/features/company/domain/repositories/company_repository.dart';
import 'package:app_mobile/features/company/domain/repositories/space_repository.dart';
import 'package:app_mobile/features/company/domain/usecases/create_company_usecase.dart';
import 'package:app_mobile/features/company/domain/usecases/get_company_by_user_id_usecase.dart';
import 'package:app_mobile/features/company/domain/usecases/get_spaces_usecase.dart';
import 'package:app_mobile/features/company/domain/usecases/update_company_usecase.dart';
import 'package:app_mobile/features/events/domain/entities/event_entity.dart';
import 'package:app_mobile/features/events/domain/repositories/event_repository.dart';
import 'package:app_mobile/features/events/domain/usecases/create_event_usecase.dart';
import 'package:app_mobile/features/events/domain/usecases/delete_event_usecase.dart';
import 'package:app_mobile/features/events/domain/usecases/get_events_usecase.dart';
import 'package:app_mobile/features/events/domain/usecases/update_event_usecase.dart';
import 'package:app_mobile/features/iam/domain/entities/user_entity.dart';
import 'package:app_mobile/features/iam/domain/repositories/iam_repository.dart';
import 'package:app_mobile/features/iam/domain/usecases/join_company_usecase.dart';
import 'package:app_mobile/features/iam/domain/usecases/sign_in_usecase.dart';
import 'package:app_mobile/features/iam/domain/usecases/sign_out_usecase.dart';
import 'package:app_mobile/features/iam/domain/usecases/sign_up_usecase.dart';
import 'package:app_mobile/features/profile/domain/entities/profile_entity.dart';
import 'package:app_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:app_mobile/features/profile/domain/usecases/assign_company_to_user_usecase.dart';
import 'package:app_mobile/features/profile/domain/usecases/get_company_members_usecase.dart';
import 'package:app_mobile/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:app_mobile/features/profile/domain/usecases/get_profiles_without_company_usecase.dart';
import 'package:app_mobile/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:fpdart/fpdart.dart';

const _tAnnouncement = AnnouncementEntity(
  id: 'ann-1',
  title: 'Sample Announcement',
  description: 'Announcement description for patrol tests',
  image: null,
  priority: 'NORMAL',
  createdBy: 'user-1',
  createdAt: '2024-01-01T00:00:00Z',
  updatedAt: '2024-01-01T00:00:00Z',
);

const _tAnnouncementHigh = AnnouncementEntity(
  id: 'ann-2',
  title: 'Urgent Announcement',
  description: 'This announcement is high priority',
  image: null,
  priority: 'HIGH',
  createdBy: 'user-1',
  createdAt: '2024-01-02T00:00:00Z',
  updatedAt: '2024-01-02T00:00:00Z',
);

const _tEvent = EventEntity(
  id: 'evt-1',
  title: 'Sample Event',
  description: 'Event description for patrol tests',
  date: '2024-06-15T10:00:00Z',
  spaceId: 'room-1',
  createdBy: 'user-1',
  recipients: [],
  createdAt: '2024-01-01T00:00:00Z',
  updatedAt: '2024-01-01T00:00:00Z',
);

// --- Fake Use Cases ---

class FakeSignInUseCase implements SignInUseCase {
  @override
  IamRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, UserEntity>> call(String username, String password) async {
    // The real IamRepositoryImpl persists the token on sign-in; the router's
    // redirect guard reads TokenStore.isSignedIn to gate every authed route.
    // Replicate that here or every post-login route bounces back to /sign-in.
    await sl<TokenStore>().save('fake-token');
    return const Right(UserEntity(
      id: 'user-1',
      username: 'testadmin',
      token: 'fake-token',
      companyId: 'company-1',
    ));
  }
}

class FakeSignUpUseCase implements SignUpUseCase {
  @override
  IamRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> call({
    required String username,
    required String password,
    required String name,
    required String lastname,
    required String email,
    List<String>? roles,
  }) async {
    return const Right(null);
  }
}

class FakeSignOutUseCase implements SignOutUseCase {
  @override
  IamRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> call() async {
    // Mirror IamRepositoryImpl.signOut: clear the token so the router guard
    // redirects back to /sign-in.
    await sl<TokenStore>().clear();
    return const Right(null);
  }
}

class FakeJoinCompanyUseCase implements JoinCompanyUseCase {
  @override
  IamRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> call(String joinCode) async {
    return const Right(null);
  }
}

class FakeGetProfileUseCase implements GetProfileUseCase {
  @override
  ProfileRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, ProfileEntity>> call({void params}) async {
    return const Right(ProfileEntity(
      id: 'profile-1',
      userId: 'user-1',
      username: 'testadmin',
      name: 'Admin',
      lastname: 'Test',
      email: 'admin@test.com',
      roles: ['ROLE_ADMIN', 'ROLE_MANAGER'],
      companyId: 'company-1',
    ));
  }
}

class FakeUpdateProfileUseCase implements UpdateProfileUseCase {
  @override
  ProfileRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, ProfileEntity>> call(ProfileEntity profile) async {
    return Right(profile);
  }
}

class FakeGetAnnouncementsUseCase implements GetAnnouncementsUseCase {
  @override
  AnnouncementRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, List<AnnouncementEntity>>> call({bool forceRefresh = false}) async {
    return const Right([_tAnnouncement, _tAnnouncementHigh]);
  }
}

class FakeGetAnnouncementByIdUseCase implements GetAnnouncementByIdUseCase {
  @override
  AnnouncementRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, AnnouncementEntity>> call(String id) async {
    if (id == 'ann-1') return const Right(_tAnnouncement);
    return const Right(_tAnnouncementHigh);
  }
}

class FakeGetAnnouncementsByPriorityUseCase implements GetAnnouncementsByPriorityUseCase {
  @override
  AnnouncementRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, List<AnnouncementEntity>>> call(String priority) async {
    if (priority == 'HIGH') return const Right([_tAnnouncementHigh]);
    return const Right([_tAnnouncement]);
  }
}

class FakeGetAnnouncementsByCreatorUseCase implements GetAnnouncementsByCreatorUseCase {
  @override
  AnnouncementRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, List<AnnouncementEntity>>> call(String createdBy) async {
    return const Right([_tAnnouncement, _tAnnouncementHigh]);
  }
}

class FakeCreateAnnouncementUseCase implements CreateAnnouncementUseCase {
  @override
  AnnouncementRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, AnnouncementEntity>> call({
    required String title,
    required String description,
    String? image,
    required String priority,
    required String createdBy,
  }) async {
    return Right(AnnouncementEntity(
      id: 'ann-new',
      title: title,
      description: description,
      image: image,
      priority: priority,
      createdBy: createdBy,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    ));
  }
}

class FakeUpdateAnnouncementUseCase implements UpdateAnnouncementUseCase {
  @override
  AnnouncementRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, AnnouncementEntity>> call({
    required String id,
    required String title,
    required String description,
    String? image,
    required String priority,
  }) async {
    return Right(AnnouncementEntity(
      id: id,
      title: title,
      description: description,
      image: image,
      priority: priority,
      createdBy: 'user-1',
      createdAt: '2024-01-01T00:00:00Z',
      updatedAt: DateTime.now().toIso8601String(),
    ));
  }
}

class FakeDeleteAnnouncementUseCase implements DeleteAnnouncementUseCase {
  @override
  AnnouncementRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> call(String id) async {
    return const Right(unit);
  }
}

class FakeGetCommentsUseCase implements GetCommentsUseCase {
  @override
  CommentRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, List<CommentEntity>>> call(String announcementId,
      {bool forceRefresh = false}) async {
    return const Right([]);
  }
}

class FakeCreateCommentUseCase implements CreateCommentUseCase {
  @override
  CommentRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, CommentEntity>> call({
    required String announcementId,
    required String content,
    required String authorId,
  }) async {
    return Right(CommentEntity(
      id: 'comment-new',
      announcementId: announcementId,
      content: content,
      authorId: authorId,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    ));
  }
}

class FakeDeleteCommentUseCase implements DeleteCommentUseCase {
  @override
  CommentRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> call(String commentId) async {
    return const Right(unit);
  }
}

class FakeGetEventsUseCase implements GetEventsUseCase {
  @override
  EventRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, List<EventEntity>>> call({
    bool forceRefresh = false,
    String? userId,
    String? filterType,
  }) async {
    return const Right([_tEvent]);
  }
}

class FakeCreateEventUseCase implements CreateEventUseCase {
  @override
  EventRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, EventEntity>> call({
    required String title,
    required String description,
    required String date,
    required String spaceId,
    required String createdBy,
    required List<String> recipientIds,
  }) async {
    return Right(EventEntity(
      id: 'evt-new',
      title: title,
      description: description,
      date: date,
      spaceId: spaceId,
      createdBy: createdBy,
      recipients: recipientIds.map((id) => EventRecipient(userId: id)).toList(),
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    ));
  }
}

class FakeUpdateEventUseCase implements UpdateEventUseCase {
  @override
  EventRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, EventEntity>> call({
    required String id,
    required String title,
    required String description,
    required String date,
    required String spaceId,
    required List<String> recipientIds,
  }) async {
    return Right(EventEntity(
      id: id,
      title: title,
      description: description,
      date: date,
      spaceId: spaceId,
      createdBy: 'manager-1',
      recipients: recipientIds.map((id) => EventRecipient(userId: id)).toList(),
      createdAt: '2024-01-01',
      updatedAt: DateTime.now().toIso8601String(),
    ));
  }
}

class FakeDeleteEventUseCase implements DeleteEventUseCase {
  @override
  EventRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> call(String id) async {
    return const Right(unit);
  }
}

class FakeGetCompanyMembersUseCase implements GetCompanyMembersUseCase {
  @override
  ProfileRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, List<ProfileEntity>>> call(String companyId) async {
    return const Right([]);
  }
}

class FakeGetProfilesWithoutCompanyUseCase implements GetProfilesWithoutCompanyUseCase {
  @override
  ProfileRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, List<ProfileEntity>>> call({bool forceRefresh = false}) async {
    return const Right([]);
  }
}

class FakeAssignCompanyToUserUseCase implements AssignCompanyToUserUseCase {
  @override
  ProfileRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> call(String userId, String companyId) async {
    return const Right(null);
  }
}

class FakeCreateCompanyUseCase implements CreateCompanyUseCase {
  @override
  CompanyRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, CompanyEntity>> call({
    required String ruc,
    required String name,
    String? iconUrl,
    required bool isActive,
    required String userId,
  }) async {
    return Right(CompanyEntity(
      id: 'comp-new',
      ruc: ruc,
      name: name,
      iconUrl: iconUrl,
      isActive: isActive,
      userId: userId,
      joinCode: 'NEW123',
    ));
  }
}

class FakeUpdateCompanyUseCase implements UpdateCompanyUseCase {
  @override
  CompanyRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, CompanyEntity>> call({
    required String id,
    required String ruc,
    required String name,
    String? iconUrl,
    required bool isActive,
  }) async {
    return Right(CompanyEntity(
      id: id,
      ruc: ruc,
      name: name,
      iconUrl: iconUrl,
      isActive: isActive,
      userId: 'user-1',
      joinCode: 'ABC123',
    ));
  }
}

class FakeGetSpacesUseCase implements GetSpacesUseCase {
  @override
  SpaceRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, List<SpaceEntity>>> call({String? date}) async {
    // One always-available room so the event-creation room picker has a
    // selectable option, and edit mode keeps booking 'room-1' (the _tEvent
    // space) instead of falling back to the network.
    return const Right([
      SpaceEntity(
        id: 'room-1',
        name: 'Main Hall',
        companyId: 'company-1',
        available: true,
      ),
    ]);
  }
}

class FakeGetCompanyByUserIdUseCase implements GetCompanyByUserIdUseCase {
  @override
  CompanyRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, CompanyEntity>> call(String userId) async {
    return const Right(CompanyEntity(
      id: 'company-1',
      ruc: '20123456789',
      name: 'Test Company',
      isActive: true,
      userId: 'user-1',
      joinCode: 'TEST123',
    ));
  }
}

class FakeRegisterAnnouncementViewUseCase implements RegisterAnnouncementViewUseCase {
  @override
  AnalyticsRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, ViewRegistrationEntity>> call({
    required String announcementId,
    required String userId,
  }) async {
    return Right(ViewRegistrationEntity(
      viewId: 'view-1',
      userId: userId,
      contentId: announcementId,
      isNewView: true,
    ));
  }
}

class FakeRegisterEventViewUseCase implements RegisterEventViewUseCase {
  @override
  AnalyticsRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, ViewRegistrationEntity>> call({
    required String eventId,
    required String userId,
  }) async {
    return Right(ViewRegistrationEntity(
      viewId: 'view-2',
      userId: userId,
      contentId: eventId,
      isNewView: true,
    ));
  }
}

class FakeGetAnnouncementStatsUseCase implements GetAnnouncementStatsUseCase {
  @override
  AnalyticsRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, ContentStatsEntity>> call(String id, {bool forceRefresh = false}) async {
    return Right(ContentStatsEntity(
      contentId: id,
      contentTitle: 'Announcement',
      totalUsers: 10,
      totalViews: 5,
      viewPercentage: 50.0,
      notViewedPercentage: 50.0,
    ));
  }
}

class FakeGetEventStatsUseCase implements GetEventStatsUseCase {
  @override
  AnalyticsRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, ContentStatsEntity>> call(String id, {bool forceRefresh = false}) async {
    return Right(ContentStatsEntity(
      contentId: id,
      contentTitle: 'Event',
      totalUsers: 10,
      totalViews: 3,
      viewPercentage: 30.0,
      notViewedPercentage: 70.0,
    ));
  }
}

class FakeGetAnnouncementViewersUseCase implements GetAnnouncementViewersUseCase {
  @override
  AnalyticsRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, List<ViewerEntity>>> call(String id, {bool forceRefresh = false}) async {
    return const Right([]);
  }
}

class FakeGetEventViewersUseCase implements GetEventViewersUseCase {
  @override
  AnalyticsRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, List<ViewerEntity>>> call(String id, {bool forceRefresh = false}) async {
    return const Right([]);
  }
}

class FakeGetUserAnnouncementViewsUseCase implements GetUserAnnouncementViewsUseCase {
  @override
  AnalyticsRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, List<UserAnnouncementViewEntity>>> call(String userId, {bool forceRefresh = false}) async {
    return const Right([]);
  }
}

class FakeGetUserEventViewsUseCase implements GetUserEventViewsUseCase {
  @override
  AnalyticsRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, List<UserEventViewEntity>>> call(String userId, {bool forceRefresh = false}) async {
    return const Right([]);
  }
}

class FakeGetMyGroupsUseCase implements GetMyGroupsUseCase {
  @override
  ChatRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, List<GroupEntity>>> call(String userId) async {
    return const Right([]);
  }
}

class FakeWatchAnalyticsUpdatesUseCase implements WatchAnalyticsUpdatesUseCase {
  @override
  AnalyticsRepository get repository => throw UnimplementedError();

  @override
  Stream<Either<Failure, AnalyticsUpdateEntity>> call({
    required String contentId,
    required bool isEvent,
  }) {
    return const Stream.empty();
  }
}

void setupAllMockDependencies() {
  sl.allowReassignment = true;

  // IAM
  sl.registerLazySingleton<SignInUseCase>(() => FakeSignInUseCase());
  sl.registerLazySingleton<SignUpUseCase>(() => FakeSignUpUseCase());
  sl.registerLazySingleton<SignOutUseCase>(() => FakeSignOutUseCase());
  sl.registerLazySingleton<JoinCompanyUseCase>(() => FakeJoinCompanyUseCase());

  // Profile
  sl.registerLazySingleton<GetProfileUseCase>(() => FakeGetProfileUseCase());
  sl.registerLazySingleton<UpdateProfileUseCase>(() => FakeUpdateProfileUseCase());
  sl.registerLazySingleton<GetCompanyMembersUseCase>(() => FakeGetCompanyMembersUseCase());
  sl.registerLazySingleton<GetProfilesWithoutCompanyUseCase>(() => FakeGetProfilesWithoutCompanyUseCase());
  sl.registerLazySingleton<AssignCompanyToUserUseCase>(() => FakeAssignCompanyToUserUseCase());

  // Announcements
  sl.registerLazySingleton<GetAnnouncementsUseCase>(() => FakeGetAnnouncementsUseCase());
  sl.registerLazySingleton<GetAnnouncementByIdUseCase>(() => FakeGetAnnouncementByIdUseCase());
  sl.registerLazySingleton<GetAnnouncementsByPriorityUseCase>(() => FakeGetAnnouncementsByPriorityUseCase());
  sl.registerLazySingleton<GetAnnouncementsByCreatorUseCase>(() => FakeGetAnnouncementsByCreatorUseCase());
  sl.registerLazySingleton<CreateAnnouncementUseCase>(() => FakeCreateAnnouncementUseCase());
  sl.registerLazySingleton<UpdateAnnouncementUseCase>(() => FakeUpdateAnnouncementUseCase());
  sl.registerLazySingleton<DeleteAnnouncementUseCase>(() => FakeDeleteAnnouncementUseCase());
  sl.registerLazySingleton<GetCommentsUseCase>(() => FakeGetCommentsUseCase());
  sl.registerLazySingleton<CreateCommentUseCase>(() => FakeCreateCommentUseCase());
  sl.registerLazySingleton<DeleteCommentUseCase>(() => FakeDeleteCommentUseCase());

  // Events
  sl.registerLazySingleton<GetEventsUseCase>(() => FakeGetEventsUseCase());
  sl.registerLazySingleton<CreateEventUseCase>(() => FakeCreateEventUseCase());
  sl.registerLazySingleton<UpdateEventUseCase>(() => FakeUpdateEventUseCase());
  sl.registerLazySingleton<DeleteEventUseCase>(() => FakeDeleteEventUseCase());

  // Company
  sl.registerLazySingleton<CreateCompanyUseCase>(() => FakeCreateCompanyUseCase());
  sl.registerLazySingleton<UpdateCompanyUseCase>(() => FakeUpdateCompanyUseCase());
  sl.registerLazySingleton<GetCompanyByUserIdUseCase>(() => FakeGetCompanyByUserIdUseCase());
  sl.registerLazySingleton<GetSpacesUseCase>(() => FakeGetSpacesUseCase());

  // Analytics
  sl.registerLazySingleton<RegisterAnnouncementViewUseCase>(() => FakeRegisterAnnouncementViewUseCase());
  sl.registerLazySingleton<RegisterEventViewUseCase>(() => FakeRegisterEventViewUseCase());
  sl.registerLazySingleton<GetAnnouncementStatsUseCase>(() => FakeGetAnnouncementStatsUseCase());
  sl.registerLazySingleton<GetEventStatsUseCase>(() => FakeGetEventStatsUseCase());
  sl.registerLazySingleton<GetAnnouncementViewersUseCase>(() => FakeGetAnnouncementViewersUseCase());
  sl.registerLazySingleton<GetEventViewersUseCase>(() => FakeGetEventViewersUseCase());
  sl.registerLazySingleton<GetUserAnnouncementViewsUseCase>(() => FakeGetUserAnnouncementViewsUseCase());
  sl.registerLazySingleton<GetUserEventViewsUseCase>(() => FakeGetUserEventViewsUseCase());
  sl.registerLazySingleton<WatchAnalyticsUpdatesUseCase>(() => FakeWatchAnalyticsUpdatesUseCase());
  sl.registerFactory<AnalyticsBloc>(() => AnalyticsBloc(
    registerAnnouncementViewUseCase: sl(),
    registerEventViewUseCase: sl(),
    getAnnouncementStatsUseCase: sl(),
    getEventStatsUseCase: sl(),
    getAnnouncementViewersUseCase: sl(),
    getEventViewersUseCase: sl(),
    getUserAnnouncementViewsUseCase: sl(),
    getUserEventViewsUseCase: sl(),
    watchAnalyticsUpdatesUseCase: sl(),
  ));

  // Chat
  sl.registerLazySingleton<GetMyGroupsUseCase>(() => FakeGetMyGroupsUseCase());
}
