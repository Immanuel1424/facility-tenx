import '../../../../core/utils/conversion_utils.dart';
import 'user_dto.dart';

/// Ticket type enum matching backend TicketType
enum TicketTypeDto {
  maintenance,
  serviceRequest,
  incident,
  inspection,
  preventive,
  complaint,
}

extension TicketTypeDtoExtension on TicketTypeDto {
  String get value {
    switch (this) {
      case TicketTypeDto.maintenance:
        return 'MAINTENANCE';
      case TicketTypeDto.serviceRequest:
        return 'SERVICE_REQUEST';
      case TicketTypeDto.incident:
        return 'INCIDENT';
      case TicketTypeDto.inspection:
        return 'INSPECTION';
      case TicketTypeDto.preventive:
        return 'PREVENTIVE';
      case TicketTypeDto.complaint:
        return 'COMPLAINT';
    }
  }

  static TicketTypeDto? fromString(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'MAINTENANCE':
        return TicketTypeDto.maintenance;
      case 'SERVICE_REQUEST':
        return TicketTypeDto.serviceRequest;
      case 'INCIDENT':
        return TicketTypeDto.incident;
      case 'INSPECTION':
        return TicketTypeDto.inspection;
      case 'PREVENTIVE':
        return TicketTypeDto.preventive;
      case 'COMPLAINT':
        return TicketTypeDto.complaint;
      default:
        return null;
    }
  }
}

class MaintenanceTicketDto {
  const MaintenanceTicketDto({
    required this.id,
    this.company_id,
    this.ticket_number,
    this.ticket_type,
    this.villa_number,
    this.villa_id,
    this.villa,
    this.site_id,
    this.site,
    this.space_id,
    this.space,
    this.created_by,
    this.creator,
    this.title,
    this.description,
    this.location_detail,
    this.contact_number,
    this.alternate_contact,
    this.preferred_time,
    this.status,
    this.priority,
    this.category_id,
    this.category,
    this.department_id,
    this.department,
    this.assigned_supervisor_id,
    this.assigned_supervisor,
    this.supervisor_assigned_at,
    this.assigned_technician_id,
    this.assigned_technician,
    this.assigned_team_id,
    this.assigned_team,
    this.assigned_by,
    this.assigner,
    this.assigned_at,
    this.acknowledged_by,
    this.acknowledger,
    this.acknowledged_at,
    this.scheduled_at,
    this.technician_notes,
    this.resolution_notes,
    this.completed_at,
    this.closed_at,
    this.auto_close_at,
    this.tenant_confirmed = false,
    this.rating,
    this.rating_comment,
    this.rated_at,
    this.rated_by,
    this.priority_details,
    this.parent_ticket_id,
    this.is_escalated = false,
    this.escalation_level = 0,
    this.escalated_at,
    this.sla_due_at,
    this.sla_status,
    this.created_at,
    this.updated_at,
  });

  final String id;
  final String? company_id;
  final String? ticket_number;
  final TicketTypeDto? ticket_type;

  // Location fields
  @Deprecated('Use villa_id instead')
  final String? villa_number;
  final String? villa_id;
  final VillaDto? villa;
  final String? site_id;
  final SiteDto? site;
  final String? space_id;
  final SpaceDto? space;

  // Creator
  final String? created_by;
  final UserDto? creator;

  // Content
  final String? title;
  final String? description;
  final String? location_detail;
  final String? contact_number;
  final String? alternate_contact;
  final String? preferred_time;
  final String? status;
  final String? priority;
  final TicketPriorityDetailsDto? priority_details;

  // Classification
  final String? category_id;
  final TicketCategoryDto? category;
  final String? department_id;
  final DepartmentDto? department;

  // Supervisor assignment
  final String? assigned_supervisor_id;
  final UserDto? assigned_supervisor;
  final DateTime? supervisor_assigned_at;

  // Technician assignment
  final String? assigned_technician_id;
  final UserDto? assigned_technician;

  // Team assignment
  final String? assigned_team_id;
  final TeamDto? assigned_team;

