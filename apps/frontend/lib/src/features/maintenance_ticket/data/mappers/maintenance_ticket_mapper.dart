import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/maintenance_ticket_entity.dart';
import '../../domain/entities/ticket_type_entity.dart';
import '../dto/maintenance_ticket_dto.dart';
import '../dto/user_dto.dart';
import 'villa_mapper.dart';
import 'team_mapper.dart';
import 'site_mapper.dart';
import 'space_mapper.dart';
import 'ticket_category_mapper.dart';

class MaintenanceTicketMapper {
  static MaintenanceTicketEntity toEntity(MaintenanceTicketDto dto) {
    // Map ticket type
    final ticketType =
        dto.ticket_type != null ? TicketType.fromDto(dto.ticket_type) : null;

    // Map creator entity and name
    final creator = dto.creator != null ? _userDtoToEntity(dto.creator!) : null;
    final creatorName =
        creator != null ? _getUserNameFromEntity(creator) : null;

    // Map assigned supervisor entity and name
    final assignedSupervisor = dto.assigned_supervisor != null
        ? _userDtoToEntity(dto.assigned_supervisor!)
        : null;
    final assignedSupervisorName = assignedSupervisor != null
        ? _getUserNameFromEntity(assignedSupervisor)
        : null;

    // Map assigned technician entity and name
    final assignedTechnician = dto.assigned_technician != null
        ? _userDtoToEntity(dto.assigned_technician!)
        : null;
    final assignedTechnicianName = assignedTechnician != null
        ? _getUserNameFromEntity(assignedTechnician)
        : null;

    // Map assigner entity
    final assigner =
        dto.assigner != null ? _userDtoToEntity(dto.assigner!) : null;

    // Map acknowledger entity
    final acknowledger =
        dto.acknowledger != null ? _userDtoToEntity(dto.acknowledger!) : null;

    // Map department entity
    final department =
        dto.department != null ? departmentToEntity(dto.department!) : null;

    return MaintenanceTicketEntity(
      id: dto.id,
      companyId: dto.company_id,
      ticketNumber: dto.ticket_number ?? 'N/A',
      ticketType: ticketType,
      // Location fields
      villaNumber: dto.villa_number,
      villaId: dto.villa_id,
      villa: VillaMapper.toEntity(dto.villa),
      siteId: dto.site_id,
      site: SiteMapper.toEntity(dto.site),
      spaceId: dto.space_id,
      space: SpaceMapper.toEntity(dto.space),
      // Creator
      createdBy: dto.created_by ?? 'Unknown',
      creator: creator,
      creatorName: creatorName,
      // Content
      title: dto.title ?? 'No Title',
      description: dto.description,
      locationDetail: dto.location_detail,
      contactNumber: dto.contact_number,
      alternateContact: dto.alternate_contact,
      preferredTime: dto.preferred_time,
      status: TicketStatus.fromString(dto.status ?? 'new'),
      priority: TicketPriority.fromString(dto.priority ?? 'medium'),
      priorityDetails: dto.priority_details != null
          ? PriorityDetailsEntity(
              colorCode: dto.priority_details!.color_code,
              iconName: dto.priority_details!.icon_name,
              defaultSlaHours: dto.priority_details!.default_sla_hours,
            )
          : null,
      // Classification
      categoryId: dto.category_id,
      category: TicketCategoryMapper.toEntity(dto.category),
      departmentId: dto.department_id,
      department: department,
      departmentName: department?.name,
      // Assignment
      assignedSupervisorId: dto.assigned_supervisor_id,
      assignedSupervisor: assignedSupervisor,
      assignedSupervisorName: assignedSupervisorName,
      supervisorAssignedAt: dto.supervisor_assigned_at,
      assignedTechnicianId: dto.assigned_technician_id,
      assignedTechnician: assignedTechnician,
      assignedTechnicianName: assignedTechnicianName,
      assignedTeamId: dto.assigned_team_id,
      assignedTeam: TeamMapper.toEntity(dto.assigned_team),
      assignedBy: dto.assigned_by,
      assigner: assigner,
      assignedAt: dto.assigned_at,
      acknowledgedBy: dto.acknowledged_by,
      acknowledger: acknowledger,
      acknowledgedAt: dto.acknowledged_at,
      scheduledAt: dto.scheduled_at,
      technicianNotes: dto.technician_notes,
      resolutionNotes: dto.resolution_notes,
      completedAt: dto.completed_at,
      closedAt: dto.closed_at,
      autoCloseAt: dto.auto_close_at,
      tenantConfirmed: dto.tenant_confirmed ?? false,
      // Rating fields
      rating: dto.rating,
      ratingComment: dto.rating_comment,
      ratedAt: dto.rated_at,
      ratedBy: dto.rated_by,
      // Parent/Child relationships
      parentTicketId: dto.parent_ticket_id,
      // Escalation
      isEscalated: dto.is_escalated ?? false,
      escalationLevel: dto.escalation_level ?? 0,
      escalatedAt: dto.escalated_at,
      // SLA Information
      slaDueAt: dto.sla_due_at,
      slaStatus: dto.sla_status,
      // Timestamps
      createdAt: dto.created_at ?? DateTime.now(),
      updatedAt: dto.updated_at ?? DateTime.now(),
    );
  }

  /// Helper method to convert UserDto to UserEntity
  static UserEntity? _userDtoToEntity(UserDto? userDto) {
    if (userDto == null ||
        userDto.id == null ||
        userDto.email == null ||
        userDto.company_id == null) {
      return null;
    }
    return UserEntity(
      id: userDto.id!,
      email: userDto.email!,
      companyId: userDto.company_id!,
      siteId: '', // Site info not available in maintenance ticket UserDto
      siteCode: '', // Site info not available in maintenance ticket UserDto
      firstName: userDto.first_name,
      lastName: userDto.last_name,
      villaNumber: userDto.villa_number?.toString(),
      roles: const [],
      permissions: const [],
    );
  }

  /// Helper method to extract user name from UserEntity
  static String? _getUserNameFromEntity(UserEntity user) {
    final firstName = user.firstName;
    final lastName = user.lastName;
    if (firstName != null && lastName != null) {
      final fullName = '$firstName $lastName'.trim();
      if (fullName.isNotEmpty) {
        return fullName;
      }
    }
    return user.email;
  }

  static DepartmentEntity departmentToEntity(DepartmentDto dto) {
    return DepartmentEntity(
      id: dto.id ?? 'UNKNOWN_ID',
      name: dto.name ?? 'Unnamed Department',
      description: dto.description,
      isActive: dto.is_active ?? true,
    );
  }
}
