import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/escalation_scheduler_config_entity.dart';
import '../../domain/repositories/escalation_scheduler_config_repository_interface.dart';

class EscalationSchedulerConfigRepository
    implements EscalationSchedulerConfigRepositoryInterface {
  EscalationSchedulerConfigRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<Either<String, EscalationSchedulerConfigEntity>> getConfig() async {
    try {
      final data = await _apiClient.getEscalationSchedulerConfig();
      return Right(
        EscalationSchedulerConfigEntity(
          intervalMinutes: data['intervalMinutes'] as int,
        ),
      );
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] as String? ??
          'Failed to fetch escalation scheduler configuration');
    } catch (e) {
      return Left(
          'Failed to fetch escalation scheduler configuration: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, EscalationSchedulerConfigEntity>> updateConfig(
    int intervalMinutes,
  ) async {
    try {
      final data = await _apiClient.updateEscalationSchedulerConfig({
        'intervalMinutes': intervalMinutes,
      });
      return Right(
        EscalationSchedulerConfigEntity(
          intervalMinutes: data['intervalMinutes'] as int,
        ),
      );
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] as String? ??
          'Failed to update escalation scheduler configuration');
    } catch (e) {
      return Left(
          'Failed to update escalation scheduler configuration: ${e.toString()}');
    }
  }
}
