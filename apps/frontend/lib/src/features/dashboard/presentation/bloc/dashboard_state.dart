import 'package:equatable/equatable.dart';

import '../../domain/entities/dashboard_stats_entity.dart';
import '../../domain/entities/dashboard_analytics_entity.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(DashboardStatsEntity stats) loaded,
    required T Function(String message) error,
  }) {
    if (this is DashboardInitial) {
      return initial();
    } else if (this is DashboardLoading) {
      return loading();
    } else if (this is DashboardLoaded) {
      return loaded((this as DashboardLoaded).stats);
    } else if (this is DashboardError) {
      return error((this as DashboardError).message);
    }
    throw Exception('Unknown DashboardState');
  }

  T? maybeWhen<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(DashboardStatsEntity stats)? loaded,
    T Function(String message)? error,
    required T Function() orElse,
  }) {
    if (this is DashboardInitial && initial != null) {
      return initial();
    } else if (this is DashboardLoading && loading != null) {
      return loading();
    } else if (this is DashboardLoaded && loaded != null) {
      return loaded((this as DashboardLoaded).stats);
    } else if (this is DashboardError && error != null) {
      return error((this as DashboardError).message);
    }
    return orElse();
  }
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  const DashboardLoaded({
    required this.stats,
    this.analytics,
  });

  final DashboardStatsEntity stats;
  final DashboardAnalyticsEntity? analytics;

  @override
  List<Object?> get props => [stats, analytics];
}

class DashboardError extends DashboardState {
  const DashboardError({required this.message});

  final String message;

  @override
  List<Object> get props => [message];
}

