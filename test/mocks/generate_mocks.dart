import 'package:app_mobile/core/auth/token_store.dart';
import 'package:app_mobile/features/announcements/data/datasources/announcement_remote_datasource.dart';
import 'package:app_mobile/features/announcements/data/datasources/comment_remote_datasource.dart';
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
import 'package:app_mobile/features/company/data/datasources/company_remote_datasource.dart';
import 'package:app_mobile/features/company/domain/usecases/create_company_usecase.dart';
import 'package:app_mobile/features/company/domain/usecases/get_company_by_user_id_usecase.dart';
import 'package:app_mobile/features/company/domain/usecases/update_company_usecase.dart';
import 'package:app_mobile/features/events/data/datasources/event_remote_datasource.dart';
import 'package:app_mobile/features/events/domain/usecases/create_event_usecase.dart';
import 'package:app_mobile/features/events/domain/usecases/delete_event_usecase.dart';
import 'package:app_mobile/features/events/domain/usecases/get_events_usecase.dart';
import 'package:app_mobile/features/events/domain/usecases/update_event_usecase.dart';
import 'package:app_mobile/features/iam/data/datasources/iam_remote_datasource.dart';
import 'package:app_mobile/features/iam/domain/usecases/join_company_usecase.dart';
import 'package:app_mobile/features/iam/domain/usecases/sign_in_usecase.dart';
import 'package:app_mobile/features/iam/domain/usecases/sign_out_usecase.dart';
import 'package:app_mobile/features/iam/domain/usecases/sign_up_usecase.dart';
import 'package:app_mobile/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:app_mobile/features/profile/domain/usecases/get_company_members_usecase.dart';
import 'package:app_mobile/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:app_mobile/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateMocks([
  // Announcement use cases
  GetAnnouncementsUseCase,
  GetAnnouncementByIdUseCase,
  GetAnnouncementsByPriorityUseCase,
  GetAnnouncementsByCreatorUseCase,
  CreateAnnouncementUseCase,
  UpdateAnnouncementUseCase,
  DeleteAnnouncementUseCase,
  // Comment use cases
  GetCommentsUseCase,
  CreateCommentUseCase,
  DeleteCommentUseCase,
  // Event use cases
  GetEventsUseCase,
  CreateEventUseCase,
  UpdateEventUseCase,
  DeleteEventUseCase,
  // IAM use cases
  SignInUseCase,
  SignUpUseCase,
  SignOutUseCase,
  JoinCompanyUseCase,
  // Company use cases
  CreateCompanyUseCase,
  UpdateCompanyUseCase,
  GetCompanyByUserIdUseCase,
  // Profile use cases
  GetProfileUseCase,
  UpdateProfileUseCase,
  GetCompanyMembersUseCase,
  // Data sources (for integration tests)
  AnnouncementRemoteDataSource,
  CommentRemoteDataSource,
  EventRemoteDataSource,
  IamRemoteDataSource,
  CompanyRemoteDataSource,
  ProfileRemoteDataSource,
  // SharedPreferences
  SharedPreferences,
  // Auth token storage
  TokenStore,
])
void main() {}
