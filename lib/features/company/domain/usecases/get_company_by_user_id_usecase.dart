import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/company_entity.dart';
import '../repositories/company_repository.dart';

class GetCompanyByUserIdUseCase {
  final CompanyRepository repository;

  GetCompanyByUserIdUseCase(this.repository);

  Future<Either<Failure, CompanyEntity>> call(String userId) {
    return repository.getCompanyByUserId(userId);
  }
}
