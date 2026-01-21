import 'package:fpdart/fpdart.dart';

import '../../../../core/network/api_client.dart';
import '../dto/company_dto.dart';
import '../mappers/company_mapper.dart';
import '../../domain/repositories/company_repository_interface.dart';
import '../../domain/entities/company_entity.dart';

class CompanyRepository implements CompanyRepositoryInterface {
  CompanyRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<Either<Exception, List<CompanyEntity>>> getCompanies() async {
    try {
      final dtos = await _apiClient.getCompanies();
      final entities = CompanyMapper.toEntityList(dtos);
      // Sort by name ascending
      entities.sort((a, b) => a.name.compareTo(b.name));
      return Right(entities);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, CompanyEntity>> getCompany(String id) async {
    try {
      final dto = await _apiClient.getCompanyById(id);
      final entity = CompanyMapper.toEntity(dto);
      return Right(entity);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, CompanyEntity>> createCompany({
    required String code,
    required String name,
    String? description,
    String? logoUrl,
    String? timezone,
    String? currency,
    bool? isActive,
  }) async {
    try {
      final dto = CreateCompanyDto(
        code: code,
        name: name,
        description: description,
        logoUrl: logoUrl,
        timezone: timezone,
        currency: currency,
        isActive: isActive,
      );
      final response = await _apiClient.createCompany(dto);
      return Right(CompanyMapper.toEntity(response));
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, CompanyEntity>> updateCompany(
    String id, {
    String? code,
    String? name,
    String? description,
    String? logoUrl,
    String? timezone,
    String? currency,
    bool? isActive,
  }) async {
    try {
      final dto = UpdateCompanyDto(
        code: code,
        name: name,
        description: description,
        logoUrl: logoUrl,
        timezone: timezone,
        currency: currency,
        isActive: isActive,
      );
      final response = await _apiClient.updateCompany(id, dto);
      return Right(CompanyMapper.toEntity(response));
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, void>> deleteCompany(String id) async {
    try {
      await _apiClient.deleteCompany(id);
      return const Right(null);
    } on Exception catch (e) {
      return Left(e);
    }
  }
}

