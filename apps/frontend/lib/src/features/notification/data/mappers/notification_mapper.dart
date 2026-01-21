import '../../domain/entities/notification_entity.dart';
import '../dto/notification_dto.dart';

class NotificationMapper {
  static NotificationEntity dtoToEntity(NotificationDto dto) {
    return NotificationEntity(
      id: dto.id,
      companyId: dto.companyId,
      recipientUserId: dto.recipientUserId,
      type: dto.type,
      severity: _parseSeverity(dto.severity),
      title: dto.title,
      message: dto.message,
      payload: dto.payload,
      isRead: dto.isRead,
      readAt: dto.readAt,
      channels: dto.channels.map(_parseChannel).toList(),
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  static NotificationSeverity _parseSeverity(String severity) {
    switch (severity.toLowerCase()) {
      case 'info':
        return NotificationSeverity.info;
      case 'warning':
        return NotificationSeverity.warning;
      case 'error':
        return NotificationSeverity.error;
      case 'success':
        return NotificationSeverity.success;
      default:
        return NotificationSeverity.info;
    }
  }

  static NotificationChannel _parseChannel(String channel) {
    switch (channel.toLowerCase()) {
      case 'in_app':
        return NotificationChannel.inApp;
      case 'email':
        return NotificationChannel.email;
      case 'sms':
        return NotificationChannel.sms;
      case 'push':
        return NotificationChannel.push;
      case 'whatsapp':
        return NotificationChannel.whatsapp;
      default:
        return NotificationChannel.inApp;
    }
  }
}

