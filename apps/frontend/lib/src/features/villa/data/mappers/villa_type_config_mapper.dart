import '../dto/villa_type_config_dto.dart';
import '../../domain/entities/villa_type_config_entity.dart';

class VillaTypeConfigMapper {
  static VillaTypeConfigEntity dtoToEntity(VillaTypeConfigDto dto) {
    return VillaTypeConfigEntity(
      id: dto.id,
      villaType: dto.villaType,
      displayName: dto.displayName,
      defaultBedroomCount: dto.defaultBedroomCount,
      defaultFloorCount: dto.defaultFloorCount,
      defaultAreaSqm: dto.defaultAreaSqm,
      displayOrder: dto.displayOrder,
      isActive: dto.isActive,
      metadata: dto.metadata,
      companyId: dto.companyId,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }
}

