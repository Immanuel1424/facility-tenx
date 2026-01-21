import 'package:equatable/equatable.dart';

class VillaEntity extends Equatable {
  const VillaEntity({
    required this.id,
    this.villaNumber,
    this.villaCode,
    this.siteId,
    this.ownerName,
    this.tenantName,
    this.contactPhone,
    this.contactEmail,
    this.isActive = true,
    this.isOccupied = true,
  });

  final String id;
  final String? villaNumber;
  final String? villaCode;
  final String? siteId;
  final String? ownerName;
  final String? tenantName;
  final String? contactPhone;
  final String? contactEmail;
  final bool isActive;
  final bool isOccupied;

  /// Display name for UI - shows just the number
  String get displayName {
    if (villaNumber != null && villaNumber!.isNotEmpty) {
      // Extract just the number part, removing prefixes like "V-", "Villa ", etc.
      final numberMatch = RegExp(r'\d+').firstMatch(villaNumber!);
      if (numberMatch != null) {
        return numberMatch.group(0)!;
      }
      // If no number found, return as-is
      return villaNumber!;
    }
    if (villaCode != null && villaCode!.isNotEmpty) {
      // Extract just the number part from villa code
      final numberMatch = RegExp(r'\d+').firstMatch(villaCode!);
      if (numberMatch != null) {
        return numberMatch.group(0)!;
      }
      // If no number found, return as-is
      return villaCode!;
    }
    return id;
  }

  /// Full display with tenant info
  String get fullDisplayName {
    final name = displayName;
    if (tenantName != null) {
      return '$name - $tenantName';
    }
    return name;
  }

  @override
  List<Object?> get props => [
        id,
        villaNumber,
        villaCode,
        siteId,
        ownerName,
        tenantName,
        contactPhone,
        contactEmail,
        isActive,
        isOccupied,
      ];
}

