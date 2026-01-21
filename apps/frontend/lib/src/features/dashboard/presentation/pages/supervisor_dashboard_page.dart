import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../notification/data/repositories/notification_repository.dart';
import '../../../notification/presentation/bloc/notification_bloc.dart';
import '../../../notification/presentation/bloc/notification_event.dart';
import '../../../notification/presentation/bloc/notification_state.dart';
import '../../../notification/domain/entities/notification_entity.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/dashboard_error_view.dart';
import '../widgets/dashboard_loading_shimmer.dart';
import '../widgets/dashboard_sidebar.dart';
import '../widgets/dashboard_stats_grid.dart';
import '../widgets/status_distribution_chart.dart';
import '../widgets/priority_distribution_chart.dart';
import '../widgets/trends_chart.dart';
import '../widgets/prediction_card.dart';
import '../widgets/performance_metrics_card.dart';
import '../widgets/villa_distribution_chart.dart';
import '../widgets/technician_performance_card.dart';
import '../../domain/entities/dashboard_stats_entity.dart';
import '../../domain/entities/dashboard_analytics_entity.dart';

class SupervisorDashboardPage extends StatefulWidget {
  const SupervisorDashboardPage({super.key});

  @override
  State<SupervisorDashboardPage> createState() =>
      _SupervisorDashboardPageState();
}