  // Assignment tracking
  final String? assigned_by;
  final UserDto? assigner;
  final DateTime? assigned_at;

  // Acknowledgement
  final String? acknowledged_by;
  final UserDto? acknowledger;
  final DateTime? acknowledged_at;

  // Workflow
  final DateTime? scheduled_at;
  final String? technician_notes;
  final String? resolution_notes;
  final DateTime? completed_at;
  final DateTime? closed_at;
  final DateTime? auto_close_at;
  final bool? tenant_confirmed;

  // Rating fields
  final int? rating;
  final String? rating_comment;
  final DateTime? rated_at;
  final String? rated_by;

  // Parent/Child relationship
  final String? parent_ticket_id;

  // Escalation
  final bool? is_escalated;
  final int? escalation_level;
  final DateTime? escalated_at;

  // SLA Information
  final DateTime? sla_due_at;
  final String? sla_status;

  // Timestamps
  final DateTime? created_at;
  final DateTime? updated_at;

  factory MaintenanceTicketDto.fromJson(Map<String, dynamic> json) {
    // Normalize camelCase keys from backend into snake_case expected by DTO
    final normalized = Map<String, dynamic>.from(json);

    void copyIfPresent(String source, String target) {
      if (normalized.containsKey(source)) {
        normalized[target] = normalized[source];
      }
    }

    copyIfPresent('companyId', 'company_id');
    copyIfPresent('ticketNumber', 'ticket_number');
    copyIfPresent('ticketType', 'ticket_type');
    copyIfPresent('villaNumber', 'villa_number');
    copyIfPresent('villaId', 'villa_id');
    copyIfPresent('siteId', 'site_id');
    copyIfPresent('spaceId', 'space_id');
    copyIfPresent('createdBy', 'created_by');
    copyIfPresent('categoryId', 'category_id');
    copyIfPresent('departmentId', 'department_id');
    copyIfPresent('assignedSupervisorId', 'assigned_supervisor_id');
    copyIfPresent('assignedSupervisor', 'assigned_supervisor');
    copyIfPresent('supervisorAssignedAt', 'supervisor_assigned_at');
    copyIfPresent('assignedTechnicianId', 'assigned_technician_id');
    copyIfPresent('assignedTechnician', 'assigned_technician');
    copyIfPresent('assignedBy', 'assigned_by');
    copyIfPresent('assignedAt', 'assigned_at');
    copyIfPresent('acknowledgedBy', 'acknowledged_by');
    copyIfPresent('acknowledgedAt', 'acknowledged_at');
    copyIfPresent('rating', 'rating');
    copyIfPresent('ratingComment', 'rating_comment');
    copyIfPresent('ratedAt', 'rated_at');
    copyIfPresent('ratedBy', 'rated_by');
    copyIfPresent('scheduledAt', 'scheduled_at');
    copyIfPresent('technicianNotes', 'technician_notes');
    copyIfPresent('resolutionNotes', 'resolution_notes');
    copyIfPresent('completedAt', 'completed_at');
    copyIfPresent('closedAt', 'closed_at');
    copyIfPresent('autoCloseAt', 'auto_close_at');
    copyIfPresent('tenantConfirmed', 'tenant_confirmed');
    copyIfPresent('assignedTeamId', 'assigned_team_id');
    copyIfPresent('parentTicketId', 'parent_ticket_id');
    copyIfPresent('isEscalated', 'is_escalated');
    copyIfPresent('escalationLevel', 'escalation_level');
    copyIfPresent('escalatedAt', 'escalated_at');
    copyIfPresent('createdAt', 'created_at');
    copyIfPresent('updatedAt', 'updated_at');

    // Nested objects (creator, department, category, etc.) are handled by
    // their own DTOs, which also normalize their internal keys.

    return MaintenanceTicketDto(
      id: normalized['id'] as String,
      company_id: normalized['company_id'] as String?,
      ticket_number: normalized['ticket_number'] as String?,
      ticket_type: TicketTypeDtoExtension.fromString(
        normalized['ticket_type'] as String?,
      ),
      villa_number: normalized['villa_number']?.toString(),
      villa_id: normalized['villa_id'] as String?,
      villa: normalized['villa'] != null
          ? VillaDto.fromJson(normalized['villa'] as Map<String, dynamic>)
          : null,
      site_id: normalized['site_id'] as String?,
      site: normalized['site'] != null
          ? SiteDto.fromJson(normalized['site'] as Map<String, dynamic>)
          : null,
      space_id: normalized['space_id'] as String?,
      space: normalized['space'] != null
          ? SpaceDto.fromJson(normalized['space'] as Map<String, dynamic>)
          : null,
      created_by: normalized['created_by'] as String?,
      creator: normalized['creator'] != null
          ? UserDto.fromJson(normalized['creator'] as Map<String, dynamic>)
          : null,
      title: normalized['title'] as String?,
      description: normalized['description'] as String?,
      location_detail: normalized['location_detail'] as String? ?? normalized['locationDetail'] as String?,
      contact_number: normalized['contact_number'] as String? ?? normalized['contactNumber'] as String?,
      alternate_contact: normalized['alternate_contact'] as String? ?? normalized['alternateContact'] as String?,
      preferred_time: normalized['preferred_time'] as String? ?? normalized['preferredTime'] as String?,
      status: normalized['status'] as String?,
      priority: normalized['priority'] as String?,
      priority_details: normalized['priority_details'] != null
          ? TicketPriorityDetailsDto.fromJson(
              normalized['priority_details'] as Map<String, dynamic>,
            )
          : null,
      category_id: normalized['category_id'] as String?,
      category: normalized['category'] != null
          ? TicketCategoryDto.fromJson(
              normalized['category'] as Map<String, dynamic>,
            )
          : null,
      department_id: normalized['department_id'] as String?,
      department: normalized['department'] != null
          ? DepartmentDto.fromJson(
              normalized['department'] as Map<String, dynamic>,
            )
          : null,
      assigned_supervisor_id: normalized['assigned_supervisor_id'] as String?,
      assigned_supervisor: normalized['assigned_supervisor'] != null
          ? UserDto.fromJson(
              normalized['assigned_supervisor'] as Map<String, dynamic>,
            )
          : null,
      supervisor_assigned_at: ConversionUtils.nullableDateTime(
        normalized['supervisor_assigned_at'] as String?,
      ),
      assigned_technician_id: normalized['assigned_technician_id'] as String?,
      assigned_technician: normalized['assigned_technician'] != null
          ? UserDto.fromJson(
              normalized['assigned_technician'] as Map<String, dynamic>,
            )
          : null,
      assigned_team_id: normalized['assigned_team_id'] as String?,
      assigned_team: normalized['assigned_team'] != null
          ? TeamDto.fromJson(
              normalized['assigned_team'] as Map<String, dynamic>)
          : null,
      assigned_by: normalized['assigned_by'] as String?,
      assigner: normalized['assigner'] != null
          ? UserDto.fromJson(normalized['assigner'] as Map<String, dynamic>)
          : null,
      assigned_at: ConversionUtils.nullableDateTime(
        normalized['assigned_at'] as String?,
      ),
      acknowledged_by: normalized['acknowledged_by'] as String?,
      acknowledger: normalized['acknowledger'] != null
          ? UserDto.fromJson(normalized['acknowledger'] as Map<String, dynamic>)
          : null,
      acknowledged_at: ConversionUtils.nullableDateTime(
        normalized['acknowledged_at'] as String?,
      ),
      scheduled_at: ConversionUtils.nullableDateTime(
        normalized['scheduled_at'] as String?,
      ),
      technician_notes: normalized['technician_notes'] as String?,
      resolution_notes: normalized['resolution_notes'] as String?,
      completed_at: ConversionUtils.nullableDateTime(
        normalized['completed_at'] as String?,
      ),
      closed_at: ConversionUtils.nullableDateTime(
        normalized['closed_at'] as String?,
      ),
      auto_close_at: ConversionUtils.nullableDateTime(
        normalized['auto_close_at'] as String?,
      ),
      tenant_confirmed: normalized['tenant_confirmed'] as bool? ?? false,
      rating: normalized['rating'] as int?,
      rating_comment: normalized['rating_comment'] as String?,
      rated_at: ConversionUtils.nullableDateTime(
        normalized['rated_at'] as String?,
      ),
      rated_by: normalized['rated_by'] as String?,
      parent_ticket_id: normalized['parent_ticket_id'] as String?,
      is_escalated: normalized['is_escalated'] as bool? ?? false,
      escalation_level: (normalized['escalation_level'] as num?)?.toInt() ?? 0,
      escalated_at: ConversionUtils.nullableDateTime(
        normalized['escalated_at'] as String?,
      ),
      sla_due_at: ConversionUtils.nullableDateTime(
        normalized['sla_due_at'] as String? ?? normalized['slaDueAt'] as String?,
      ),
      sla_status: normalized['sla_status'] as String? ?? normalized['slaStatus'] as String?,
      created_at: ConversionUtils.nullableDateTime(
        normalized['created_at'] as String?,
      ),
      updated_at: ConversionUtils.nullableDateTime(
        normalized['updated_at'] as String?,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': company_id,
      'ticket_number': ticket_number,
      'ticket_type': ticket_type?.value,
      'villa_number': villa_number,
      'villa_id': villa_id,
      'villa': villa?.toJson(),
      'site_id': site_id,
      'site': site?.toJson(),
      'space_id': space_id,
      'space': space?.toJson(),
      'created_by': created_by,
      'creator': creator?.toJson(),
      'title': title,
      'description': description,
      'location_detail': location_detail,
      'contact_number': contact_number,
      'alternate_contact': alternate_contact,
      'preferred_time': preferred_time,
      'status': status,
      'priority': priority,
      'priority_details': priority_details?.toJson(),
      'category_id': category_id,
      'category': category?.toJson(),
      'department_id': department_id,
      'department': department?.toJson(),
      'assigned_supervisor_id': assigned_supervisor_id,
      'assigned_supervisor': assigned_supervisor?.toJson(),
      'supervisor_assigned_at': supervisor_assigned_at?.toIso8601String(),
      'assigned_technician_id': assigned_technician_id,
      'assigned_technician': assigned_technician?.toJson(),
      'assigned_team_id': assigned_team_id,
      'assigned_team': assigned_team?.toJson(),
      'assigned_by': assigned_by,
      'assigner': assigner?.toJson(),
      'assigned_at': assigned_at?.toIso8601String(),
      'acknowledged_by': acknowledged_by,
      'acknowledger': acknowledger?.toJson(),
      'acknowledged_at': acknowledged_at?.toIso8601String(),
      'scheduled_at': scheduled_at?.toIso8601String(),
      'technician_notes': technician_notes,
      'resolution_notes': resolution_notes,
      'completed_at': completed_at?.toIso8601String(),
      'closed_at': closed_at?.toIso8601String(),
      'auto_close_at': auto_close_at?.toIso8601String(),
      'tenant_confirmed': tenant_confirmed,
      'rating': rating,
      'rating_comment': rating_comment,
      'rated_at': rated_at?.toIso8601String(),
      'rated_by': rated_by,
      'parent_ticket_id': parent_ticket_id,
      'is_escalated': is_escalated,
      'escalation_level': escalation_level,
      'escalated_at': escalated_at?.toIso8601String(),
      'sla_due_at': sla_due_at?.toIso8601String(),
      'sla_status': sla_status,
      'created_at': created_at?.toIso8601String(),
      'updated_at': updated_at?.toIso8601String(),
    };
  }
}

class DepartmentDto {
  const DepartmentDto({
    this.id,
    this.name,
    this.description,
    this.is_active = true,
  });

