import '../../domain/entities/site_entity.dart';
import '../dto/site_dto.dart';

class SiteMapper {
  static SiteEntity toEntity(SiteDto dto) {
    return SiteEntity(
      id: dto.id,
      code: dto.code,
      name: dto.name,
      description: dto.description,
      address: dto.address,
      city: dto.city,
      country: dto.country,
      isParent: dto.isParent,
      isActive: dto.isActive,
      parentSiteId: dto.parentSiteId,
      companyId: dto.companyId,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  static List<SiteEntity> toEntityList(List<SiteDto> dtos) {
    return dtos.map((dto) => toEntity(dto)).toList();
  }
}

