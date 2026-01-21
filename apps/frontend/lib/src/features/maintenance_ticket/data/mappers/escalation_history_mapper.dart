import '../../domain/entities/escalation_history_entity.dart';
import '../dto/maintenance_ticket_dto.dart';

class EscalationHistoryMapper {
  static EscalationHistoryEntity toEntity(EscalationHistoryDto dto) {
    return EscalationHistoryEntity(
      id: dto.id,
      companyId: dto.company_id,
      ticketId: dto.ticket_id,
      escalationLevel: dto.escalation_level,
      escalatedFromRole: dto.escalated_from_role,
      escalatedToRole: dto.escalated_to_role,
      reason: dto.reason,
      escalatedBy: dto.escalated_by,
      escalatedAt: dto.escalated_at,
      isAutomatic: dto.is_automatic,
      createdAt: dto.created_at,
      updatedAt: dto.updated_at,
    );
  }
}
