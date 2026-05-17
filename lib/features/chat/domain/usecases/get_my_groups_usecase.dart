import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/group_entity.dart';
import '../repositories/chat_repository.dart';

class GetMyGroupsUseCase {
  final ChatRepository repository;

  GetMyGroupsUseCase(this.repository);

  Future<Either<Failure, List<GroupEntity>>> call(String userId) {
    return repository.getMyGroups(userId);
  }
}
