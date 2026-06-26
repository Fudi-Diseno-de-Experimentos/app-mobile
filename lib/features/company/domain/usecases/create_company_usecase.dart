import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/company/domain/entities/company_entity.dart';
import 'package:app_mobile/features/company/domain/repositories/company_repository.dart';
import 'package:fpdart/fpdart.dart';

class CreateCompanyUseCase {
  final CompanyRepository repository;

  CreateCompanyUseCase(this.repository);

  Future<Either<Failure, CompanyEntity>> call({
    required String ruc,
    required String name,
    String? iconUrl,
    required bool isActive,
    required String userId,
  }) {
    return repository.createCompany(
      ruc: ruc,
      name: name,
      iconUrl: iconUrl,
      isActive: isActive,
      userId: userId,
    );
  }
}
