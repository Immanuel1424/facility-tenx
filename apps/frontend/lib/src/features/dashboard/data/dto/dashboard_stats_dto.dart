class DashboardStatsDto {
  DashboardStatsDto({
    required this.openRequests,
    required this.inProgress,
    required this.resolved,
    required this.totalRequests,
    required this.activeUsers,
    required this.pendingApproval,
    required this.completedToday,
    required this.assigned,
    required this.completed,
    required this.pending,
    required this.acknowledged,
    required this.onHold,
  });

  final int openRequests;
  final int inProgress;
  final int resolved;
  final int totalRequests;
  final int activeUsers;
  final int pendingApproval;
  final int completedToday;
  final int assigned;
  final int completed;
  final int pending;
  final int acknowledged;
  final int onHold;

  factory DashboardStatsDto.fromJson(Map<String, dynamic> json) =>
      DashboardStatsDto(
        openRequests: (json['openRequests'] as num?)?.toInt() ?? 0,
        inProgress: (json['inProgress'] as num?)?.toInt() ?? 0,
        resolved: (json['resolved'] as num?)?.toInt() ?? 0,
        totalRequests: (json['totalRequests'] as num?)?.toInt() ?? 0,
        activeUsers: (json['activeUsers'] as num?)?.toInt() ?? 0,
        pendingApproval: (json['pendingApproval'] as num?)?.toInt() ?? 0,
        completedToday: (json['completedToday'] as num?)?.toInt() ?? 0,
        assigned: (json['assigned'] as num?)?.toInt() ?? 0,
        completed: (json['completed'] as num?)?.toInt() ?? 0,
        pending: (json['pending'] as num?)?.toInt() ?? 0,
        acknowledged: (json['acknowledged'] as num?)?.toInt() ?? 0,
        onHold: (json['onHold'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'openRequests': openRequests,
        'inProgress': inProgress,
        'resolved': resolved,
        'totalRequests': totalRequests,
        'activeUsers': activeUsers,
        'pendingApproval': pendingApproval,
        'completedToday': completedToday,
        'assigned': assigned,
        'completed': completed,
        'pending': pending,
        'acknowledged': acknowledged,
        'onHold': onHold,
      };
}
