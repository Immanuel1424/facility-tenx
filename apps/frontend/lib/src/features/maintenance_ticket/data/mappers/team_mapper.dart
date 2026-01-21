import '../../domain/entities/team_entity.dart';
import '../dto/maintenance_ticket_dto.dart';

class TeamMapper {
  static TeamEntity? toEntity(TeamDto? dto) {
    if (dto == null) return null;

    return TeamEntity(
      id: dto.id ?? 'UNKNOWN_ID',
      name: dto.name,
      description: dto.description,
      departmentId: dto.department_id,
      leadUserId: dto.lead_user_id,
      isActive: dto.is_active ?? true,
      colorCode: dto.color_code,
    );
  }
}
