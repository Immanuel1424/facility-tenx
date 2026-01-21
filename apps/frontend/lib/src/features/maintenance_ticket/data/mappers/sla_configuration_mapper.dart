import '../../domain/entities/maintenance_ticket_entity.dart';
import '../../domain/entities/sla_configuration_entity.dart';
import '../dto/sla_configuration_dto.dart';

class SlaConfigurationMapper {
  static SlaConfigurationEntity toEntity(SlaConfigurationDto dto) {
    return SlaConfigurationEntity(
      id: dto.id,
      companyId: dto.company_id,
      name: dto.name,
      description: dto.description,
      priority: TicketPriority.fromString(dto.priority),
      firstResponseTimeMinutes: dto.first_response_time_minutes,
      acknowledgementTimeMinutes: dto.acknowledgement_time_minutes,
      resolutionTimeMinutes: dto.resolution_time_minutes,
      escalationLevel1Minutes: dto.escalation_level_1_minutes,
      escalationLevel2Minutes: dto.escalation_level_2_minutes,
      escalationLevel3Minutes: dto.escalation_level_3_minutes,
      applyBusinessHours: dto.apply_business_hours,
      businessStartTime: dto.business_start_time,
      businessEndTime: dto.business_end_time,
      workingDays: dto.working_days,
      excludeHolidays: dto.exclude_holidays,
      isActive: dto.is_active,
      createdById: dto.created_by_id,
      createdAt: dto.created_at,
      updatedAt: dto.updated_at,
    );
  }
}
