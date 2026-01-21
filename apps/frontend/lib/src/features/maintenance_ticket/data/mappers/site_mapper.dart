import '../../domain/entities/site_entity.dart';
import '../dto/maintenance_ticket_dto.dart';

class SiteMapper {
  static SiteEntity? toEntity(SiteDto? dto) {
    if (dto == null) return null;

    return SiteEntity(
      id: dto.id ?? 'UNKNOWN_ID',
      code: dto.code,
      name: dto.name,
      description: dto.description,
      companyId: dto.company_id,
      isParent: dto.is_parent ?? true,
      isActive: dto.is_active ?? true,
    );
  }
}
