class UserDto {
  const UserDto({
    this.id,
    this.company_id,
    this.email,
    this.first_name,
    this.last_name,
    this.villa_number,
  });

  final String? id;
  final String? company_id;
  final String? email;
  final String? first_name;
  final String? last_name;
  final String? villa_number;

  factory UserDto.fromJson(Map<String, dynamic> json) {
    // Normalize camelCase keys from backend into snake_case expected by DTO
    final normalized = Map<String, dynamic>.from(json);

    if (normalized.containsKey('companyId')) {
      normalized['company_id'] = normalized['companyId'];
    }
    if (normalized.containsKey('firstName')) {
      normalized['first_name'] = normalized['firstName'];
    }
    if (normalized.containsKey('lastName')) {
      normalized['last_name'] = normalized['lastName'];
    }
    if (normalized.containsKey('villaNumber')) {
      normalized['villa_number'] = normalized['villaNumber'];
    }

    return UserDto(
      id: normalized['id'] as String?,
      company_id: normalized['company_id'] as String?,
      email: normalized['email'] as String?,
      first_name: normalized['first_name'] as String?,
      last_name: normalized['last_name'] as String?,
      villa_number: normalized['villa_number']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'company_id': company_id,
        'email': email,
        'first_name': first_name,
        'last_name': last_name,
        'villa_number': villa_number,
      };
}
