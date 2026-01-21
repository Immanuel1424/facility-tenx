import 'package:equatable/equatable.dart';

class RoleEntity extends Equatable {
  const RoleEntity({
    required this.id,
    required this.companyId,
    required this.name,
    this.description,
    this.hierarchyLevel = 0,
    this.parentRoleId,
    this.permissionIds = const [],
  });

  final String id;
  final String companyId;
  final String name;
  final String? description;
  final int hierarchyLevel;
  final String? parentRoleId;
  final List<String> permissionIds;

  @override
  List<Object?> get props => [
        id,
        companyId,
        name,
        description,
        hierarchyLevel,
        parentRoleId,
        permissionIds,
      ];
}

