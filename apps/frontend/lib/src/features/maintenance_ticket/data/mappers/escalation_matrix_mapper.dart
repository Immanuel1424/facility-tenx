import '../../domain/entities/escalation_matrix_entity.dart';
import '../dto/maintenance_ticket_dto.dart';

class EscalationMatrixMapper {
  static EscalationMatrixEntity toEntity(EscalationMatrixDto dto) {
    return EscalationMatrixEntity(
      priority: dto.priority,
      level1Minutes: dto.level1_minutes,
      level2Minutes: dto.level2_minutes,
      level3Minutes: dto.level3_minutes,
    );
  }
}
