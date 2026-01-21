import 'package:equatable/equatable.dart';

class VillaEntity extends Equatable {
  const VillaEntity({
    required this.id,
    required this.villaNumber,
    this.villaCode,
    this.siteId,
    this.spaceId,
    this.ownerName,
    this.tenantName,
    this.contactPhone,
    this.contactEmail,
    this.block,
    this.street,
    this.city,
    this.pinCode,
    this.makaniNumber,
    this.poBox,
    required this.isActive,
    required this.isOccupied,
    this.floorCount,
    this.bedroomCount,
    this.bathroomCount,
    this.areaSqm,
    this.villaType,
    this.buildingName,
    this.openFrom,
    this.unitNo,
    this.unitName,
    this.primaryView,
    this.unitCategory,
    this.floor,
    this.parkingSlotNumber,
    this.meterNumber,
    this.waterMeterNumber,
    this.measure,
    this.externalArea,
    this.remarks,
    this.metadata,
    required this.companyId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String villaNumber;
  final String? villaCode;
  final String? siteId;
  final String? spaceId;
  final String? ownerName;
  final String? tenantName;
  final String? contactPhone;
  final String? contactEmail;
  final String? block;
  final String? street;
  final String? city;
  final String? pinCode;
  final String? makaniNumber;
  final String? poBox;
  final bool isActive;
  final bool isOccupied;
  final int? floorCount;
  final int? bedroomCount;
  final int? bathroomCount;
  final double? areaSqm;
  final String? villaType;
  final String? buildingName;
  final DateTime? openFrom;
  final String? unitNo;
  final String? unitName;
  final String? primaryView;
  final String? unitCategory;
  final String? floor;
  final String? parkingSlotNumber;
  final String? meterNumber;
  final String? waterMeterNumber;
  final String? measure;
  final String? externalArea;
  final String? remarks;
  final Map<String, dynamic>? metadata;
  final String companyId;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        villaNumber,
        villaCode,
        siteId,
        spaceId,
        ownerName,
        tenantName,
        contactPhone,
        contactEmail,
        block,
        street,
        city,
        pinCode,
        makaniNumber,
        poBox,
        isActive,
        isOccupied,
        floorCount,
        bedroomCount,
        bathroomCount,
        areaSqm,
        villaType,
        buildingName,
        openFrom,
        unitNo,
        unitName,
        primaryView,
        unitCategory,
        floor,
        parkingSlotNumber,
        meterNumber,
        waterMeterNumber,
        measure,
        externalArea,
        remarks,
        metadata,
        companyId,
        createdAt,
        updatedAt,
      ];
}

