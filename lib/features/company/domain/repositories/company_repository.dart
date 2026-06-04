import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/company_entity.dart';

abstract class CompanyRepository {
  Future<Either<Failure, CompanyEntity>> createCompany({
    required String ruc,
    required String nombre,
    String? iconUrl,
    required bool isActive,
    required String userId,
  });

  Future<Either<Failure, CompanyEntity>> updateCompany({
    required String id,
    required String ruc,
    required String nombre,
    String? iconUrl,
    required bool isActive,
  });

  Future<Either<Failure, CompanyEntity>> getCompanyByUserId(String userId);
  Future<Either<Failure, CompanyEntity>> getCompanyById(String id);
}
