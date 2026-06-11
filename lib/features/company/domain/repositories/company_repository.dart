import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/company/domain/entities/company_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract class CompanyRepository {
  Future<Either<Failure, CompanyEntity>> createCompany({
    required String ruc,
    required String name,
    String? iconUrl,
    required bool isActive,
    required String userId,
  });

  Future<Either<Failure, CompanyEntity>> updateCompany({
    required String id,
    required String ruc,
    required String name,
    String? iconUrl,
    required bool isActive,
  });

  Future<Either<Failure, CompanyEntity>> getCompanyByUserId(String userId);
  Future<Either<Failure, CompanyEntity>> getCompanyById(String id);
}
