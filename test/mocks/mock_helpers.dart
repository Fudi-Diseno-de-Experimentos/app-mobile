import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/announcements/domain/entities/announcement_entity.dart';
import 'package:app_mobile/features/announcements/domain/entities/comment_entity.dart';
import 'package:app_mobile/features/company/domain/entities/company_entity.dart';
import 'package:app_mobile/features/events/domain/entities/event_entity.dart';
import 'package:app_mobile/features/iam/domain/entities/user_entity.dart';
import 'package:app_mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:app_mobile/features/profile/domain/entities/profile_entity.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';

void registerFallbackValues() {
  // Either<Failure, T> fallback values for mockito
  provideDummy<Either<Failure, List<AnnouncementEntity>>>(
    const Right([]),
  );
  provideDummy<Either<Failure, List<NotificationEntity>>>(
    const Right([]),
  );
  provideDummy<Either<Failure, AnnouncementEntity>>(
    const Right(AnnouncementEntity(
      id: '',
      title: '',
      description: '',
      priority: '',
      createdBy: '',
      createdAt: '',
      updatedAt: '',
    )),
  );
  provideDummy<Either<Failure, void>>(const Right(null));
  provideDummy<Either<Failure, List<CommentEntity>>>(const Right([]));
  provideDummy<Either<Failure, CommentEntity>>(
    const Right(CommentEntity(
      id: '',
      announcementId: '',
      content: '',
      authorId: '',
      createdAt: '',
      updatedAt: '',
    )),
  );
  provideDummy<Either<Failure, List<EventEntity>>>(const Right([]));
  provideDummy<Either<Failure, EventEntity>>(
    const Right(EventEntity(
      id: '',
      title: '',
      description: '',
      date: '',
      spaceId: '',
      createdBy: '',
      recipients: [],
      createdAt: '',
      updatedAt: '',
    )),
  );
  provideDummy<Either<Failure, Unit>>(const Right(unit));
  provideDummy<Either<Failure, UserEntity>>(
    const Right(UserEntity(id: '', username: '', token: '')),
  );
  provideDummy<Either<Failure, CompanyEntity>>(
    const Right(CompanyEntity(
      id: '',
      ruc: '',
      name: '',
      isActive: true,
      userId: '',
      joinCode: '',
    )),
  );
  provideDummy<Either<Failure, ProfileEntity>>(
    const Right(ProfileEntity(
      id: '',
      username: '',
      name: '',
      lastname: '',
      email: '',
    )),
  );
  provideDummy<Either<Failure, List<ProfileEntity>>>(const Right([]));
}
