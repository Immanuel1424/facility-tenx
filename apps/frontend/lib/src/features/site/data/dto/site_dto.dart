class SiteDto {
  const SiteDto({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.address,
    this.city,
    this.country,
    required this.isParent,
    required this.isActive,
    this.parentSiteId,
    this.companyId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String code;
  final String name;
  final String? description;
  final String? address;
  final String? city;
  final String? country;
  final bool isParent;
  final bool isActive;
  final String? parentSiteId;
  final String? companyId;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory SiteDto.fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);

    // Normalize snake_case to camelCase
    if (normalized.containsKey('is_parent')) {
      normalized['isParent'] = normalized['is_parent'];
    }
    if (normalized.containsKey('is_active')) {
      normalized['isActive'] = normalized['is_active'];
    }
    if (normalized.containsKey('parent_site_id')) {
      normalized['parentSiteId'] = normalized['parent_site_id'];
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

    return SiteDto(
      id: normalized['id'] as String,
      code: normalized['code'] as String,
      name: normalized['name'] as String,
      description: normalized['description'] as String?,
      address: normalized['address'] as String?,
      city: normalized['city'] as String?,
      country: normalized['country'] as String?,
      isParent: normalized['isParent'] as bool? ?? true,
      isActive: normalized['isActive'] as bool? ?? true,
      parentSiteId: normalized['parentSiteId'] as String?,
      companyId: normalized['companyId'] as String?,
      createdAt: DateTime.parse(normalized['createdAt'] as String),
      updatedAt: DateTime.parse(normalized['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'description': description,
        'address': address,
        'city': city,
        'country': country,
        'is_parent': isParent,
        'is_active': isActive,
        'parent_site_id': parentSiteId,
        'company_id': companyId,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class CreateSiteDto {
  const CreateSiteDto({
    this.code,
    required this.name,
    required this.isParent,
    this.parentSiteId,
    this.createAdmin,
    this.adminEmail,
    this.adminPassword,
    this.adminFirstName,
    this.adminLastName,
    this.companyId,
  });

  final String? code;
  final String name;
  final bool isParent;
  final String? parentSiteId;
  final bool? createAdmin;
  final String? adminEmail;
  final String? adminPassword;
  final String? adminFirstName;
  final String? adminLastName;
  final String? companyId;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'name': name,
      'isParent': isParent,
    };
    if (code != null) json['code'] = code;
    if (parentSiteId != null) json['parentSiteId'] = parentSiteId;
    if (createAdmin != null) json['createAdmin'] = createAdmin;
    if (adminEmail != null) json['adminEmail'] = adminEmail;
    if (adminPassword != null) json['adminPassword'] = adminPassword;
    if (adminFirstName != null) json['adminFirstName'] = adminFirstName;
    if (adminLastName != null) json['adminLastName'] = adminLastName;
    if (companyId != null) json['companyId'] = companyId;
    return json;
  }
}

class UpdateSiteDto {
  const UpdateSiteDto({
    this.code,
    this.name,
    this.description,
    this.address,
    this.city,
    this.country,
    this.isParent,
    this.isActive,
    this.parentSiteId,
  });

  final String? code;
  final String? name;
  final String? description;
  final String? address;
  final String? city;
  final String? country;
  final bool? isParent;
  final bool? isActive;
  final String? parentSiteId;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (code != null) json['code'] = code;
    if (name != null) json['name'] = name;
    if (description != null) json['description'] = description;
    if (address != null) json['address'] = address;
    if (city != null) json['city'] = city;
    if (country != null) json['country'] = country;
    if (isParent != null) json['isParent'] = isParent;
    if (isActive != null) json['isActive'] = isActive;
    if (parentSiteId != null) json['parentSiteId'] = parentSiteId;
    return json;
  }
}

