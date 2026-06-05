import 'package:fpdart/fpdart.dart';
import 'package:app_mobile/core/error/failures.dart';

import 'package:app_mobile/features/iam/domain/entities/user_entity.dart';
import 'package:app_mobile/features/iam/domain/usecases/sign_in_usecase.dart';
import 'package:app_mobile/features/iam/domain/repositories/iam_repository.dart';

import 'package:app_mobile/features/profile/domain/entities/profile_entity.dart';
import 'package:app_mobile/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:app_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:app_mobile/features/profile/domain/usecases/get_company_members_usecase.dart';

import 'package:app_mobile/features/announcements/domain/entities/announcement_entity.dart';
import 'package:app_mobile/features/announcements/domain/usecases/get_announcements_usecase.dart';
import 'package:app_mobile/features/announcements/domain/usecases/create_announcement_usecase.dart';
import 'package:app_mobile/features/announcements/domain/repositories/announcement_repository.dart';

import 'package:app_mobile/features/events/domain/entities/event_entity.dart';
import 'package:app_mobile/features/events/domain/usecases/get_events_usecase.dart';
import 'package:app_mobile/features/events/domain/usecases/create_event_usecase.dart';
import 'package:app_mobile/features/events/domain/repositories/event_repository.dart';

import 'package:app_mobile/app/di.dart';

class FakeSignInUseCase implements SignInUseCase {
  @override
  IamRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, UserEntity>> call(
    String username,
    String password,
  ) async {
    return const Right(
      UserEntity(
        id: '1',
        username: 'testadmin',
        token: 'fake-token',
        companyId: 'company-1',
      ),
    );
  }
}

class FakeGetProfileUseCase implements GetProfileUseCase {
  @override
  ProfileRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, ProfileEntity>> call({void params}) async {
    return const Right(
      ProfileEntity(
        id: '1',
        username: 'testadmin',
        name: 'Admin',
        lastname: 'Test',
        email: 'admin@test.com',
        roles: ['ROLE_ADMIN', 'ROLE_MANAGER'],
      ),
    );
  }
}

class FakeGetAnnouncementsUseCase implements GetAnnouncementsUseCase {
  @override
  AnnouncementRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, List<AnnouncementEntity>>> call({void params}) async {
    return const Right([]);
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
    return Right(
      AnnouncementEntity(
        id: 'ann-1',
        title: title,
        description: description,
        image: image,
        priority: priority,
        createdBy: createdBy,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
    );
  }
}

class FakeGetEventsUseCase implements GetEventsUseCase {
  @override
  EventRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, List<EventEntity>>> call({void params}) async {
    return const Right([]);
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
    required String location,
    required String createdBy,
    required List<String> recipientIds,
  }) async {
    return Right(
      EventEntity(
        id: 'event-1',
        title: title,
        description: description,
        date: date,
        location: location,
        createdBy: createdBy,
        recipientIds: recipientIds,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
    );
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

void setupMockDependencies() {
  sl.allowReassignment = true;
  sl.registerLazySingleton<SignInUseCase>(() => FakeSignInUseCase());
  sl.registerLazySingleton<GetProfileUseCase>(() => FakeGetProfileUseCase());
  sl.registerLazySingleton<GetAnnouncementsUseCase>(
    () => FakeGetAnnouncementsUseCase(),
  );
  sl.registerLazySingleton<CreateAnnouncementUseCase>(
    () => FakeCreateAnnouncementUseCase(),
  );
  sl.registerLazySingleton<GetEventsUseCase>(() => FakeGetEventsUseCase());
  sl.registerLazySingleton<CreateEventUseCase>(() => FakeCreateEventUseCase());
  sl.registerLazySingleton<GetCompanyMembersUseCase>(
    () => FakeGetCompanyMembersUseCase(),
  );
}
