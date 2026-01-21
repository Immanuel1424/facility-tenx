import 'package:equatable/equatable.dart';

enum AnnouncementCategory {
  maintenance,
  emergency,
  general,
  info;

  static AnnouncementCategory fromString(String value) {
    return AnnouncementCategory.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => AnnouncementCategory.general,
    );
  }

  String get displayName {
    switch (this) {
      case AnnouncementCategory.maintenance:
        return 'Maintenance';
      case AnnouncementCategory.emergency:
        return 'Emergency';
      case AnnouncementCategory.general:
        return 'General';
      case AnnouncementCategory.info:
        return 'Info';
    }
  }
}

enum AnnouncementPriority {
  low,
  medium,
  high,
  urgent;

  static AnnouncementPriority fromString(String value) {
    return AnnouncementPriority.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => AnnouncementPriority.medium,
    );
  }

  String get displayName {
    switch (this) {
      case AnnouncementPriority.low:
        return 'Low';
      case AnnouncementPriority.medium:
        return 'Medium';
      case AnnouncementPriority.high:
        return 'High';
      case AnnouncementPriority.urgent:
        return 'Urgent';
    }
  }
}

enum AnnouncementTargetAudience {
  all,
  roles;

  static AnnouncementTargetAudience fromString(String value) {
    return AnnouncementTargetAudience.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => AnnouncementTargetAudience.all,
    );
  }
}

class AnnouncementEntity extends Equatable {
  const AnnouncementEntity({
    required this.id,
    required this.companyId,
    required this.createdByUserId,
    required this.title,
    required this.message,
    required this.category,
    required this.priority,
    required this.targetAudience,
    this.targetRoles,
    this.scheduledAt,
    this.expiresAt,
    required this.isPublished,
    this.publishedAt,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String companyId;
  final String createdByUserId;
  final String title;
  final String message;
  final AnnouncementCategory category;
  final AnnouncementPriority priority;
  final AnnouncementTargetAudience targetAudience;
  final List<String>? targetRoles;
  final DateTime? scheduledAt;
  final DateTime? expiresAt;
  final bool isPublished;
  final DateTime? publishedAt;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        companyId,
        createdByUserId,
        title,
        message,
        category,
        priority,
        targetAudience,
        targetRoles,
        scheduledAt,
        expiresAt,
        isPublished,
        publishedAt,
        metadata,
        createdAt,
        updatedAt,
      ];
}

