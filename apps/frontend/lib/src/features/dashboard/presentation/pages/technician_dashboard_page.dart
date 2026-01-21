import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../maintenance_ticket/data/repositories/maintenance_ticket_repository.dart';
import '../../../maintenance_ticket/domain/entities/maintenance_ticket_entity.dart';
import '../../../maintenance_ticket/presentation/bloc/maintenance_ticket_bloc.dart';
import '../../../maintenance_ticket/presentation/bloc/maintenance_ticket_event.dart';
import '../../../maintenance_ticket/presentation/bloc/maintenance_ticket_state.dart';
import '../../../maintenance_ticket/presentation/widgets/location_display_widget.dart';
import '../../../notification/data/repositories/notification_repository.dart';
import '../../../notification/presentation/bloc/notification_bloc.dart';
import '../../../notification/presentation/bloc/notification_event.dart';
import '../../domain/entities/dashboard_stats_entity.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/dashboard_error_view.dart';
import '../widgets/dashboard_loading_shimmer.dart';
import '../widgets/dashboard_shared_widgets.dart';

class TechnicianDashboardPage extends StatelessWidget {
  const TechnicianDashboardPage({super.key});

  /// Helper to get the actual technician role from user
  static String _getTechnicianRole(UserEntity? user) {
    if (user == null || user.roles.isEmpty) {
      return 'TECHNICIAN';
    }
    return user.roles.firstWhere(
      (String r) => r.toUpperCase() == 'TECHNICIAN',
      orElse: () => user.roles.first,
    );
  }

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
                  final dashboardBloc = context.read<DashboardBloc>();
                  final dashboardState = dashboardBloc.state;

