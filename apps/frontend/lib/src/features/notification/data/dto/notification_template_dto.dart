class NotificationTemplateDto {
  NotificationTemplateDto({
    required this.id,
    required this.code,
    required this.channel,
    this.subject,
    required this.body,
    this.defaultVariables,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String code;
  final String channel;
  final String? subject;
  final String body;
  final Map<String, dynamic>? defaultVariables;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory NotificationTemplateDto.fromJson(Map<String, dynamic> json) {
    // Handle date parsing - backend might return ISO string or already parsed
    DateTime parseDate(dynamic dateValue) {
      if (dateValue is String) {
        return DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        return dateValue;
      } else {
        // Fallback to current time if parsing fails
        return DateTime.now();
      }
    }

    return NotificationTemplateDto(
      id: json['id'] as String,
      code: json['code'] as String,
      channel: json['channel'] as String,
      subject: json['subject'] as String?,
      body: json['body'] as String,
      defaultVariables: json['defaultVariables'] != null
          ? Map<String, dynamic>.from(json['defaultVariables'] as Map)
          : null,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'channel': channel,
      'subject': subject,
      'body': body,
      'defaultVariables': defaultVariables,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'code': code,
      'channel': channel,
      'subject': subject,
      'body': body,
      'defaultVariables': defaultVariables,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'subject': subject,
      'body': body,
      'defaultVariables': defaultVariables,
    };
  }
}

