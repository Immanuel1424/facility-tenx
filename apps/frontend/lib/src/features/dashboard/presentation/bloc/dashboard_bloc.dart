import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/dashboard_repository_interface.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc({
    required DashboardRepositoryInterface dashboardRepository,
  })  : _dashboardRepository = dashboardRepository,
        super(const DashboardInitial()) {
    on<LoadDashboardStatsEvent>(_onLoadStats);
    on<RefreshDashboardEvent>(_onRefresh);
    on<LoadDashboardAnalyticsEvent>(_onLoadAnalytics);
  }

  final DashboardRepositoryInterface _dashboardRepository;
  
  // Debounce timer to prevent rapid successive refreshes
  Timer? _refreshDebounceTimer;
  DateTime? _lastRefreshTime;
  
  // Minimum time between refreshes (2 seconds)
  static const Duration _minRefreshInterval = Duration(seconds: 2);

  Future<void> _onLoadStats(
    LoadDashboardStatsEvent event,
    Emitter<DashboardState> emit,
  ) async {
    print('📊 Loading dashboard stats for company: ${event.companyId}, role: ${event.role}');
    emit(const DashboardLoading());

    final result = await _dashboardRepository.getDashboardStats(
      companyId: event.companyId,
      role: event.role,
    );

    result.fold(
      (error) {
        print('❌ Failed to load dashboard stats: $error');
        emit(
          DashboardError(message: error.toString()),
        );
      },
      (stats) {
        print('✅ Dashboard stats loaded successfully - Total: ${stats.totalRequests}');
        emit(
          DashboardLoaded(stats: stats),
        );
      },
    );
  }

  Future<void> _onRefresh(
    RefreshDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    // Debounce: Cancel any pending refresh
    _refreshDebounceTimer?.cancel();
    
    // Check if we're refreshing too frequently
    final now = DateTime.now();
    if (_lastRefreshTime != null &&
        now.difference(_lastRefreshTime!) < _minRefreshInterval) {
      // Too soon, debounce it
      _refreshDebounceTimer = Timer(
        _minRefreshInterval - now.difference(_lastRefreshTime!),
        () {
          add(event);
        },
      );
      return;
    }
    
    _lastRefreshTime = now;
    
    // Keep current state if loaded, otherwise show loading
    if (state is DashboardLoaded) {
      // Optimistic update - keep showing current data while refreshing
      final currentState = state as DashboardLoaded;
      emit(DashboardLoaded(
        stats: currentState.stats,
        analytics: currentState.analytics,
      ));
    } else {
      emit(const DashboardLoading());
    }

    final result = await _dashboardRepository.getDashboardStats(
      companyId: event.companyId,
      role: event.role,
    );

    result.fold(
      (error) => emit(
        DashboardError(message: error.toString()),
      ),
      (stats) {
        // Preserve analytics when refreshing stats
        if (state is DashboardLoaded) {
          final currentState = state as DashboardLoaded;
          emit(
            DashboardLoaded(
              stats: stats,
              analytics: currentState.analytics,
            ),
          );
        } else {
          emit(DashboardLoaded(stats: stats));
        }
      },
    );
  }
  
  @override
  Future<void> close() {
    _refreshDebounceTimer?.cancel();
    return super.close();
  }

  Future<void> _onLoadAnalytics(
    LoadDashboardAnalyticsEvent event,
    Emitter<DashboardState> emit,
  ) async {
    final result = await _dashboardRepository.getDashboardAnalytics(
      companyId: event.companyId,
      role: event.role,
      period: event.period,
    );

    result.fold(
      (error) {
        // Don't emit error if we have stats, just log it
        print('Failed to load analytics: $error');
        if (state is DashboardLoaded) {
          // Keep current state if analytics fails - analytics is optional
          // Don't show error, just log it
          return;
        }
        // If stats aren't loaded yet, analytics failure shouldn't cause an error
        // because analytics depends on stats. Just log it.
        print('⚠️ Analytics failed but stats not loaded yet - ignoring error');
      },
      (analytics) {
        if (state is DashboardLoaded) {
          // Merge analytics with existing stats
          final currentState = state as DashboardLoaded;
          emit(
            DashboardLoaded(
              stats: currentState.stats,
              analytics: analytics,
            ),
          );
        } else {
          // If no stats loaded yet, analytics shouldn't be loaded
          // This shouldn't happen if we only call analytics after stats load
          // Just log it and don't emit error since analytics is optional
          print('⚠️ Analytics loaded but stats not loaded yet - ignoring');
        }
      },
    );
  }
}
