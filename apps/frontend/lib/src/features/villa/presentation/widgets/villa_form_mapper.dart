import '../bloc/villa_event.dart';

/// Maps form data to CreateVilla event
/// Handles null/empty string conversion and type parsing
class VillaFormMapper {
  static CreateVilla mapFormDataToEvent(Map<String, dynamic> formData) {
    return CreateVilla(
      villaNumber: formData['villa_number'] as String,
      ownerName: _parseOptionalString(formData['owner_name']),
      contactPhone: _parseOptionalString(formData['contact_phone']),
      contactEmail: _parseOptionalString(formData['contact_email']),
      city: _parseOptionalString(formData['city']),
      pinCode: _parseOptionalString(formData['pin_code']),
      block: _parseOptionalString(formData['block']),
      street: _parseOptionalString(formData['street']),
      floorCount: _parseOptionalInt(formData['floor_count']),
      bedroomCount: _parseOptionalInt(formData['bedroom_count']),
      areaSqm: _parseOptionalDouble(formData['area_sqm']),
      villaType: _parseOptionalString(formData['villa_type']),
      parkingSlotNumber: _parseOptionalString(formData['parking_slot_number']),
      meterNumber: _parseOptionalString(formData['meter_number']),
      waterMeterNumber: _parseOptionalString(formData['water_meter_number']),
      remarks: _parseOptionalString(formData['remarks']),
      isActive: formData['is_active'] as bool? ?? true,
      isOccupied: false,
    );
  }

  static String? _parseOptionalString(dynamic value) {
    if (value == null) return null;
    final trimmed = value.toString().trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static int? _parseOptionalInt(dynamic value) {
    if (value == null) return null;
    final trimmed = value.toString().trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  static double? _parseOptionalDouble(dynamic value) {
    if (value == null) return null;
    final trimmed = value.toString().trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed);
  }
}

