class NotificationDto {
  NotificationDto({
    required this.id,
    this.companyId,
    this.recipientUserId,
    required this.type,
    required this.severity,
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
  final String severity;
  final String? title;
  final String message;
  final Map<String, dynamic>? payload;
  final bool isRead;
  final DateTime? readAt;
  final List<String> channels;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    if (normalized.containsKey('company_id')) {
      normalized['companyId'] = normalized['company_id'];
    }
    if (normalized.containsKey('recipient_user_id')) {
      normalized['recipientUserId'] = normalized['recipient_user_id'];
    }
    if (normalized.containsKey('is_read')) {
      normalized['isRead'] = normalized['is_read'];
    }
    if (normalized.containsKey('read_at')) {
      normalized['readAt'] = normalized['read_at'];
    }
    if (normalized.containsKey('created_at')) {
      normalized['createdAt'] = normalized['created_at'];
    }
    if (normalized.containsKey('updated_at')) {
      normalized['updatedAt'] = normalized['updated_at'];
    }
    return NotificationDto(
      id: normalized['id'] as String,
      companyId: normalized['companyId'] as String?,
      recipientUserId: normalized['recipientUserId'] as String?,
      type: normalized['type'] as String,
      severity: normalized['severity'] as String,
      title: normalized['title'] as String?,
      message: normalized['message'] as String,
      payload: normalized['payload'] as Map<String, dynamic>?,
      isRead: normalized['isRead'] as bool? ?? false,
      readAt: normalized['readAt'] != null
          ? DateTime.parse(normalized['readAt'] as String)
          : null,
      channels: (normalized['channels'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: DateTime.parse(normalized['createdAt'] as String),
      updatedAt: DateTime.parse(normalized['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'company_id': companyId,
        'recipient_user_id': recipientUserId,
        'type': type,
        'severity': severity,
        'title': title,
        'message': message,
        'payload': payload,
        'is_read': isRead,
        'read_at': readAt?.toIso8601String(),
        'channels': channels,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
