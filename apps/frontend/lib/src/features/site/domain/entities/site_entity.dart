class SiteEntity {
  const SiteEntity({
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
}

