import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/group_entity.dart';
import '../repositories/chat_repository.dart';

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