class _SupervisorDashboardPageState extends State<SupervisorDashboardPage> {
  String _selectedPeriod = 'weekly';

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NotificationBloc>(
          create: (context) => NotificationBloc(
            repository: getIt<NotificationRepository>(),
          )..add(const LoadNotificationList()),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              state.when(
                initial: () {},
                loading: () {},
                authenticated: (user) {
                  _loadDashboardIfNeeded(context, user.companyId);
                  _loadAnalyticsIfNeeded(context, user.companyId);
                },
                unauthenticated: () => context.go('/login'),
                error: (_) {},
              );
            },
          ),
          BlocListener<DashboardBloc, DashboardState>(
            listener: (context, state) {
              state.maybeWhen(
                error: (message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to load dashboard: $message'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                orElse: () {},
              );
            },
          ),
        ],
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final companyId = authState.maybeWhen(
              authenticated: (user) => user.companyId,
              orElse: () => null,
            );

            // Load dashboard stats and analytics on initial mount
            if (companyId != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _loadDashboardIfNeeded(context, companyId);
                _loadAnalyticsIfNeeded(context, companyId);
              });
            }

            final refreshCallback = companyId != null
                ? () {
                    _refreshDashboard(context, companyId);
                    _loadAnalyticsIfNeeded(context, companyId);
                  }
                : null;

            final currentRoute = GoRouterState.of(context).uri.path;

            return ResponsiveLayout(
              mobileBreakpoint: 768,
              mobileBuilder: (context) => Scaffold(
                backgroundColor: Theme.of(context).colorScheme.surface,
                body: BlocBuilder<DashboardBloc, DashboardState>(
                  builder: (context, state) {
                    if (state is DashboardInitial || state is DashboardLoading) {
                      return const DashboardLoadingShimmer();
                    }
                    if (state is DashboardError) {
                      return DashboardErrorView(
                        message: state.message,
                        onRetry: refreshCallback,
                      );
                    }
                    if (state is DashboardLoaded) {
                      return _MobileDashboardLayout(
                        stats: state.stats,
                        analytics: state.analytics,
                        onRefresh: refreshCallback,
                        selectedPeriod: _selectedPeriod,
                        onPeriodChanged: (period) {
                          setState(() {
                            _selectedPeriod = period;
                          });
                          if (companyId != null) {
                            _loadAnalyticsIfNeeded(context, companyId);
                          }
                        },
                      );
                    }
                    return const DashboardLoadingShimmer();
                  },
                ),
                floatingActionButton: FloatingActionButton.extended(
                  onPressed: () => context.push('/maintenance-tickets'),
                  icon: const Icon(Icons.view_list),
                  label: const Text('View All Tickets'),
                  elevation: 4,
                ),
              ),
              desktopBuilder: (context) => Scaffold(
                backgroundColor: Theme.of(context).colorScheme.surface,
                body: Row(
                  children: [
                    DashboardSidebar(
                      currentRoute: currentRoute,
                      isExpanded: true,
                    ),
                    Expanded(
                      child: BlocBuilder<DashboardBloc, DashboardState>(
                        builder: (context, state) {
                          if (state is DashboardInitial ||
                              state is DashboardLoading) {
                            return const DashboardLoadingShimmer();
                          }
                          if (state is DashboardError) {
                            return DashboardErrorView(
                              message: state.message,
                              onRetry: refreshCallback,
                            );
                          }
                          if (state is DashboardLoaded) {
                            return _SupervisorDashboardLayout(
                              stats: state.stats,
                              analytics: state.analytics,
                              onRefresh: refreshCallback,
                              selectedPeriod: _selectedPeriod,
                              onPeriodChanged: (period) {
                                setState(() {
                                  _selectedPeriod = period;
                                });
                                if (companyId != null) {
                                  _loadAnalyticsIfNeeded(context, companyId);
                                }
                              },
                            );
                          }
                          return const DashboardLoadingShimmer();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _loadDashboardIfNeeded(BuildContext context, String companyId) {
    final dashboardBloc = context.read<DashboardBloc>();
    final dashboardState = dashboardBloc.state;

    if (dashboardState is! DashboardLoaded &&
        dashboardState is! DashboardLoading) {
      dashboardBloc.add(
        LoadDashboardStatsEvent(
          companyId: companyId,
          role: 'SUPERVISOR',
        ),
      );
    }
  }

  void _refreshDashboard(BuildContext context, String companyId) {
    context.read<DashboardBloc>().add(
          RefreshDashboardEvent(
            companyId: companyId,
            role: 'SUPERVISOR',
          ),
        );
  }

  void _loadAnalyticsIfNeeded(BuildContext context, String companyId) {
    final dashboardBloc = context.read<DashboardBloc>();
    dashboardBloc.add(
      LoadDashboardAnalyticsEvent(
        companyId: companyId,
        role: 'SUPERVISOR',
        period: _selectedPeriod,
      ),
    );
  }
}

class _MobileDashboardLayout extends StatelessWidget {
  const _MobileDashboardLayout({
    required this.stats,
    this.analytics,
    this.onRefresh,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  final DashboardStatsEntity stats;
  final DashboardAnalyticsEntity? analytics;
  final VoidCallback? onRefresh;
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _DashboardHeader(
                onRefresh: onRefresh,
                selectedPeriod: selectedPeriod,
                onPeriodChanged: onPeriodChanged,
              ),
              const SizedBox(height: 24),
              _KeyMetricsSection(stats: stats),
              const SizedBox(height: 24),
              _ChartsSection(analytics: analytics),
              if (analytics != null) ...[
                const SizedBox(height: 24),
                _VillaAndTechnicianSection(analytics: analytics!),
                const SizedBox(height: 24),
                _AnalyticsSection(analytics: analytics!),
              ],
            ]),
          ),
        ),
      ],
    );
  }
}

class _SupervisorDashboardLayout extends StatelessWidget {
  const _SupervisorDashboardLayout({
    required this.stats,
    this.analytics,
    this.onRefresh,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  final DashboardStatsEntity stats;
  final DashboardAnalyticsEntity? analytics;
  final VoidCallback? onRefresh;
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth > 1400 ? 48.0 : 24.0;
        return Container(
          constraints: const BoxConstraints(maxWidth: 1920),
          margin: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 24,
          ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _DashboardHeader(
              onRefresh: onRefresh,
              selectedPeriod: selectedPeriod,
              onPeriodChanged: onPeriodChanged,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: _KeyMetricsSection(stats: stats),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: _ChartsSection(analytics: analytics),
          ),
          if (analytics != null) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: _VillaAndTechnicianSection(analytics: analytics!),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: _AnalyticsSection(analytics: analytics!),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
        );
      },
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    this.onRefresh,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  final VoidCallback? onRefresh;
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState.maybeWhen(
          authenticated: (user) => user,
          orElse: () => null,
        );

        final firstName = user?.firstName ?? 'Supervisor';
        final displayName = firstName;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, $displayName',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Supervisor Dashboard - Monitor and update ticket status',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PeriodSelector(
                  selectedPeriod: selectedPeriod,
                  onChanged: onPeriodChanged,
                ),
                const SizedBox(width: 12),
                if (onRefresh != null)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                    onPressed: onRefresh,
                  ),
                const SizedBox(width: 12),
                _NotificationButton(colorScheme: colorScheme),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _SearchBar extends StatefulWidget {
  const _SearchBar({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 40,
      decoration: BoxDecoration(
        color: widget.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search tickets...',
          hintStyle: TextStyle(
            color: widget.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: widget.colorScheme.onSurface.withValues(alpha: 0.6),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
        ),
        style: TextStyle(
          fontSize: 14,
          color: widget.colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        final unreadCount = state.maybeWhen(
              listLoaded: (List<NotificationEntity> notifications) =>
                  notifications.where((n) => !n.isRead).length,
              orElse: () => 0,
            ) ??
            0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              tooltip: 'Notifications',
              onPressed: () => context.push('/notifications'),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.selectedPeriod,
    required this.onChanged,
  });

  final String selectedPeriod;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(
          value: 'daily',
          label: Text('Daily'),
        ),
        ButtonSegment(
          value: 'weekly',
          label: Text('Weekly'),
        ),
        ButtonSegment(
          value: 'monthly',
          label: Text('Monthly'),
        ),
      ],
      selected: {selectedPeriod},
      onSelectionChanged: (Set<String> selection) {
        onChanged(selection.first);
      },
    );
  }
}

class _KeyMetricsSection extends StatelessWidget {
  const _KeyMetricsSection({required this.stats});

  final DashboardStatsEntity stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.dashboard,
              size: 24,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Work Status Overview',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DashboardStatsGrid(stats: stats),
      ],
    );
  }
}

