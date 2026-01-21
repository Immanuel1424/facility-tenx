import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardStatsEvent extends DashboardEvent {
  const LoadDashboardStatsEvent({
    this.companyId,
    this.role,
  });

  final String? companyId;
  final String? role;

  @override
  List<Object?> get props => [companyId, role];
}

class RefreshDashboardEvent extends DashboardEvent {
  const RefreshDashboardEvent({
    this.companyId,
    this.role,
  });

  final String? companyId;
  final String? role;

  @override
  List<Object?> get props => [companyId, role];
}

class LoadDashboardAnalyticsEvent extends DashboardEvent {
  const LoadDashboardAnalyticsEvent({
    this.companyId,
    this.role,
    this.period = 'weekly',
  });

  final String? companyId;
  final String? role;
  final String period;

  @override
  List<Object?> get props => [companyId, role, period];
}
