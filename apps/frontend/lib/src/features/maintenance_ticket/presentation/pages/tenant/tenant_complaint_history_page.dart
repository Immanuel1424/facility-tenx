import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/di/service_locator.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../bloc/maintenance_ticket_bloc.dart';
import '../../bloc/maintenance_ticket_event.dart';
import '../../bloc/maintenance_ticket_state.dart';
import '../../widgets/maintenance_ticket_list_item.dart';
import '../../../data/repositories/maintenance_ticket_repository.dart';

class TenantComplaintHistoryPage extends StatelessWidget {
  const TenantComplaintHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MaintenanceTicketBloc(
        repository: getIt<MaintenanceTicketRepository>(),
      ),
      child: const _TenantComplaintHistoryContent(),
    );
  }
}

class _TenantComplaintHistoryContent extends StatefulWidget {
  const _TenantComplaintHistoryContent();

  @override
  State<_TenantComplaintHistoryContent> createState() =>
      _TenantComplaintHistoryContentState();
}

class _TenantComplaintHistoryContentState
    extends State<_TenantComplaintHistoryContent> {
  @override
  void initState() {
    super.initState();
    _loadClosedTickets();
  }

  void _loadClosedTickets() {
    final user = context.read<AuthBloc>().state.maybeWhen(
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

    if (villaNumbers.isNotEmpty) {
      context.read<MaintenanceTicketBloc>().add(
            LoadMaintenanceTickets(
              status: 'CLOSED',
              villaNumbers: villaNumbers,
              page: 1,
              limit: 100,
            ),
          );
    }
  }

  void _refresh() {
    _loadClosedTickets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint History'),
      ),
      body: BlocConsumer<MaintenanceTicketBloc, MaintenanceTicketState>(
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
                      Icons.history,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No closed tickets',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You don\'t have any closed complaints yet',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
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
    );
  }
}
