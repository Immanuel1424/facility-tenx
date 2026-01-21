import 'package:equatable/equatable.dart';

class StatusDistributionEntity extends Equatable {
  const StatusDistributionEntity({
    required this.status,
    required this.count,
    required this.percentage,
  });

  final String status;
  final int count;
  final double percentage;

  @override
  List<Object> get props => [status, count, percentage];
}

class PriorityDistributionEntity extends Equatable {
  const PriorityDistributionEntity({
    required this.priority,
    required this.count,
    required this.percentage,
  });

  final String priority;
  final int count;
  final double percentage;

  @override
  List<Object> get props => [priority, count, percentage];
}

class DepartmentDistributionEntity extends Equatable {
  const DepartmentDistributionEntity({
    required this.departmentName,
    required this.count,
    required this.percentage,
  });

  final String departmentName;
  final int count;
  final double percentage;

  @override
  List<Object> get props => [departmentName, count, percentage];
}

class TrendDataPointEntity extends Equatable {
  const TrendDataPointEntity({
    required this.date,
    required this.created,
    required this.resolved,
    required this.inProgress,
  });

  final String date;
  final int created;
  final int resolved;
  final int inProgress;

  @override
  List<Object> get props => [date, created, resolved, inProgress];
}

class PerformanceMetricsEntity extends Equatable {
  const PerformanceMetricsEntity({
    required this.averageResolutionTime,
    required this.averageFirstResponseTime,
    required this.slaCompliance,
    required this.ticketsResolved,
  });

  final double averageResolutionTime;
  final double averageFirstResponseTime;
  final double slaCompliance;
  final int ticketsResolved;

  @override
  List<Object> get props => [
        averageResolutionTime,
        averageFirstResponseTime,
        slaCompliance,
        ticketsResolved,
      ];
}

class PredictionEntity extends Equatable {
  const PredictionEntity({
    required this.predictedVolume,
    required this.confidence,
    required this.trend,
    required this.expectedResolutionTime,
  });

  final int predictedVolume;
  final int confidence;
  final String trend;
  final double expectedResolutionTime;

  @override
  List<Object> get props => [
        predictedVolume,
        confidence,
        trend,
        expectedResolutionTime,
      ];
}

class VillaDistributionEntity extends Equatable {
  const VillaDistributionEntity({
    required this.villaNumber,
    required this.count,
    required this.percentage,
  });

  final String villaNumber;
  final int count;
  final double percentage;

  @override
  List<Object> get props => [villaNumber, count, percentage];
}

class TechnicianPerformanceEntity extends Equatable {
  const TechnicianPerformanceEntity({
    required this.technicianId,
    required this.technicianName,
    required this.totalTickets,
    required this.completedTickets,
    required this.averageResolutionTime,
    required this.completionRate,
  });

  final String technicianId;
  final String technicianName;
  final int totalTickets;
  final int completedTickets;
  final double averageResolutionTime;
  final double completionRate;

  @override
  List<Object> get props => [
        technicianId,
        technicianName,
        totalTickets,
        completedTickets,
        averageResolutionTime,
        completionRate,
      ];
}

class DashboardAnalyticsEntity extends Equatable {
  const DashboardAnalyticsEntity({
    required this.statusDistribution,
    required this.priorityDistribution,
    required this.departmentDistribution,
    required this.villaDistribution,
    required this.technicianPerformance,
    required this.trends,
    required this.performance,
    required this.predictions,
  });

  final List<StatusDistributionEntity> statusDistribution;
  final List<PriorityDistributionEntity> priorityDistribution;
  final List<DepartmentDistributionEntity> departmentDistribution;
  final List<VillaDistributionEntity> villaDistribution;
  final List<TechnicianPerformanceEntity> technicianPerformance;
  final List<TrendDataPointEntity> trends;
  final PerformanceMetricsEntity performance;
  final PredictionEntity predictions;

  @override
  List<Object> get props => [
        statusDistribution,
        priorityDistribution,
        departmentDistribution,
        villaDistribution,
        technicianPerformance,
        trends,
        performance,
        predictions,
      ];
}
