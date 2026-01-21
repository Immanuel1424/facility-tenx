class VillaDto {
  const VillaDto({
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

  factory VillaDto.fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    
    // Normalize snake_case to camelCase
    if (normalized.containsKey('villa_number')) {
      normalized['villaNumber'] = normalized['villa_number'];
    }
    if (normalized.containsKey('villa_code')) {
      normalized['villaCode'] = normalized['villa_code'];
    }
    if (normalized.containsKey('site_id')) {
      normalized['siteId'] = normalized['site_id'];
    }
    if (normalized.containsKey('space_id')) {
      normalized['spaceId'] = normalized['space_id'];
    }
    if (normalized.containsKey('owner_name')) {
      normalized['ownerName'] = normalized['owner_name'];
    }
    if (normalized.containsKey('tenant_name')) {
      normalized['tenantName'] = normalized['tenant_name'];
    }
    if (normalized.containsKey('contact_phone')) {
      normalized['contactPhone'] = normalized['contact_phone'];
    }
    if (normalized.containsKey('contact_email')) {
      normalized['contactEmail'] = normalized['contact_email'];
    }
    if (normalized.containsKey('city')) {
      normalized['city'] = normalized['city'];
    }
    if (normalized.containsKey('pin_code')) {
      normalized['pinCode'] = normalized['pin_code'];
    }
    if (normalized.containsKey('makani_number')) {
      normalized['makaniNumber'] = normalized['makani_number'];
    }
    if (normalized.containsKey('po_box')) {
      normalized['poBox'] = normalized['po_box'];
    }
    if (normalized.containsKey('is_active')) {
      normalized['isActive'] = normalized['is_active'];
    }
    if (normalized.containsKey('is_occupied')) {
      normalized['isOccupied'] = normalized['is_occupied'];
    }
    if (normalized.containsKey('floor_count')) {
      normalized['floorCount'] = normalized['floor_count'];
    }
    if (normalized.containsKey('bedroom_count')) {
      normalized['bedroomCount'] = normalized['bedroom_count'];
    }
    if (normalized.containsKey('bathroom_count')) {
      normalized['bathroomCount'] = normalized['bathroom_count'];
    }
    if (normalized.containsKey('area_sqm')) {
      normalized['areaSqm'] = normalized['area_sqm'];
    }
    if (normalized.containsKey('villa_type')) {
      normalized['villaType'] = normalized['villa_type'];
    }
    if (normalized.containsKey('building_name')) {
      normalized['buildingName'] = normalized['building_name'];
    }
    if (normalized.containsKey('open_from')) {
      normalized['openFrom'] = normalized['open_from'];
    }
    if (normalized.containsKey('unit_no')) {
      normalized['unitNo'] = normalized['unit_no'];
    }
    if (normalized.containsKey('unit_name')) {
      normalized['unitName'] = normalized['unit_name'];
    }
    if (normalized.containsKey('primary_view')) {
      normalized['primaryView'] = normalized['primary_view'];
    }
    if (normalized.containsKey('unit_category')) {
      normalized['unitCategory'] = normalized['unit_category'];
    }
    if (normalized.containsKey('floor')) {
      normalized['floor'] = normalized['floor'];
    }
    if (normalized.containsKey('parking_slot_number')) {
      normalized['parkingSlotNumber'] = normalized['parking_slot_number'];
    }
    if (normalized.containsKey('meter_number')) {
      normalized['meterNumber'] = normalized['meter_number'];
    }
    if (normalized.containsKey('water_meter_number')) {
      normalized['waterMeterNumber'] = normalized['water_meter_number'];
    }
    if (normalized.containsKey('measure')) {
      normalized['measure'] = normalized['measure'];
    }
    if (normalized.containsKey('external_area')) {
      normalized['externalArea'] = normalized['external_area'];
    }
    if (normalized.containsKey('remarks')) {
      normalized['remarks'] = normalized['remarks'];
    }
    if (normalized.containsKey('company_id')) {
      normalized['companyId'] = normalized['company_id'];
    }
    if (normalized.containsKey('created_at')) {
      normalized['createdAt'] = normalized['created_at'];
    }
    if (normalized.containsKey('updated_at')) {
      normalized['updatedAt'] = normalized['updated_at'];
    }

    // Handle areaSqm conversion (decimal to double)
    double? areaSqmValue;
    if (normalized['areaSqm'] != null) {
      if (normalized['areaSqm'] is String) {
        areaSqmValue = double.tryParse(normalized['areaSqm'] as String);
      } else if (normalized['areaSqm'] is num) {
        areaSqmValue = (normalized['areaSqm'] as num).toDouble();
      }
    }

    return VillaDto(
      id: normalized['id'] as String,
      villaNumber: normalized['villaNumber']?.toString() ?? '',
      villaCode: normalized['villaCode'] as String?,
      siteId: normalized['siteId'] as String?,
      spaceId: normalized['spaceId'] as String?,
      ownerName: normalized['ownerName'] as String?,
      tenantName: normalized['tenantName'] as String?,
      contactPhone: normalized['contactPhone'] as String?,
      contactEmail: normalized['contactEmail'] as String?,
      block: normalized['block'] as String?,
      street: normalized['street'] as String?,
      city: normalized['city'] as String?,
      pinCode: normalized['pinCode'] as String?,
      makaniNumber: normalized['makaniNumber'] as String?,
      poBox: normalized['poBox'] as String?,
      isActive: normalized['isActive'] as bool? ?? true,
      isOccupied: normalized['isOccupied'] as bool? ?? true,
      floorCount: normalized['floorCount'] as int?,
      bedroomCount: normalized['bedroomCount'] as int?,
      bathroomCount: normalized['bathroomCount'] as int?,
      areaSqm: areaSqmValue,
      villaType: normalized['villaType'] as String?,
      buildingName: normalized['buildingName'] as String?,
      openFrom: () {
        final openFromValue = normalized['openFrom'];
        return openFromValue != null
            ? DateTime.tryParse(openFromValue.toString())
            : null;
      }(),
      unitNo: normalized['unitNo'] as String?,
      unitName: normalized['unitName'] as String?,
      primaryView: normalized['primaryView'] as String?,
      unitCategory: normalized['unitCategory'] as String?,
      floor: normalized['floor'] as String?,
      parkingSlotNumber: normalized['parkingSlotNumber'] as String?,
      meterNumber: normalized['meterNumber'] as String?,
      waterMeterNumber: normalized['waterMeterNumber'] as String?,
      measure: normalized['measure'] as String?,
      externalArea: normalized['externalArea'] as String?,
      remarks: normalized['remarks'] as String?,
      metadata: normalized['metadata'] as Map<String, dynamic>?,
      companyId: normalized['companyId'] as String,
      createdAt: DateTime.parse(normalized['createdAt'] as String),
      updatedAt: DateTime.parse(normalized['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'villa_number': villaNumber,
        'villa_code': villaCode,
        'site_id': siteId,
        'space_id': spaceId,
        'owner_name': ownerName,
        'tenant_name': tenantName,
        'contact_phone': contactPhone,
        'contact_email': contactEmail,
        'block': block,
        'street': street,
        'city': city,
        'pin_code': pinCode,
        'makani_number': makaniNumber,
        'po_box': poBox,
        'is_active': isActive,
        'is_occupied': isOccupied,
        'floor_count': floorCount,
        'bedroom_count': bedroomCount,
        'bathroom_count': bathroomCount,
        'area_sqm': areaSqm,
        'villa_type': villaType,
        'building_name': buildingName,
        'open_from': openFrom?.toIso8601String().split('T')[0],
        'unit_no': unitNo,
        'unit_name': unitName,
        'primary_view': primaryView,
        'unit_category': unitCategory,
        'floor': floor,
        'parking_slot_number': parkingSlotNumber,
        'meter_number': meterNumber,
        'water_meter_number': waterMeterNumber,
        'measure': measure,
        'external_area': externalArea,
        'remarks': remarks,
        'metadata': metadata,
        'company_id': companyId,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class CreateVillaDto {
  const CreateVillaDto({
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

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'villaNumber': villaNumber,
    };
    if (villaCode != null) json['villaCode'] = villaCode;
    if (siteId != null) json['siteId'] = siteId;
    if (spaceId != null) json['spaceId'] = spaceId;
    if (ownerName != null) json['ownerName'] = ownerName;
    if (tenantName != null) json['tenantName'] = tenantName;
    if (contactPhone != null) json['contactPhone'] = contactPhone;
    if (contactEmail != null) json['contactEmail'] = contactEmail;
    if (block != null) json['block'] = block;
    if (street != null) json['street'] = street;
    if (city != null) json['city'] = city;
    if (pinCode != null) json['pinCode'] = pinCode;
    if (makaniNumber != null) json['makaniNumber'] = makaniNumber;
    if (poBox != null) json['poBox'] = poBox;
    if (isActive != null) json['isActive'] = isActive;
    if (isOccupied != null) json['isOccupied'] = isOccupied;
    if (floorCount != null) json['floorCount'] = floorCount;
    if (bedroomCount != null) json['bedroomCount'] = bedroomCount;
    if (bathroomCount != null) json['bathroomCount'] = bathroomCount;
    if (areaSqm != null) json['areaSqm'] = areaSqm;
    if (villaType != null) json['villaType'] = villaType;
    if (buildingName != null) json['buildingName'] = buildingName;
    final openFromValue = openFrom;
    if (openFromValue != null) {
      json['openFrom'] = openFromValue.toIso8601String().split('T')[0];
    }
    if (unitNo != null) json['unitNo'] = unitNo;
    if (unitName != null) json['unitName'] = unitName;
    if (primaryView != null) json['primaryView'] = primaryView;
    if (unitCategory != null) json['unitCategory'] = unitCategory;
    if (floor != null) json['floor'] = floor;
    if (parkingSlotNumber != null) json['parkingSlotNumber'] = parkingSlotNumber;
    if (meterNumber != null) json['meterNumber'] = meterNumber;
    if (waterMeterNumber != null) json['waterMeterNumber'] = waterMeterNumber;
    if (measure != null) json['measure'] = measure;
    if (externalArea != null) json['externalArea'] = externalArea;
    if (remarks != null) json['remarks'] = remarks;
    return json;
  }
}

class UpdateVillaDto {
  const UpdateVillaDto({
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

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (villaNumber != null) json['villaNumber'] = villaNumber;
    if (villaCode != null) json['villaCode'] = villaCode;
    if (siteId != null) json['siteId'] = siteId;
    if (spaceId != null) json['spaceId'] = spaceId;
    if (ownerName != null) json['ownerName'] = ownerName;
    if (tenantName != null) json['tenantName'] = tenantName;
    if (contactPhone != null) json['contactPhone'] = contactPhone;
    if (contactEmail != null) json['contactEmail'] = contactEmail;
    if (block != null) json['block'] = block;
    if (street != null) json['street'] = street;
    if (city != null) json['city'] = city;
    if (pinCode != null) json['pinCode'] = pinCode;
    if (makaniNumber != null) json['makaniNumber'] = makaniNumber;
    if (poBox != null) json['poBox'] = poBox;
    if (isActive != null) json['isActive'] = isActive;
    if (isOccupied != null) json['isOccupied'] = isOccupied;
    if (floorCount != null) json['floorCount'] = floorCount;
    if (bedroomCount != null) json['bedroomCount'] = bedroomCount;
    if (bathroomCount != null) json['bathroomCount'] = bathroomCount;
    if (areaSqm != null) json['areaSqm'] = areaSqm;
    if (villaType != null) json['villaType'] = villaType;
    if (buildingName != null) json['buildingName'] = buildingName;
    final openFromValue = openFrom;
    if (openFromValue != null) {
      json['openFrom'] = openFromValue.toIso8601String().split('T')[0];
    }
    if (unitNo != null) json['unitNo'] = unitNo;
    if (unitName != null) json['unitName'] = unitName;
    if (primaryView != null) json['primaryView'] = primaryView;
    if (unitCategory != null) json['unitCategory'] = unitCategory;
    if (floor != null) json['floor'] = floor;
    if (parkingSlotNumber != null) json['parkingSlotNumber'] = parkingSlotNumber;
    if (meterNumber != null) json['meterNumber'] = meterNumber;
    if (waterMeterNumber != null) json['waterMeterNumber'] = waterMeterNumber;
    if (measure != null) json['measure'] = measure;
    if (externalArea != null) json['externalArea'] = externalArea;
    if (remarks != null) json['remarks'] = remarks;
    return json;
  }
}

