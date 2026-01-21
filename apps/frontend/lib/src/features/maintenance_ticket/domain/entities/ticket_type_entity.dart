/// Ticket type enum matching backend TicketType
enum TicketType {
  maintenance,
  serviceRequest,
  incident,
  inspection,
  preventive,
  complaint;

  /// Convert from DTO enum
  static TicketType? fromDto(dynamic dtoValue) {
    if (dtoValue == null) return null;
    
    final String value = dtoValue.toString().toUpperCase();
    switch (value) {
      case 'MAINTENANCE':
        return TicketType.maintenance;
      case 'SERVICE_REQUEST':
        return TicketType.serviceRequest;
      case 'INCIDENT':
        return TicketType.incident;
      case 'INSPECTION':
        return TicketType.inspection;
      case 'PREVENTIVE':
        return TicketType.preventive;
      case 'COMPLAINT':
        return TicketType.complaint;
      default:
        return null;
    }
  }

  /// Convert to backend string value
  String get backendValue {
    switch (this) {
      case TicketType.maintenance:
        return 'MAINTENANCE';
      case TicketType.serviceRequest:
        return 'SERVICE_REQUEST';
      case TicketType.incident:
        return 'INCIDENT';
      case TicketType.inspection:
        return 'INSPECTION';
      case TicketType.preventive:
        return 'PREVENTIVE';
      case TicketType.complaint:
        return 'COMPLAINT';
    }
  }

  /// Display name for UI
  String get displayName {
    switch (this) {
      case TicketType.maintenance:
        return 'Maintenance';
      case TicketType.serviceRequest:
        return 'Service Request';
      case TicketType.incident:
        return 'Incident';
      case TicketType.inspection:
        return 'Inspection';
      case TicketType.preventive:
        return 'Preventive';
      case TicketType.complaint:
        return 'Complaint';
    }
  }

  /// Color for UI display
  int get colorValue {
    switch (this) {
      case TicketType.maintenance:
        return 0xFF2196F3; // Blue
      case TicketType.serviceRequest:
        return 0xFF4CAF50; // Green
      case TicketType.incident:
        return 0xFFF44336; // Red
      case TicketType.inspection:
        return 0xFFFF9800; // Orange
      case TicketType.preventive:
        return 0xFF9C27B0; // Purple
      case TicketType.complaint:
        return 0xFFFFEB3B; // Yellow
    }
  }
}

