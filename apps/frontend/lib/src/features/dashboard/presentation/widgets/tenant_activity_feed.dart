import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../maintenance_ticket/presentation/bloc/maintenance_ticket_bloc.dart';
import '../../../maintenance_ticket/presentation/bloc/maintenance_ticket_event.dart';
import '../../../maintenance_ticket/presentation/bloc/maintenance_ticket_state.dart';
import '../../../maintenance_ticket/presentation/widgets/maintenance_ticket_list_item.dart';
import '../../../maintenance_ticket/domain/entities/maintenance_ticket_entity.dart';
import '../widgets/tenant_announcements_section.dart';
import '../widgets/dashboard_shared_widgets.dart';

class TenantActivityFeed extends StatelessWidget {
  const TenantActivityFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState.maybeWhen(
          authenticated: (u) => u,
          orElse: () => null,
        );

        if (user == null) {
          return const SizedBox.shrink();
        }

        return _ActivityFeedContent(userId: user.id);
      },
    );
  }
}

class _ActivityFeedContent extends StatefulWidget {
  const _ActivityFeedContent({required this.userId});

  final String userId;

  @override
  State<_ActivityFeedContent> createState() => _ActivityFeedContentState();
}

class _ActivityFeedContentState extends State<_ActivityFeedContent> {
  String?
      _selectedStatus; // null = All, or specific status like 'NEW', 'IN_PROGRESS', etc.
  final Set<String> _selectedVillas =
      {}; // Empty = All, otherwise specific villas
  final TextEditingController _searchController = TextEditingController();

  // Note: Business data comes from BLoC state, not local variables

