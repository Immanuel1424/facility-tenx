import 'package:flutter/material.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/maintenance_ticket_entity.dart';

/// Beautiful, reusable status timeline widget with horizontal layout
/// Shows the complete lifecycle of a maintenance ticket with visual indicators
class StatusTimelineWidget extends StatelessWidget {
  const StatusTimelineWidget({
    super.key,
    required this.ticket,
    this.showDates = true,
    this.compact = true, // Default to compact mode
  });

  final MaintenanceTicketEntity ticket;
  final bool showDates;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final statusesList = _buildStatusList(context, ticket);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use same breakpoint as ResponsiveLayout (768px)
        final isWeb = constraints.maxWidth >= 768.0;
        final isDesktop = constraints.maxWidth >= 1200.0;

        // Use larger sizes for web/desktop
        final effectiveCompact = isWeb ? false : compact;
        final effectiveShowDates = isWeb ? true : showDates;

        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: isWeb ? 16 : 8,
            horizontal: isWeb ? 8 : 0,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: statusesList.asMap().entries.map((entry) {
                final index = entry.key;
                final statusData = entry.value;
                final isLast = index == statusesList.length - 1;

                return _buildHorizontalTimelineItem(
                  context,
                  statusData,
                  isLast,
                  effectiveCompact,
                  effectiveShowDates,
                  isWeb: isWeb,
                  isDesktop: isDesktop,
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHorizontalTimelineItem(
    BuildContext context,
    _TimelineStatusData statusData,
    bool isLast,
    bool compact,
    bool showDates, {
    bool isWeb = false,
    bool isDesktop = false,
  }) {
    final spacing = isDesktop ? 24.0 : (isWeb ? 16.0 : 4.0);
    final lineWidth = isDesktop ? 40.0 : (isWeb ? 32.0 : 16.0);
    final lineHeight = isWeb ? 3.0 : 2.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Indicator and content
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicator
            _buildIndicator(
              context,
              statusData.icon,
              statusData.isCompleted,
              statusData.isActive,
              statusData.color,
              compact,
              isWeb: isWeb,
              isDesktop: isDesktop,
            ),
            SizedBox(height: isWeb ? 12 : 6),
            // Status content
            _buildHorizontalStatusContent(
              context,
              statusData,
              compact,
              showDates,
              isWeb: isWeb,
              isDesktop: isDesktop,
            ),
          ],
        ),
        // Connector line
        if (!isLast)
          Padding(
            padding: EdgeInsets.only(
              top: isWeb ? 20 : 12,
              left: spacing / 2,
              right: spacing / 2,
            ),
            child: Container(
              width: lineWidth,
              height: lineHeight,
              decoration: BoxDecoration(
                color: statusData.isCompleted
                    ? statusData.color
                    : Theme.of(context).colorScheme.outline.withValues(
                          alpha: 0.2,
                        ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildIndicator(
    BuildContext context,
    IconData icon,
    bool isCompleted,
    bool isActive,
    Color color,
    bool compact, {
    bool isWeb = false,
    bool isDesktop = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    // Use green for active status
    final activeColor = Colors.green;

    final size = isDesktop ? 32.0 : (isWeb ? 28.0 : 20.0);
    final borderWidth = isActive ? (isWeb ? 3.0 : 2.0) : (isWeb ? 2.0 : 1.5);
    final shadowBlur = isWeb ? 6.0 : 4.0;
    final shadowSpread = isWeb ? 2.0 : 1.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted
            ? color
            : isActive
                ? activeColor
                : colorScheme.surfaceContainerHighest,
        border: Border.all(
          color: isCompleted
              ? color
              : isActive
                  ? activeColor
                  : colorScheme.outline.withValues(alpha: 0.3),
          width: borderWidth,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: activeColor.withValues(alpha: 0.3),
                  blurRadius: shadowBlur,
                  spreadRadius: shadowSpread,
                ),
              ]
            : null,
      ),
      // Show icon on web/desktop for better visibility
      child: isWeb
          ? Icon(
              icon,
              size: isDesktop ? 18 : 16,
              color: isCompleted || isActive
                  ? Colors.white
                  : colorScheme.onSurfaceVariant,
            )
          : null,
    );
  }

  Widget _buildHorizontalStatusContent(
    BuildContext context,
    _TimelineStatusData statusData,
    bool compact,
    bool showDates, {
    bool isWeb = false,
    bool isDesktop = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCompleted = statusData.isCompleted;
    final isActive = statusData.isActive;

    final labelFontSize = isDesktop ? 14.0 : (isWeb ? 13.0 : 10.0);
    final dateFontSize = isDesktop ? 11.0 : (isWeb ? 10.0 : 8.0);
    final maxWidth = isDesktop ? 120.0 : (isWeb ? 100.0 : 70.0);

    final labelWidget = Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Text(
        statusData.label,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight:
                  isActive || isCompleted ? FontWeight.w600 : FontWeight.w500,
              color: isActive || isCompleted
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontSize: labelFontSize,
            ),
      ),
    );

    if (!showDates || statusData.date == null) {
      return labelWidget;
    }

    final dateText = isDesktop
        ? DateFormatter.formatDate(statusData.date!)
        : DateFormatter.formatDateCompact(statusData.date!);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        labelWidget,
        SizedBox(height: isWeb ? 6 : 4),
        Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Text(
            dateText,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: dateFontSize,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
          ),
        ),
      ],
    );
  }