  final String? id;
  final String? name;
  final String? description;
  final bool? is_active;

  factory DepartmentDto.fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    if (normalized.containsKey('isActive')) {
      normalized['is_active'] = normalized['isActive'];
    }
    return DepartmentDto(
      id: normalized['id'] as String?,
      name: normalized['name'] as String?,
      description: normalized['description'] as String?,
      is_active: normalized['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'is_active': is_active,
      };
}

class TicketCategoryDto {
  const TicketCategoryDto({
    this.id,
    this.code,
    this.name,
    this.description,
    this.parent_category_id,
    this.display_order = 0,
    this.is_active = true,
    this.icon,
    this.color_code,
  });

  final String? id;
  final String? code;
  final String? name;
  final String? description;
  final String? parent_category_id;
  final int? display_order;
  final bool? is_active;
  final String? icon;
  final String? color_code;

  factory TicketCategoryDto.fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    if (normalized.containsKey('parentCategoryId')) {
      normalized['parent_category_id'] = normalized['parentCategoryId'];
    }
    if (normalized.containsKey('displayOrder')) {
      normalized['display_order'] = normalized['displayOrder'];
    }
    if (normalized.containsKey('isActive')) {
      normalized['is_active'] = normalized['isActive'];
    }
    if (normalized.containsKey('colorCode')) {
      normalized['color_code'] = normalized['colorCode'];
    }
    return TicketCategoryDto(
      id: normalized['id'] as String?,
      code: normalized['code'] as String?,
      name: normalized['name'] as String?,
      description: normalized['description'] as String?,
      parent_category_id: normalized['parent_category_id'] as String?,
      display_order: (normalized['display_order'] as num?)?.toInt() ?? 0,
      is_active: normalized['is_active'] as bool? ?? true,
      icon: normalized['icon'] as String?,
      color_code: normalized['color_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'description': description,
        'parent_category_id': parent_category_id,
        'display_order': display_order,
        'is_active': is_active,
        'icon': icon,
        'color_code': color_code,
      };
}

class TeamDto {
  const TeamDto({
    this.id,
    this.name,
    this.description,
    this.department_id,
    this.lead_user_id,
    this.is_active = true,
    this.color_code,
  });

