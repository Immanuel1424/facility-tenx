import '../../domain/entities/maintenance_ticket_entity.dart';

/// Result model for paginated ticket queries
class PaginatedTicketsResult {
  const PaginatedTicketsResult({
    required this.tickets,
    required this.total,
  });

  final List<MaintenanceTicketEntity> tickets;
  final int total;
}
