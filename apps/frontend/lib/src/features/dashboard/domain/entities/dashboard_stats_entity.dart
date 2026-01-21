import 'package:equatable/equatable.dart';

class DashboardStatsEntity extends Equatable {
  const DashboardStatsEntity({
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

  @override
  List<Object> get props => [
        openRequests,
        inProgress,
        resolved,
        totalRequests,
        activeUsers,
        pendingApproval,
        completedToday,
        assigned,
        completed,
        pending,
        acknowledged,
        onHold,
      ];
}
