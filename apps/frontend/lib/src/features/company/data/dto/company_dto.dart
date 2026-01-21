class CompanyDto {
  const CompanyDto({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.logoUrl,
    this.timezone,
    this.currency,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String code;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? timezone;
  final String? currency;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory CompanyDto.fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);

    // Normalize snake_case to camelCase
    if (normalized.containsKey('logo_url')) {
      normalized['logoUrl'] = normalized['logo_url'];
    }
    if (normalized.containsKey('is_active')) {
      normalized['isActive'] = normalized['is_active'];
    }
    if (normalized.containsKey('created_at')) {
      normalized['createdAt'] = normalized['created_at'];
    }
    if (normalized.containsKey('updated_at')) {
      normalized['updatedAt'] = normalized['updated_at'];
    }

    return CompanyDto(
      id: normalized['id'] as String,
      code: normalized['code'] as String,
      name: normalized['name'] as String,
      description: normalized['description'] as String?,
      logoUrl: normalized['logoUrl'] as String?,
      timezone: normalized['timezone'] as String?,
      currency: normalized['currency'] as String?,
      isActive: normalized['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(normalized['createdAt'] as String),
      updatedAt: DateTime.parse(normalized['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'description': description,
        'logo_url': logoUrl,
        'timezone': timezone,
        'currency': currency,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class CreateCompanyDto {
  const CreateCompanyDto({
    required this.code,
    required this.name,
    this.description,
    this.logoUrl,
    this.timezone,
    this.currency,
    this.isActive,
  });

  final String code;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? timezone;
  final String? currency;
  final bool? isActive;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'code': code,
      'name': name,
    };
    if (description != null) json['description'] = description;
    if (logoUrl != null) json['logoUrl'] = logoUrl;
    if (timezone != null) json['timezone'] = timezone;
    if (currency != null) json['currency'] = currency;
    if (isActive != null) json['isActive'] = isActive;
    return json;
  }
}

class UpdateCompanyDto {
  const UpdateCompanyDto({
    this.code,
    this.name,
    this.description,
    this.logoUrl,
    this.timezone,
    this.currency,
    this.isActive,
  });

  final String? code;
  final String? name;
  final String? description;
  final String? logoUrl;
  final String? timezone;
  final String? currency;
  final bool? isActive;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (code != null) json['code'] = code;
    if (name != null) json['name'] = name;
    if (description != null) json['description'] = description;
    if (logoUrl != null) json['logoUrl'] = logoUrl;
    if (timezone != null) json['timezone'] = timezone;
    if (currency != null) json['currency'] = currency;
    if (isActive != null) json['isActive'] = isActive;
    return json;
  }
}