  final String? id;
  final String? name;
  final String? description;
  final String? department_id;
  final String? lead_user_id;
  final bool? is_active;
  final String? color_code;

  factory TeamDto.fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    if (normalized.containsKey('departmentId')) {
      normalized['department_id'] = normalized['departmentId'];
    }
    if (normalized.containsKey('leadUserId')) {
      normalized['lead_user_id'] = normalized['leadUserId'];
    }
    if (normalized.containsKey('isActive')) {
      normalized['is_active'] = normalized['isActive'];
    }
    if (normalized.containsKey('colorCode')) {
      normalized['color_code'] = normalized['colorCode'];
    }
    return TeamDto(
      id: normalized['id'] as String?,
      name: normalized['name'] as String?,
      description: normalized['description'] as String?,
      department_id: normalized['department_id'] as String?,
      lead_user_id: normalized['lead_user_id'] as String?,
      is_active: normalized['is_active'] as bool? ?? true,
      color_code: normalized['color_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'department_id': department_id,
        'lead_user_id': lead_user_id,
        'is_active': is_active,
        'color_code': color_code,
      };
}

class VillaDto {
  const VillaDto({
    this.id,
    this.villa_number,
    this.villa_code,
    this.site_id,
    this.owner_name,
    this.tenant_name,
    this.contact_phone,
    this.contact_email,
    this.is_active = true,
    this.is_occupied = true,
  });

