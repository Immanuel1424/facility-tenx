import '../../domain/entities/space_entity.dart';
import '../dto/maintenance_ticket_dto.dart';

class SpaceMapper {
  static SpaceEntity? toEntity(SpaceDto? dto) {
    if (dto == null) return null;

    return SpaceEntity(
      id: dto.id ?? 'UNKNOWN_ID',
      code: dto.code,
      name: dto.name,
      description: dto.description,
      siteId: dto.site_id,
      isActive: dto.is_active ?? true,
    );
  }
}
