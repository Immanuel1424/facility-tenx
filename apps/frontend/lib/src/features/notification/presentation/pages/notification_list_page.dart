import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/role_access_control.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/repositories/notification_repository.dart';
import '../../domain/entities/notification_entity.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';

class NotificationListPage extends StatelessWidget {
  const NotificationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Try to reuse existing NotificationBloc from parent (e.g., dashboard route)
    // If not available, create a new one
    try {
      final existingBloc = BlocProvider.of<NotificationBloc>(context);
      // Bloc exists, use it and refresh notifications
      existingBloc.add(const LoadNotificationList());
      return const _NotificationListContent();
    } catch (_) {
      // No existing bloc, create new one
      return BlocProvider(
        create: (context) => NotificationBloc(
          repository: getIt<NotificationRepository>(),
        )..add(const LoadNotificationList()),
        child: const _NotificationListContent(),
      );
    }
  }
}

class _NotificationListContent extends StatelessWidget {
  const _NotificationListContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.done_all),
                onPressed: () {
                  context.read<NotificationBloc>().add(
                        const MarkAllNotificationsAsRead(),
                      );
                },
                tooltip: 'Mark all as read',
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          state.maybeWhen(
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: Colors.red,
                ),
              );
            },
            markedAsRead: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notification marked as read'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            listLoaded: (notifications) {
              if (notifications.isEmpty) {
                return const Center(
                  child: Text('No notifications'),
                );
              }

              final unreadCount = notifications.where((n) => !n.isRead).length;

              return Column(
                children: [
                  if (unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.blue.shade50,
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            '$unreadCount unread notification${unreadCount > 1 ? 's' : ''}',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              context.read<NotificationBloc>().add(
                                    const MarkAllNotificationsAsRead(),
                                  );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blue.shade700,
                            ),
                            child: const Text('Mark as read'),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return _NotificationListItem(
                          notification: notification,
                          onTap: () {
                            // Mark as read if unread
                            if (!notification.isRead) {
                              context.read<NotificationBloc>().add(
                                    MarkNotificationAsRead(notification.id),
                                  );
                            }

                            // Navigate to ticket details if ticketId is present in payload
                            final ticketId = notification.payload?['ticketId'] as String?;
                            if (ticketId != null && ticketId.isNotEmpty) {
                              // Determine user role to route to appropriate page
                              final authState = context.read<AuthBloc>().state;
                              final isTenant = authState.maybeWhen(
                                    authenticated: (user) =>
                                        RoleAccessControl.isTenant(user),
                                    orElse: () => false,
                                  ) ??
                                  false;

                              // Navigate to appropriate ticket detail page
                              if (isTenant) {
                                context.push('/tenant/complaints/$ticketId');
                              } else {
                                context.push('/maintenance-tickets/$ticketId');
                              }
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
            markedAsRead: (_) => const SizedBox.shrink(),
            error: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: $message',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<NotificationBloc>().add(
                            const LoadNotificationList(),
                          );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationListItem extends StatelessWidget {
  const _NotificationListItem({
    required this.notification,
    this.onTap,
  });

  final NotificationEntity notification;
  final VoidCallback? onTap;

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

  @override
  Widget build(BuildContext context) {
    final severityColor = _getSeverityColor(notification.severity);
    final severityIcon = _getSeverityIcon(notification.severity);

    return Card(
      color: notification.isRead ? null : severityColor.withValues(alpha: 0.1),
      child: ListTile(
        leading: Icon(severityIcon, color: severityColor),
        title: Text(
          notification.title ?? notification.type,
          style: TextStyle(
            fontWeight:
                notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: 4),
            Text(
              _formatDateTime(notification.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
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
        onTap: onTap,
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
