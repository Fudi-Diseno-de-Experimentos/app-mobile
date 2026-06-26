import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/company/domain/entities/company_entity.dart';
import 'package:app_mobile/features/company/domain/repositories/company_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetCompanyUseCase {
  final CompanyRepository repository;

  GetCompanyUseCase(this.repository);

  Future<Either<Failure, CompanyEntity>> call(String id) {
    return repository.getCompanyById(id);
  }
}
