import 'package:flutter/material.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/entities/escalation_history_entity.dart';
import '../../domain/repositories/maintenance_ticket_repository_interface.dart';

/// Widget to display escalation history for a ticket
class EscalationHistoryWidget extends StatefulWidget {
  const EscalationHistoryWidget({
    super.key,
    required this.ticketId,
  });

  final String ticketId;

  @override
  State<EscalationHistoryWidget> createState() =>
      _EscalationHistoryWidgetState();
}

class _EscalationHistoryWidgetState extends State<EscalationHistoryWidget> {
  List<EscalationHistoryEntity> _history = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repository = getIt<MaintenanceTicketRepositoryInterface>();
      final result = await repository.getEscalationHistory(widget.ticketId);

      result.fold(
        (error) {
          if (mounted) {
            setState(() {
              _error = error;
              _isLoading = false;
            });
          }
        },
        (history) {
          if (mounted) {
            setState(() {
              _history = history;
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to load escalation history',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadHistory,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_history.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              Icons.timeline_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              'No escalation history',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _history.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final entry = _history[index];
        return _buildHistoryItem(context, entry);
      },
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    EscalationHistoryEntity entry,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isWeb = MediaQuery.of(context).size.width >= 768;

    // Determine color based on escalation level
    Color levelColor;
    IconData levelIcon;
    switch (entry.escalationLevel) {
      case 1:
        levelColor = Colors.orange;
        levelIcon = Icons.trending_up;
        break;
      case 2:
        levelColor = Colors.deepOrange;
        levelIcon = Icons.trending_up;
        break;
      case 3:
        levelColor = Colors.red;
        levelIcon = Icons.priority_high;
        break;
      default:
        levelColor = colorScheme.primary;
        levelIcon = Icons.info;
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isWeb ? 16.0 : 12.0,
        vertical: isWeb ? 12.0 : 8.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level indicator
          Container(
            width: isWeb ? 40 : 32,
            height: isWeb ? 40 : 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: levelColor.withValues(alpha: 0.1),
              border: Border.all(
                color: levelColor,
                width: 2,
              ),
            ),
            child: Icon(
              levelIcon,
              size: isWeb ? 20 : 16,
              color: levelColor,
            ),
          ),
          SizedBox(width: isWeb ? 16 : 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.escalationLevelDisplay,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: levelColor,
                            ),
                      ),
                    ),
                    // Automatic/Manual badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWeb ? 8 : 6,
                        vertical: isWeb ? 4 : 2,
                      ),
                      decoration: BoxDecoration(
                        color: entry.isAutomatic
                            ? Colors.blue.withValues(alpha: 0.1)
                            : Colors.purple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        entry.escalationType,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: entry.isAutomatic
                                  ? Colors.blue
                                  : Colors.purple,
                              fontWeight: FontWeight.w500,
                              fontSize: isWeb ? 11 : 9,
                            ),
                      ),
                    ),
                  ],
                ),
                if (entry.escalatedToRole != null) ...[
                  SizedBox(height: isWeb ? 4 : 2),
                  Text(
                    'Escalated to: ${entry.escalatedToRole}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
                if (entry.reason != null && entry.reason!.isNotEmpty) ...[
                  SizedBox(height: isWeb ? 4 : 2),
                  Text(
                    entry.reason!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
                SizedBox(height: isWeb ? 4 : 2),
                Text(
                  DateFormatter.formatDateTime(entry.escalatedAt),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        fontSize: isWeb ? 11 : 10,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
