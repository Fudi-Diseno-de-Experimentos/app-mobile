import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/company/domain/entities/space_entity.dart';
import 'package:app_mobile/features/company/domain/repositories/space_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetSpacesUseCase {
  final SpaceRepository repository;

  GetSpacesUseCase(this.repository);

  Future<Either<Failure, List<SpaceEntity>>> call({String? date}) {
    return repository.getSpaces(date: date);
  }
}
