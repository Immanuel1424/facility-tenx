import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/maintenance_ticket_bloc.dart';
import '../bloc/maintenance_ticket_event.dart';
import '../bloc/maintenance_ticket_state.dart';
import '../../domain/entities/maintenance_ticket_entity.dart';

class EscalationWidget extends StatelessWidget {
  const EscalationWidget({
    super.key,
    required this.ticket,
    this.onEscalate,
  });

  final MaintenanceTicketEntity ticket;
  final VoidCallback? onEscalate;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<MaintenanceTicketBloc, MaintenanceTicketState>(
      listener: (context, state) {
        if (state is MaintenanceTicketEscalated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Ticket escalated successfully'),
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
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    color: ticket.isEscalated
                        ? colorScheme.error
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Escalation Status',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (ticket.isEscalated) ...[
                _buildEscalationInfo(context, ticket),
              ] else ...[
                Text(
                  'This ticket has not been escalated.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                if (onEscalate != null) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showEscalateDialog(context),
                    icon: const Icon(Icons.trending_up),
                    label: const Text('Escalate Ticket'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.errorContainer,
                      foregroundColor: colorScheme.onErrorContainer,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEscalationInfo(
    BuildContext context,
    MaintenanceTicketEntity ticket,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning,
                size: 16,
                color: colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 8),
              Text(
                'Escalated - Level ${ticket.escalationLevel}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        if (ticket.escalatedAt != null) ...[
          const SizedBox(height: 8),
          Text(
            'Escalated on: ${_formatDate(ticket.escalatedAt!)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ],
    );
  }

  void _showEscalateDialog(BuildContext context) {
    final reasonController = TextEditingController();
    int escalationLevel = 1;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Escalate Ticket'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Escalation Reason',
                  hintText: 'Enter reason for escalation...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: escalationLevel,
                decoration: const InputDecoration(
                  labelText: 'Target Escalation Level',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(3, (index) => index + 1).map((level) {
                  String levelLabel;
                  switch (level) {
                    case 1:
                      levelLabel = 'Level 1 (SUPERVISOR)';
                      break;
                    case 2:
                      levelLabel = 'Level 2 (SITE_COORDINATOR)';
                      break;
                    case 3:
                      levelLabel = 'Level 3 (ADMIN)';
                      break;
                    default:
                      levelLabel = 'Level $level';
                  }
                  return DropdownMenuItem<int>(
                    value: level,
                    child: Text(levelLabel),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    escalationLevel = value ?? 1;
                  });
                },
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
              if (reasonController.text.isNotEmpty) {
                context.read<MaintenanceTicketBloc>().add(
                      EscalateTicket(
                        ticketId: ticket.id,
                        escalationLevel: escalationLevel,
                        reason: reasonController.text,
                      ),
                    );
                Navigator.of(dialogContext).pop();
                onEscalate?.call();
              }
            },
            child: const Text('Escalate'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

