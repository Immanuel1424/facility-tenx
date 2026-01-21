import 'package:flutter/material.dart';
import '../../../notification/domain/entities/notification_entity.dart';

class DashboardNotificationItem extends StatelessWidget {
  const DashboardNotificationItem({
    super.key,
    required this.notification,
  });

  final NotificationEntity notification;

  Color _getSeverityColor(NotificationSeverity severity) {
    switch (severity) {
      case NotificationSeverity.info:
        return Colors.blue;
      case NotificationSeverity.warning:
        return Colors.orange;
      case NotificationSeverity.error:
        return Colors.red;
      case NotificationSeverity.success:
        return Colors.green;
    }
  }

  IconData _getSeverityIcon(NotificationSeverity severity) {
    switch (severity) {
      case NotificationSeverity.info:
        return Icons.info;
      case NotificationSeverity.warning:
        return Icons.warning;
      case NotificationSeverity.error:
        return Icons.error;
      case NotificationSeverity.success:
        return Icons.check_circle;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final severityColor = _getSeverityColor(notification.severity);
    final severityIcon = _getSeverityIcon(notification.severity);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: notification.isRead ? null : severityColor.withValues(alpha: 0.05),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
        leading: Icon(severityIcon, color: severityColor, size: 20),
        title: Text(
          notification.title ?? notification.type,
          style: TextStyle(
            fontSize: 13,
            fontWeight:
                notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: const TextStyle(fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _formatDateTime(notification.createdAt),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: severityColor,
                  shape: BoxShape.circle,
                ),
              ),
      ),
    );
  }
}
