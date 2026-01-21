import 'package:fpdart/fpdart.dart';

import '../../../../core/network/api_client.dart';
import '../dto/site_dto.dart';
import '../mappers/site_mapper.dart';
import '../../domain/repositories/site_repository_interface.dart';
import '../../domain/entities/site_entity.dart';

class SiteRepository implements SiteRepositoryInterface {
  SiteRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<Either<Exception, List<SiteEntity>>> getSites({
    String? companyId,
  }) async {
    try {
      final dtos = await _apiClient.getSitesForManagement(companyId: companyId);
      final entities = SiteMapper.toEntityList(dtos);
      // Sort by code ascending
      entities.sort((a, b) => a.code.compareTo(b.code));
      return Right(entities);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, SiteEntity>> getSiteById(String id) async {
    try {
      final dto = await _apiClient.getSiteById(id);
      final entity = SiteMapper.toEntity(dto);
      return Right(entity);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, SiteEntity>> createSite({
    required String name,
    required bool isParent,
    String? code,
    String? parentSiteId,
    bool? createAdmin,
    String? adminEmail,
    String? adminPassword,
    String? adminFirstName,
    String? adminLastName,
    String? companyId,
  }) async {
    try {
      final dto = CreateSiteDto(
        code: code,
        name: name,
        isParent: isParent,
        parentSiteId: parentSiteId,
        createAdmin: createAdmin,
        adminEmail: adminEmail,
        adminPassword: adminPassword,
        adminFirstName: adminFirstName,
        adminLastName: adminLastName,
        companyId: companyId,
      );
      final response = await _apiClient.createSite(dto);
      return Right(SiteMapper.toEntity(response));
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, SiteEntity>> updateSite(
    String id, {
    String? code,
    String? name,
    String? description,
    String? address,
    String? city,
    String? country,
    bool? isParent,
    bool? isActive,
    String? parentSiteId,
  }) async {
    try {
      final dto = UpdateSiteDto(
        code: code,
        name: name,
        description: description,
        address: address,
        city: city,
        country: country,
        isParent: isParent,
        isActive: isActive,
        parentSiteId: parentSiteId,
      );
      final response = await _apiClient.updateSite(id, dto);
      return Right(SiteMapper.toEntity(response));
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, void>> deleteSite(String id) async {
    try {
      await _apiClient.deleteSite(id);
      return const Right(null);
    } on Exception catch (e) {
      return Left(e);
    }
  }
}

