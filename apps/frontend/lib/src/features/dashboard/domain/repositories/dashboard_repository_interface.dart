import 'package:fpdart/fpdart.dart';

import '../entities/dashboard_stats_entity.dart';
import '../entities/dashboard_analytics_entity.dart';

abstract class DashboardRepositoryInterface {
  Future<Either<Exception, DashboardStatsEntity>> getDashboardStats({
    String? companyId,
    String? role,
  });

  Future<Either<Exception, DashboardAnalyticsEntity>> getDashboardAnalytics({
    String? companyId,
    String? role,
    String period = 'weekly',
  });
}
