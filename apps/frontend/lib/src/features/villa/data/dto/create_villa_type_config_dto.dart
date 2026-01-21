class CreateVillaTypeConfigDto {
  const CreateVillaTypeConfigDto({
    required this.villaType,
    this.displayName,
    this.defaultBedroomCount,
    this.defaultFloorCount,
    this.defaultAreaSqm,
    this.displayOrder = 0,
    this.isActive = true,
    this.metadata,
  });

  final String villaType;
  final String? displayName;
  final int? defaultBedroomCount;
  final int? defaultFloorCount;
  final double? defaultAreaSqm;
  final int displayOrder;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() {
    return {
      'villaType': villaType,
      if (displayName != null) 'displayName': displayName,
      if (defaultBedroomCount != null)
        'defaultBedroomCount': defaultBedroomCount,
      if (defaultFloorCount != null) 'defaultFloorCount': defaultFloorCount,
      if (defaultAreaSqm != null) 'defaultAreaSqm': defaultAreaSqm,
      'displayOrder': displayOrder,
      'isActive': isActive,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

