import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/company/domain/entities/space_entity.dart';
import 'package:app_mobile/features/company/domain/repositories/space_repository.dart';
import 'package:fpdart/fpdart.dart';

class CreateSpaceUseCase {
  final SpaceRepository repository;

  CreateSpaceUseCase(this.repository);

  Future<Either<Failure, SpaceEntity>> call({
    required String name,
    String? description,
  }) {
    return repository.createSpace(name: name, description: description);
  }
}
