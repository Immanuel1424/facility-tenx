import '../../domain/entities/user_entity.dart';

class UserMapper {
  static UserEntity fromJson(Map<String, dynamic> json) {
    final List<TenantVillaEntity> villas = (json['villas'] as List<dynamic>?)
            ?.map((raw) {
              final map = raw as Map<String, dynamic>;
              return TenantVillaEntity(
                id: map['id'] as String,
                villaNumber: map['villaNumber']?.toString() ?? '',
                villaCode: map['villaCode'] as String?,
                name: map['name'] as String?,
              );
            })
            .toList() ??
        const [];

    return UserEntity(
      id: json['id'] as String,
      email: json['email'] as String,
      companyId: json['companyId'] as String,
      siteId: json['siteId'] as String? ?? '',
      siteCode: json['siteCode'] as String? ?? '',
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      villaNumber: json['villaNumber']?.toString(),
      phoneNumber: json['phoneNumber'] as String?,
      villas: villas,
      roles:
          (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}
