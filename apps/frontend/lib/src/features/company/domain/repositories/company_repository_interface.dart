import 'package:fpdart/fpdart.dart';
import '../entities/company_entity.dart';

abstract class CompanyRepositoryInterface {
  Future<Either<Exception, List<CompanyEntity>>> getCompanies();
  Future<Either<Exception, CompanyEntity>> getCompany(String id);
  Future<Either<Exception, CompanyEntity>> createCompany({
    required String code,
    required String name,
    String? description,
    String? logoUrl,
    String? timezone,
    String? currency,
    bool? isActive,
  });
  Future<Either<Exception, CompanyEntity>> updateCompany(
    String id, {
    String? code,
    String? name,
    String? description,
    String? logoUrl,
    String? timezone,
    String? currency,
    bool? isActive,
  });
  Future<Either<Exception, void>> deleteCompany(String id);
}

