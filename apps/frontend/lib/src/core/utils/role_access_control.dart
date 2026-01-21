import '../../features/auth/domain/entities/user_entity.dart';

/// Role-based access control utility
class RoleAccessControl {
  /// Check if user has a specific role
  static bool hasRole(UserEntity user, String role) {
    return user.roles.contains(role.toUpperCase());
  }

  /// Check if user has any of the specified roles
  static bool hasAnyRole(UserEntity user, List<String> roles) {
    return roles.any((role) => hasRole(user, role));
  }

  /// Check if user has all of the specified roles
  static bool hasAllRoles(UserEntity user, List<String> roles) {
    return roles.every((role) => hasRole(user, role));
  }

  /// Check if user is TENANT
  static bool isTenant(UserEntity user) {
    return hasRole(user, 'TENANT');
  }

  /// Check if user is ADMIN
  static bool isAdmin(UserEntity user) {
    return hasRole(user, 'ADMIN');
  }

  /// Check if user is SITE_COORDINATOR
  static bool isSiteCoordinator(UserEntity user) {
    return hasRole(user, 'SITE_COORDINATOR');
  }

  /// Check if user is SUPERVISOR
  static bool isSupervisor(UserEntity user) {
    return hasRole(user, 'SUPERVISOR');
  }

  /// Check if user is TECHNICIAN
  static bool isTechnician(UserEntity user) {
    return hasRole(user, 'TECHNICIAN');
  }

  /// Check if user can view internal notes
  static bool canViewInternalNotes(UserEntity user) {
    return hasAnyRole(user, [
      'ADMIN',
      'SITE_COORDINATOR',
      'SUPERVISOR',
      'TECHNICIAN',
    ]);
  }

  /// Check if user can assign tickets
  static bool canAssignTickets(UserEntity user) {
    return hasAnyRole(user, ['ADMIN', 'SITE_COORDINATOR']);
  }

  /// Check if user can reassign tickets
  static bool canReassignTickets(UserEntity user) {
    return isAdmin(user);
  }

  /// Check if user can escalate tickets
  static bool canEscalateTickets(UserEntity user) {
    return hasAnyRole(user, ['ADMIN', 'SITE_COORDINATOR']);
  }

  /// Check if user can link tickets
  static bool canLinkTickets(UserEntity user) {
    return isAdmin(user);
  }

  /// Check if user can acknowledge tickets
  static bool canAcknowledgeTickets(UserEntity user) {
    return hasAnyRole(user, ['ADMIN', 'SITE_COORDINATOR']);
  }

  /// Check if user can update ticket status
  static bool canUpdateTicketStatus(UserEntity user) {
    return hasAnyRole(user, [
      'ADMIN',
      'SITE_COORDINATOR',
      'SUPERVISOR',
      'TECHNICIAN',
    ]);
  }

  /// Check if user can add work notes
  static bool canAddWorkNotes(UserEntity user) {
    return hasAnyRole(user, [
      'ADMIN',
      'SITE_COORDINATOR',
      'SUPERVISOR',
      'TECHNICIAN',
    ]);
  }

  /// Check if user can schedule visits
  static bool canScheduleVisits(UserEntity user) {
    return hasAnyRole(user, ['ADMIN', 'SITE_COORDINATOR']);
  }

  /// Check if user can manage users
  static bool canManageUsers(UserEntity user) {
    return isAdmin(user);
  }

  /// Check if user can view all tickets (not just their own)
  static bool canViewAllTickets(UserEntity user) {
    return hasAnyRole(user, [
      'ADMIN',
      'SITE_COORDINATOR',
      'SUPERVISOR',
      'TECHNICIAN',
    ]);
  }

  /// Check if user can view only assigned tickets
  static bool canViewOnlyAssignedTickets(UserEntity user) {
    return isTechnician(user);
  }

  /// Check if user can create tickets
  static bool canCreateTickets(UserEntity user) {
    // All authenticated users can create tickets
    return true;
  }

  /// Check if user can edit tickets
  static bool canEditTickets(UserEntity user) {
    return hasAnyRole(user, ['ADMIN', 'SITE_COORDINATOR']);
  }

  /// Check if user can delete tickets
  static bool canDeleteTickets(UserEntity user) {
    return isAdmin(user);
  }

  /// Check if user can cancel tickets
  static bool canCancelTickets(UserEntity user) {
    return hasAnyRole(user, ['ADMIN', 'SITE_COORDINATOR']);
  }
}

