import 'package:equatable/equatable.dart';

abstract class VillaEvent extends Equatable {
  const VillaEvent();

  @override
  List<Object?> get props => [];
}

class LoadVillaList extends VillaEvent {
  const LoadVillaList();
}

class LoadActiveVillaList extends VillaEvent {
  const LoadActiveVillaList();
}

class LoadAvailableVillaList extends VillaEvent {
  const LoadAvailableVillaList();
}

class LoadVillaDetail extends VillaEvent {
  const LoadVillaDetail(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class CreateVilla extends VillaEvent {
  const CreateVilla({
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
    this.isActive,
    this.isOccupied,
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
  });

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
  final bool? isActive;
  final bool? isOccupied;
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

  @override
  List<Object?> get props => [
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
      ];
}

class UpdateVilla extends VillaEvent {
  const UpdateVilla({
    required this.id,
    this.villaNumber,
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
    this.isActive,
    this.isOccupied,
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
  });

  final String id;
  final String? villaNumber;
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
  final bool? isActive;
  final bool? isOccupied;
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
      ];
}

class DeleteVilla extends VillaEvent {
  const DeleteVilla(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class ActivateVilla extends VillaEvent {
  const ActivateVilla(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class DeactivateVilla extends VillaEvent {
  const DeactivateVilla(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

