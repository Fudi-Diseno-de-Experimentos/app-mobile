import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/company/domain/entities/space_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract class SpaceRepository {
  Future<Either<Failure, List<SpaceEntity>>> getSpaces({String? date});
  Future<Either<Failure, SpaceEntity>> createSpace({
    required String name,
    String? description,
  });
  Future<Either<Failure, SpaceEntity>> updateSpace({
    required String id,
    required String name,
    String? description,
  });
  Future<Either<Failure, Unit>> deleteSpace(String id);
}