                  if (dashboardState is! DashboardLoaded &&
                      dashboardState is! DashboardLoading) {
                    // Get the actual technician role from user
                    final technicianRole = user.roles.firstWhere(
                      (r) => r.toUpperCase() == 'TECHNICIAN',
                      orElse: () => user.roles.isNotEmpty
                          ? user.roles.first
                          : 'TECHNICIAN',
                    );
                    dashboardBloc.add(
                      LoadDashboardStatsEvent(
                        companyId: user.companyId,
                        role: technicianRole,
                      ),
                    );
                  }
                },
                unauthenticated: () {
                  // Router will automatically redirect via refreshListenable
                  // But we can also manually navigate to ensure it happens
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) {
                      context.go('/company-selection');
                    }
                  });
                },
                error: (_) {},
              );
            },
          ),
          BlocListener<DashboardBloc, DashboardState>(
            listener: (context, state) {
              state.maybeWhen(
                error: (message) {
                  final colorScheme = Theme.of(context).colorScheme;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              'Failed to load dashboard: $message',
                              style: TextStyle(
                                color: colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: colorScheme.errorContainer,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(16),
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

            if (companyId != null) {
              final dashboardBloc = context.read<DashboardBloc>();
              final dashboardState = dashboardBloc.state;

              if (dashboardState is DashboardInitial) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (dashboardBloc.state is DashboardInitial) {
                    // Get the actual technician role from user
                    final user = authState.maybeWhen(
                      authenticated: (u) => u,
                      orElse: () => null,
                    );
                    dashboardBloc.add(
                      LoadDashboardStatsEvent(
                        companyId: companyId,
                        role: TechnicianDashboardPage._getTechnicianRole(user),
                      ),
                    );
                  }
                });
              }
            }

            return Scaffold(
              appBar: _TechnicianAppBar(companyId: companyId),
              body: BlocBuilder<DashboardBloc, DashboardState>(
                builder: (context, state) {
                  return state.when(
                    initial: () => const DashboardLoadingShimmer(),
                    loading: () => const DashboardLoadingShimmer(),
                    loaded: (stats) => ResponsiveLayout(
                      mobileBuilder: (context) =>
                          _MobileLayout(stats: stats, companyId: companyId),
                      desktopBuilder: (context) =>
                          _DesktopLayout(stats: stats, companyId: companyId),
                      mobileBreakpoint: 768.0,
                    ),
                    error: (message) => DashboardErrorView(
                      message: message,
                      onRetry: companyId != null
                          ? () {
                              // Get the actual technician role from user
                              final user = authState.maybeWhen(
                                authenticated: (u) => u,
                                orElse: () => null,
                              );
                              context.read<DashboardBloc>().add(
                                    RefreshDashboardEvent(
                                      companyId: companyId,
                                      role: TechnicianDashboardPage
                                          ._getTechnicianRole(user),
                                    ),
                                  );
                            }
                          : null,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TechnicianAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _TechnicianAppBar({this.companyId});

  final String? companyId;

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final weekDay = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];
    return '${weekDay[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isWeb = MediaQuery.of(context).size.width >= 768;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 1,
      automaticallyImplyLeading: false,
      backgroundColor: colorScheme.primary,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 80,
      leadingWidth: 80,
      leading: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final user = authState.maybeWhen(
            authenticated: (u) => u,
            orElse: () => null,
          );
          return Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
            child: InkWell(
              onTap: () => context.push('/profile'),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.surface, // Use theme color for dark mode support
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: colorScheme.surface, // Use theme color for dark mode support
                  child: Text(
                    (user?.firstName ?? '').isNotEmpty
                        ? (user?.firstName ?? '')[0].toUpperCase()
                        : 'T',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      title: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final user = authState.maybeWhen(
            authenticated: (u) => u,
            orElse: () => null,
          );
          final primaryRole =
              user?.roles.isNotEmpty == true ? user!.roles.first : 'Technician';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_getTimeBasedGreeting()}, ${user?.firstName ?? 'Technician'}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colorScheme.onPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.build_circle,
                    size: 14,
                    color: colorScheme.onPrimary.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      primaryRole,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimary.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '•',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getFormattedDate(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      centerTitle: false,
      actions: [
        if (isWeb)
          BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              return BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  final user = authState.maybeWhen(
                    authenticated: (u) => u,
                    orElse: () => null,
                  );
                  return IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh Dashboard',
                    onPressed: companyId != null
                        ? () {
                            context.read<DashboardBloc>().add(
                                  RefreshDashboardEvent(
                                    companyId: companyId!,
                                    role: TechnicianDashboardPage
                                        ._getTechnicianRole(user),
                                  ),
                                );
                          }
                        : null,
                  );
                },
              );
            },
          ),
        SizedBox(width: isWeb ? 16 : 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            final widget = state.maybeWhen(
              loaded: (stats) {
                final assigned = stats.assigned;
                final inProgress = stats.inProgress;
                final completed = stats.completed;
                final total = assigned + inProgress + completed;

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color:
                            colorScheme.outlineVariant.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          total > 0
                              ? '$assigned Assigned • $inProgress In Progress • $completed Completed'
                              : 'No tickets assigned',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
              orElse: () {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color:
                            colorScheme.outlineVariant.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Loading ticket counts...',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
            return widget ?? const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(120); // 80 toolbar + 40 bottom
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({required this.stats, this.companyId});

  final DashboardStatsEntity stats;
  final String? companyId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState.maybeWhen(
          authenticated: (u) => u,
          orElse: () => null,
        );
        final userId = user?.id;

        if (userId == null) {
          return const SizedBox.shrink();
        }

        return BlocProvider<MaintenanceTicketBloc>(
          create: (context) => MaintenanceTicketBloc(
            repository: getIt<MaintenanceTicketRepository>(),
          )..add(
              LoadMaintenanceTickets(
                assignedTechnicianId: userId,
                page: 1,
                limit: 100, // Maximum allowed by backend API
              ),
            ),
          child: BlocListener<MaintenanceTicketBloc, MaintenanceTicketState>(
            listener: (context, state) {
              state.maybeWhen(
                statusChanged: (updatedTicket) {
                  // Show success message based on status
                  final isCompleted =
                      updatedTicket.status == TicketStatus.completed;
                  final isInProgress =
                      updatedTicket.status == TicketStatus.inProgress;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            isCompleted
                                ? '${updatedTicket.ticketNumber} marked as completed'
                                : isInProgress
                                    ? '${updatedTicket.ticketNumber} is now in progress'
                                    : '${updatedTicket.ticketNumber} status updated',
                          ),
                        ],
                      ),
                      backgroundColor: isCompleted ? Colors.green : Colors.blue,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );

                  // Refresh the ticket list after status change
                  context.read<MaintenanceTicketBloc>().add(
                        LoadMaintenanceTickets(
                          assignedTechnicianId: userId,
                          page: 1,
                          limit: 100,
                        ),
                      );
                },
                notesAdded: (updatedTicket) {
                  // Show success message for notes
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Notes added successfully'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );

                  // Refresh the ticket list after notes added
                  context.read<MaintenanceTicketBloc>().add(
                        LoadMaintenanceTickets(
                          assignedTechnicianId: userId,
                          page: 1,
                          limit: 100,
                        ),
                      );
                },
                error: (message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('Error: $message'),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                },
                orElse: () {},
              );
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                return RefreshIndicator(
                  onRefresh: () async {
                    if (companyId != null) {
                      final technicianRole =
                          TechnicianDashboardPage._getTechnicianRole(user);
                      context.read<DashboardBloc>().add(
                            RefreshDashboardEvent(
                              companyId: companyId!,
                              role: technicianRole,
                            ),
                          );
                    }
                    context.read<MaintenanceTicketBloc>().add(
                          LoadMaintenanceTickets(
                            assignedTechnicianId: userId,
                            page: 1,
                            limit: 100, // Maximum allowed by backend API
                          ),
                        );
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: _ActionOrientedTicketList(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({required this.stats, this.companyId});

  final DashboardStatsEntity stats;
  final String? companyId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState.maybeWhen(
          authenticated: (u) => u,
          orElse: () => null,
        );
        final userId = user?.id;

        if (userId == null) {
          return const SizedBox.shrink();
        }

        return BlocProvider<MaintenanceTicketBloc>(
          create: (context) => MaintenanceTicketBloc(
            repository: getIt<MaintenanceTicketRepository>(),
          )..add(
              LoadMaintenanceTickets(
                assignedTechnicianId: userId,
                page: 1,
                limit: 100, // Maximum allowed by backend API
              ),
            ),
          child: BlocListener<MaintenanceTicketBloc, MaintenanceTicketState>(
            listener: (context, state) {
              state.maybeWhen(
                statusChanged: (updatedTicket) {
                  // Show success message based on status
                  final isCompleted =
                      updatedTicket.status == TicketStatus.completed;
                  final isInProgress =
                      updatedTicket.status == TicketStatus.inProgress;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            isCompleted
                                ? '${updatedTicket.ticketNumber} marked as completed'
                                : isInProgress
                                    ? '${updatedTicket.ticketNumber} is now in progress'
                                    : '${updatedTicket.ticketNumber} status updated',
                          ),
                        ],
                      ),
                      backgroundColor: isCompleted ? Colors.green : Colors.blue,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );

                  // Refresh the ticket list after status change
                  context.read<MaintenanceTicketBloc>().add(
                        LoadMaintenanceTickets(
                          assignedTechnicianId: userId,
                          page: 1,
                          limit: 100,
                        ),
                      );
                },
                notesAdded: (updatedTicket) {
                  // Show success message for notes
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Notes added successfully'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );

                  // Refresh the ticket list after notes added
                  context.read<MaintenanceTicketBloc>().add(
                        LoadMaintenanceTickets(
                          assignedTechnicianId: userId,
                          page: 1,
                          limit: 100,
                        ),
                      );
                },
                error: (message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('Error: $message'),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                },
                orElse: () {},
              );
            },
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1920),
              margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width > 1400 ? 24 : 16,
                vertical: 16,
              ),
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(
                    child: _ActionOrientedTicketList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActionOrientedTicketList extends StatefulWidget {
  const _ActionOrientedTicketList();

  @override
  State<_ActionOrientedTicketList> createState() =>
      _ActionOrientedTicketListState();
}

class _ActionOrientedTicketListState extends State<_ActionOrientedTicketList> {
  _TicketFilter _selectedFilter = _TicketFilter.assigned;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        // Trigger rebuild when search text changes
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onFilterChanged(_TicketFilter filter) {
    if (_selectedFilter == filter) return;
    setState(() {
      _selectedFilter = filter;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = 80.0; // AppBar height
    final headerSearchHeight =
        200.0; // Approximate height for header, filters, and search
    final padding = 32.0; // Top and bottom padding
    final availableHeight =
        screenHeight - appBarHeight - headerSearchHeight - padding;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Snapshot Cards Section
        BlocBuilder<MaintenanceTicketBloc, MaintenanceTicketState>(
          builder: (context, state) {
            // Calculate counts based on loaded tickets
            int assignedCount = 0;
            int inProgressCount = 0;
            int completedCount = 0;
            int allCount = 0;

            state.maybeWhen(
              listLoaded: (tickets, _) {
                allCount = tickets.length;
                assignedCount = tickets.where((t) {
                  return t.assignedTechnicianId != null &&
                      t.status == TicketStatus.assigned;
                }).length;
                inProgressCount = tickets.where((t) {
                  return t.assignedTechnicianId != null &&
                      t.status == TicketStatus.inProgress;
                }).length;
                completedCount = tickets.where((t) {
                  return t.assignedTechnicianId != null &&
                      t.status == TicketStatus.completed;
                }).length;
              },
              orElse: () {},
            );

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with title and subtitle
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Tickets',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Snapshot of assigned tickets',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Quick Snapshots - Grid Layout
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 600;
                      // Calculate number of columns based on screen width
                      final crossAxisCount = constraints.maxWidth > 600
                          ? (constraints.maxWidth > 900 ? 4 : 3)
                          : 2;
                      const spacing = 12.0;
                      const runSpacing = 12.0;

                      final cards = [
                        QuickSnapshotCard(
                          label: 'ALL',
                          count: allCount,
                          color: theme.colorScheme.primary,
                          onTap: () => _onFilterChanged(_TicketFilter.all),
                        ),
                        QuickSnapshotCard(
                          label: 'ASSIGNED',
                          count: assignedCount,
                          color: const Color(0xFF8B5CF6),
                          onTap: () => _onFilterChanged(_TicketFilter.assigned),
                        ),
                        QuickSnapshotCard(
                          label: 'IN PROGRESS',
                          count: inProgressCount,
                          color: const Color(0xFF6366F1),
                          onTap: () =>
                              _onFilterChanged(_TicketFilter.inProgress),
                        ),
                        QuickSnapshotCard(
                          label: 'COMPLETED',
                          count: completedCount,
                          color: const Color(0xFF10B981),
                          onTap: () =>
                              _onFilterChanged(_TicketFilter.completed),
                        ),
                      ];

                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: runSpacing,
                        childAspectRatio: isMobile ? 2.2 : 2.5,
                        children: cards,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        // My Schedule Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Schedule',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              BlocBuilder<MaintenanceTicketBloc, MaintenanceTicketState>(
                builder: (context, state) {
                  // Calculate counts based on loaded tickets
                  int assignedCount = 0;
                  int inProgressCount = 0;
                  int completedCount = 0;
                  int allCount = 0;

                  state.maybeWhen(
                    listLoaded: (tickets, _) {
                      allCount = tickets.length;
                      assignedCount = tickets.where((t) {
                        return t.assignedTechnicianId != null &&
                            t.status == TicketStatus.assigned;
                      }).length;
                      inProgressCount = tickets.where((t) {
                        return t.assignedTechnicianId != null &&
                            t.status == TicketStatus.inProgress;
                      }).length;
                      completedCount = tickets.where((t) {
                        return t.assignedTechnicianId != null &&
                            t.status == TicketStatus.completed;
                      }).length;
                    },
                    orElse: () {},
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            DashboardFilterChip(
                              label: 'Assigned ($assignedCount)',
                              isSelected:
                                  _selectedFilter == _TicketFilter.assigned,
                              onSelected: () =>
                                  _onFilterChanged(_TicketFilter.assigned),
                            ),
                            const SizedBox(width: 8),
                            DashboardFilterChip(
                              label: 'In Progress ($inProgressCount)',
                              isSelected:
                                  _selectedFilter == _TicketFilter.inProgress,
                              onSelected: () =>
                                  _onFilterChanged(_TicketFilter.inProgress),
                            ),
                            const SizedBox(width: 8),
                            DashboardFilterChip(
                              label: 'Completed ($completedCount)',
                              isSelected:
                                  _selectedFilter == _TicketFilter.completed,
                              onSelected: () =>
                                  _onFilterChanged(_TicketFilter.completed),
                            ),
                            const SizedBox(width: 8),
                            DashboardFilterChip(
                              label: 'All Tickets ($allCount)',
                              isSelected: _selectedFilter == _TicketFilter.all,
                              onSelected: () =>
                                  _onFilterChanged(_TicketFilter.all),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText:
                              'Search by title, ticket number, or villa...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: availableHeight > 0 ? availableHeight : 400,
          child: _TicketGroupView(
            filter: _selectedFilter,
            searchQuery: _searchController.text,
          ),
        ),
      ],
    );
  }
}

enum _TicketFilter {
  assigned,
  inProgress,
  completed,
  all,
}

class _TicketGroupView extends StatelessWidget {
  const _TicketGroupView({
    required this.filter,
    this.searchQuery = '',
  });

  final _TicketFilter filter;
  final String searchQuery;

  List<MaintenanceTicketEntity> _filterTickets(
    List<MaintenanceTicketEntity> tickets,
  ) {
    List<MaintenanceTicketEntity> filteredByStatus;
    switch (filter) {
      case _TicketFilter.assigned:
        // Show only tickets with status ASSIGNED
        filteredByStatus = tickets.where((t) {
          return t.assignedTechnicianId != null &&
              t.status == TicketStatus.assigned;
        }).toList();
        break;
      case _TicketFilter.inProgress:
        // Show only tickets with status IN_PROGRESS
        filteredByStatus = tickets.where((t) {
          return t.assignedTechnicianId != null &&
              t.status == TicketStatus.inProgress;
        }).toList();
        break;
      case _TicketFilter.completed:
        // Show only completed tickets assigned to technician
        filteredByStatus = tickets.where((t) {
          return t.assignedTechnicianId != null &&
              t.status == TicketStatus.completed;
        }).toList();
        break;
      case _TicketFilter.all:
        filteredByStatus = tickets;
        break;
    }

    // Apply search filter if query is provided
    if (searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      filteredByStatus = filteredByStatus.where((ticket) {
        // Search by title
        final matchesTitle = ticket.title.toLowerCase().contains(query);

        // Search by ticket number
        final matchesTicketNumber =
            ticket.ticketNumber.toLowerCase().contains(query);

        // Search by villa number
        final matchesVilla = ticket.villaNumber != null &&
            ticket.villaNumber.toString().contains(query);

        return matchesTitle || matchesTicketNumber || matchesVilla;
      }).toList();
    }

    // Sort based on filter
    // Primary sort: createdAt DESC (latest first) - as requested by user
    // Secondary sort: priority/status for better UX
    switch (filter) {
      case _TicketFilter.assigned:
        filteredByStatus.sort((a, b) {
          // Primary: Sort by createdAt (latest first)
          final createdAtDiff = b.createdAt.compareTo(a.createdAt);
          if (createdAtDiff != 0) return createdAtDiff;

          // Secondary: Sort by priority (urgent first)
          final priorityOrder = {
            TicketPriority.urgent: 0,
            TicketPriority.high: 1,
            TicketPriority.medium: 2,
            TicketPriority.low: 3,
          };
          final priorityDiff = (priorityOrder[a.priority] ?? 2) -
              (priorityOrder[b.priority] ?? 2);
          if (priorityDiff != 0) return priorityDiff;

          // Tertiary: Sort by scheduled time (earliest first)
          if (a.scheduledAt != null && b.scheduledAt != null) {
            return a.scheduledAt!.compareTo(b.scheduledAt!);
          }
          if (a.scheduledAt != null) return -1;
          if (b.scheduledAt != null) return 1;
          return 0;
        });
        break;
      case _TicketFilter.inProgress:
        filteredByStatus.sort((a, b) {
          // Primary: Sort by createdAt (latest first)
          final createdAtDiff = b.createdAt.compareTo(a.createdAt);
          if (createdAtDiff != 0) return createdAtDiff;

          // Secondary: Sort by priority (urgent first)
          final priorityOrder = {
            TicketPriority.urgent: 0,
            TicketPriority.high: 1,
            TicketPriority.medium: 2,
            TicketPriority.low: 3,
          };
          final priorityDiff = (priorityOrder[a.priority] ?? 2) -
              (priorityOrder[b.priority] ?? 2);
          if (priorityDiff != 0) return priorityDiff;

          // Tertiary: Sort by scheduled time (earliest first)
          if (a.scheduledAt != null && b.scheduledAt != null) {
            return a.scheduledAt!.compareTo(b.scheduledAt!);
          }
          if (a.scheduledAt != null) return -1;
          if (b.scheduledAt != null) return 1;
          return 0;
        });
        break;
      case _TicketFilter.completed:
        filteredByStatus.sort((a, b) {
          // Primary: Sort by createdAt (latest first)
          final createdAtDiff = b.createdAt.compareTo(a.createdAt);
          if (createdAtDiff != 0) return createdAtDiff;

          // Secondary: Sort by completion date (most recent first)
          if (a.completedAt != null && b.completedAt != null) {
            return b.completedAt!.compareTo(a.completedAt!);
          }
          if (a.completedAt != null) return -1;
          if (b.completedAt != null) return 1;
          // Fallback to updated date
          return b.updatedAt.compareTo(a.updatedAt);
        });
        break;
      case _TicketFilter.all:
        filteredByStatus.sort((a, b) {
          // Primary: Sort by createdAt (latest first)
          final createdAtDiff = b.createdAt.compareTo(a.createdAt);
          if (createdAtDiff != 0) return createdAtDiff;

          // Secondary: Sort by priority (urgent first)
          final priorityOrder = {
            TicketPriority.urgent: 0,
            TicketPriority.high: 1,
            TicketPriority.medium: 2,
            TicketPriority.low: 3,
          };
          final priorityDiff = (priorityOrder[a.priority] ?? 2) -
              (priorityOrder[b.priority] ?? 2);
          if (priorityDiff != 0) return priorityDiff;

          // Tertiary: Sort by status
          final statusOrder = {
            TicketStatus.assigned: 0,
            TicketStatus.inProgress: 1,
            TicketStatus.acknowledged: 2,
            TicketStatus.new_: 3,
            TicketStatus.onHold: 4,
            TicketStatus.completed: 5,
            TicketStatus.cancelled: 6,
          };
          final statusDiff =
              (statusOrder[a.status] ?? 3) - (statusOrder[b.status] ?? 3);
          if (statusDiff != 0) return statusDiff;

          // Quaternary: Sort by scheduled time
          if (a.scheduledAt != null && b.scheduledAt != null) {
            return a.scheduledAt!.compareTo(b.scheduledAt!);
          }
          return 0;
        });
        break;
    }

    return filteredByStatus;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MaintenanceTicketBloc, MaintenanceTicketState>(
      builder: (context, state) {
        return state.maybeWhen(
              listLoaded: (tickets, _) {
                // Tickets are already filtered by assignedTechnicianId when loaded
                // So we can directly filter by status
                final filteredTickets = _filterTickets(tickets);

                if (filteredTickets.isEmpty) {
                  return _EmptyState(
                    filter: filter,
                    hasSearchQuery: searchQuery.trim().isNotEmpty,
                  );
                }

                // For all views, show as list
                return ListView(
                  padding: EdgeInsets.zero,
                  children: filteredTickets
                      .map((ticket) => _ActionTicketCard(ticket: ticket))
                      .toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (message) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load tickets',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              orElse: () => const Center(
                child: CircularProgressIndicator(),
              ),
            ) ??
            const Center(
              child: CircularProgressIndicator(),
            );
      },
    );
  }
}


class _ActionTicketCard extends StatelessWidget {
  const _ActionTicketCard({required this.ticket});

  final MaintenanceTicketEntity ticket;

  Color _getPriorityColor(TicketPriority priority) {
    if (ticket.priorityDetails?.colorCode != null) {
      try {
        return Color(
          int.parse(
            ticket.priorityDetails!.colorCode!.replaceFirst('#', '0xFF'),
          ),
        );
      } catch (e) {
        // Fallback
      }
    }
    switch (priority) {
      case TicketPriority.low:
        return Colors.green;
      case TicketPriority.medium:
        return Colors.blue;
      case TicketPriority.high:
        return Colors.orange;
      case TicketPriority.urgent:
        return Colors.red;
    }
  }

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.new_:
        return Colors.blue;
      case TicketStatus.acknowledged:
        return Colors.orange;
      case TicketStatus.assigned:
        return Colors.purple;
      case TicketStatus.inProgress:
        return Colors.indigo;
      case TicketStatus.onHold:
        return Colors.amber;
      case TicketStatus.completed:
        return Colors.green;
      case TicketStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priorityColor = _getPriorityColor(ticket.priority);
    final statusColor = _getStatusColor(ticket.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: InkWell(
        onTap: () async {
          // Navigate to detail page and wait for return
          await context.push('/maintenance-tickets/${ticket.id}');
          
          // Refresh ticket list and dashboard when returning
          if (context.mounted) {
            final authState = context.read<AuthBloc>().state;
            final user = authState.maybeWhen(
              authenticated: (u) => u,
              orElse: () => null,
            );
            final userId = user?.id;
            final companyId = user?.companyId;
            
            if (userId != null) {
              // Refresh ticket list
              context.read<MaintenanceTicketBloc>().add(
                    LoadMaintenanceTickets(
                      assignedTechnicianId: userId,
                      page: 1,
                      limit: 100,
                    ),
                  );
            }
            
            // Refresh dashboard stats
            if (companyId != null) {
              final technicianRole =
                  TechnicianDashboardPage._getTechnicianRole(user);
              context.read<DashboardBloc>().add(
                    RefreshDashboardEvent(
                      companyId: companyId,
                      role: technicianRole,
                    ),
                  );
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.ticketNumber,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      ticket.status.displayName,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                ticket.title,
                style: theme.textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (ticket.description != null && ticket.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    ticket.description!,
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      ticket.priority.displayName,
                      style: TextStyle(
                        color: priorityColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (ticket.category != null) ...[
                    const Spacer(),
                    Text(
                      ticket.category!.code ?? '',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              LocationDisplayWidget(ticket: ticket),
              const SizedBox(height: 12),
              _QuickActionButtons(ticket: ticket),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionButtons extends StatelessWidget {
  const _QuickActionButtons({required this.ticket});

  final MaintenanceTicketEntity ticket;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        if (ticket.status == TicketStatus.assigned ||
            ticket.status == TicketStatus.acknowledged) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _startWork(context),
              icon: const Icon(Icons.play_arrow, size: 18),
              label: const Text('Start'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _startWork(BuildContext context) {
    // Dispatch status change event
    context.read<MaintenanceTicketBloc>().add(
          ChangeMaintenanceTicketStatus(
            id: ticket.id,
            status: TicketStatus.inProgress.displayName,
            notes: null,
          ),
        );

    // Show success message (optimistic update)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('Starting work on ${ticket.ticketNumber}...'),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addNotes(BuildContext context) {
    // Capture the bloc before showing dialog
    final bloc = context.read<MaintenanceTicketBloc>();
    final notesController = TextEditingController();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final theme = Theme.of(context);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => isMobile
          ? Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: screenWidth - 32,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Work Notes',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your work notes...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(16),
                      ),
                      maxLines: 6,
                      autofocus: true,
                      textInputAction: TextInputAction.newline,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (notesController.text.trim().isNotEmpty) {
                            bloc.add(
                              AddTechnicianNotes(
                                id: ticket.id,
                                notes: notesController.text.trim(),
                              ),
                            );
                            Navigator.of(dialogContext).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Please enter notes before saving'),
                                backgroundColor: Colors.orange,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text('Save'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : AlertDialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 24,
              ),
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              title: const Text('Add Work Notes'),
              content: SizedBox(
                width: 400,
                child: TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your work notes...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(16),
                  ),
                  maxLines: 5,
                  autofocus: true,
                  textInputAction: TextInputAction.newline,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (notesController.text.trim().isNotEmpty) {
                      bloc.add(
                        AddTechnicianNotes(
                          id: ticket.id,
                          notes: notesController.text.trim(),
                        ),
                      );
                      Navigator.of(dialogContext).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter notes before saving'),
                          backgroundColor: Colors.orange,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
    );
  }

  void _completeTicket(BuildContext context) {
    // Capture the bloc before showing dialog
    final bloc = context.read<MaintenanceTicketBloc>();
    final notesController = TextEditingController();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final theme = Theme.of(context);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => isMobile
          ? Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: screenWidth - 32,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete Ticket',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    const Text('Add resolution notes (optional):'),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        hintText: 'Describe what was done...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(16),
                      ),
                      maxLines: 5,
                      autofocus: true,
                      textInputAction: TextInputAction.newline,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          bloc.add(
                            ChangeMaintenanceTicketStatus(
                              id: ticket.id,
                              status: TicketStatus.completed.displayName,
                              notes: notesController.text.trim().isEmpty
                                  ? null
                                  : notesController.text.trim(),
                            ),
                          );
                          Navigator.of(dialogContext).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer, // Use theme color for dark mode
                          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer, // Use theme color for dark mode
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text('Complete'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : AlertDialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 24,
              ),
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              title: const Text('Complete Ticket'),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Add resolution notes (optional):'),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        hintText: 'Describe what was done...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(16),
                      ),
                      maxLines: 4,
                      autofocus: true,
                      textInputAction: TextInputAction.newline,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    bloc.add(
                      ChangeMaintenanceTicketStatus(
                        id: ticket.id,
                        status: TicketStatus.completed.displayName,
                        notes: notesController.text.trim().isEmpty
                            ? null
                            : notesController.text.trim(),
                      ),
                    );
                    Navigator.of(dialogContext).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer, // Use theme color for dark mode
                    foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer, // Use theme color for dark mode
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text('Complete'),
                ),
              ],
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.filter,
    this.hasSearchQuery = false,
  });

  final _TicketFilter filter;
  final bool hasSearchQuery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String message;
    IconData icon;

    if (hasSearchQuery) {
      message = 'No tickets found';
      icon = Icons.search_off;
    } else {
      switch (filter) {
        case _TicketFilter.assigned:
          message = 'No assigned tickets';
          icon = Icons.assignment_outlined;
          break;
        case _TicketFilter.inProgress:
          message = 'No in progress tickets';
          icon = Icons.play_circle_outline;
          break;
        case _TicketFilter.completed:
          message = 'No completed tickets';
          icon = Icons.check_circle_outline;
          break;
        case _TicketFilter.all:
          message = 'No tickets found';
          icon = Icons.list_outlined;
          break;
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 48,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
