import '../../domain/entities/announcement_entity.dart';
import '../dto/announcement_dto.dart';

class AnnouncementMapper {
  static AnnouncementEntity toEntity(AnnouncementDto dto) {
    return AnnouncementEntity(
      id: dto.id,
      companyId: dto.company_id,
      createdByUserId: dto.created_by_user_id,
      title: dto.title,
      message: dto.message,
      category: AnnouncementCategory.fromString(dto.category),
      priority: AnnouncementPriority.fromString(dto.priority),
      targetAudience: AnnouncementTargetAudience.fromString(dto.target_audience),
      targetRoles: dto.target_roles,
      scheduledAt: dto.scheduled_at != null
          ? DateTime.parse(dto.scheduled_at!)
          : null,
      expiresAt:
          dto.expires_at != null ? DateTime.parse(dto.expires_at!) : null,
      isPublished: dto.is_published,
      publishedAt: dto.published_at != null
          ? DateTime.parse(dto.published_at!)
          : null,
      metadata: dto.metadata,
      createdAt: DateTime.parse(dto.created_at),
      updatedAt: DateTime.parse(dto.updated_at),
    );
  }

  static List<AnnouncementEntity> toEntityList(List<AnnouncementDto> dtos) {
    return dtos.map((dto) => toEntity(dto)).toList();
  }
}

