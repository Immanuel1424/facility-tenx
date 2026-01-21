import 'package:equatable/equatable.dart';

class SiteEntity extends Equatable {
  const SiteEntity({
    required this.id,
    this.code,
    this.name,
    this.description,
    this.companyId,
    this.isParent = true,
    this.isActive = true,
  });

  final String id;
  final String? code;
  final String? name;
  final String? description;
  final String? companyId;
  final bool isParent;
  final bool isActive;

  /// Display name for UI
  String get displayName {
    if (name != null && name!.isNotEmpty) {
      return name!;
    }
    if (code != null && code!.isNotEmpty) {
      return code!;
    }
    return 'Site $id';
  }

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        description,
        companyId,
        isParent,
        isActive,
      ];
}

