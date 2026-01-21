import '../dto/department_dto.dart';
import '../../domain/entities/department_entity.dart';

class DepartmentMapper {
  static DepartmentEntity toEntity(DepartmentDto dto) {
    return DepartmentEntity(
      id: dto.id,
      name: dto.name,
      description: dto.description,
      isActive: dto.isActive,
      companyId: dto.companyId,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  static List<DepartmentEntity> toEntityList(List<DepartmentDto> dtos) {
    return dtos.map(toEntity).toList();
  }
}

