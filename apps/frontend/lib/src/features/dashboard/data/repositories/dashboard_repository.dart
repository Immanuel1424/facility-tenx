import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/dashboard_stats_entity.dart';
import '../../domain/entities/dashboard_analytics_entity.dart';
import '../../domain/repositories/dashboard_repository_interface.dart';

class DashboardRepository implements DashboardRepositoryInterface {
  DashboardRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<Either<Exception, DashboardStatsEntity>> getDashboardStats({
    String? companyId,
    String? role,
  }) async {
    try {
      final dto = await _apiClient.getDashboardStats(
        companyId: companyId,
        role: role,
      );

      // Map DTO to Entity
      final entity = DashboardStatsEntity(
        openRequests: dto.openRequests,
        inProgress: dto.inProgress,
        resolved: dto.resolved,
        totalRequests: dto.totalRequests,
        activeUsers: dto.activeUsers,
        pendingApproval: dto.pendingApproval,
        completedToday: dto.completedToday,
        assigned: dto.assigned,
        completed: dto.completed,
        pending: dto.pending,
        acknowledged: dto.acknowledged,
        onHold: dto.onHold,
      );

      return Right(entity);
    } on DioException catch (e) {
      // Provide more specific error messages for Dio exceptions
      final errorMessage = e.response?.data?['message'] as String? ??
          e.response?.statusMessage ??
          e.message ??
          'Failed to load dashboard statistics';
      print('❌ Dashboard stats error: $errorMessage');
      print('Response: ${e.response?.data}');
      return Left(Exception(errorMessage));
    } catch (e, stackTrace) {
      print('❌ Unexpected error loading dashboard stats: $e');
      print('Stack trace: $stackTrace');
      return Left(
        Exception('Failed to load dashboard statistics: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Exception, DashboardAnalyticsEntity>> getDashboardAnalytics({
    String? companyId,
    String? role,
    String period = 'weekly',
  }) async {
    try {
      final dto = await _apiClient.getDashboardAnalytics(
        companyId: companyId,
        role: role,
        period: period,
      );

      // Map DTO to Entity
      final entity = DashboardAnalyticsEntity(
        statusDistribution: dto.statusDistribution
            .map(
              (e) => StatusDistributionEntity(
                status: e.status,
                count: e.count,
                percentage: e.percentage,
              ),
            )
            .toList(),
        priorityDistribution: dto.priorityDistribution
            .map(
              (e) => PriorityDistributionEntity(
                priority: e.priority,
                count: e.count,
                percentage: e.percentage,
              ),
            )
            .toList(),
        departmentDistribution: dto.departmentDistribution
            .map(
              (e) => DepartmentDistributionEntity(
                departmentName: e.departmentName,
                count: e.count,
                percentage: e.percentage,
              ),
            )
            .toList(),
        villaDistribution: dto.villaDistribution
            .map(
              (e) => VillaDistributionEntity(
                villaNumber: e.villaNumber,
                count: e.count,
                percentage: e.percentage,
              ),
            )
            .toList(),
        technicianPerformance: dto.technicianPerformance
            .map(
              (e) => TechnicianPerformanceEntity(
                technicianId: e.technicianId,
                technicianName: e.technicianName,
                totalTickets: e.totalTickets,
                completedTickets: e.completedTickets,
                averageResolutionTime: e.averageResolutionTime,
                completionRate: e.completionRate,
              ),
            )
            .toList(),
        trends: dto.trends
            .map(
              (e) => TrendDataPointEntity(
                date: e.date,
                created: e.created,
                resolved: e.resolved,
                inProgress: e.inProgress,
              ),
            )
            .toList(),
        performance: PerformanceMetricsEntity(
          averageResolutionTime: dto.performance.averageResolutionTime,
          averageFirstResponseTime: dto.performance.averageFirstResponseTime,
          slaCompliance: dto.performance.slaCompliance,
          ticketsResolved: dto.performance.ticketsResolved,
        ),
        predictions: PredictionEntity(
          predictedVolume: dto.predictions.predictedVolume,
          confidence: dto.predictions.confidence,
          trend: dto.predictions.trend,
          expectedResolutionTime: dto.predictions.expectedResolutionTime,
        ),
      );

      return Right(entity);
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] as String? ??
          e.response?.statusMessage ??
          e.message ??
          'Failed to load dashboard analytics';
      print('❌ Dashboard analytics error: $errorMessage');
      print('Response: ${e.response?.data}');
      return Left(Exception(errorMessage));
    } catch (e, stackTrace) {
      print('❌ Unexpected error loading dashboard analytics: $e');
      print('Stack trace: $stackTrace');
      return Left(
        Exception('Failed to load dashboard analytics: ${e.toString()}'),
      );
    }
  }
}