  @override
  void initState() {
    super.initState();
    // The parent component (tenant_dashboard_page) loads all tickets on init
    // We'll cache them via BlocListener when they arrive
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onStatusFilterChanged(String? status) {
    if (_selectedStatus == status) return;

    setState(() {
      _selectedStatus = status;
    });

    _loadTickets();
  }

  void _onSearchChanged(String query) {
    // Trigger rebuild to show filtered results
    setState(() {});
  }

  void _onVillaFilterChanged(String villaId) {
    setState(() {
      if (_selectedVillas.contains(villaId)) {
        _selectedVillas.remove(villaId);
      } else {
        _selectedVillas.add(villaId);
      }
      // Reset status filter to "All" to fetch fresh stats for the new selection
      _selectedStatus = null;
    });
  }

  void _onApplyVillaFilter() {
    Navigator.pop(context);
    _loadTickets();
  }

  void _onClearVillaFilter() {
    setState(() {
      _selectedVillas.clear();
    });
    Navigator.pop(context);
    _loadTickets();
  }

  void _loadTickets() {
    final authState = context.read<AuthBloc>().state;
    authState.maybeWhen(
      authenticated: (user) {
        context.read<MaintenanceTicketBloc>().add(
              LoadMaintenanceTickets(
                villaNumbers: _selectedVillas.isNotEmpty
                    ? _selectedVillas.toList()
                    : null,
                status: _selectedStatus,
                page: 1,
                limit: 50,
              ),
            );
      },
      orElse: () {},
    );
  }

  void _showVillaFilterBottomSheet(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final user = authState.maybeWhen(
      authenticated: (u) => u,
      orElse: () => null,
    );

    if (user == null) return;

    // Collect all villa numbers for this tenant
    final List<String> villaNumbers = user.villas.isNotEmpty
        ? user.villas.map((v) => v.villaNumber).toList()
        : user.villaNumber != null
            ? <String>[user.villaNumber!]
            : <String>[];

    // If only 1 or 0 villas, no need to show filter
    if (villaNumbers.length <= 1) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Filter by Villa',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          if (_selectedVillas.isNotEmpty)
                            TextButton(
                              onPressed: _onClearVillaFilter,
                              child: const Text('Clear All'),
                            ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          ...villaNumbers.map(
                            (villa) {
                              final isSelected =
                                  _selectedVillas.contains(villa);
                              return CheckboxListTile(
                                value: isSelected,
                                title: Text('Villa $villa'),
                                secondary: const Icon(Icons.home_outlined),
                                onChanged: (bool? value) {
                                  setModalState(() {
                                    _onVillaFilterChanged(villa);
                                  });
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FilledButton(
                              onPressed: _onApplyVillaFilter,
                              style: FilledButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Apply'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<MaintenanceTicketEntity> _filterTickets(
    List<MaintenanceTicketEntity> tickets,
  ) {
    List<MaintenanceTicketEntity> filtered = tickets;

    // Status filtering is now done server-side via LoadMaintenanceTickets
    // Only apply client-side search filter here
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((ticket) {
        final title = ticket.title.toLowerCase();
        final id = ticket.ticketNumber.toLowerCase();
        return title.contains(query) || id.contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<MaintenanceTicketBloc, MaintenanceTicketState>(
      listener: (context, state) {
        // Cache all tickets when loaded without status filter for accurate counts
        state.maybeWhen(
          listLoaded: (loadedTickets, total) {
            // No local caching needed - read directly from BLoC state in builder
          },
          orElse: () {},
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Announcements Section (shown at top)
          // This will be handled by TenantAnnouncementsSection in parent
          
          // Tickets Label and Quick Snapshots
          BlocBuilder<MaintenanceTicketBloc, MaintenanceTicketState>(
            builder: (context, state) {
              // Read directly from BLoC state - no local caching needed
              final List<MaintenanceTicketEntity> ticketsForCounts =
                  state.maybeWhen(
                    listLoaded: (tickets, _) => tickets,
                    orElse: () => <MaintenanceTicketEntity>[],
                  ) ?? <MaintenanceTicketEntity>[];

              // Calculate status counts for snapshot cards using enum values
              final newCount = ticketsForCounts
                  .where((t) => t.status == TicketStatus.new_)
                  .length;
              final inProgressCount = ticketsForCounts
                  .where((t) => t.status == TicketStatus.inProgress)
                  .length;
              final completedCount = ticketsForCounts
                  .where((t) => t.status == TicketStatus.completed)
                  .length;

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          'Snapshot of all tickets',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Quick Snapshots - Grid Layout
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 600;
                        // For 3 cards: 2 columns on mobile, 3 columns on tablet/desktop
                        final crossAxisCount = isMobile ? 2 : 3;
                        const spacing = 12.0;
                        const runSpacing = 12.0;

                        // Show only New, In Progress, and Completed for both mobile and desktop
                        final cards = [
                          QuickSnapshotCard(
                            label: 'NEW',
                            count: newCount,
                            color: const Color(0xFF3B82F6),
                            onTap: () => _onStatusFilterChanged('NEW'),
                          ),
                          QuickSnapshotCard(
                            label: 'IN PROGRESS',
                            count: inProgressCount,
                            color: const Color(0xFF6366F1),
                            onTap: () => _onStatusFilterChanged('IN_PROGRESS'),
                          ),
                          QuickSnapshotCard(
                            label: 'COMPLETED',
                            count: completedCount,
                            color: const Color(0xFF10B981),
                            onTap: () => _onStatusFilterChanged('COMPLETED'),
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

          // Announcements Section (after snapshot cards)
          const TenantAnnouncementsSection(),

          // Activity Feed Section
          BlocBuilder<MaintenanceTicketBloc, MaintenanceTicketState>(
            builder: (context, state) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with title and subtitle
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Filters',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap on a ticket to view details',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<MaintenanceTicketBloc, MaintenanceTicketState>(
                      builder: (context, state) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: Row(
                            children: [
                              DashboardFilterChip(
                                label: 'All',
                                isSelected: _selectedStatus == null,
                                onSelected: () => _onStatusFilterChanged(null),
                              ),
                              const SizedBox(width: 8),
                              // Active tickets first (priority order)
                              StatusFilterChip(
                                label: 'New',
                                status: 'NEW',
                                isSelected: _selectedStatus == 'NEW',
                                onSelected: () => _onStatusFilterChanged('NEW'),
                              ),
                              const SizedBox(width: 8),
                              StatusFilterChip(
                                label: 'In Progress',
                                status: 'IN_PROGRESS',
                                isSelected: _selectedStatus == 'IN_PROGRESS',
                                onSelected: () =>
                                    _onStatusFilterChanged('IN_PROGRESS'),
                              ),
                              const SizedBox(width: 8),
                              StatusFilterChip(
                                label: 'Assigned',
                                status: 'ASSIGNED',
                                isSelected: _selectedStatus == 'ASSIGNED',
                                onSelected: () =>
                                    _onStatusFilterChanged('ASSIGNED'),
                              ),
                              const SizedBox(width: 8),
                              StatusFilterChip(
                                label: 'Acknowledged',
                                status: 'ACKNOWLEDGED',
                                isSelected: _selectedStatus == 'ACKNOWLEDGED',
                                onSelected: () =>
                                    _onStatusFilterChanged('ACKNOWLEDGED'),
                              ),
                              const SizedBox(width: 8),
                              // Completed/Cancelled at the end
                              StatusFilterChip(
                                label: 'Completed',
                                status: 'COMPLETED',
                                isSelected: _selectedStatus == 'COMPLETED',
                                onSelected: () =>
                                    _onStatusFilterChanged('COMPLETED'),
                              ),
                              const SizedBox(width: 8),
                              StatusFilterChip(
                                label: 'Cancelled',
                                status: 'CANCELLED',
                                isSelected: _selectedStatus == 'CANCELLED',
                                onSelected: () =>
                                    _onStatusFilterChanged('CANCELLED'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              hintText: 'Search tickets...',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        _onSearchChanged('');
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface, // Use theme color for dark mode support
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: colorScheme.outline
                                      .withValues(alpha: 0.3),
                                  width: 1.2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: colorScheme.outline
                                      .withValues(alpha: 0.3),
                                  width: 1.2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: colorScheme.primary
                                      .withValues(alpha: 0.9),
                                  width: 1.6,
                                ),
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                            ),
                          ),
                        ),
                        // Only show filter button if user has multiple villas
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final user = state.maybeWhen(
                              authenticated: (u) => u,
                              orElse: () => null,
                            );
                            if (user == null) return const SizedBox.shrink();

                            // If explicit list is empty but single number exists, count is 1.
                            // If list has items, use that count.
                            // Simplified logic:
                            final hasMultipleVillas = user.villas.length > 1;

                            if (!hasMultipleVillas)
                              return const SizedBox.shrink();

                            return Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: InkWell(
                                onTap: () =>
                                    _showVillaFilterBottomSheet(context),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: _selectedVillas.isNotEmpty
                                        ? colorScheme.primaryContainer
                                        : colorScheme.surface, // Use theme color for dark mode support
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _selectedVillas.isNotEmpty
                                          ? colorScheme.primary
                                          : colorScheme.outline
                                              .withValues(alpha: 0.3),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.filter_list_rounded,
                                    color: _selectedVillas.isNotEmpty
                                        ? colorScheme.primary
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          BlocBuilder<MaintenanceTicketBloc, MaintenanceTicketState>(
            builder: (context, state) {
              return state.maybeWhen(
                    initial: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    listLoaded: (tickets, _) {
                      final filteredTickets = _filterTickets(tickets);

                      if (filteredTickets.isEmpty) {
                        return _buildEmptyState(
                          context,
                          _selectedStatus != null,
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredTickets.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final ticket = filteredTickets[index];
                            return MaintenanceTicketListItem(
                              key: ValueKey(ticket.id),
                              ticket: ticket,
                              onTap: () async {
                                await context
                                    .push('/tenant/complaints/${ticket.id}');
                                if (context.mounted) {
                                  final authState =
                                      context.read<AuthBloc>().state;
                                  authState.maybeWhen(
                                    authenticated: (user) {
                                      context.read<MaintenanceTicketBloc>().add(
                                            LoadMaintenanceTickets(
                                              // Multi-villa: reload with current filters
                                              villaNumbers:
                                                  _selectedVillas.isNotEmpty
                                                      ? _selectedVillas.toList()
                                                      : null,
                                              status: _selectedStatus,
                                              page: 1,
                                              limit: 50,
                                            ),
                                          );
                                    },
                                    orElse: () {},
                                  );
                                }
                              },
                            );
                          },
                        ),
                      );
                    },
                    error: (message) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load activity',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              message,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                context.read<MaintenanceTicketBloc>().add(
                                      const LoadMaintenanceTickets(
                                        page: 1,
                                        limit: 50,
                                      ),
                                    );
                              },
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Retry'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ) ??
                  const SizedBox.shrink();
            },
          ),
          // Add some bottom padding for the FAB
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isFiltered) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFiltered
                    ? Icons.filter_alt_outlined
                    : Icons.assignment_outlined,
                size: 64,
                color: colorScheme.primary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isFiltered ? 'No tickets found' : 'No tickets yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isFiltered
                  ? 'Try adjusting your filters to see more results'
                  : 'Create your first maintenance ticket\nto get quick assistance for your villa',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            if (!isFiltered) ...[
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () {
                  context.push('/tenant/complaints/create/ai');
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create Ticket'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

