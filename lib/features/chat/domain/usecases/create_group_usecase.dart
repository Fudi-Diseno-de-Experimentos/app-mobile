import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/chat/domain/entities/group_entity.dart';
import 'package:app_mobile/features/chat/domain/repositories/chat_repository.dart';
import 'package:fpdart/fpdart.dart';

class CreateGroupUseCase {
  final ChatRepository repository;

  CreateGroupUseCase(this.repository);

  Future<Either<Failure, GroupEntity>> call({
    required String name,
    String? description,
    String? imageUrl,
    required String visibility,
    required List<String> memberIds,
    required String createdBy,
  }) {
    return repository.createGroup(
      name: name,
      description: description,
      imageUrl: imageUrl,
      visibility: visibility,
      memberIds: memberIds,
      createdBy: createdBy,
    );
  }
}
