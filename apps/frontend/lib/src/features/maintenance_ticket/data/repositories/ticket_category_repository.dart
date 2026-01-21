import 'package:fpdart/fpdart.dart';

import '../../../../core/network/api_client.dart';
import '../dto/create_ticket_category_dto.dart';
import '../dto/update_ticket_category_dto.dart';
import '../dto/maintenance_ticket_dto.dart';
import '../mappers/ticket_category_mapper.dart';
import '../../domain/entities/ticket_category_entity.dart';

class TicketCategoryRepository {
  TicketCategoryRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<Either<Exception, List<TicketCategoryEntity>>> getAll({
    bool activeOnly = true,
  }) async {
    try {
      final dtos = await _apiClient.getAllTicketCategories(
        activeOnly: activeOnly,
      );
      final entities = dtos
          .map<TicketCategoryEntity?>((TicketCategoryDto dto) => TicketCategoryMapper.toEntity(dto))
          .whereType<TicketCategoryEntity>()
          .toList();
      return Right(entities);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  Future<Either<Exception, TicketCategoryEntity>> getById(String id) async {
    try {
      final dto = await _apiClient.getTicketCategoryById(id);
      final entity = TicketCategoryMapper.toEntity(dto);
      if (entity == null) {
        return Left(Exception('Category not found'));
      }
      return Right(entity);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  Future<Either<Exception, TicketCategoryEntity>> create(
    CreateTicketCategoryDto dto,
  ) async {
    try {
      final response = await _apiClient.createTicketCategory(dto.toJson());
      final entity = TicketCategoryMapper.toEntity(response);
      if (entity == null) {
        return Left(Exception('Failed to create category'));
      }
      return Right(entity);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  Future<Either<Exception, TicketCategoryEntity>> update(
    String id,
    UpdateTicketCategoryDto dto,
  ) async {
    try {
      final response = await _apiClient.updateTicketCategory(id, dto.toJson());
      final entity = TicketCategoryMapper.toEntity(response);
      if (entity == null) {
        return Left(Exception('Failed to update category'));
      }
      return Right(entity);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  Future<Either<Exception, void>> delete(String id) async {
    try {
      await _apiClient.deleteTicketCategory(id);
      return const Right(null);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  Future<Either<Exception, TicketCategoryEntity>> activate(String id) async {
    try {
      final response = await _apiClient.activateTicketCategory(id);
      final entity = TicketCategoryMapper.toEntity(response);
      if (entity == null) {
        return Left(Exception('Failed to activate category'));
      }
      return Right(entity);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  Future<Either<Exception, TicketCategoryEntity>> deactivate(String id) async {
    try {
      final response = await _apiClient.deactivateTicketCategory(id);
      final entity = TicketCategoryMapper.toEntity(response);
      if (entity == null) {
        return Left(Exception('Failed to deactivate category'));
      }
      return Right(entity);
    } on Exception catch (e) {
      return Left(e);
    }
  }
}

