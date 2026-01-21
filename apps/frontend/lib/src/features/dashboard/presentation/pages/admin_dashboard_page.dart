import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/header_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../notification/data/repositories/notification_repository.dart';
import '../../../notification/presentation/bloc/notification_bloc.dart';
import '../../../notification/presentation/bloc/notification_event.dart';
import '../../../notification/presentation/bloc/notification_state.dart';
import '../../../notification/domain/entities/notification_entity.dart';
import '../../domain/services/dashboard_event_service.dart' as event_service;
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

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with WidgetsBindingObserver {
  String _selectedPeriod = 'weekly';
  
  // Event subscription for dashboard refresh events
  StreamSubscription<event_service.DashboardEvent>? _dashboardEventSubscription;
  
  // Polling timer for periodic dashboard updates
  Timer? _pollingTimer;
  
  // Polling timer for periodic notification updates
  Timer? _notificationPollingTimer;
  
  // Track last refresh time for foreground refresh
  DateTime? _lastRefreshTime;
  
  // Polling interval (30 seconds)
  static const Duration _pollingInterval = Duration(seconds: 30);
  
  // Notification polling interval (60 seconds - less frequent than dashboard)
  static const Duration _notificationPollingInterval = Duration(seconds: 60);
  
  // Consider data stale after 60 seconds
  static const Duration _staleDataThreshold = Duration(seconds: 60);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        // Verify token exists before proceeding
        // This syncs AuthBloc state if token was cleared
        const storage = FlutterSecureStorage();
        final token = await storage.read(key: 'access_token');
        
        if (token == null) {
          // Token is missing - sync AuthBloc state by emitting logout
          debugPrint('⚠️ AdminDashboard: No token found, syncing AuthBloc state');
          if (mounted) {
            context.read<AuthBloc>().add(const LogoutEvent());
          }
          return;
        }
        
        final authState = context.read<AuthBloc>().state;
        authState.maybeWhen(
          authenticated: (user) {
            _loadDashboard(context, user.companyId);
            _setupEventListeners(user.companyId);
            _startPolling(user.companyId);
            _startNotificationPolling();
            // Refresh notifications on dashboard load
            _refreshNotifications(context);
          },
          orElse: () {},
        );
      }
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh notifications when route becomes active (navigating back to dashboard)
    // This ensures badge count updates when returning from notification page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          final currentRoute = GoRouterState.of(context).uri.path;
          if (currentRoute == '/dashboard') {
            // Small delay to ensure navigation is complete
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                _refreshNotifications(context);
              }
            });
          }
        } catch (e) {
          // Route not available, ignore
          debugPrint('Could not determine route: $e');
        }
      }
    });
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dashboardEventSubscription?.cancel();
    _pollingTimer?.cancel();
    _notificationPollingTimer?.cancel();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.resumed) {
      // App came to foreground - refresh if data is stale
      final authState = context.read<AuthBloc>().state;
      authState.maybeWhen(
        authenticated: (user) {
          if (_lastRefreshTime == null ||
              DateTime.now().difference(_lastRefreshTime!) >
                  _staleDataThreshold) {
            _refreshDashboard(context, user.companyId);
          }
          // Also refresh notifications when app comes to foreground
          _refreshNotifications(context);
        },
        orElse: () {},
      );
    }
  }
  
  /// Refresh notifications list
  void _refreshNotifications(BuildContext context) {
    if (!mounted) return;
    try {
      // Check if NotificationBloc exists in context
      final notificationBloc = context.read<NotificationBloc>();
      notificationBloc.add(const LoadNotificationList());
    } catch (e) {
      // NotificationBloc not available, ignore
      debugPrint('NotificationBloc not available for refresh: $e');
    }
  }
  
  /// Start polling for notification updates
  void _startNotificationPolling() {
    _notificationPollingTimer?.cancel();
    _notificationPollingTimer = Timer.periodic(
      _notificationPollingInterval,
      (timer) {
        if (mounted) {
          final authState = context.read<AuthBloc>().state;
          authState.maybeWhen(
            authenticated: (_) {
              // Only poll if dashboard is visible
              try {
                final currentRoute = GoRouterState.of(context).uri.path;
                if (currentRoute == '/dashboard') {
                  _refreshNotifications(context);
                }
              } catch (e) {
                // If we can't determine route, skip this poll cycle
                debugPrint('⚠️ Could not determine route for notification polling: $e');
              }
            },
            orElse: () {
              // User logged out - stop polling
              timer.cancel();
            },
          );
        } else {
          // Widget disposed - stop polling
          timer.cancel();
        }
      },
    );
  }
  
  /// Setup event listeners for dashboard refresh events
  void _setupEventListeners(String companyId) {
    _dashboardEventSubscription?.cancel();
    _dashboardEventSubscription = event_service.DashboardEventService.instance.events.listen(
      (event) {
        // Only refresh if event is for this company and widget is mounted
        if (event.companyId == companyId && mounted) {
          // Refresh immediately when ticket events occur
          // The widget being mounted means it's likely visible
          _refreshDashboard(context, companyId);
        }
      },
      onError: (Object error) {
        debugPrint('❌ Dashboard event subscription error: $error');
      },
    );
  }
  
  /// Start polling for dashboard updates
  void _startPolling(String companyId) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(_pollingInterval, (timer) {
      if (mounted) {
        final authState = context.read<AuthBloc>().state;
        authState.maybeWhen(
          authenticated: (user) {
            // Only poll if dashboard is visible
            try {
              final currentRoute = GoRouterState.of(context).uri.path;
              
              if (currentRoute == '/dashboard') {
                _refreshDashboard(context, user.companyId);
              }
            } catch (e) {
              // If we can't determine route, skip this poll cycle
              debugPrint('⚠️ Could not determine route for polling: $e');
            }
          },
          orElse: () {
            // User logged out - stop polling
            timer.cancel();
          },
        );
      } else {
        // Widget disposed - stop polling
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // NotificationBloc is now provided at route level (in app_router.dart)
    // Try to get existing bloc, or create new one if not available (fallback)
    NotificationBloc? notificationBloc;
    try {
      notificationBloc = BlocProvider.of<NotificationBloc>(context);
      // Refresh notifications when dashboard is built
      notificationBloc.add(const LoadNotificationList());
    } catch (_) {
      // No existing bloc (shouldn't happen if route provides it, but fallback)
      notificationBloc = NotificationBloc(
        repository: getIt<NotificationRepository>(),
      )..add(const LoadNotificationList());
    }

    return BlocProvider<NotificationBloc>.value(
      value: notificationBloc,
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              state.when(
                initial: () {},
                loading: () {},
                authenticated: (user) {
                  _loadDashboard(context, user.companyId);
                  // Setup event listeners and polling when authenticated
                  _setupEventListeners(user.companyId);
                  _startPolling(user.companyId);
                  // Refresh notifications when authenticated
                  _refreshNotifications(context);
                },
                unauthenticated: () {
                  // Clean up when logged out
                  _dashboardEventSubscription?.cancel();
                  _pollingTimer?.cancel();
                  _notificationPollingTimer?.cancel();
                  context.go('/login');
                },
                error: (_) {},
              );
            },
          ),
          // Listen to notification state changes
          BlocListener<NotificationBloc, NotificationState>(
            listener: (context, state) {
              // When notifications are marked as read, refresh the list
              // This ensures the badge count updates immediately
              state.maybeWhen(
                markedAsRead: (_) {
                  // Small delay to ensure backend has processed the update
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (mounted) {
                      context.read<NotificationBloc>().add(const LoadNotificationList());
                    }
                  });
                },
                orElse: () {},
              );
            },
          ),
          BlocListener<DashboardBloc, DashboardState>(
            listener: (context, state) {
              state.maybeWhen(
                loaded: (stats) {
                  final authState = context.read<AuthBloc>().state;
                  authState.maybeWhen(
                    authenticated: (user) {
                      _loadAnalytics(context, user.companyId);
                    },
                    orElse: () {},
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

            final refreshCallback = companyId != null
                ? () => _refreshDashboard(context, companyId)
                : null;

            final currentRoute = GoRouterState.of(context).uri.path;
            
            // Refresh notifications when dashboard route is active
            // This handles the case when user navigates back from notification page
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && currentRoute == '/dashboard') {
                _refreshNotifications(context);
              }
            });

            return ResponsiveLayout(
              mobileBreakpoint: 768,
              mobileBuilder: (context) => _buildMobileLayout(
                context,
                refreshCallback,
              ),
              desktopBuilder: (context) => _buildDesktopLayout(
                context,
                currentRoute,
                refreshCallback,
              ),
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
              selectedPeriod: _selectedPeriod,
              onPeriodChanged: (period) {
                if (!mounted) return;
                setState(() {
                  _selectedPeriod = period;
                });
                if (!mounted) return;
                final authState = context.read<AuthBloc>().state;
                authState.maybeWhen(
                  authenticated: (user) {
                    if (mounted) {
                      _loadAnalytics(context, user.companyId);
                    }
                  },
                  orElse: () {},
                );
              },
            );
          }

          return const DashboardLoadingShimmer();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/maintenance-tickets/create'),
        icon: const Icon(Icons.add),
        label: const Text('New Ticket'),
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
          DashboardSidebar(
            currentRoute: currentRoute,
            isExpanded: true,
          ),
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
                      if (!mounted) return;
                      setState(() {
                        _selectedPeriod = period;
                      });
                      if (!mounted) return;
                      final authState = context.read<AuthBloc>().state;
                      authState.maybeWhen(
                        authenticated: (user) {
                          if (mounted) {
                            _loadAnalytics(context, user.companyId);
                          }
                        },
                        orElse: () {},
                      );
                    },
                  );
                }

                return const DashboardLoadingShimmer();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _loadDashboard(BuildContext context, String companyId) {
    if (!mounted) return;
    try {
      final dashboardBloc = context.read<DashboardBloc>();
      final dashboardState = dashboardBloc.state;

      if (dashboardState is! DashboardLoaded &&
          dashboardState is! DashboardLoading) {
        dashboardBloc.add(
          LoadDashboardStatsEvent(
            companyId: companyId,
            role: 'ADMIN',
          ),
        );
      }
    } catch (e) {
      // DashboardBloc not available, ignore
      debugPrint('DashboardBloc not available: $e');
    }
  }

  void _loadAnalytics(BuildContext context, String companyId) {
    if (!mounted) return;
    try {
      final dashboardBloc = context.read<DashboardBloc>();
      final dashboardState = dashboardBloc.state;

      if (dashboardState is DashboardLoaded) {
        dashboardBloc.add(
          LoadDashboardAnalyticsEvent(
            companyId: companyId,
            role: 'ADMIN',
            period: _selectedPeriod,
          ),
        );
      }
    } catch (e) {
      // DashboardBloc not available, ignore
      debugPrint('DashboardBloc not available: $e');
    }
  }

  void _refreshDashboard(BuildContext context, String companyId) {
    if (!mounted) return;
    try {
      _lastRefreshTime = DateTime.now();
      context.read<DashboardBloc>().add(
            RefreshDashboardEvent(
              companyId: companyId,
              role: 'ADMIN',
            ),
          );
    } catch (e) {
      // DashboardBloc not available, ignore
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          const SizedBox(height: 32),
        ],
      ),
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
    final isMobile = MediaQuery.of(context).size.width < 768;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState.maybeWhen(
          authenticated: (user) => user,
          orElse: () => null,
        );

        final firstName = user?.firstName ?? 'User';
        final displayName = firstName;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, $displayName',
                    style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ) ??
                        theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Actionable insights and analytics for your maintenance operations',
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
      },
    );
  }
}

