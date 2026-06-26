import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/company/domain/entities/company_entity.dart';
import 'package:app_mobile/features/company/domain/repositories/company_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetCompanyByUserIdUseCase {
  final CompanyRepository repository;

  GetCompanyByUserIdUseCase(this.repository);

  Future<Either<Failure, CompanyEntity>> call(String userId) {
    return repository.getCompanyByUserId(userId);
  }
}
