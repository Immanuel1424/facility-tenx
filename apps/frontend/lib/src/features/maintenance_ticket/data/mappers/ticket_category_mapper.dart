import '../../domain/entities/ticket_category_entity.dart';
import '../dto/maintenance_ticket_dto.dart';

class TicketCategoryMapper {
  static TicketCategoryEntity? toEntity(TicketCategoryDto? dto) {
    if (dto == null) return null;

    return TicketCategoryEntity(
      id: dto.id ?? 'UNKNOWN_ID',
      code: dto.code,
      name: dto.name,
      description: dto.description,
      parentCategoryId: dto.parent_category_id,
      displayOrder: dto.display_order ?? 0,
      isActive: dto.is_active ?? true,
      icon: dto.icon,
      colorCode: dto.color_code,
    );
  }
}