  final String? id;
  final String? villa_number;
  final String? villa_code;
  final String? site_id;
  final String? owner_name;
  final String? tenant_name;
  final String? contact_phone;
  final String? contact_email;
  final bool? is_active;
  final bool? is_occupied;

  factory VillaDto.fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    
    // Handle simplified format from /lookup/villas endpoint (returns { id, code, name })
    if (normalized.containsKey('code') && !normalized.containsKey('villa_code')) {
      normalized['villa_code'] = normalized['code'];
    }
    if (normalized.containsKey('name') && !normalized.containsKey('villa_number')) {
      // Use name as villa_number if not provided (for lookup endpoint compatibility)
      normalized['villa_number'] = normalized['name']?.toString();
    }
    
    if (normalized.containsKey('villaNumber')) {
      normalized['villa_number'] = normalized['villaNumber']?.toString();
    }
    if (normalized.containsKey('villaCode')) {
      normalized['villa_code'] = normalized['villaCode'];
    }
    if (normalized.containsKey('siteId')) {
      normalized['site_id'] = normalized['siteId'];
    }
    if (normalized.containsKey('ownerName')) {
      normalized['owner_name'] = normalized['ownerName'];
    }
    if (normalized.containsKey('tenantName')) {
      normalized['tenant_name'] = normalized['tenantName'];
    }
    if (normalized.containsKey('contactPhone')) {
      normalized['contact_phone'] = normalized['contactPhone'];
    }
    if (normalized.containsKey('contactEmail')) {
      normalized['contact_email'] = normalized['contactEmail'];
    }
    if (normalized.containsKey('isActive')) {
      normalized['is_active'] = normalized['isActive'];
    }
    if (normalized.containsKey('isOccupied')) {
      normalized['is_occupied'] = normalized['isOccupied'];
    }
    return VillaDto(
      id: normalized['id'] as String?,
      villa_number: normalized['villa_number']?.toString(),
      villa_code: normalized['villa_code'] as String?,
      site_id: normalized['site_id'] as String?,
      owner_name: normalized['owner_name'] as String?,
      tenant_name: normalized['tenant_name'] as String?,
      contact_phone: normalized['contact_phone'] as String?,
      contact_email: normalized['contact_email'] as String?,
      is_active: normalized['is_active'] as bool? ?? true,
      is_occupied: normalized['is_occupied'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'villa_number': villa_number,
        'villa_code': villa_code,
        'site_id': site_id,
        'owner_name': owner_name,
        'tenant_name': tenant_name,
        'contact_phone': contact_phone,
        'contact_email': contact_email,
        'is_active': is_active,
        'is_occupied': is_occupied,
      };
}

class CompanyDto {
  const CompanyDto({
    this.id,
    this.code,
    this.name,
  });

