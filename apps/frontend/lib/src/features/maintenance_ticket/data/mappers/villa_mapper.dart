import '../../domain/entities/villa_entity.dart';
import '../dto/maintenance_ticket_dto.dart';

class VillaMapper {
  static VillaEntity? toEntity(VillaDto? dto) {
    if (dto == null) return null;

    // Handle empty string villa_number (from lookup endpoint that returns name)
    final villaNumber = dto.villa_number?.toString().trim();
    final villaCode = dto.villa_code?.trim();

    return VillaEntity(
      id: dto.id ?? 'UNKNOWN_ID',
      villaNumber: villaNumber?.isNotEmpty == true ? villaNumber : null,
      villaCode: villaCode?.isNotEmpty == true ? villaCode : null,
      siteId: dto.site_id,
      ownerName: dto.owner_name,
      tenantName: dto.tenant_name,
      contactPhone: dto.contact_phone,
      contactEmail: dto.contact_email,
      isActive: dto.is_active ?? true,
      isOccupied: dto.is_occupied ?? true,
    );
  }
}
