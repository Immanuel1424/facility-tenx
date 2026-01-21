import '../dto/company_dto.dart';
import '../../domain/entities/company_entity.dart';

class CompanyMapper {
  static CompanyEntity toEntity(CompanyDto dto) {
    return CompanyEntity(
      id: dto.id,
      code: dto.code,
      name: dto.name,
      description: dto.description,
      logoUrl: dto.logoUrl,
      timezone: dto.timezone,
      currency: dto.currency,
      isActive: dto.isActive,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  static List<CompanyEntity> toEntityList(List<CompanyDto> dtos) {
    return dtos.map(toEntity).toList();
  }
}

