import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user_entity.dart';
import 'ticket_type_entity.dart';
import 'villa_entity.dart';
import 'team_entity.dart';
import 'site_entity.dart';
import 'space_entity.dart';
import 'ticket_category_entity.dart';

enum TicketStatus {
  new_,
  acknowledged,
  assigned,
  inProgress,
  onHold,
  completed,
  cancelled;

  static TicketStatus fromString(String value) {
    // Normalize both the input and enum names for comparison
    final normalizedValue = value.toLowerCase().replaceAll('_', '');
    return TicketStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == normalizedValue,
      orElse: () => TicketStatus.new_,
    );
  }

  String get displayName {
    switch (this) {
      case TicketStatus.new_:
        return 'New';
      case TicketStatus.acknowledged:
        return 'Acknowledged';
      case TicketStatus.assigned:
        return 'Assigned';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.onHold:
        return 'On Hold';
      case TicketStatus.completed:
        return 'Completed';
      case TicketStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Converts the enum to the backend API format (uppercase with underscores)
  String get toBackendValue {
    switch (this) {
      case TicketStatus.new_:
        return 'NEW';
      case TicketStatus.acknowledged:
        return 'ACKNOWLEDGED';
      case TicketStatus.assigned:
        return 'ASSIGNED';
      case TicketStatus.inProgress:
        return 'IN_PROGRESS';
      case TicketStatus.onHold:
        return 'ON_HOLD';
      case TicketStatus.completed:
        return 'COMPLETED';
      case TicketStatus.cancelled:
        return 'CANCELLED';
    }
  }
}

enum TicketPriority {
  low,
  medium,
  high,
  urgent;

  static TicketPriority fromString(String value) {
    return TicketPriority.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => TicketPriority.medium,
    );
  }

  String get displayName {
    return name.toUpperCase();
  }

  /// Converts the enum to the backend API format (uppercase)
  String get toBackendValue {
    return name.toUpperCase();
  }
}

