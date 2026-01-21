import 'package:equatable/equatable.dart';

class VillaTypeConfigEntity extends Equatable {
  const VillaTypeConfigEntity({
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

  String get displayLabel => displayName ?? villaType;

  @override
  List<Object?> get props => [
        id,
        villaType,
        displayName,
        defaultBedroomCount,
        defaultFloorCount,
        defaultAreaSqm,
        displayOrder,
        isActive,
        metadata,
        companyId,
        createdAt,
        updatedAt,
      ];
}

