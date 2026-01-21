import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/header_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../notification/data/repositories/notification_repository.dart';
import '../../../notification/presentation/bloc/notification_bloc.dart';
import '../../../notification/presentation/bloc/notification_event.dart';
import '../../../notification/presentation/bloc/notification_state.dart';
import '../../../notification/domain/entities/notification_entity.dart';
import '../../../../core/network/api_client.dart';
import '../../../company/data/repositories/company_repository.dart';
import '../../../company/presentation/bloc/company_bloc.dart';
import '../../../company/presentation/bloc/company_event.dart';
import '../../../company/presentation/bloc/company_state.dart';
import '../../../company/domain/entities/company_entity.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/dashboard_error_view.dart';
import '../widgets/dashboard_loading_shimmer.dart';
import '../widgets/dashboard_sidebar.dart';
import '../widgets/dashboard_stat_card_enhanced.dart';
import '../utils/dashboard_stat_config.dart';
import '../../domain/entities/dashboard_stats_entity.dart';
import '../../domain/entities/dashboard_analytics_entity.dart';

class SuperAdminDashboardPage extends StatefulWidget {
  const SuperAdminDashboardPage({super.key});

  @override
  State<SuperAdminDashboardPage> createState() =>
      _SuperAdminDashboardPageState();
}

class _SuperAdminDashboardPageState extends State<SuperAdminDashboardPage> {
  String _selectedPeriod = 'weekly';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authState = context.read<AuthBloc>().state;
        authState.maybeWhen(
          authenticated: (user) {
            _loadDashboard(context, user.companyId);
          },
          orElse: () {},
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      key: const ValueKey('super_admin_dashboard_providers'),
      providers: [
        BlocProvider<NotificationBloc>(
          create: (context) => NotificationBloc(
            repository: getIt<NotificationRepository>(),
          )..add(const LoadNotificationList()),
        ),
        BlocProvider<CompanyBloc>(
          create: (context) => CompanyBloc(
            repository: CompanyRepository(
              apiClient: getIt<ApiClient>(),
            ),
          )..add(const LoadCompanyList()),
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
                  _loadDashboard(context, null); // Super admin doesn't need companyId
                },
                unauthenticated: () => context.go('/login'),
                error: (_) {},
              );
            },
          ),
          BlocListener<DashboardBloc, DashboardState>(
            listener: (context, state) {
              state.maybeWhen(
                loaded: (stats) {
                  _loadAnalytics(context, null); // Super admin doesn't need companyId
                },
                orElse: () {},
              );
            },
          ),
        ],
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            return authState.maybeWhen(
                  authenticated: (user) {
                    final currentRoute = GoRouterState.of(context).uri.path;
                    return ResponsiveLayout(
                      mobileBreakpoint: 768,
                      mobileBuilder: (context) => _buildMobileLayout(
                        context,
                        () => _refreshDashboard(context, null),
                      ),
                      desktopBuilder: (context) => _buildDesktopLayout(
                        context,
                        currentRoute,
                        () => _refreshDashboard(context, null),
                      ),
                    );
                  },
                  orElse: () => const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  ),
                ) ??
                const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    VoidCallback? refreshCallback,
  ) {
    return Scaffold(
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
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    String currentRoute,
    VoidCallback? refreshCallback,
  ) {
    return Scaffold(
      body: Row(
        children: [
          DashboardSidebar(currentRoute: currentRoute),
          Expanded(
            child: BlocBuilder<DashboardBloc, DashboardState>(
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
                  return _DesktopDashboardLayout(
                    stats: state.stats,
                    analytics: state.analytics,
                    onRefresh: refreshCallback,
                    selectedPeriod: _selectedPeriod,
                    onPeriodChanged: (period) {
                      setState(() {
                        _selectedPeriod = period;
                      });
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _loadDashboard(BuildContext context, String? companyId) {
    if (!mounted) return;
    try {
      final dashboardBloc = context.read<DashboardBloc>();
      final dashboardState = dashboardBloc.state;

      if (dashboardState is! DashboardLoaded) {
        dashboardBloc.add(
          LoadDashboardStatsEvent(
            companyId: companyId,
            role: 'SUPER_ADMIN',
          ),
        );
      }
    } catch (e) {
      debugPrint('DashboardBloc not available: $e');
    }
  }

  void _loadAnalytics(BuildContext context, String? companyId) {
    if (!mounted) return;
    try {
      final dashboardBloc = context.read<DashboardBloc>();
      final dashboardState = dashboardBloc.state;

      if (dashboardState is DashboardLoaded) {
        dashboardBloc.add(
          LoadDashboardAnalyticsEvent(
            companyId: companyId,
            role: 'SUPER_ADMIN',
            period: _selectedPeriod,
          ),
        );
      }
    } catch (e) {
      debugPrint('DashboardBloc not available: $e');
    }
  }

  void _refreshDashboard(BuildContext context, String? companyId) {
    if (!mounted) return;
    try {
      context.read<DashboardBloc>().add(
            RefreshDashboardEvent(
              companyId: companyId,
              role: 'SUPER_ADMIN',
            ),
          );
      // Also refresh companies list
      context.read<CompanyBloc>().add(const LoadCompanyList());
    } catch (e) {
      debugPrint('DashboardBloc not available: $e');
    }
  }
}

class _DesktopDashboardLayout extends StatelessWidget {
  const _DesktopDashboardLayout({
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
                child: _SuperAdminHeader(
                  onRefresh: onRefresh,
                  selectedPeriod: selectedPeriod,
                  onPeriodChanged: onPeriodChanged,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: _KeyMetricsSection(stats: stats),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        );
      },
    );
  }
}

class _MobileDashboardLayout extends StatelessWidget {
  const _MobileDashboardLayout({
    required this.stats,
    this.analytics,
    this.onRefresh,
  });

  final DashboardStatsEntity stats;
  final DashboardAnalyticsEntity? analytics;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SuperAdminHeader(
            onRefresh: onRefresh,
            selectedPeriod: 'weekly',
            onPeriodChanged: (_) {},
          ),
          const SizedBox(height: 24),
          _KeyMetricsSection(stats: stats),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SuperAdminHeader extends StatelessWidget {
  const _SuperAdminHeader({
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
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    size: isMobile ? 28 : 32,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'Super Admin Dashboard',
                      style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ) ??
                          theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'System-wide administration and management',
                style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ) ??
                    theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (!isMobile) ...[
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onRefresh != null)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                    onPressed: onRefresh,
                  ),
                const SizedBox(width: 8),
                _NotificationButton(colorScheme: colorScheme),
              ],
            ),
          ),
        ] else ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onRefresh != null)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                  onPressed: onRefresh,
                ),
              const SizedBox(width: 8),
              _NotificationButton(colorScheme: colorScheme),
            ],
          ),
        ],
      ],
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
                right: 8,
                top: 8,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: colorScheme.error,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _KeyMetricsSection extends StatelessWidget {
  const _KeyMetricsSection({required this.stats});

  final DashboardStatsEntity stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          'System Overview',
          icon: Icons.dashboard,
        ),
        const SizedBox(height: 16),
        _SuperAdminStatsGrid(stats: stats),
      ],
    );
  }
}

