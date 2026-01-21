import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/maintenance_ticket_entity.dart';

class MaintenanceTicketPriorityChip extends StatelessWidget {
  const MaintenanceTicketPriorityChip({
    super.key,
    required this.priority,
    this.priorityDetails,
    this.showIcon = false,
  });

  final TicketPriority priority;
  final PriorityDetailsEntity? priorityDetails;
  final bool showIcon;

  Color _getPriorityColor() {
    // Use color from API if available, otherwise fallback to defaults
    if (priorityDetails?.colorCode != null) {
      try {
        return Color(
          int.parse(
            priorityDetails!.colorCode!.replaceFirst('#', '0xFF'),
          ),
        );
      } catch (e) {
        // If parsing fails, fallback to defaults
      }
    }
    // Fallback to theme colors if API data not available
    switch (priority) {
      case TicketPriority.low:
        return AppColors.success;
      case TicketPriority.medium:
        return AppColors.primary;
      case TicketPriority.high:
        return AppColors.warning;
      case TicketPriority.urgent:
        return AppColors.destructive;
    }
  }

  IconData _getPriorityIcon() {
    // Use icon from API if available
    if (priorityDetails?.iconName != null) {
      // Map Material icon names to IconData
      switch (priorityDetails!.iconName!.toLowerCase()) {
        case 'arrow_upward':
          return Icons.arrow_upward;
        case 'arrow_downward':
          return Icons.arrow_downward;
        case 'remove':
          return Icons.remove;
        case 'priority_high':
          return Icons.priority_high;
        default:
          break;
      }
    }
    // Fallback to defaults
    switch (priority) {
      case TicketPriority.low:
        return Icons.arrow_downward;
      case TicketPriority.medium:
        return Icons.remove;
      case TicketPriority.high:
        return Icons.arrow_upward;
      case TicketPriority.urgent:
        return Icons.priority_high;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getPriorityColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(_getPriorityIcon(), color: color, size: 16),
            const SizedBox(width: 4),
          ],
          Text(
            priority.displayName,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
