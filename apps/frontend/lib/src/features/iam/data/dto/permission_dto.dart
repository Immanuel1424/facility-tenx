class PermissionDto {
  PermissionDto({
    required this.id,
    required this.companyId,
    required this.resource,
    required this.action,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String companyId;
  final String resource;
  final String action;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory PermissionDto.fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    if (normalized.containsKey('company_id')) {
      normalized['companyId'] = normalized['company_id'];
    }
    if (normalized.containsKey('created_at')) {
      normalized['createdAt'] = normalized['created_at'];
    }
    if (normalized.containsKey('updated_at')) {
      normalized['updatedAt'] = normalized['updated_at'];
    }
    return PermissionDto(
      id: normalized['id'] as String,
      companyId: normalized['companyId'] as String,
      resource: normalized['resource'] as String,
      action: normalized['action'] as String,
      description: normalized['description'] as String?,
      createdAt: DateTime.parse(normalized['createdAt'] as String),
      updatedAt: DateTime.parse(normalized['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'company_id': companyId,
        'resource': resource,
        'action': action,
        'description': description,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class CreatePermissionDto {
  CreatePermissionDto({
    required this.resource,
    required this.action,
    this.description,
  });

  final String resource;
  final String action;
  final String? description;

  Map<String, dynamic> toJson() => {
        'resource': resource,
        'action': action,
        'description': description,
      };
}

class UpdatePermissionDto {
  UpdatePermissionDto({
    this.resource,
    this.action,
    this.description,
  });

  final String? resource;
  final String? action;
  final String? description;

  Map<String, dynamic> toJson() => {
        'resource': resource,
        'action': action,
        'description': description,
      };
}