  List<_TimelineStatusData> _buildStatusList(
    BuildContext context,
    MaintenanceTicketEntity ticket,
  ) {
    final statuses = <_TimelineStatusData>[];

    // NEW
    statuses.add(
      _TimelineStatusData(
        label: 'New',
        description: null, // Hide description in compact mode
        icon: Icons.new_releases_rounded,
        isActive: ticket.status == TicketStatus.new_,
        isCompleted: _isStatusCompleted(ticket.status, TicketStatus.new_),
        date: ticket.createdAt,
        color: Colors.blue,
      ),
    );

    // ACKNOWLEDGED
    statuses.add(
      _TimelineStatusData(
        label: 'Acknowledged',
        description: null, // Hide description in compact mode
        icon: Icons.check_circle_outline_rounded,
        isActive: ticket.status == TicketStatus.acknowledged,
        isCompleted:
            _isStatusCompleted(ticket.status, TicketStatus.acknowledged),
        date: ticket.acknowledgedAt,
        color: Colors.cyan,
      ),
    );

    // ASSIGNED
    statuses.add(
      _TimelineStatusData(
        label: 'Assigned',
        description: null, // Hide description in compact mode
        icon: Icons.assignment_rounded,
        isActive: ticket.status == TicketStatus.assigned,
        isCompleted: _isStatusCompleted(ticket.status, TicketStatus.assigned),
        date: ticket.assignedAt,
        color: Colors.orange,
      ),
    );

    // IN_PROGRESS
    statuses.add(
      _TimelineStatusData(
        label: 'In Progress',
        description: null, // Hide description in compact mode
        icon: Icons.build_rounded,
        isActive: ticket.status == TicketStatus.inProgress,
        isCompleted: _isStatusCompleted(ticket.status, TicketStatus.inProgress),
        date: null,
        color: Colors.deepPurple,
      ),
    );

    // ON_HOLD (optional, only if ticket has been on hold)
    if (ticket.status == TicketStatus.onHold ||
        _isStatusCompleted(ticket.status, TicketStatus.onHold)) {
      statuses.add(
        _TimelineStatusData(
          label: 'On Hold',
          description: 'Ticket is temporarily paused',
          icon: Icons.pause_circle_outline_rounded,
          isActive: ticket.status == TicketStatus.onHold,
          isCompleted: _isStatusCompleted(ticket.status, TicketStatus.onHold),
          date: null,
          color: Colors.amber,
        ),
      );
    }

    // COMPLETED
    statuses.add(
      _TimelineStatusData(
        label: 'Completed',
        description: null, // Hide description in compact mode
        icon: Icons.check_circle_rounded,
        isActive: ticket.status == TicketStatus.completed,
        isCompleted: _isStatusCompleted(ticket.status, TicketStatus.completed),
        date: ticket.completedAt,
        color: Colors.green,
      ),
    );

    // CANCELLED (only if cancelled)
    if (ticket.status == TicketStatus.cancelled) {
      statuses.add(
        _TimelineStatusData(
          label: 'Cancelled',
          description: 'Ticket has been cancelled',
          icon: Icons.cancel_rounded,
          isActive: true,
          isCompleted: true,
          date: ticket.closedAt,
          color: Colors.red,
        ),
      );
    }

    return statuses;
  }

  bool _isStatusCompleted(TicketStatus current, TicketStatus target) {
    final statusOrder = [
      TicketStatus.new_,
      TicketStatus.acknowledged,
      TicketStatus.assigned,
      TicketStatus.inProgress,
      TicketStatus.onHold,
      TicketStatus.completed,
      TicketStatus.cancelled,
    ];

    final currentIndex = statusOrder.indexOf(current);
    final targetIndex = statusOrder.indexOf(target);

    return currentIndex > targetIndex;
  }
}

class _TimelineStatusData {
  const _TimelineStatusData({
    required this.label,
    this.description,
    required this.icon,
    required this.isActive,
    required this.isCompleted,
    this.date,
    required this.color,
  });

  final String label;
  final String? description;
  final IconData icon;
  final bool isActive;
  final bool isCompleted;
  final DateTime? date;
  final Color color;
}
