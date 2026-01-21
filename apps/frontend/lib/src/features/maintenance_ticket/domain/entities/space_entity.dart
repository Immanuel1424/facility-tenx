import 'package:equatable/equatable.dart';

class SpaceEntity extends Equatable {
  const SpaceEntity({
    required this.id,
    this.code,
    this.name,
    this.description,
    this.siteId,
    this.isActive = true,
  });

  final String id;
  final String? code;
  final String? name;
  final String? description;
  final String? siteId;
  final bool isActive;

  /// Display name for UI
  String get displayName {
    if (name != null && name!.isNotEmpty) {
      return name!;
    }
    if (code != null && code!.isNotEmpty) {
      return code!;
    }
    return 'Space $id';
  }

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        description,
        siteId,
        isActive,
      ];
}

