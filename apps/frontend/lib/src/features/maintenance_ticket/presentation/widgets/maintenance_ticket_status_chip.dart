import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/maintenance_ticket_entity.dart';

class MaintenanceTicketStatusChip extends StatelessWidget {
  const MaintenanceTicketStatusChip({
    super.key,
    required this.status,
  });

  final TicketStatus status;

  Color _getStatusColor(BuildContext context) {
    final statusTheme = context.ticketStatusTheme;
    switch (status) {
      case TicketStatus.new_:
        return statusTheme.statusNew;
      case TicketStatus.acknowledged:
        return statusTheme.statusInProgress; // Use warning color
      case TicketStatus.assigned:
        return statusTheme.statusNew; // Use primary blue
      case TicketStatus.inProgress:
        return statusTheme.statusInProgress;
      case TicketStatus.onHold:
        return statusTheme.statusInProgress; // Use warning color
      case TicketStatus.completed:
        return statusTheme.statusResolved;
      case TicketStatus.cancelled:
        return statusTheme.statusError;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
