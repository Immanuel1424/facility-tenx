class UpdateTicketCategoryDto {
  const UpdateTicketCategoryDto({
    this.code,
    this.name,
    this.description,
    this.parentCategoryId,
    this.displayOrder,
    this.isActive,
    this.icon,
    this.colorCode,
    this.defaultSlaHours,
    this.defaultDepartmentId,
  });

  final String? code;
  final String? name;
  final String? description;
  final String? parentCategoryId;
  final int? displayOrder;
  final bool? isActive;
  final String? icon;
  final String? colorCode;
  final int? defaultSlaHours;
  final String? defaultDepartmentId;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (code != null) json['code'] = code;
    if (name != null) json['name'] = name;
    if (description != null) json['description'] = description;
    if (parentCategoryId != null) json['parent_category_id'] = parentCategoryId;
    if (displayOrder != null) json['display_order'] = displayOrder;
    if (isActive != null) json['is_active'] = isActive;
    if (icon != null) json['icon'] = icon;
    if (colorCode != null) json['color_code'] = colorCode;
    if (defaultSlaHours != null) json['default_sla_hours'] = defaultSlaHours;
    if (defaultDepartmentId != null) json['default_department_id'] = defaultDepartmentId;
    return json;
  }
}

