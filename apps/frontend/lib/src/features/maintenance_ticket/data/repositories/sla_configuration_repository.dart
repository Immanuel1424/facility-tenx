import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/sla_configuration_entity.dart';
import '../../domain/repositories/sla_configuration_repository_interface.dart';
import '../dto/sla_configuration_dto.dart';
import '../mappers/sla_configuration_mapper.dart';

class SlaConfigurationRepository
    implements SlaConfigurationRepositoryInterface {
  SlaConfigurationRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<Either<String, List<SlaConfigurationEntity>>> getAll() async {
    try {
      final dtos = await _apiClient.getSlaConfigurations();
      return Right(
        dtos
            .map((dto) => SlaConfigurationMapper.toEntity(dto))
            .toList(),
      );
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] as String? ??
          'Failed to fetch SLA configurations');
    } catch (e) {
      return Left('Failed to fetch SLA configurations: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<SlaConfigurationEntity>>> getActive() async {
    try {
      final dtos = await _apiClient.getActiveSlaConfigurations();
      return Right(
        dtos
            .map((dto) => SlaConfigurationMapper.toEntity(dto))
            .toList(),
      );
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] as String? ??
          'Failed to fetch active SLA configurations');
    } catch (e) {
      return Left(
          'Failed to fetch active SLA configurations: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, SlaConfigurationEntity>> getById(String id) async {
    try {
      final dto = await _apiClient.getSlaConfigurationById(id);
      return Right(SlaConfigurationMapper.toEntity(dto));
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] as String? ??
          'Failed to fetch SLA configuration');
    } catch (e) {
      return Left('Failed to fetch SLA configuration: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, SlaConfigurationEntity>> create(
    SlaConfigurationEntity entity,
  ) async {
    try {
      final dto = CreateSlaConfigurationDto(
        name: entity.name,
        description: entity.description,
        priority: entity.priority.toBackendValue,
        first_response_time_minutes: entity.firstResponseTimeMinutes,
        acknowledgement_time_minutes: entity.acknowledgementTimeMinutes,
        resolution_time_minutes: entity.resolutionTimeMinutes,
        escalation_level_1_minutes: entity.escalationLevel1Minutes,
        escalation_level_2_minutes: entity.escalationLevel2Minutes,
        escalation_level_3_minutes: entity.escalationLevel3Minutes,
        apply_business_hours: entity.applyBusinessHours,
        business_start_time: entity.businessStartTime,
        business_end_time: entity.businessEndTime,
        working_days: entity.workingDays,
        exclude_holidays: entity.excludeHolidays,
      );
      final responseDto = await _apiClient.createSlaConfiguration(dto.toJson());
      return Right(SlaConfigurationMapper.toEntity(responseDto));
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] as String? ??
          'Failed to create SLA configuration');
    } catch (e) {
      return Left('Failed to create SLA configuration: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, SlaConfigurationEntity>> update(
    String id,
    SlaConfigurationEntity entity,
  ) async {
    try {
      final dto = UpdateSlaConfigurationDto(
        name: entity.name,
        description: entity.description,
        priority: entity.priority.toBackendValue,
        first_response_time_minutes: entity.firstResponseTimeMinutes,
        acknowledgement_time_minutes: entity.acknowledgementTimeMinutes,
        resolution_time_minutes: entity.resolutionTimeMinutes,
        escalation_level_1_minutes: entity.escalationLevel1Minutes,
        escalation_level_2_minutes: entity.escalationLevel2Minutes,
        escalation_level_3_minutes: entity.escalationLevel3Minutes,
        apply_business_hours: entity.applyBusinessHours,
        business_start_time: entity.businessStartTime,
        business_end_time: entity.businessEndTime,
        working_days: entity.workingDays,
        exclude_holidays: entity.excludeHolidays,
        is_active: entity.isActive,
      );
      final responseDto =
          await _apiClient.updateSlaConfiguration(id, dto.toJson());
      return Right(SlaConfigurationMapper.toEntity(responseDto));
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] as String? ??
          'Failed to update SLA configuration');
    } catch (e) {
      return Left('Failed to update SLA configuration: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> delete(String id) async {
    try {
      await _apiClient.deleteSlaConfiguration(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] as String? ??
          'Failed to delete SLA configuration');
    } catch (e) {
      return Left('Failed to delete SLA configuration: ${e.toString()}');
    }
  }
}
