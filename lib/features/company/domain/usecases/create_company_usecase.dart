import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/company_entity.dart';
import '../repositories/company_repository.dart';

class CreateCompanyUseCase {
  final CompanyRepository repository;

  CreateCompanyUseCase(this.repository);

  Future<Either<Failure, CompanyEntity>> call({
    required String ruc,
    required String nombre,
    String? iconUrl,
    required bool isActive,
    required String userId,
  }) {
    return repository.createCompany(
      ruc: ruc,
      nombre: nombre,
      iconUrl: iconUrl,
      isActive: isActive,
      userId: userId,
    );
  }
}
