import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/chat/domain/entities/group_entity.dart';
import 'package:app_mobile/features/chat/domain/repositories/chat_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateGroupUseCase {
  final ChatRepository repository;

  UpdateGroupUseCase(this.repository);

  Future<Either<Failure, GroupEntity>> call({
    required String groupId,
    String? name,
    String? description,
    String? imageUrl,
  }) {
    return repository.updateGroup(
      groupId: groupId,
      name: name,
      description: description,
      imageUrl: imageUrl,
    );
  }
}
