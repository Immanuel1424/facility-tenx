class StatusDistributionDto {
  StatusDistributionDto({
    required this.status,
    required this.count,
    required this.percentage,
  });

  final String status;
  final int count;
  final double percentage;

  factory StatusDistributionDto.fromJson(Map<String, dynamic> json) =>
      StatusDistributionDto(
        status: json['status'] as String,
        count: (json['count'] as num?)?.toInt() ?? 0,
        percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'status': status,
        'count': count,
        'percentage': percentage,
      };
}

class PriorityDistributionDto {
  PriorityDistributionDto({
    required this.priority,
    required this.count,
    required this.percentage,
  });

  final String priority;
  final int count;
  final double percentage;

  factory PriorityDistributionDto.fromJson(Map<String, dynamic> json) =>
      PriorityDistributionDto(
        priority: json['priority'] as String,
        count: (json['count'] as num?)?.toInt() ?? 0,
        percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'priority': priority,
        'count': count,
        'percentage': percentage,
      };
}

class DepartmentDistributionDto {
  DepartmentDistributionDto({
    required this.departmentName,
    required this.count,
    required this.percentage,
  });

  final String departmentName;
  final int count;
  final double percentage;

  factory DepartmentDistributionDto.fromJson(Map<String, dynamic> json) =>
      DepartmentDistributionDto(
        departmentName: json['departmentName'] as String,
        count: (json['count'] as num?)?.toInt() ?? 0,
        percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'departmentName': departmentName,
        'count': count,
        'percentage': percentage,
      };
}

class TrendDataPointDto {
  TrendDataPointDto({
    required this.date,
    required this.created,
    required this.resolved,
    required this.inProgress,
  });

  final String date;
  final int created;
  final int resolved;
  final int inProgress;

