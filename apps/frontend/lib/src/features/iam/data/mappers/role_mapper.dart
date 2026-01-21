import '../../domain/entities/role_entity.dart';
import '../dto/role_dto.dart';

class RoleMapper {
  static RoleEntity dtoToEntity(RoleDto dto) {
    return RoleEntity(
      id: dto.id,
      companyId: dto.companyId,
      name: dto.name,
      description: dto.description,
      hierarchyLevel: dto.hierarchyLevel,
      parentRoleId: dto.parentRoleId,
    );
  }
}

