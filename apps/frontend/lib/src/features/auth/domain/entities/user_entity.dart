import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    required this.companyId,
    required this.siteId,
    required this.siteCode,
    this.firstName,
    this.lastName,
    this.villaNumber,
    this.villas = const [],
    this.phoneNumber,
    this.alternatePhoneNumber,
    this.leaseExpiryDate,
    this.roles = const [],
    this.permissions = const [],
  });

  final String id;
  final String email;
  final String companyId;
  final String siteId;
  final String siteCode;
  final String? firstName;
  final String? lastName;
  final String? villaNumber;
  final List<TenantVillaEntity> villas;
  final String? phoneNumber;
  final String? alternatePhoneNumber;
  final DateTime? leaseExpiryDate;
  final List<String> roles;
  final List<String> permissions;

  @override
  List<Object?> get props => [
        id,
        email,
        companyId,
        siteId,
        siteCode,
        firstName,
        lastName,
        villaNumber,
        villas,
        phoneNumber,
        alternatePhoneNumber,
        leaseExpiryDate,
        roles,
        permissions,
      ];
}

class TenantVillaEntity extends Equatable {
  const TenantVillaEntity({
    required this.id,
    required this.villaNumber,
    this.villaCode,
    this.name,
  });

  final String id;
  final String villaNumber;
  final String? villaCode;
  final String? name;

  @override
  List<Object?> get props => [id, villaNumber, villaCode, name];
}