  factory TrendDataPointDto.fromJson(Map<String, dynamic> json) =>
      TrendDataPointDto(
        date: json['date'] as String,
        created: (json['created'] as num?)?.toInt() ?? 0,
        resolved: (json['resolved'] as num?)?.toInt() ?? 0,
        inProgress: (json['inProgress'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'date': date,
        'created': created,
        'resolved': resolved,
        'inProgress': inProgress,
      };
}

class PerformanceMetricsDto {
  PerformanceMetricsDto({
    required this.averageResolutionTime,
    required this.averageFirstResponseTime,
    required this.slaCompliance,
    required this.ticketsResolved,
  });

  final double averageResolutionTime;
  final double averageFirstResponseTime;
  final double slaCompliance;
  final int ticketsResolved;

  factory PerformanceMetricsDto.fromJson(Map<String, dynamic> json) =>
      PerformanceMetricsDto(
        averageResolutionTime:
            (json['averageResolutionTime'] as num?)?.toDouble() ?? 0.0,
        averageFirstResponseTime:
            (json['averageFirstResponseTime'] as num?)?.toDouble() ?? 0.0,
        slaCompliance: (json['slaCompliance'] as num?)?.toDouble() ?? 0.0,
        ticketsResolved: (json['ticketsResolved'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'averageResolutionTime': averageResolutionTime,
        'averageFirstResponseTime': averageFirstResponseTime,
        'slaCompliance': slaCompliance,
        'ticketsResolved': ticketsResolved,
      };
}

class PredictionDto {
  PredictionDto({
    required this.predictedVolume,
    required this.confidence,
    required this.trend,
    required this.expectedResolutionTime,
  });

  final int predictedVolume;
  final int confidence;
  final String trend;
  final double expectedResolutionTime;

  factory PredictionDto.fromJson(Map<String, dynamic> json) => PredictionDto(
        predictedVolume: (json['predictedVolume'] as num?)?.toInt() ?? 0,
        confidence: (json['confidence'] as num?)?.toInt() ?? 0,
        trend: json['trend'] as String,
        expectedResolutionTime:
            (json['expectedResolutionTime'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'predictedVolume': predictedVolume,
        'confidence': confidence,
        'trend': trend,
        'expectedResolutionTime': expectedResolutionTime,
      };
}

class VillaDistributionDto {
  VillaDistributionDto({
    required this.villaNumber,
    required this.count,
    required this.percentage,
  });

  final String villaNumber;
  final int count;
  final double percentage;

  factory VillaDistributionDto.fromJson(Map<String, dynamic> json) =>
      VillaDistributionDto(
        villaNumber: json['villaNumber']?.toString() ?? '',
        count: (json['count'] as num?)?.toInt() ?? 0,
        percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'villaNumber': villaNumber,
        'count': count,
        'percentage': percentage,
      };
}

class TechnicianPerformanceDto {
  TechnicianPerformanceDto({
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

  factory TechnicianPerformanceDto.fromJson(Map<String, dynamic> json) =>
      TechnicianPerformanceDto(
        technicianId: json['technicianId'] as String,
        technicianName: json['technicianName'] as String,
        totalTickets: (json['totalTickets'] as num?)?.toInt() ?? 0,
        completedTickets: (json['completedTickets'] as num?)?.toInt() ?? 0,
        averageResolutionTime:
            (json['averageResolutionTime'] as num?)?.toDouble() ?? 0.0,
        completionRate: (json['completionRate'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'technicianId': technicianId,
        'technicianName': technicianName,
        'totalTickets': totalTickets,
        'completedTickets': completedTickets,
        'averageResolutionTime': averageResolutionTime,
        'completionRate': completionRate,
      };
}

class DashboardAnalyticsDto {
  DashboardAnalyticsDto({
    required this.statusDistribution,
    required this.priorityDistribution,
    required this.departmentDistribution,
    required this.villaDistribution,
    required this.technicianPerformance,
    required this.trends,
    required this.performance,
    required this.predictions,
  });

  final List<StatusDistributionDto> statusDistribution;
  final List<PriorityDistributionDto> priorityDistribution;
  final List<DepartmentDistributionDto> departmentDistribution;
  final List<VillaDistributionDto> villaDistribution;
  final List<TechnicianPerformanceDto> technicianPerformance;
  final List<TrendDataPointDto> trends;
  final PerformanceMetricsDto performance;
  final PredictionDto predictions;

  factory DashboardAnalyticsDto.fromJson(Map<String, dynamic> json) {
    // Handle wrapped response format
    dynamic data = json;
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      data = data['data'];
    }

    return DashboardAnalyticsDto(
      statusDistribution: (data['statusDistribution'] as List<dynamic>?)
              ?.map((e) => StatusDistributionDto.fromJson(
                    e as Map<String, dynamic>,
                  ))
              .toList() ??
          [],
      priorityDistribution: (data['priorityDistribution'] as List<dynamic>?)
              ?.map((e) => PriorityDistributionDto.fromJson(
                    e as Map<String, dynamic>,
                  ))
              .toList() ??
          [],
      departmentDistribution: (data['departmentDistribution'] as List<dynamic>?)
              ?.map((e) => DepartmentDistributionDto.fromJson(
                    e as Map<String, dynamic>,
                  ))
              .toList() ??
          [],
      villaDistribution: (data['villaDistribution'] as List<dynamic>?)
              ?.map((e) => VillaDistributionDto.fromJson(
                    e as Map<String, dynamic>,
                  ))
              .toList() ??
          [],
      technicianPerformance: (data['technicianPerformance'] as List<dynamic>?)
              ?.map((e) => TechnicianPerformanceDto.fromJson(
                    e as Map<String, dynamic>,
                  ))
              .toList() ??
          [],
      trends: (data['trends'] as List<dynamic>?)
              ?.map((e) => TrendDataPointDto.fromJson(
                    e as Map<String, dynamic>,
                  ))
              .toList() ??
          [],
      performance: PerformanceMetricsDto.fromJson(
        data['performance'] as Map<String, dynamic>,
      ),
      predictions: PredictionDto.fromJson(
        data['predictions'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'statusDistribution':
            statusDistribution.map((e) => e.toJson()).toList(),
        'priorityDistribution':
            priorityDistribution.map((e) => e.toJson()).toList(),
        'departmentDistribution':
            departmentDistribution.map((e) => e.toJson()).toList(),
        'villaDistribution': villaDistribution.map((e) => e.toJson()).toList(),
        'technicianPerformance':
            technicianPerformance.map((e) => e.toJson()).toList(),
        'trends': trends.map((e) => e.toJson()).toList(),
        'performance': performance.toJson(),
        'predictions': predictions.toJson(),
      };
}