  final String? id;
  final String? code;
  final String? name;

  factory CompanyDto.fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    return CompanyDto(
      id: normalized['id'] as String?,
      code: normalized['code'] as String?,
      name: normalized['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
      };
}

class SiteDto {
  const SiteDto({
    this.id,
    this.code,
    this.name,
    this.description,
    this.company_id,
    this.is_parent = true,
    this.is_active = true,
  });

  final String? id;
  final String? code;
  final String? name;
  final String? description;
  final String? company_id;
  final bool? is_parent;
  final bool? is_active;

  factory SiteDto.fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    if (normalized.containsKey('companyId')) {
      normalized['company_id'] = normalized['companyId'];
    }
    if (normalized.containsKey('isParent')) {
      normalized['is_parent'] = normalized['isParent'];
    }
    if (normalized.containsKey('isActive')) {
      normalized['is_active'] = normalized['isActive'];
    }
    return SiteDto(
      id: normalized['id'] as String?,
      code: normalized['code'] as String?,
      name: normalized['name'] as String?,
      description: normalized['description'] as String?,
      company_id: normalized['company_id'] as String?,
      is_parent: normalized['is_parent'] as bool? ?? true,
      is_active: normalized['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'description': description,
        'company_id': company_id,
        'is_parent': is_parent,
        'is_active': is_active,
      };
}

class SpaceDto {
  const SpaceDto({
    this.id,
    this.code,
    this.name,
    this.description,
    this.site_id,
    this.is_active = true,
  });

  final String? id;
  final String? code;
  final String? name;
  final String? description;
  final String? site_id;
  final bool? is_active;

