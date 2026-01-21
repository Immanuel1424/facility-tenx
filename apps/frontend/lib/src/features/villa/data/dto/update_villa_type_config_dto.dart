class UpdateVillaTypeConfigDto {
  const UpdateVillaTypeConfigDto({
    this.villaType,
    this.displayName,
    this.defaultBedroomCount,
    this.defaultFloorCount,
    this.defaultAreaSqm,
    this.displayOrder,
    this.isActive,
    this.metadata,
  });

  final String? villaType;
  final String? displayName;
  final int? defaultBedroomCount;
  final int? defaultFloorCount;
  final double? defaultAreaSqm;
  final int? displayOrder;
  final bool? isActive;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (villaType != null) json['villaType'] = villaType;
    if (displayName != null) json['displayName'] = displayName;
    if (defaultBedroomCount != null)
      json['defaultBedroomCount'] = defaultBedroomCount;
    if (defaultFloorCount != null) json['defaultFloorCount'] = defaultFloorCount;
    if (defaultAreaSqm != null) json['defaultAreaSqm'] = defaultAreaSqm;
    if (displayOrder != null) json['displayOrder'] = displayOrder;
    if (isActive != null) json['isActive'] = isActive;
    if (metadata != null) json['metadata'] = metadata;
    return json;
  }
}

