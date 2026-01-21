import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/di/service_locator.dart';
import '../../../../../core/widgets/app_bar_icon_button.dart';
import '../../bloc/maintenance_ticket_bloc.dart';
import '../../bloc/maintenance_ticket_event.dart';
import '../../bloc/maintenance_ticket_state.dart';
import '../../widgets/maintenance_ticket_list_item.dart';
import '../../../data/repositories/maintenance_ticket_repository.dart';

class TenantTicketListPage extends StatelessWidget {
  const TenantTicketListPage({
    super.key,
    this.statusFilter,
  });

  final String? statusFilter;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MaintenanceTicketBloc(
        repository: getIt<MaintenanceTicketRepository>(),
      ),
      child: _TenantTicketListContent(statusFilter: statusFilter),
    );
  }
}

class _TenantTicketListContent extends StatefulWidget {
  const _TenantTicketListContent({this.statusFilter});

  final String? statusFilter;

  @override
  State<_TenantTicketListContent> createState() =>
      _TenantTicketListContentState();
}

class _TenantTicketListContentState extends State<_TenantTicketListContent> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadTickets() {
    final normalizedStatus = _normalizeStatus(widget.statusFilter);
    context.read<MaintenanceTicketBloc>().add(
          LoadMaintenanceTickets(
            status: normalizedStatus,
            // No explicit villaNumber: backend will use all villas for this tenant
            page: 1,
            limit: 50,
          ),
        );
  }

  void _refresh() {
    final normalizedStatus = _normalizeStatus(widget.statusFilter);
    context.read<MaintenanceTicketBloc>().add(
          LoadMaintenanceTickets(
            status: normalizedStatus,
            // All villas for this tenant; search still applied
            search:
                _searchController.text.isEmpty ? null : _searchController.text,
            page: 1,
            limit: 50,
          ),
        );
  }

  String? _normalizeStatus(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final value = raw.toUpperCase();
    switch (value) {
      case 'OPEN':
        return 'NEW';
      case 'RESOLVED':
        return 'COMPLETED';
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Complaints'),
        actions: [
          AppBarIconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tickets...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _refresh();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: (_) => _refresh(),
            ),
          ),
          Expanded(
            child: BlocConsumer<MaintenanceTicketBloc, MaintenanceTicketState>(
              listener: (context, state) {
                state.maybeWhen(
                  orElse: () {},
                  error: (message) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                );
              },
              builder: (context, state) {
                if (state is MaintenanceTicketInitial) {
                  return const Center(child: Text('No tickets loaded'));
                } else if (state is MaintenanceTicketLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is MaintenanceTicketListLoaded) {
                  if (state.tickets.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tickets found',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.statusFilter != null
                                ? 'No ${widget.statusFilter} tickets'
                                : 'You haven\'t raised any complaints yet',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async => _refresh(),
                    child: ListView.builder(
                      itemCount: state.tickets.length,
                      itemBuilder: (context, index) {
                        return MaintenanceTicketListItem(
                          ticket: state.tickets[index],
                          onTap: () => context.push(
                            '/tenant/complaints/${state.tickets[index].id}',
                          ),
                        );
                      },
                    ),
                  );
                } else if (state is MaintenanceTicketError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refresh,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tenant/complaints/create'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Raise Complaint'),
        elevation: 4,
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (bottomSheetContext) => Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Filter Tickets',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Filter options
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    title: const Text('All'),
                    leading: Radio<String?>(
                      value: null,
                      groupValue: widget.statusFilter,
                      onChanged: (value) {
                        Navigator.pop(bottomSheetContext);
                        context.push('/tenant/complaints');
                      },
                    ),
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      context.push('/tenant/complaints');
                    },
                  ),
                  ListTile(
                    title: const Text('Open'),
                    leading: Radio<String?>(
                      value: 'NEW',
                      groupValue: widget.statusFilter,
                      onChanged: (value) {
                        Navigator.pop(bottomSheetContext);
                        context.push('/tenant/complaints?status=NEW');
                      },
                    ),
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      context.push('/tenant/complaints?status=NEW');
                    },
                  ),
                  ListTile(
                    title: const Text('In Progress'),
                    leading: Radio<String?>(
                      value: 'IN_PROGRESS',
                      groupValue: widget.statusFilter,
                      onChanged: (value) {
                        Navigator.pop(bottomSheetContext);
                        context.push('/tenant/complaints?status=IN_PROGRESS');
                      },
                    ),
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      context.push('/tenant/complaints?status=IN_PROGRESS');
                    },
                  ),
                  ListTile(
                    title: const Text('Completed'),
                    leading: Radio<String?>(
                      value: 'COMPLETED',
                      groupValue: widget.statusFilter,
                      onChanged: (value) {
                        Navigator.pop(bottomSheetContext);
                        context.push('/tenant/complaints?status=COMPLETED');
                      },
                    ),
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      context.push('/tenant/complaints?status=COMPLETED');
                    },
                  ),
                  ListTile(
                    title: const Text('Closed'),
                    leading: Radio<String?>(
                      value: 'CLOSED',
                      groupValue: widget.statusFilter,
                      onChanged: (value) {
                        Navigator.pop(bottomSheetContext);
                        context.push('/tenant/complaints?status=CLOSED');
                      },
                    ),
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      context.push('/tenant/complaints?status=CLOSED');
                    },
                  ),
                ],
              ),
            ),
            // Bottom padding for safe area
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}
