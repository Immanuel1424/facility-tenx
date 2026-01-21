class DepartmentDto {
  const DepartmentDto({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
    required this.companyId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String? description;
  final bool isActive;
  final String companyId;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory DepartmentDto.fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    if (normalized.containsKey('is_active')) {
      normalized['isActive'] = normalized['is_active'];
    }
    if (normalized.containsKey('company_id')) {
      normalized['companyId'] = normalized['company_id'];
    }
    if (normalized.containsKey('created_at')) {
      normalized['createdAt'] = normalized['created_at'];
    }
    if (normalized.containsKey('updated_at')) {
      normalized['updatedAt'] = normalized['updated_at'];
    }
    return DepartmentDto(
      id: normalized['id'] as String,
      name: normalized['name'] as String,
      description: normalized['description'] as String?,
      isActive: normalized['isActive'] as bool? ?? true,
      companyId: normalized['companyId'] as String,
      createdAt: DateTime.parse(normalized['createdAt'] as String),
      updatedAt: DateTime.parse(normalized['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'is_active': isActive,
        'company_id': companyId,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class CreateDepartmentDto {
  const CreateDepartmentDto({
    required this.name,
    this.description,
  });

  final String name;
  final String? description;

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
      };
}

class UpdateDepartmentDto {
  const UpdateDepartmentDto({
    this.name,
    this.description,
  });

  final String? name;
  final String? description;

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
      };
}
