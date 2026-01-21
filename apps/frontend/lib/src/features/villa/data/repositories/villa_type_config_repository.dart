import 'package:fpdart/fpdart.dart';

import '../../../../core/network/api_client.dart';
import '../dto/create_villa_type_config_dto.dart';
import '../dto/update_villa_type_config_dto.dart';
import '../mappers/villa_type_config_mapper.dart';
import '../../domain/entities/villa_type_config_entity.dart';

class VillaTypeConfigRepository {
  VillaTypeConfigRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<Either<Exception, List<VillaTypeConfigEntity>>> getAll({
    bool includeInactive = false,
  }) async {
    try {
      final dtos = await _apiClient.getVillaTypeConfigs(
        includeInactive: includeInactive,
      );
      final entities = dtos
          .map(VillaTypeConfigMapper.dtoToEntity)
          .toList();
      return Right(entities);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  Future<Either<Exception, VillaTypeConfigEntity>> getById(String id) async {
    try {
      final dto = await _apiClient.getVillaTypeConfigById(id);
      return Right(VillaTypeConfigMapper.dtoToEntity(dto));
    } on Exception catch (e) {
      return Left(e);
    }
  }

  Future<Either<Exception, VillaTypeConfigEntity>> create(
    CreateVillaTypeConfigDto dto,
  ) async {
    try {
      final response = await _apiClient.createVillaTypeConfig(dto);
      return Right(VillaTypeConfigMapper.dtoToEntity(response));
    } on Exception catch (e) {
      return Left(e);
    }
  }

  Future<Either<Exception, VillaTypeConfigEntity>> update(
    String id,
    UpdateVillaTypeConfigDto dto,
  ) async {
    try {
      final response = await _apiClient.updateVillaTypeConfig(id, dto);
      return Right(VillaTypeConfigMapper.dtoToEntity(response));
    } on Exception catch (e) {
      return Left(e);
    }
  }

  Future<Either<Exception, void>> delete(String id) async {
    try {
      await _apiClient.deleteVillaTypeConfig(id);
      return const Right(null);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  Future<Either<Exception, VillaTypeConfigEntity>> activate(String id) async {
    try {
      final response = await _apiClient.activateVillaTypeConfig(id);
      return Right(VillaTypeConfigMapper.dtoToEntity(response));
    } on Exception catch (e) {
      return Left(e);
    }
  }

  Future<Either<Exception, VillaTypeConfigEntity>> deactivate(String id) async {
    try {
      final response = await _apiClient.deactivateVillaTypeConfig(id);
      return Right(VillaTypeConfigMapper.dtoToEntity(response));
    } on Exception catch (e) {
      return Left(e);
    }
  }
}

