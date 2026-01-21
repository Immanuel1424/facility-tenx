class CompanyEntity {
  const CompanyEntity({
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
}