class MaintenanceTicketEntity extends Equatable {
  const MaintenanceTicketEntity({
    required this.id,
    this.companyId,
    required this.ticketNumber,
    this.ticketType,
    this.villaNumber,
    this.villaId,
    this.villa,
    this.siteId,
    this.site,
    this.spaceId,
    this.space,
    required this.createdBy,
    this.creator,
    this.creatorName,
    required this.title,
    this.description,
    this.locationDetail,
    this.contactNumber,
    this.alternateContact,
    this.preferredTime,
    required this.status,
    required this.priority,
    this.priorityDetails,
    // Classification
    this.categoryId,
    this.category,
    this.departmentId,
    this.department,
    this.departmentName,
    // Assignment fields
    this.assignedSupervisorId,
    this.assignedSupervisor,
    this.assignedSupervisorName,
    this.supervisorAssignedAt,
    this.assignedTechnicianId,
    this.assignedTechnician,
    this.assignedTechnicianName,
    this.assignedTeamId,
    this.assignedTeam,
    this.assignedBy,
    this.assigner,
    this.assignedAt,
    this.acknowledgedBy,
    this.acknowledger,
    this.acknowledgedAt,
    this.scheduledAt,
    this.technicianNotes,
    this.resolutionNotes,
    this.completedAt,
    this.closedAt,
    this.autoCloseAt,
    required this.tenantConfirmed,
    // Rating fields
    this.rating,
    this.ratingComment,
    this.ratedAt,
    this.ratedBy,
    // Parent/Child relationships
    this.parentTicketId,
    // Escalation fields
    this.isEscalated = false,
    this.escalationLevel = 0,
    this.escalatedAt,
    // SLA fields
    this.slaDueAt,
    this.slaStatus,
    // Timestamps
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String? companyId;
  final String ticketNumber;
  final TicketType? ticketType;

  // Location fields
  final String? villaNumber;
  final String? villaId;
  final VillaEntity? villa;
  final String? siteId;
  final SiteEntity? site;
  final String? spaceId;
  final SpaceEntity? space;

  // Creator
  final String createdBy;
  final UserEntity? creator;
  final String? creatorName;

  // Content
  final String title;
  final String? description;
  final String? locationDetail;
  final String? contactNumber;
  final String? alternateContact;
  final String? preferredTime;
  final TicketStatus status;
  final TicketPriority priority;
  final PriorityDetailsEntity? priorityDetails;

  // Classification
  final String? categoryId;
  final TicketCategoryEntity? category;
  final String? departmentId;
  final DepartmentEntity? department;
  final String? departmentName;

  // Assignment
  final String? assignedSupervisorId;
  final UserEntity? assignedSupervisor;
  final String? assignedSupervisorName;
  final DateTime? supervisorAssignedAt;
  final String? assignedTechnicianId;
  final UserEntity? assignedTechnician;
  final String? assignedTechnicianName;
  final String? assignedTeamId;
  final TeamEntity? assignedTeam;
  final String? assignedBy;
  final UserEntity? assigner;
  final DateTime? assignedAt;
  final String? acknowledgedBy;
  final UserEntity? acknowledger;
  final DateTime? acknowledgedAt;
  final DateTime? scheduledAt;
  final String? technicianNotes;
  final String? resolutionNotes;
  final DateTime? completedAt;
  final DateTime? closedAt;
  final DateTime? autoCloseAt;
  final bool tenantConfirmed;

  // Rating fields
  final int? rating;
  final String? ratingComment;
  final DateTime? ratedAt;
  final String? ratedBy;

  // Parent/Child relationships
  final String? parentTicketId;

  // Escalation
  final bool isEscalated;
  final int escalationLevel;
  final DateTime? escalatedAt;

  // SLA Information
  final DateTime? slaDueAt;
  final String? slaStatus;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Helper: Get location display string
  String get locationDisplay {
    if (villa != null) {
      return villa!.displayName;
    }
    if (site != null && space != null) {
      return '${site!.displayName} → ${space!.displayName}';
    }
    if (site != null) {
      return site!.displayName;
    }
    if (space != null) {
      return space!.displayName;
    }
    // Fallback to deprecated villa_number for backward compatibility
    if (villaNumber != null) {
      return 'Villa $villaNumber';
    }
    return 'Unknown Location';
  }

  /// Helper: Check if ticket has parent
  bool hasParent() => parentTicketId != null && parentTicketId!.isNotEmpty;

  /// Helper: Check if ticket is escalated
  bool isEscalatedTicket() => isEscalated && escalationLevel > 0;

  /// Helper: Get ticket type display name
  String get ticketTypeDisplay {
    return ticketType?.displayName ?? 'Unknown';
  }

  /// Helper: Get ticket type color
  int? get ticketTypeColor => ticketType?.colorValue;

  /// Helper: Get creator name (from entity or fallback to stored name)
  String? get creatorDisplayName {
    if (creator != null) {
      final name =
          '${creator!.firstName ?? ''} ${creator!.lastName ?? ''}'.trim();
      return name.isNotEmpty ? name : creator!.email;
    }
    return creatorName;
  }

  /// Helper: Get department name (from entity or fallback to stored name)
  String? get departmentDisplayName {
    return department?.name ?? departmentName;
  }

  /// Helper: Get assigned supervisor name (from entity or fallback to stored name)
  String? get assignedSupervisorDisplayName {
    if (assignedSupervisor != null) {
      final name =
          '${assignedSupervisor!.firstName ?? ''} ${assignedSupervisor!.lastName ?? ''}'
              .trim();
      return name.isNotEmpty ? name : assignedSupervisor!.email;
    }
    return assignedSupervisorName;
  }

  /// Helper: Get assigned technician name (from entity or fallback to stored name)
  String? get assignedTechnicianDisplayName {
    if (assignedTechnician != null) {
      final name =
          '${assignedTechnician!.firstName ?? ''} ${assignedTechnician!.lastName ?? ''}'
              .trim();
      return name.isNotEmpty ? name : assignedTechnician!.email;
    }
    return assignedTechnicianName;
  }

  @override
  List<Object?> get props => [
        id,
        companyId,
        ticketNumber,
        ticketType,
        villaNumber,
        villaId,
        villa,
        siteId,
        site,
        spaceId,
        space,
        createdBy,
        creator,
        creatorName,
        title,
        description,
        locationDetail,
        contactNumber,
        alternateContact,
        preferredTime,
        status,
        priority,
        priorityDetails,
        categoryId,
        category,
        departmentId,
        department,
        departmentName,
        assignedSupervisorId,
        assignedSupervisor,
        assignedSupervisorName,
        supervisorAssignedAt,
        assignedTechnicianId,
        assignedTechnician,
        assignedTechnicianName,
        assignedTeamId,
        assignedTeam,
        assignedBy,
        assigner,
        assignedAt,
        acknowledgedBy,
        acknowledger,
        acknowledgedAt,
        scheduledAt,
        technicianNotes,
        resolutionNotes,
        completedAt,
        closedAt,
        autoCloseAt,
        tenantConfirmed,
        rating,
        ratingComment,
        ratedAt,
        ratedBy,
        parentTicketId,
        isEscalated,
        escalationLevel,
        escalatedAt,
        slaDueAt,
        slaStatus,
        createdAt,
        updatedAt,
      ];
}

class PriorityDetailsEntity extends Equatable {
  const PriorityDetailsEntity({
    this.colorCode,
    this.iconName,
    this.defaultSlaHours,
  });

  final String? colorCode;
  final String? iconName;
  final int? defaultSlaHours;

  @override
  List<Object?> get props => [colorCode, iconName, defaultSlaHours];
}

class DepartmentEntity extends Equatable {
  const DepartmentEntity({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
  });

  final String id;
  final String name;
  final String? description;
  final bool isActive;

  @override
  List<Object?> get props => [id, name, description, isActive];
}