class _SuperAdminStatsGrid extends StatelessWidget {
  const _SuperAdminStatsGrid({required this.stats});

  final DashboardStatsEntity stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final visibleConfigs = SuperAdminDashboardStatConfigs.configs;
        final isWeb = constraints.maxWidth > 768;
        
        final cardCount = visibleConfigs.length;
        final availableWidth = constraints.maxWidth;
        
        int crossAxisCount;
        if (availableWidth > 1920) {
          crossAxisCount = cardCount >= 6 ? 6 : (cardCount >= 5 ? 5 : cardCount);
        } else if (availableWidth > 1600) {
          crossAxisCount = cardCount >= 5 ? 5 : (cardCount >= 4 ? 4 : cardCount);
        } else if (availableWidth > 1200) {
          crossAxisCount = cardCount >= 4 ? 4 : (cardCount >= 3 ? 3 : cardCount);
        } else if (availableWidth > 800) {
          crossAxisCount = cardCount >= 3 ? 3 : cardCount;
        } else if (availableWidth >= 768) {
          crossAxisCount = cardCount >= 2 ? 2 : 1;
        } else {
          crossAxisCount = 1;
        }

        final spacing = isWeb
            ? (availableWidth > 1920
                ? 28.0
                : availableWidth > 1600
                    ? 24.0
                    : availableWidth > 1200
                        ? 20.0
                        : 18.0)
            : 16.0;

        final childAspectRatio = isWeb
            ? (availableWidth > 1920
                ? 4.0
                : availableWidth > 1600
                    ? 3.6
                    : availableWidth > 1400
                        ? 3.3
                        : availableWidth > 1200
                            ? 3.0
                            : availableWidth > 1000
                                ? 2.6
                                : 2.4)
            : (availableWidth >= 768 ? 2.0 : 2.1);

        return BlocBuilder<CompanyBloc, CompanyState>(
          builder: (context, companyState) {
            // Get company count from CompanyBloc
            final companyCount = companyState.maybeWhen(
              listLoaded: (List<CompanyEntity> companies) => companies.length,
              orElse: () => 0,
            );

            return GridView.count(
              crossAxisCount: crossAxisCount,
              padding: EdgeInsets.zero,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: childAspectRatio,
              children: visibleConfigs.map((config) {
                // Override value for Total Companies
                int value;
                if (config.title == 'Total Companies') {
                  value = companyCount;
                } else {
                  value = config.getValue(stats);
                }
                
                return DashboardStatCardEnhanced(
                  title: config.title,
                  value: value.toString(),
                  icon: config.icon,
                  color: config.color,
                  subtitle: _getSubtitle(config.title),
                  onTap: () => context.push(config.route),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  String? _getSubtitle(String title) {
    switch (title) {
      case 'Total Companies':
        return 'All registered companies';
      case 'Active Users':
        return 'System-wide users';
      case 'Total Tickets':
        return 'Across all companies';
      case 'Open Requests':
        return 'Awaiting action';
      case 'In Progress':
        return 'Currently active';
      case 'Completed':
        return 'Successfully closed';
      default:
        return null;
    }
  }
}

