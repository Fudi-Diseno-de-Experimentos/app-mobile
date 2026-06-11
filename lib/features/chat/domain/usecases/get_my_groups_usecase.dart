import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/chat/domain/entities/group_entity.dart';
import 'package:app_mobile/features/chat/domain/repositories/chat_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetMyGroupsUseCase {
  final ChatRepository repository;

  GetMyGroupsUseCase(this.repository);

  Future<Either<Failure, List<GroupEntity>>> call(String userId) {
    return repository.getMyGroups(userId);
  }
}
