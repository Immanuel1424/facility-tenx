class AnnouncementDto {
  const AnnouncementDto({
    required this.id,
    required this.company_id,
    required this.created_by_user_id,
    required this.title,
    required this.message,
    required this.category,
    required this.priority,
    required this.target_audience,
    this.target_roles,
    this.scheduled_at,
    this.expires_at,
    required this.is_published,
    this.published_at,
    this.metadata,
    required this.created_at,
    required this.updated_at,
  });

  final String id;
  final String company_id;
  final String created_by_user_id;
  final String title;
  final String message;
  final String category;
  final String priority;
  final String target_audience;
  final List<String>? target_roles;
  final String? scheduled_at;
  final String? expires_at;
  final bool is_published;
  final String? published_at;
  final Map<String, dynamic>? metadata;
  final String created_at;
  final String updated_at;

  factory AnnouncementDto.fromJson(Map<String, dynamic> json) {
    return AnnouncementDto(
      id: json['id'] as String,
      company_id: (json['company_id'] ?? json['companyId']) as String,
      created_by_user_id:
          (json['created_by_user_id'] ?? json['createdByUserId']) as String,
      title: json['title'] as String,
      message: json['message'] as String,
      category: json['category'] as String,
      priority: json['priority'] as String,
      target_audience:
          (json['target_audience'] ?? json['targetAudience']) as String,
      target_roles: (json['target_roles'] ?? json['targetRoles']) != null
          ? List<String>.from(
              (json['target_roles'] ?? json['targetRoles']) as List,
            )
          : null,
      scheduled_at: (json['scheduled_at'] ?? json['scheduledAt']) as String?,
      expires_at: (json['expires_at'] ?? json['expiresAt']) as String?,
      is_published: (json['is_published'] ?? json['isPublished']) as bool,
      published_at: (json['published_at'] ?? json['publishedAt']) as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      created_at: (json['created_at'] ?? json['createdAt']) as String,
      updated_at: (json['updated_at'] ?? json['updatedAt']) as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': company_id,
      'created_by_user_id': created_by_user_id,
      'title': title,
      'message': message,
      'category': category,
      'priority': priority,
      'target_audience': target_audience,
      if (target_roles != null) 'target_roles': target_roles,
      if (scheduled_at != null) 'scheduled_at': scheduled_at,
      if (expires_at != null) 'expires_at': expires_at,
      'is_published': is_published,
      if (published_at != null) 'published_at': published_at,
      if (metadata != null) 'metadata': metadata,
      'created_at': created_at,
      'updated_at': updated_at,
    };
  }
}

class PaginatedAnnouncementsResponseDto {
  const PaginatedAnnouncementsResponseDto({
    required this.data,
    required this.total,
  });

  final List<AnnouncementDto> data;
  final int total;

  factory PaginatedAnnouncementsResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return PaginatedAnnouncementsResponseDto(
      data: dataList
          .map((item) => AnnouncementDto.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
    );
  }
}

