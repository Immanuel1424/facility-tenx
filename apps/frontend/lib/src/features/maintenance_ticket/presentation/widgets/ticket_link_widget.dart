import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/maintenance_ticket_bloc.dart';
import '../bloc/maintenance_ticket_event.dart';
import '../bloc/maintenance_ticket_state.dart';
import '../../domain/entities/maintenance_ticket_entity.dart';

class TicketLinkWidget extends StatelessWidget {
  const TicketLinkWidget({
    super.key,
    required this.ticket,
    this.onLink,
  });

  final MaintenanceTicketEntity ticket;
  final VoidCallback? onLink;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<MaintenanceTicketBloc, MaintenanceTicketState>(
      listener: (context, state) {
        if (state is MaintenanceTicketLinked) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Ticket linked successfully'),
              backgroundColor: colorScheme.primaryContainer,
            ),
          );
        } else if (state is MaintenanceTicketError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: colorScheme.errorContainer,
            ),
          );
        }
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.link,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ticket Relationships',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (ticket.hasParent()) ...[
                _buildParentTicket(context, ticket),
              ],
              _buildChildTickets(context, ticket),
              if (onLink != null && !ticket.hasParent()) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _showLinkDialog(context),
                  icon: const Icon(Icons.link),
                  label: const Text('Link to Parent Ticket'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParentTicket(
    BuildContext context,
    MaintenanceTicketEntity ticket,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Parent Ticket',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: () {
              context.push('/maintenance-tickets/${ticket.parentTicketId}');
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_upward,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ticket.parentTicketId ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildTickets(
    BuildContext context,
    MaintenanceTicketEntity ticket,
  ) {
    return BlocBuilder<MaintenanceTicketBloc, MaintenanceTicketState>(
      builder: (context, state) {
        final bloc = context.read<MaintenanceTicketBloc>();
        // Get child tickets from state or cache
        final cachedTickets = bloc.getCachedChildTickets(ticket.id);
        List<MaintenanceTicketEntity> childTickets = state is ChildTicketsLoaded
            ? state.childTickets
            : cachedTickets;
        // Check if we've already loaded (state shows loaded OR cache contains this ticket ID)
        final hasLoaded = state is ChildTicketsLoaded || bloc.hasCachedChildTickets(ticket.id);

        // Load child tickets if not already loaded/cached
        if (!hasLoaded && state is! MaintenanceTicketLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            print('🔄 Loading child tickets for ticket: ${ticket.id}');
            bloc.add(LoadChildTickets(parentTicketId: ticket.id));
          });
          // Show loading indicator while fetching
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )),
          );
        }

        // Show message when loaded but empty (including 404 case)
        if (hasLoaded && childTickets.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No child tickets',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Child Tickets (${childTickets.length})',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            ...childTickets.map((child) => _buildChildTicketItem(context, child)),
          ],
        );
      },
    );
  }

  Widget _buildChildTicketItem(
    BuildContext context,
    MaintenanceTicketEntity child,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          context.push('/maintenance-tickets/${child.id}');
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.arrow_downward,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.ticketNumber,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    if (child.title.isNotEmpty)
                      Text(
                        child.title,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLinkDialog(BuildContext context) {
    final parentTicketIdController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Link to Parent Ticket'),
        content: TextField(
          controller: parentTicketIdController,
          decoration: const InputDecoration(
            labelText: 'Parent Ticket ID',
            hintText: 'Enter parent ticket ID...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (parentTicketIdController.text.isNotEmpty) {
                context.read<MaintenanceTicketBloc>().add(
                      LinkTicket(
                        ticketId: ticket.id,
                        parentTicketId: parentTicketIdController.text.trim(),
                      ),
                    );
                Navigator.of(dialogContext).pop();
                onLink?.call();
              }
            },
            child: const Text('Link'),
          ),
        ],
      ),
    );
  }
}