class _ChartsSection extends StatelessWidget {
  const _ChartsSection({this.analytics});

  final DashboardAnalyticsEntity? analytics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.trending_up,
              size: 24,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Current Status & Trends',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (analytics == null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Loading analytics...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          )
        else if (analytics != null)
          ResponsiveLayout(
            mobileBreakpoint: 768,
            mobileBuilder: (context) {
              final safeAnalytics = analytics!;
              return Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: StatusDistributionChart(
                        statusDistribution: safeAnalytics.statusDistribution,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: PriorityDistributionChart(
                        priorityDistribution: safeAnalytics.priorityDistribution,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TrendsChart(trends: safeAnalytics.trends),
                    ),
                  ),
                ],
              );
            },
            desktopBuilder: (context) {
              final safeAnalytics = analytics!;
              return Column(
                children: [
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: StatusDistributionChart(
                                statusDistribution: safeAnalytics.statusDistribution,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: PriorityDistributionChart(
                                priorityDistribution: safeAnalytics.priorityDistribution,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TrendsChart(trends: safeAnalytics.trends),
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}

class _VillaAndTechnicianSection extends StatelessWidget {
  const _VillaAndTechnicianSection({required this.analytics});

  final DashboardAnalyticsEntity analytics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.insights,
              size: 24,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Villa & Technician Insights',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ResponsiveLayout(
          mobileBreakpoint: 768,
          mobileBuilder: (context) => Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: VillaDistributionChart(
                    villaDistribution: analytics.villaDistribution,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TechnicianPerformanceCard(
                technicianPerformance: analytics.technicianPerformance,
              ),
            ],
          ),
          desktopBuilder: (context) => IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: VillaDistributionChart(
                        villaDistribution: analytics.villaDistribution,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: TechnicianPerformanceCard(
                    technicianPerformance: analytics.technicianPerformance,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AnalyticsSection extends StatelessWidget {
  const _AnalyticsSection({required this.analytics});

  final DashboardAnalyticsEntity analytics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.analytics,
              size: 24,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Performance Metrics & Forecasts',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ResponsiveLayout(
          mobileBreakpoint: 768,
          mobileBuilder: (context) => Column(
            children: [
              PerformanceMetricsCard(performance: analytics.performance),
              const SizedBox(height: 16),
              PredictionCard(prediction: analytics.predictions),
            ],
          ),
          desktopBuilder: (context) => IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: PerformanceMetricsCard(
                    performance: analytics.performance,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PredictionCard(prediction: analytics.predictions),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

