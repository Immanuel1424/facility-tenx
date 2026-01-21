/// Helper function to parse double from JSON (handles both string and number)
double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) {
    try {
      return double.parse(value);
    } catch (e) {
      return null;
    }
  }
  return null;
}

class VillaTypeConfigDto {
  const VillaTypeConfigDto({
    required this.id,
    required this.villaType,
    this.displayName,
    this.defaultBedroomCount,
    this.defaultFloorCount,
    this.defaultAreaSqm,
    required this.displayOrder,
    required this.isActive,
    this.metadata,
    this.companyId,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String villaType;
  final String? displayName;
  final int? defaultBedroomCount;
  final int? defaultFloorCount;
  final double? defaultAreaSqm;
  final int displayOrder;
  final bool isActive;
  final Map<String, dynamic>? metadata;
  final String? companyId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory VillaTypeConfigDto.fromJson(Map<String, dynamic> json) {
    return VillaTypeConfigDto(
      id: json['id'] as String,
      villaType: json['villaType'] as String? ?? json['villa_type'] as String,
      displayName: json['displayName'] as String? ?? json['display_name'] as String?,
      defaultBedroomCount: json['defaultBedroomCount'] as int? ?? 
          (json['default_bedroom_count'] as num?)?.toInt(),
      defaultFloorCount: json['defaultFloorCount'] as int? ?? 
          (json['default_floor_count'] as num?)?.toInt(),
      defaultAreaSqm: _parseDouble(json['defaultAreaSqm']) ?? 
          _parseDouble(json['default_area_sqm']),
      displayOrder: json['displayOrder'] as int? ?? 
          (json['display_order'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? 
          (json['is_active'] as bool?) ?? true,
      metadata: json['metadata'] as Map<String, dynamic>?,
      companyId: json['companyId'] as String? ?? json['company_id'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'villaType': villaType,
      if (displayName != null) 'displayName': displayName,
      if (defaultBedroomCount != null) 'defaultBedroomCount': defaultBedroomCount,
      if (defaultFloorCount != null) 'defaultFloorCount': defaultFloorCount,
      if (defaultAreaSqm != null) 'defaultAreaSqm': defaultAreaSqm,
      'displayOrder': displayOrder,
      'isActive': isActive,
      if (metadata != null) 'metadata': metadata,
      if (companyId != null) 'companyId': companyId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}
