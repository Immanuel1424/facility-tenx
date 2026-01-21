class CreateTicketCategoryDto {
  const CreateTicketCategoryDto({
    this.code,
    required this.name,
    this.description,
    this.parentCategoryId,
    this.displayOrder = 0,
    this.icon,
    this.colorCode,
    this.defaultSlaHours,
    this.defaultDepartmentId,
  });

  final String? code;
  final String name;
  final String? description;
  final String? parentCategoryId;
  final int displayOrder;
  final String? icon;
  final String? colorCode;
  final int? defaultSlaHours;
  final String? defaultDepartmentId;

  Map<String, dynamic> toJson() {
    return {
      if (code != null) 'code': code,
      'name': name,
      if (description != null) 'description': description,
      if (parentCategoryId != null) 'parent_category_id': parentCategoryId,
      'display_order': displayOrder,
      if (icon != null) 'icon': icon,
      if (colorCode != null) 'color_code': colorCode,
      if (defaultSlaHours != null) 'default_sla_hours': defaultSlaHours,
      if (defaultDepartmentId != null) 'default_department_id': defaultDepartmentId,
    };
  }
}

