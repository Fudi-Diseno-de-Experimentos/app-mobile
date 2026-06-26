import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/company/domain/entities/company_entity.dart';
import 'package:app_mobile/features/company/domain/repositories/company_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateCompanyUseCase {
  final CompanyRepository repository;

  UpdateCompanyUseCase(this.repository);

  Future<Either<Failure, CompanyEntity>> call({
    required String id,
    required String ruc,
    required String name,
    String? iconUrl,
    required bool isActive,
  }) {
    return repository.updateCompany(
      id: id,
      ruc: ruc,
      name: name,
      iconUrl: iconUrl,
      isActive: isActive,
    );
  }
}