  factory SpaceDto.fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    if (normalized.containsKey('siteId')) {
      normalized['site_id'] = normalized['siteId'];
    }
    if (normalized.containsKey('isActive')) {
      normalized['is_active'] = normalized['isActive'];
    }
    return SpaceDto(
      id: normalized['id'] as String?,
      code: normalized['code'] as String?,
      name: normalized['name'] as String?,
      description: normalized['description'] as String?,
      site_id: normalized['site_id'] as String?,
      is_active: normalized['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'description': description,
        'site_id': site_id,
        'is_active': is_active,
      };
}

// UserDto is now imported from user_dto.dart

class CreateTicketDto {
  const CreateTicketDto({
    required this.title,
    this.description,
    this.villa_number,
    this.villa_id,
    this.site_id,
    this.space_id,
    this.priority,
    this.category_id,
    this.ticket_type,
    this.contact_number,
    this.alternate_contact,
    this.preferred_time,
    this.category,
    this.location_detail,
  });

  final String title;
  final String? description;
  @Deprecated('Use villa_id instead')
  final String? villa_number;
  final String? villa_id;
  final String? site_id;
  final String? space_id;
  final String? priority;
  final String? category_id;
  final String? ticket_type;
  final String? contact_number;
  final String? alternate_contact;
  final String? preferred_time;
  final String? category;
  final String? location_detail;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'title': title,
    };
    // Only include fields that the backend CreateTicketDto accepts
    if (description != null && description!.isNotEmpty) {
      json['description'] = description;
    }
    if (villa_number != null) {
      json['villa_number'] = villa_number;
    }
    if (priority != null) {
      json['priority'] = priority;
    }
    if (contact_number != null && contact_number!.isNotEmpty) {
      json['contact_number'] = contact_number;
    }
    if (alternate_contact != null && alternate_contact!.isNotEmpty) {
      json['alternate_contact'] = alternate_contact;
    }
    if (preferred_time != null && preferred_time!.isNotEmpty) {
      json['preferred_time'] = preferred_time;
    }
    if (category != null && category!.isNotEmpty) {
      json['category'] = category;
    }
    if (category_id != null && category_id!.isNotEmpty) {
      json['category_id'] = category_id;
    }
    if (ticket_type != null && ticket_type!.isNotEmpty) {
      json['ticket_type'] = ticket_type;
    }
    if (location_detail != null && location_detail!.isNotEmpty) {
      json['location_detail'] = location_detail;
    }
    // Backend CreateTicketDto does NOT accept:
    // - villa_id
    // - site_id
    // - space_id
    // These fields are excluded from the JSON payload
    return json;
  }
}

class UpdateTicketDto {
  const UpdateTicketDto({
    this.title,
    this.description,
    this.priority,
    this.category_id,
    this.site_id,
    this.space_id,
  });

  final String? title;
  final String? description;
  final String? priority;
  final String? category_id;
  final String? site_id;
  final String? space_id;

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'priority': priority,
        'category_id': category_id,
        'site_id': site_id,
        'space_id': space_id,
      };
}

class ChangeStatusDto {
  const ChangeStatusDto({
    required this.status,
    this.notes,
  });

  final String status;
  final String? notes;

  Map<String, dynamic> toJson() => {
        'status': status,
        'notes': notes,
      };
}

class AddNotesDto {
  const AddNotesDto({required this.notes});

  final String notes;

  Map<String, dynamic> toJson() => {'notes': notes};
}

class EscalateTicketDto {
  const EscalateTicketDto({
    required this.escalation_level,
    this.reason,
  });

  final int escalation_level;
  final String? reason;

  Map<String, dynamic> toJson() => {
        'escalation_level': escalation_level,
        if (reason != null) 'reason': reason,
      };
}

class EscalationHistoryDto {
  const EscalationHistoryDto({
    required this.id,
    required this.company_id,
    required this.ticket_id,
    required this.escalation_level,
    this.escalated_from_role,
    this.escalated_to_role,
    this.reason,
    this.escalated_by,
    required this.escalated_at,
    required this.is_automatic,
    required this.created_at,
    required this.updated_at,
  });

  final String id;
  final String company_id;
  final String ticket_id;
  final int escalation_level;
  final String? escalated_from_role;
  final String? escalated_to_role;
  final String? reason;
  final String? escalated_by;
  final DateTime escalated_at;
  final bool is_automatic;
  final DateTime created_at;
  final DateTime updated_at;

