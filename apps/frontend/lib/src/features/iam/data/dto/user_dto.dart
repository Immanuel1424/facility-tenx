class UserDto {
  UserDto({
    required this.id,
    required this.companyId,
    required this.email,
    this.firstName,
    this.lastName,
    this.villaNumber,
    this.villaNumbers,
    this.villas,
    this.phoneNumber,
    this.alternatePhoneNumber,
    this.departmentId,
    required this.status,
    required this.authProvider,
    this.lastLoginAt,
    this.leaseExpiryDate,
    this.roles,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String companyId;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? villaNumber;
  final List<String>? villaNumbers;

  /// Raw villas payload from backend (/users/me), kept generic so features
  /// like Auth can map it into strongly typed TenantVillaEntity.
  final List<Map<String, dynamic>>? villas;
  final String? phoneNumber;
  final String? alternatePhoneNumber;
  final String? departmentId;
  final String status;
  final String authProvider;
  final DateTime? lastLoginAt;
  final DateTime? leaseExpiryDate;
  final List<String>? roles;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory UserDto.fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    if (normalized.containsKey('company_id')) {
      normalized['companyId'] = normalized['company_id'];
    }
    if (normalized.containsKey('first_name')) {
      normalized['firstName'] = normalized['first_name'];
    }
    if (normalized.containsKey('last_name')) {
      normalized['lastName'] = normalized['last_name'];
    }
    if (normalized.containsKey('villa_number')) {
      normalized['villaNumber'] = normalized['villa_number'];
    }
    if (normalized.containsKey('villa_numbers')) {
      normalized['villaNumbers'] = normalized['villa_numbers'];
    }
    if (normalized.containsKey('phone_number')) {
      normalized['phoneNumber'] = normalized['phone_number'];
    }
    if (normalized.containsKey('alternate_phone_number')) {
      normalized['alternatePhoneNumber'] = normalized['alternate_phone_number'];
    }
    if (normalized.containsKey('lease_expiry_date')) {
      normalized['leaseExpiryDate'] = normalized['lease_expiry_date'];
    }
    if (normalized.containsKey('department_id')) {
      normalized['departmentId'] = normalized['department_id'];
    }
    if (normalized.containsKey('auth_provider')) {
      normalized['authProvider'] = normalized['auth_provider'];
    }
    if (normalized.containsKey('roles')) {
      normalized['roles'] = normalized['roles'];
    }
    if (normalized.containsKey('last_login_at')) {
      normalized['lastLoginAt'] = normalized['last_login_at'];
    }
    if (normalized.containsKey('created_at')) {
      normalized['createdAt'] = normalized['created_at'];
    }
    if (normalized.containsKey('updated_at')) {
      normalized['updatedAt'] = normalized['updated_at'];
    }
    // Preserve villas array (supports both snake_case and camelCase keys)
    if (normalized.containsKey('villas') && normalized['villas'] is List) {
      normalized['villas'] = (normalized['villas'] as List)
          .whereType<Map<String, dynamic>>()
          .toList();
    }
    return UserDto(
      id: (normalized['id'] as String?) ?? '',
      companyId: (normalized['companyId'] as String?) ?? '',
      email: (normalized['email'] as String?) ?? '',
      firstName: normalized['firstName'] as String?,
      lastName: normalized['lastName'] as String?,
      villaNumber: normalized['villaNumber']?.toString(),
      villaNumbers: normalized['villaNumbers'] != null
          ? List<String>.from(
              (normalized['villaNumbers'] as List).map((e) => e.toString()),
            )
          : null,
      villas: normalized['villas'] as List<Map<String, dynamic>>?,
      phoneNumber: normalized['phoneNumber'] as String?,
      alternatePhoneNumber: normalized['alternatePhoneNumber'] as String?,
      departmentId: normalized['departmentId'] as String?,
      status: normalized['status'] as String? ?? 'active',
      authProvider: normalized['authProvider'] as String? ?? 'local',
      leaseExpiryDate: normalized['leaseExpiryDate'] != null
          ? DateTime.parse(normalized['leaseExpiryDate'] as String)
          : null,
      roles: normalized['roles'] != null
          ? List<String>.from(normalized['roles'] as List)
          : (normalized['userRoles'] != null
              ? (normalized['userRoles'] as List)
                  .map((e) => e['role']?['name'] as String?)
                  .where((name) => name != null)
                  .cast<String>()
                  .toList()
              : null),
      lastLoginAt: normalized['lastLoginAt'] != null
          ? DateTime.parse(normalized['lastLoginAt'] as String)
          : null,
      createdAt: normalized['createdAt'] != null
          ? DateTime.parse(normalized['createdAt'] as String)
          : DateTime.now(),
      updatedAt: normalized['updatedAt'] != null
          ? DateTime.parse(normalized['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'company_id': companyId,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'villa_number': villaNumber,
        if (villaNumbers != null) 'villa_numbers': villaNumbers,
        'phone_number': phoneNumber,
        'alternate_phone_number': alternatePhoneNumber,
        'status': status,
        'auth_provider': authProvider,
        'last_login_at': lastLoginAt?.toIso8601String(),
        'lease_expiry_date': leaseExpiryDate?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class CreateUserDto {
  CreateUserDto({
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
    this.villaNumber,
    this.villaNumbers,
    this.phoneNumber,
    this.alternatePhoneNumber,
    this.leaseExpiryDate,
    this.roleId,
    this.departmentId,
    this.sendCredentialsViaEmail,
    this.forcePasswordChangeOnFirstLogin,
    this.status,
    this.employeeId,
    this.designation,
    this.joiningDate,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.notes,
    this.companyId,
  });

  final String email;
  final String password;
  final String? firstName;
  final String? lastName;
  final String? villaNumber;
  final List<String>? villaNumbers;
  final String? phoneNumber;
  final String? alternatePhoneNumber;
  final DateTime? leaseExpiryDate;
  final String? roleId;
  final String? departmentId;
  final bool? sendCredentialsViaEmail;
  final bool? forcePasswordChangeOnFirstLogin;
  final String? status;
  final String? employeeId;
  final String? designation;
  final DateTime? joiningDate;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? notes;
  final String? companyId;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        if (villaNumber != null) 'villaNumber': villaNumber,
        if (villaNumbers != null) 'villaNumbers': villaNumbers,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (alternatePhoneNumber != null)
          'alternatePhoneNumber': alternatePhoneNumber,
        if (leaseExpiryDate != null)
          'leaseExpiryDate': leaseExpiryDate?.toIso8601String(),
        if (roleId != null) 'roleId': roleId,
        if (departmentId != null) 'departmentId': departmentId,
        if (sendCredentialsViaEmail != null)
          'sendCredentialsViaEmail': sendCredentialsViaEmail,
        if (forcePasswordChangeOnFirstLogin != null)
          'forcePasswordChangeOnFirstLogin': forcePasswordChangeOnFirstLogin,
        if (status != null) 'status': status,
        if (employeeId != null) 'employeeId': employeeId,
        if (designation != null) 'designation': designation,
        if (joiningDate != null) 'joiningDate': joiningDate?.toIso8601String(),
        if (emergencyContactName != null) 'emergencyContactName': emergencyContactName,
        if (emergencyContactPhone != null) 'emergencyContactPhone': emergencyContactPhone,
        if (notes != null) 'notes': notes,
        if (companyId != null) 'companyId': companyId,
      };
}

class UpdateUserDto {
  UpdateUserDto({
    this.email,
    this.firstName,
    this.lastName,
    this.villaNumber,
    this.villaNumbers,
    this.phoneNumber,
    this.alternatePhoneNumber,
    this.leaseExpiryDate,
    this.status,
    this.roleId,
    this.departmentId,
  });

  final String? email;
  final String? firstName;
  final String? lastName;
  final String? villaNumber;
  final List<String>? villaNumbers;
  final String? phoneNumber;
  final String? alternatePhoneNumber;
  final DateTime? leaseExpiryDate;
  final String? status;
  final String? roleId;
  final String? departmentId;

  Map<String, dynamic> toJson() => {
        if (email != null) 'email': email,
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (villaNumber != null) 'villaNumber': villaNumber,
        if (villaNumbers != null) 'villaNumbers': villaNumbers,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (alternatePhoneNumber != null)
          'alternatePhoneNumber': alternatePhoneNumber,
        if (leaseExpiryDate != null)
          'leaseExpiryDate': leaseExpiryDate?.toIso8601String(),
        if (status != null) 'status': status,
        if (roleId != null) 'roleId': roleId,
        if (departmentId != null) 'departmentId': departmentId,
      };
}

class ResetPasswordDto {
  ResetPasswordDto({
    required this.newPassword,
  });

  final String newPassword;

  Map<String, dynamic> toJson() => {
        'newPassword': newPassword,
      };
}

class AssignRoleDto {
  AssignRoleDto({
    required this.userId,
    required this.roleId,
  });

  final String userId;
  final String roleId;

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'roleId': roleId,
      };
}