class _NotificationButton extends StatefulWidget {
  const _NotificationButton({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  State<_NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<_NotificationButton> {
  int _previousCount = 0;

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

        // Trigger animation when count increases
        final shouldAnimate = unreadCount > _previousCount && unreadCount > 0;
        if (shouldAnimate) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _previousCount = unreadCount;
              });
            }
          });
        } else {
          _previousCount = unreadCount;
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: Icon(
                unreadCount > 0
                    ? Icons.notifications
                    : Icons.notifications_outlined,
              ),
              tooltip: unreadCount > 0
                  ? '$unreadCount unread notification${unreadCount == 1 ? '' : 's'}'
                  : 'Notifications',
              onPressed: () => context.push('/notifications'),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: _NotificationBadge(
                  count: unreadCount,
                  colorScheme: widget.colorScheme,
                )
                    .animate(
                      target: shouldAnimate ? 1 : 0,
                    )
                    .scale(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.2, 1.2),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.elasticOut,
                    )
                    .then()
                    .scale(
                      begin: const Offset(1.2, 1.2),
                      end: const Offset(1.0, 1.0),
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                    ),
              ),
          ],
        );
      },
    );
  }
}

/// Material Design 3 compliant notification badge
/// 
/// Best Practices:
/// - Shows count up to 99, then "99+"
/// - Uses error color for visibility
/// - Properly sized for readability
/// - Includes subtle animation
/// - Accessible with proper semantics
class _NotificationBadge extends StatelessWidget {
  const _NotificationBadge({
    required this.count,
    required this.colorScheme,
  });

