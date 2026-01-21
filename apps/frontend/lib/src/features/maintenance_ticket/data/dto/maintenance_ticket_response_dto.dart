import 'maintenance_ticket_dto.dart';

class MaintenanceTicketsResponseDto {
  const MaintenanceTicketsResponseDto({
    required this.tickets,
    required this.total,
  });

  final List<MaintenanceTicketDto> tickets;
  final int total;

  factory MaintenanceTicketsResponseDto.fromJson(Map<String, dynamic> json) {
    // Safely handle tickets - could be List or null
    List<MaintenanceTicketDto> tickets = [];
    final ticketsValue = json['tickets'];
    if (ticketsValue is List) {
      tickets = ticketsValue
          .map((e) {
            if (e is Map<String, dynamic>) {
              return MaintenanceTicketDto.fromJson(e);
            }
            return null;
          })
          .whereType<MaintenanceTicketDto>()
          .toList();
    } else if (ticketsValue != null) {
      // If tickets is not a list, log warning but don't crash
      print('⚠️ Warning: tickets field is not a List, got ${ticketsValue.runtimeType}');
    }

    final total = (json['total'] as num?)?.toInt() ?? 0;
    return MaintenanceTicketsResponseDto(tickets: tickets, total: total);
  }

  Map<String, dynamic> toJson() => {
        'tickets': tickets.map((e) => e.toJson()).toList(),
        'total': total,
      };
}
