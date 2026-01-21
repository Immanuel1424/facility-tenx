import '../../domain/entities/permission_entity.dart';
import '../dto/permission_dto.dart';

class PermissionMapper {
  static PermissionEntity dtoToEntity(PermissionDto dto) {
    return PermissionEntity(
      id: dto.id,
      companyId: dto.companyId,
      resource: dto.resource,
      action: dto.action,
      description: dto.description,
    );
  }
}

