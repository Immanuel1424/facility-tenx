import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../maintenance_ticket/domain/repositories/maintenance_ticket_repository_interface.dart';
import '../../../maintenance_ticket/presentation/bloc/maintenance_ticket_bloc.dart';
import '../../../maintenance_ticket/presentation/bloc/maintenance_ticket_event.dart';
import '../../../maintenance_ticket/presentation/bloc/maintenance_ticket_state.dart';
import '../../../maintenance_ticket/domain/entities/maintenance_ticket_entity.dart';

class DashboardRecentTickets extends StatelessWidget {
  const DashboardRecentTickets({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MaintenanceTicketBloc>(
      create: (context) => MaintenanceTicketBloc(
        repository: getIt<MaintenanceTicketRepositoryInterface>(),
      )..add(
          const LoadMaintenanceTickets(
            page: 1,
            limit: 4,
            // Backend should return tickets sorted by newest first by default
          ),
        ),
      child: const _RecentTicketsContent(),
    );
  }
}

class _RecentTicketsContent extends StatelessWidget {
  const _RecentTicketsContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Tickets',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Latest maintenance requests',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh',
                      onPressed: () {
                        context.read<MaintenanceTicketBloc>().add(
                          const LoadMaintenanceTickets(
                            page: 1,
                            limit: 4,
                          ),
                        );
                      },
                    ),
                    TextButton(
                      onPressed: () => context.push('/maintenance-tickets'),
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            BlocBuilder<MaintenanceTicketBloc, MaintenanceTicketState>(
              builder: (context, state) {
                // Handle initial state
                if (state is MaintenanceTicketInitial) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                if (state is MaintenanceTicketLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                if (state is MaintenanceTicketListLoaded) {
                  final tickets = state.tickets;
                  if (tickets.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 48,
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No tickets yet',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      return _TicketCard(
                        key: ValueKey(tickets[index].id),
                        ticket: tickets[index],
                      );
                    },
                  );
                }
                
                if (state is MaintenanceTicketError) {
                  return Center(
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
                            'Failed to load tickets',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<MaintenanceTicketBloc>().add(
                                const LoadMaintenanceTickets(
                                  page: 1,
                                  limit: 4,
                                ),
                              );
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    super.key,
    required this.ticket,
  });

  final MaintenanceTicketEntity ticket;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => context.push('/maintenance-tickets/${ticket.id}'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(ticket.title)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              _getCategoryIcon(ticket.title),
                              size: 16,
                              color: _getCategoryColor(ticket.title),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              ticket.ticketNumber,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontFamily: 'monospace',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  ticket.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                if (ticket.description != null)
                  Expanded(
                    child: Text(
                      ticket.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _StatusBadge(status: ticket.status.name),
                    const SizedBox(width: 8),
                    _PriorityBadge(
                      priority: ticket.priority.name,
                      priorityDetails: ticket.priorityDetails,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDate(ticket.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('ac') || lowerTitle.contains('cooling')) {
      return Colors.blue;
    } else if (lowerTitle.contains('faucet') || lowerTitle.contains('water')) {
      return Colors.cyan;
    } else if (lowerTitle.contains('garden') ||
        lowerTitle.contains('irrigation')) {
      return Colors.green;
    } else if (lowerTitle.contains('power') || lowerTitle.contains('outlet')) {
      return Colors.amber;
    }
    return Colors.grey;
  }

  IconData _getCategoryIcon(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('ac') || lowerTitle.contains('cooling')) {
      return Icons.ac_unit;
    } else if (lowerTitle.contains('faucet') || lowerTitle.contains('water')) {
      return Icons.build;
    } else if (lowerTitle.contains('garden') ||
        lowerTitle.contains('irrigation')) {
      return Icons.local_florist;
    } else if (lowerTitle.contains('power') || lowerTitle.contains('outlet')) {
      return Icons.flash_on;
    }
    return Icons.description;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? 'almost 1 year ago' : 'almost $years years ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? 'almost 1 month ago' : 'almost $months months ago';
    } else if (difference.inDays > 0) {
      return difference.inDays == 1
          ? '1 day ago'
          : '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1
          ? '1 hour ago'
          : '${difference.inHours} hours ago';
    } else {
      return 'Just now';
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = _getStatusInfo(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  (Color, IconData, String) _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'new':
      case 'open':
        return (Colors.blue, Icons.radio_button_unchecked, 'New');
      case 'in_progress':
      case 'inprogress':
        return (Colors.teal, Icons.play_arrow, 'In Progress');
      case 'assigned':
        return (Colors.orange, Icons.person, 'Assigned');
      case 'acknowledged':
        return (Colors.purple, Icons.access_time, 'Acknowledged');
      case 'completed':
      case 'resolved':
        return (Colors.green, Icons.check_circle, 'Completed');
      case 'on_hold':
      case 'onhold':
        return (Colors.grey, Icons.pause, 'On Hold');
      default:
        return (Colors.grey, Icons.circle, status);
    }
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({
    required this.priority,
    this.priorityDetails,
  });

  final String priority;
  final PriorityDetailsEntity? priorityDetails;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _getPriorityInfo(priority);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            priority,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  (Color, IconData) _getPriorityInfo(String priority) {
    // Use color from API if available
    Color? apiColor;
    IconData? apiIcon;
    if (priorityDetails != null) {
      if (priorityDetails!.colorCode != null) {
        try {
          apiColor = Color(
            int.parse(
              priorityDetails!.colorCode!.replaceFirst('#', '0xFF'),
            ),
          );
        } catch (e) {
          // If parsing fails, use defaults
        }
      }
      if (priorityDetails!.iconName != null) {
        switch (priorityDetails!.iconName!.toLowerCase()) {
          case 'arrow_upward':
            apiIcon = Icons.arrow_upward;
            break;
          case 'arrow_downward':
            apiIcon = Icons.arrow_downward;
            break;
          case 'remove':
            apiIcon = Icons.remove;
            break;
          case 'priority_high':
            apiIcon = Icons.priority_high;
            break;
          default:
            break;
        }
      }
    }
    // Use API values if available, otherwise fallback to defaults
    if (apiColor != null && apiIcon != null) {
      return (apiColor, apiIcon);
    }
    // Fallback to hardcoded colors
    switch (priority.toLowerCase()) {
      case 'high':
        return (apiColor ?? Colors.amber, apiIcon ?? Icons.arrow_upward);
      case 'medium':
        return (apiColor ?? Colors.blue, apiIcon ?? Icons.arrow_forward);
      case 'low':
        return (apiColor ?? Colors.grey, apiIcon ?? Icons.arrow_downward);
      default:
        return (apiColor ?? Colors.grey, apiIcon ?? Icons.remove);
    }
  }
}