  factory EscalationHistoryDto.fromJson(Map<String, dynamic> json) {
    return EscalationHistoryDto(
      id: json['id'] as String,
      company_id: json['company_id'] as String? ?? json['companyId'] as String,
      ticket_id: json['ticket_id'] as String? ?? json['ticketId'] as String,
      escalation_level: json['escalation_level'] as int? ??
          json['escalationLevel'] as int,
      escalated_from_role: json['escalated_from_role'] as String? ??
          json['escalatedFromRole'] as String?,
      escalated_to_role: json['escalated_to_role'] as String? ??
          json['escalatedToRole'] as String?,
      reason: json['reason'] as String?,
      escalated_by: json['escalated_by'] as String? ??
          json['escalatedBy'] as String?,
      escalated_at: json['escalated_at'] != null
          ? DateTime.parse(json['escalated_at'] as String)
          : DateTime.parse(json['escalatedAt'] as String),
      is_automatic: json['is_automatic'] as bool? ??
          json['isAutomatic'] as bool? ??
          false,
      created_at: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.parse(json['createdAt'] as String),
      updated_at: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'company_id': company_id,
        'ticket_id': ticket_id,
        'escalation_level': escalation_level,
        if (escalated_from_role != null)
          'escalated_from_role': escalated_from_role,
        if (escalated_to_role != null) 'escalated_to_role': escalated_to_role,
        if (reason != null) 'reason': reason,
        if (escalated_by != null) 'escalated_by': escalated_by,
        'escalated_at': escalated_at.toIso8601String(),
        'is_automatic': is_automatic,
        'created_at': created_at.toIso8601String(),
        'updated_at': updated_at.toIso8601String(),
      };
}

class EscalationMatrixDto {
  const EscalationMatrixDto({
    required this.priority,
    this.level1_minutes,
    this.level2_minutes,
    this.level3_minutes,
  });

  final String priority;
  final int? level1_minutes;
  final int? level2_minutes;
  final int? level3_minutes;

  factory EscalationMatrixDto.fromJson(Map<String, dynamic> json) {
    return EscalationMatrixDto(
      priority: json['priority'] as String,
      level1_minutes: json['level1_minutes'] as int? ??
          json['level1Minutes'] as int?,
      level2_minutes: json['level2_minutes'] as int? ??
          json['level2Minutes'] as int?,
      level3_minutes: json['level3_minutes'] as int? ??
          json['level3Minutes'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'priority': priority,
        if (level1_minutes != null) 'level1_minutes': level1_minutes,
        if (level2_minutes != null) 'level2_minutes': level2_minutes,
        if (level3_minutes != null) 'level3_minutes': level3_minutes,
      };
}

class LinkTicketDto {
  const LinkTicketDto({
    required this.parent_ticket_id,
  });

  final String parent_ticket_id;

  Map<String, dynamic> toJson() => {'parent_ticket_id': parent_ticket_id};
}

class TicketPriorityDetailsDto {
  const TicketPriorityDetailsDto({
    this.color_code,
    this.icon_name,
    this.default_sla_hours,
  });

  // Backend PriorityDetails returns camelCase (colorCode, iconName, defaultSlaHours)
  // but we use snake_case in DTO. Custom fromJson handles both formats.
  final String? color_code;
  final String? icon_name;
  final int? default_sla_hours;

  factory TicketPriorityDetailsDto.fromJson(Map<String, dynamic> json) {
    // Handle both camelCase (from backend) and snake_case formats
    return TicketPriorityDetailsDto(
      color_code: json['color_code'] as String? ?? json['colorCode'] as String?,
      icon_name: json['icon_name'] as String? ?? json['iconName'] as String?,
      default_sla_hours: json['default_sla_hours'] as int? ??
          (json['defaultSlaHours'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'color_code': color_code,
        'icon_name': icon_name,
        'default_sla_hours': default_sla_hours,
      };
}
