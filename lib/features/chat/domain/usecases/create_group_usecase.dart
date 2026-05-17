import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/group_entity.dart';
import '../repositories/chat_repository.dart';

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
