import 'package:flutter/material.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/maintenance_ticket_entity.dart';

class MaintenanceTicketListItem extends StatelessWidget {
  const MaintenanceTicketListItem({
    super.key,
    required this.ticket,
    this.onTap,
  });

  final MaintenanceTicketEntity ticket;
  final VoidCallback? onTap;

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.new_:
        return const Color(0xFF3B82F6); // Light blue
      case TicketStatus.acknowledged:
        return const Color(0xFFF59E0B); // Orange
      case TicketStatus.assigned:
        return const Color(0xFF8B5CF6); // Purple
      case TicketStatus.inProgress:
        return const Color(0xFF6366F1); // Indigo
      case TicketStatus.onHold:
        return const Color(0xFFF59E0B); // Amber
      case TicketStatus.completed:
        return const Color(0xFF10B981); // Green
      case TicketStatus.cancelled:
        return const Color(0xFFEF4444); // Red
    }
  }

  String _getStatusDisplayName(TicketStatus status) {
    switch (status) {
      case TicketStatus.new_:
        return 'New';
      case TicketStatus.acknowledged:
        return 'Acknowledged';
      case TicketStatus.assigned:
        return 'Assigned';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.onHold:
        return 'On Hold';
      case TicketStatus.completed:
        return 'Completed';
      case TicketStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getPriorityColor(TicketPriority priority) {
    // Use color from API if available, otherwise fallback to defaults
    if (ticket.priorityDetails?.colorCode != null) {
      try {
        return Color(
          int.parse(
            ticket.priorityDetails!.colorCode!.replaceFirst('#', '0xFF'),
          ),
        );
      } catch (e) {
        // If parsing fails, fallback to defaults
      }
    }
    // Fallback to hardcoded colors if API data not available
    switch (priority) {
      case TicketPriority.low:
        return const Color(0xFF10B981); // Green
      case TicketPriority.medium:
        return const Color(0xFF3B82F6); // Blue
      case TicketPriority.high:
        return const Color(0xFFF59E0B); // Orange
      case TicketPriority.urgent:
        return const Color(0xFFEF4444); // Red
    }
  }

  String _formatCreatedTime(DateTime dateTime) {
    return DateFormatter.formatDateTimeRelative(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = _getStatusColor(ticket.status);
    final priorityColor = _getPriorityColor(ticket.priority);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      decoration: BoxDecoration(
        color: colorScheme.surface, // Use theme color for dark mode support
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2), // Use theme color for dark mode
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05), // Use theme color for dark mode
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Title first (most important) and Status badge (right aligned)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title (bold, dark text) - Most prominent, takes most space
                    Expanded(
                      child: Text(
                        ticket.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: colorScheme.onSurface, // Use theme color for dark mode visibility
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Status badge (compact, right aligned)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getStatusDisplayName(ticket.status),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                // Description (if available)
                if (ticket.description != null &&
                    ticket.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    ticket.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant, // Use theme color for dark mode visibility
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                // Ticket ID, Priority and Villa row
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Ticket ID (first in row)
                    Text(
                      ticket.ticketNumber,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant, // Use theme color for dark mode visibility
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    // Separator dot
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.5), // Use theme color for dark mode
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Priority indicator (dot + text)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: priorityColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          ticket.priority.displayName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant, // Use theme color for dark mode visibility
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    // Villa number (if available)
                    if (ticket.villaNumber != null) ...[
                      // Separator dot
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.5), // Use theme color for dark mode
                          shape: BoxShape.circle,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.home_outlined,
                            size: 14,
                            color: colorScheme.onSurfaceVariant, // Use theme color for dark mode
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Villa ${ticket.villaNumber}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant, // Use theme color for dark mode visibility
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                // Bottom row: Created time and Details link
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Created time
                    Text(
                      _formatCreatedTime(ticket.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant, // Use theme color for dark mode visibility
                        fontSize: 12,
                      ),
                    ),
                    // Details link with arrow
                    Row(
                      children: [
                        Text(
                          'Details',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: colorScheme.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
