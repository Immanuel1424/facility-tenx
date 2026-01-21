class CreateAnnouncementDto {
  const CreateAnnouncementDto({
    required this.title,
    required this.message,
    required this.category,
    required this.priority,
    required this.target_audience,
    this.target_roles,
    this.scheduled_at,
    this.expires_at,
    this.publish_immediately,
  });

  final String title;
  final String message;
  final String category;
  final String priority;
  final String target_audience;
  final List<String>? target_roles;
  final String? scheduled_at;
  final String? expires_at;
  final bool? publish_immediately;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'message': message,
      'category': category,
      'priority': priority,
      'targetAudience': target_audience,
      if (target_roles != null && target_roles!.isNotEmpty)
        'targetRoles': target_roles,
      if (scheduled_at != null) 'scheduledAt': scheduled_at,
      if (expires_at != null) 'expiresAt': expires_at,
      if (publish_immediately != null)
        'publishImmediately': publish_immediately,
    };
  }
}

