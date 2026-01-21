import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/jwt_utils.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

import '../../../notification/data/repositories/notification_repository.dart';
import '../../../notification/presentation/bloc/notification_bloc.dart';
import '../../../notification/presentation/bloc/notification_event.dart';
import '../../../notification/presentation/bloc/notification_state.dart';
import '../../../notification/domain/entities/notification_entity.dart';
import '../widgets/tenant_activity_feed.dart';
import '../../../maintenance_ticket/presentation/bloc/maintenance_ticket_bloc.dart';
import '../../../maintenance_ticket/presentation/bloc/maintenance_ticket_event.dart';
import '../../../maintenance_ticket/data/repositories/maintenance_ticket_repository.dart';
import '../../../announcement/presentation/bloc/announcement_bloc.dart';
import '../../../announcement/presentation/bloc/announcement_event.dart';

class TenantDashboardPage extends StatelessWidget {
  const TenantDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NotificationBloc>(
          create: (context) => NotificationBloc(
            repository: getIt<NotificationRepository>(),
          )..add(const LoadNotificationList()),
        ),
        BlocProvider<MaintenanceTicketBloc>(
          create: (context) => MaintenanceTicketBloc(
            repository: getIt<MaintenanceTicketRepository>(),
          ),
        ),
        BlocProvider<AnnouncementBloc>(
          create: (context) =>
              getIt<AnnouncementBloc>()..add(const LoadAnnouncements()),
        ),
      ],
      child: const _TenantDashboardContent(),
    );
  }
}

class _TenantDashboardContent extends StatefulWidget {
  const _TenantDashboardContent();

  @override
  State<_TenantDashboardContent> createState() =>
      _TenantDashboardContentState();
}

class _TenantDashboardContentState extends State<_TenantDashboardContent> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _companyName;
  bool _isLoadingCompanyName = true;

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

  Future<void> _loadCompanyName() async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token != null) {
        final companyName = JwtUtils.getCompanyName(token);
        if (mounted) {
          setState(() {
            _companyName = companyName;
            _isLoadingCompanyName = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingCompanyName = false;
          });
        }
      }
    } catch (e) {
      print('⚠️ Error loading company name: $e');
      if (mounted) {
        setState(() {
          _isLoadingCompanyName = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCompanyName();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authState = context.read<AuthBloc>().state;
        authState.maybeWhen(
          authenticated: (user) {
            // Load all tickets across all villas for this tenant
            context.read<MaintenanceTicketBloc>().add(
                  const LoadMaintenanceTickets(
                    status: null,
                    page: 1,
                    limit: 100, // Maximum allowed by backend
                  ),
                );
            // Load announcements for tenant
            context.read<AnnouncementBloc>().add(
                  const LoadAnnouncements(),
                );
          },
          orElse: () {},
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            state.maybeWhen(
              authenticated: (user) {
                // No setState needed - BlocBuilder will rebuild automatically
              },
              unauthenticated: () {
                if (mounted) {
                  context.go('/login');
                }
              },
              orElse: () {},
            );
          },
        ),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final user = authState.maybeWhen(
            authenticated: (u) => u,
            orElse: () => null,
          );
          return Scaffold(
            extendBodyBehindAppBar: false,
            appBar: AppBar(
              elevation: 0,
              scrolledUnderElevation: 1,
              backgroundColor: Theme.of(context).colorScheme.primary,
              surfaceTintColor: Colors.transparent,
              toolbarHeight: 72,
              leadingWidth: 64,
              leading: Padding(
                padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                child: InkWell(
                  onTap: () => context.push('/profile'),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.surface, // Use theme color for dark mode support
                    ),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Theme.of(context).colorScheme.surface, // Use theme color for dark mode support
                      child: Text(
                        (user?.firstName ?? '').isNotEmpty
                            ? (user?.firstName ?? '')[0].toUpperCase()
                            : 'T',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_getTimeBasedGreeting()}, ${user?.firstName ?? 'Tenant'}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isLoadingCompanyName
                        ? 'Loading...'
                        : _companyName != null && _companyName!.isNotEmpty
                            ? 'Welcome back to $_companyName'
                            : 'Welcome back',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              centerTitle: false,
              actions: [
                _NotificationButton(
                  colorScheme: Theme.of(context).colorScheme,
                ),
                const SizedBox(width: 8),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(40),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withValues(alpha: 0.2),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (user != null) ...[
                        Icon(
                          Icons.link_rounded,
                          size: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              // Collect all villa numbers for this tenant
                              final List<String> villaNumbers =
                                  user.villas.isNotEmpty
                                      ? user.villas
                                          .map((v) => v.villaNumber)
                                          .toList()
                                      : user.villaNumber != null
                                          ? <String>[user.villaNumber!]
                                          : <String>[];

                              final String villaText = villaNumbers.isEmpty
                                  ? 'Tenant Portal'
                                  : villaNumbers.length == 1
                                      ? 'Villa ${villaNumbers.first} • Tenant Portal'
                                      : 'Villas ${villaNumbers.join(', ')} • Tenant Portal';

                              return Text(
                                villaText,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.7),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                final authState = context.read<AuthBloc>().state;
                authState.maybeWhen(
                  authenticated: (_) {
                    context.read<MaintenanceTicketBloc>().add(
                          const LoadMaintenanceTickets(
                            status: null,
                            page: 1,
                            limit: 100,
                          ),
                        );
                    context.read<AnnouncementBloc>().add(
                          const LoadAnnouncements(),
                        );
                  },
                  orElse: () {},
                );
                // Wait a bit for the refresh to complete
                await Future<void>.delayed(const Duration(milliseconds: 500));
              },
              child: const SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    TenantActivityFeed(),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                await context.push('/tenant/complaints/create/ai');
                // Refresh tickets when returning
                if (context.mounted) {
                  final authState = context.read<AuthBloc>().state;
                  authState.maybeWhen(
                    authenticated: (_) {
                      context.read<MaintenanceTicketBloc>().add(
                            const LoadMaintenanceTickets(
                              page: 1,
                              limit: 50,
                            ),
                          );
                    },
                    orElse: () {},
                  );
                }
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary, // Use theme color for dark mode
              elevation: 4,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Ticket'),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          );
        },
      ),
    );
  }
}

// Removed unused methods: _loadDashboardIfNeeded, _refreshDashboard

// Removed unused classes: _TenantDashboardLayout, _TenantStatsSection, _SummaryHeroCard, _WorkflowSection, _TenantVillaInfoSection

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
              icon: Icon(
                Icons.notifications_outlined,
                color: colorScheme.onPrimary,
              ),
              tooltip: 'Notifications',
              onPressed: () => context.push('/notifications'),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3), // Use theme color for dark mode
              ),
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
