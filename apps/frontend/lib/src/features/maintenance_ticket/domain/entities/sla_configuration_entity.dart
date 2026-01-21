import 'package:equatable/equatable.dart';

import 'maintenance_ticket_entity.dart';

class SlaConfigurationEntity extends Equatable {
  const SlaConfigurationEntity({
    required this.id,
    required this.companyId,
    required this.name,
    this.description,
    required this.priority,
    required this.firstResponseTimeMinutes,
    required this.acknowledgementTimeMinutes,
    required this.resolutionTimeMinutes,
    this.escalationLevel1Minutes,
    this.escalationLevel2Minutes,
    this.escalationLevel3Minutes,
    this.applyBusinessHours = true,
    this.businessStartTime,
    this.businessEndTime,
    this.workingDays,
    this.excludeHolidays = true,
    this.isActive = true,
    this.createdById,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String companyId;
  final String name;
  final String? description;
  final TicketPriority priority;
  final int firstResponseTimeMinutes;
  final int acknowledgementTimeMinutes;
  final int resolutionTimeMinutes;
  final int? escalationLevel1Minutes;
  final int? escalationLevel2Minutes;
  final int? escalationLevel3Minutes;
  final bool applyBusinessHours;
  final String? businessStartTime; // HH:MM format
  final String? businessEndTime; // HH:MM format
  final String? workingDays; // Comma-separated: "1,2,3,4,5" (Mon-Fri)
  final bool excludeHolidays;
  final bool isActive;
  final String? createdById;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get priorityDisplayName => priority.displayName;

  String get workingDaysDisplay {
    if (workingDays == null || workingDays!.isEmpty) {
      return 'All Days';
    }
    final days = workingDays!.split(',');
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days
        .map((d) {
          final index = int.tryParse(d.trim());
          if (index != null && index >= 1 && index <= 7) {
            return dayNames[index - 1];
          }
          return '';
        })
        .where((d) => d.isNotEmpty)
        .join(', ');
  }

  @override
  List<Object?> get props => [
        id,
        companyId,
        name,
        description,
        priority,
        firstResponseTimeMinutes,
        acknowledgementTimeMinutes,
        resolutionTimeMinutes,
        escalationLevel1Minutes,
        escalationLevel2Minutes,
        escalationLevel3Minutes,
        applyBusinessHours,
        businessStartTime,
        businessEndTime,
        workingDays,
        excludeHolidays,
        isActive,
        createdById,
        createdAt,
        updatedAt,
      ];
}
