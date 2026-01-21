import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Example TicketCard widget demonstrating proper theme consumption.
/// This widget shows how to access:
/// 1. Standard Material 3 colors via Theme.of(context).colorScheme
/// 2. Custom TicketStatusTheme extension via context.ticketStatusTheme
/// 3. Typography via Theme.of(context).textTheme
///
/// **Key Principle:** ZERO hard-coded colors or styles - everything flows
/// through Theme.of(context).
class TicketCardExample extends StatelessWidget {
  const TicketCardExample({
    super.key,
    required this.ticketId,
    required this.title,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.onTap,
  });

  final String ticketId;
  final String title;
  final TicketStatus status;
  final String priority;
  final DateTime createdAt;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ticketStatusTheme = context.ticketStatusTheme;
    final textTheme = theme.textTheme;

    // Get status color from custom ThemeExtension
    final statusColor = _getStatusColor(ticketStatusTheme, status);
    final statusLabel = _getStatusLabel(status);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Ticket ID and Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ticket ID - Monospace for important data
                  Text(
                    '#$ticketId',
                    style: textTheme.titleMedium?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  // Status Badge
                  _StatusBadge(
                    label: statusLabel,
                    color: statusColor,
                    textTheme: textTheme,
                    colorScheme: colorScheme,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Title
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Metadata Row: Priority and Date
              Row(
                children: [
                  // Priority Chip
                  _PriorityChip(
                    priority: priority,
                    textTheme: textTheme,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(width: 8),
                  // Created Date
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(createdAt),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(TicketStatusTheme theme, TicketStatus status) {
    switch (status) {
      case TicketStatus.new_:
        return theme.statusNew;
      case TicketStatus.inProgress:
        return theme.statusInProgress;
      case TicketStatus.resolved:
        return theme.statusResolved;
      case TicketStatus.error:
        return theme.statusError;
    }
  }

  String _getStatusLabel(TicketStatus status) {
    switch (status) {
      case TicketStatus.new_:
        return 'New';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.resolved:
        return 'Resolved';
      case TicketStatus.error:
        return 'Overdue';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Status Badge widget - demonstrates using custom status colors
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
    required this.textTheme,
    required this.colorScheme,
  });

  final String label;
  final Color color;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    // Use theme's onSurface for proper contrast
    final textColor = colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Priority Chip widget - demonstrates using standard colorScheme colors
class _PriorityChip extends StatelessWidget {
  const _PriorityChip({
    required this.priority,
    required this.textTheme,
    required this.colorScheme,
  });

  final String priority;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    // Map priority to colorScheme colors (not hard-coded!)
    final priorityColor = _getPriorityColor(priority);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: priorityColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        priority.toUpperCase(),
        style: textTheme.labelSmall?.copyWith(
          color: priorityColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    // Use colorScheme colors, not hard-coded values
    switch (priority.toLowerCase()) {
      case 'high':
        return colorScheme.error;
      case 'medium':
        return colorScheme.tertiary;
      case 'low':
        return colorScheme.primary;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }
}

/// Enum for ticket status (for demonstration)
enum TicketStatus {
  new_,
  inProgress,
  resolved,
  error,
}
