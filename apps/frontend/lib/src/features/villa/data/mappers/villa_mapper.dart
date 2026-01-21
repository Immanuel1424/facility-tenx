import '../dto/villa_dto.dart';
import '../../domain/entities/villa_entity.dart';

class VillaMapper {
  static VillaEntity toEntity(VillaDto dto) {
    return VillaEntity(
      id: dto.id,
      villaNumber: dto.villaNumber,
      villaCode: dto.villaCode,
      siteId: dto.siteId,
      spaceId: dto.spaceId,
      ownerName: dto.ownerName,
      tenantName: dto.tenantName,
      contactPhone: dto.contactPhone,
      contactEmail: dto.contactEmail,
      block: dto.block,
      street: dto.street,
      city: dto.city,
      pinCode: dto.pinCode,
      makaniNumber: dto.makaniNumber,
      poBox: dto.poBox,
      isActive: dto.isActive,
      isOccupied: dto.isOccupied,
      floorCount: dto.floorCount,
      bedroomCount: dto.bedroomCount,
      bathroomCount: dto.bathroomCount,
      areaSqm: dto.areaSqm,
      villaType: dto.villaType,
      buildingName: dto.buildingName,
      openFrom: dto.openFrom,
      unitNo: dto.unitNo,
      unitName: dto.unitName,
      primaryView: dto.primaryView,
      unitCategory: dto.unitCategory,
      floor: dto.floor,
      parkingSlotNumber: dto.parkingSlotNumber,
      meterNumber: dto.meterNumber,
      waterMeterNumber: dto.waterMeterNumber,
      measure: dto.measure,
      externalArea: dto.externalArea,
      remarks: dto.remarks,
      metadata: dto.metadata,
      companyId: dto.companyId,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  static List<VillaEntity> toEntityList(List<VillaDto> dtos) {
    return dtos.map(toEntity).toList();
  }
}

