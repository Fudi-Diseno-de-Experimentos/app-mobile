import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/company_entity.dart';
import '../repositories/company_repository.dart';

class UpdateCompanyUseCase {
  final CompanyRepository repository;

  UpdateCompanyUseCase(this.repository);

  Future<Either<Failure, CompanyEntity>> call({
    required String id,
    required String ruc,
    required String nombre,
    String? iconUrl,
    required bool isActive,
  }) {
    return repository.updateCompany(
      id: id,
      ruc: ruc,
      nombre: nombre,
      iconUrl: iconUrl,
      isActive: isActive,
    );
  }
}