  final int count;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final displayText = count > 99 ? '99+' : count.toString();
    final isSingleDigit = count < 10;
    
    // Material Design 3 badge sizing
    // Single digit: 16x16, Double digit: 20x20 (min width)
    final badgeSize = isSingleDigit ? 16.0 : 20.0;
    final minWidth = isSingleDigit ? 16.0 : 20.0;
    final fontSize = isSingleDigit ? 10.0 : 9.0;
    final padding = isSingleDigit 
        ? const EdgeInsets.all(2.0)
        : const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0);

    return Container(
      constraints: BoxConstraints(
        minWidth: minWidth,
        minHeight: badgeSize,
      ),
      padding: padding,
      decoration: BoxDecoration(
        color: colorScheme.error,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(badgeSize / 2),
        // Subtle shadow for depth (Material Design elevation)
        boxShadow: [
          BoxShadow(
            color: colorScheme.error.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        // Border for contrast against light backgrounds
        border: Border.all(
          color: colorScheme.surface,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          displayText,
          style: TextStyle(
            color: colorScheme.onError,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            height: 1.0, // Tight line height for better centering
            letterSpacing: -0.5, // Tighter spacing for numbers
          ),
          textAlign: TextAlign.center,
        ),
      ),
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
          'Key Metrics',
          icon: Icons.dashboard,
        ),
        const SizedBox(height: 16),
        DashboardStatsGrid(stats: stats),
      ],
    );
  }
}

class _AnalyticsSection extends StatelessWidget {
  const _AnalyticsSection({required this.analytics});

  final DashboardAnalyticsEntity analytics;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          'Performance Metrics & Forecasts',
          icon: Icons.analytics,
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
                  ) ??
                  theme.textTheme.titleMedium?.copyWith(
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
                  ) ??
                  theme.textTheme.titleMedium?.copyWith(
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
                    ) ??
                    theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
              ),
            ),
          )
        else
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
                        priorityDistribution:
                            safeAnalytics.priorityDistribution,
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
                                statusDistribution:
                                    safeAnalytics.statusDistribution,
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
                                priorityDistribution:
                                    safeAnalytics.priorityDistribution,
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
