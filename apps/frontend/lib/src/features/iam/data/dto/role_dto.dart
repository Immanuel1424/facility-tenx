class RoleDto {
  RoleDto({
    required this.id,
    required this.companyId,
    required this.name,
    this.description,
    this.hierarchyLevel = 0,
    this.parentRoleId,
    this.parentRole,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String companyId;
  final String name;
  final String? description;
  final int hierarchyLevel;
  final String? parentRoleId;
  final RoleDto? parentRole;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory RoleDto.fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    if (normalized.containsKey('company_id')) {
      normalized['companyId'] = normalized['company_id'];
    }
    if (normalized.containsKey('hierarchy_level')) {
      normalized['hierarchyLevel'] = normalized['hierarchy_level'];
    }
    if (normalized.containsKey('parent_role_id')) {
      normalized['parentRoleId'] = normalized['parent_role_id'];
    }
    if (normalized.containsKey('parent_role')) {
      normalized['parentRole'] = normalized['parent_role'];
    }
    if (normalized.containsKey('created_at')) {
      normalized['createdAt'] = normalized['created_at'];
    }
    if (normalized.containsKey('updated_at')) {
      normalized['updatedAt'] = normalized['updated_at'];
    }
    return RoleDto(
      id: normalized['id'] as String,
      companyId: normalized['companyId'] as String,
      name: normalized['name'] as String,
      description: normalized['description'] as String?,
      hierarchyLevel: (normalized['hierarchyLevel'] as num?)?.toInt() ?? 0,
      parentRoleId: normalized['parentRoleId'] as String?,
      parentRole: normalized['parentRole'] != null
          ? RoleDto.fromJson(normalized['parentRole'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(normalized['createdAt'] as String),
      updatedAt: DateTime.parse(normalized['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'company_id': companyId,
        'name': name,
        'description': description,
        'hierarchy_level': hierarchyLevel,
        'parent_role_id': parentRoleId,
        'parent_role': parentRole?.toJson(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class CreateRoleDto {
  CreateRoleDto({
    required this.name,
    this.description,
    this.hierarchyLevel = 0,
    this.parentRoleId,
    this.companyId,
  });

  final String name;
  final String? description;
  final int hierarchyLevel;
  final String? parentRoleId;
  final String? companyId;

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'hierarchy_level': hierarchyLevel,
        'parent_role_id': parentRoleId,
        if (companyId != null) 'company_id': companyId,
      };
}

class UpdateRoleDto {
  UpdateRoleDto({
    this.name,
    this.description,
    this.hierarchyLevel,
    this.parentRoleId,
  });

  final String? name;
  final String? description;
  final int? hierarchyLevel;
  final String? parentRoleId;

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'hierarchy_level': hierarchyLevel,
        'parent_role_id': parentRoleId,
      };
}

class AssignPermissionDto {
  AssignPermissionDto({
    required this.permissionId,
  });

  final String permissionId;

  Map<String, dynamic> toJson() => {'permissionId': permissionId};
}

class BulkAssignPermissionsDto {
  BulkAssignPermissionsDto({
    required this.permissionIds,
  });

  final List<String> permissionIds;

  Map<String, dynamic> toJson() => {'permissionIds': permissionIds};
}

class BulkRemovePermissionsDto {
  BulkRemovePermissionsDto({
    required this.permissionIds,
  });

  final List<String> permissionIds;

  Map<String, dynamic> toJson() => {'permissionIds': permissionIds};
}
