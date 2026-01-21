import '../../features/auth/domain/entities/user_entity.dart';

/// Utility class for checking user permissions
class PermissionChecker {
  /// Checks if user has a specific permission
  /// Format: "resource:action" (e.g., "service_request:create")
  static bool hasPermission(UserEntity user, String permission) {
    return user.permissions.contains(permission);
  }

  /// Checks if user has any of the specified permissions
  static bool hasAnyPermission(UserEntity user, List<String> permissions) {
    return permissions.any((permission) => user.permissions.contains(permission));
  }

  /// Checks if user has all of the specified permissions
  static bool hasAllPermissions(UserEntity user, List<String> permissions) {
    return permissions.every((permission) => user.permissions.contains(permission));
  }

  /// Checks if user has a specific role (case-insensitive)
  static bool hasRole(UserEntity user, String role) {
    final userRolesLower = user.roles.map((r) => r.toLowerCase()).toList();
    return userRolesLower.contains(role.toLowerCase());
  }

  /// Checks if user has any of the specified roles
  static bool hasAnyRole(UserEntity user, List<String> roles) {
    final lowerRoles = roles.map((r) => r.toLowerCase()).toList();
    return user.roles.any((role) => lowerRoles.contains(role.toLowerCase()));
  }

  /// Checks if user has all of the specified roles
  static bool hasAllRoles(UserEntity user, List<String> roles) {
    final lowerRoles = roles.map((r) => r.toLowerCase()).toList();
    return roles.every((role) => lowerRoles.contains(role.toLowerCase()));
  }

  /// Checks if user is admin (ADMIN role)
  static bool isAdmin(UserEntity user) {
    return hasRole(user, 'ADMIN');
  }

  /// Checks if user is super admin (SUPER_ADMIN role)
  static bool isSuperAdmin(UserEntity user) {
    return hasRole(user, 'SUPER_ADMIN');
  }

  /// Checks if user can perform action on resource
  /// This is a convenience method that checks both permission and role
  static bool canPerform(
    UserEntity user,
    String resource,
    String action,
  ) {
    final permission = '$resource:$action';
    
    // Super Admin can do everything (highest privilege)
    if (isSuperAdmin(user)) {
      return true;
    }
    
    // Admin can do everything
    if (isAdmin(user)) {
      return true;
    }

    // Check specific permission
    if (hasPermission(user, permission)) {
      return true;
    }

    // Check for wildcard permissions
    if (hasPermission(user, '$resource:*')) {
      return true;
    }

    return false;
  }
}

