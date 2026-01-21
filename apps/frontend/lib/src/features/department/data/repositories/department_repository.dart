import 'package:fpdart/fpdart.dart';

import '../../../../core/network/api_client.dart';
import '../dto/department_dto.dart';
import '../mappers/department_mapper.dart';
import '../../domain/repositories/department_repository_interface.dart';
import '../../domain/entities/department_entity.dart';

class DepartmentRepository implements DepartmentRepositoryInterface {
  DepartmentRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<Either<Exception, List<DepartmentEntity>>> getDepartments() async {
    try {
      final dtos = await _apiClient.getDepartments();
      final entities = DepartmentMapper.toEntityList(dtos);
      return Right(entities);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, DepartmentEntity>> getDepartment(String id) async {
    try {
      final dto = await _apiClient.getDepartment(id);
      final entity = DepartmentMapper.toEntity(dto);
      return Right(entity);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, DepartmentEntity>> createDepartment({
    required String name,
    String? description,
  }) async {
    try {
      final dto = CreateDepartmentDto(
        name: name,
        description: description,
      );
      final createdDto = await _apiClient.createDepartment(dto);
      final entity = DepartmentMapper.toEntity(createdDto);
      return Right(entity);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, DepartmentEntity>> updateDepartment({
    required String id,
    String? name,
    String? description,
  }) async {
    try {
      final dto = UpdateDepartmentDto(
        name: name,
        description: description,
      );
      final updatedDto = await _apiClient.updateDepartment(id, dto);
      final entity = DepartmentMapper.toEntity(updatedDto);
      return Right(entity);
    } on Exception catch (e) {
      return Left(e);
    }
  }
}

