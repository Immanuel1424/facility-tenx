import 'package:equatable/equatable.dart';

enum NotificationSeverity {
  info,
  warning,
  error,
  success,
}

enum NotificationChannel {
  inApp,
  email,
  sms,
  push,
  whatsapp,
}

class NotificationEntity extends Equatable {
  const NotificationEntity({
    required this.id,
    this.companyId,
    this.recipientUserId,
    required this.type,
    this.severity = NotificationSeverity.info,
    this.title,
    required this.message,
    this.payload,
    this.isRead = false,
    this.readAt,
    this.channels = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String? companyId;
  final String? recipientUserId;
  final String type;
  final NotificationSeverity severity;
  final String? title;
  final String message;
  final Map<String, dynamic>? payload;
  final bool isRead;
  final DateTime? readAt;
  final List<NotificationChannel> channels;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        companyId,
        recipientUserId,
        type,
        severity,
        title,
        message,
        payload,
        isRead,
        readAt,
        channels,
        createdAt,
        updatedAt,
      ];
}

