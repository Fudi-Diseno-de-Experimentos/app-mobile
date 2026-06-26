import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/company/domain/repositories/space_repository.dart';
import 'package:fpdart/fpdart.dart';

class DeleteSpaceUseCase {
  final SpaceRepository repository;

  DeleteSpaceUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String id) {
    return repository.deleteSpace(id);
  }
}
