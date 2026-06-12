import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/company/domain/entities/space_entity.dart';
import 'package:app_mobile/features/company/domain/repositories/space_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateSpaceUseCase {
  final SpaceRepository repository;

  UpdateSpaceUseCase(this.repository);

  Future<Either<Failure, SpaceEntity>> call({
    required String id,
    required String name,
    String? description,
  }) {
    return repository.updateSpace(id: id, name: name, description: description);
  }
}
