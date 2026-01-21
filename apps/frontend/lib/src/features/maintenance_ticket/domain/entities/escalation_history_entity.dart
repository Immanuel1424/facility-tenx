import 'package:equatable/equatable.dart';

class EscalationHistoryEntity extends Equatable {
  const EscalationHistoryEntity({
    required this.id,
    required this.companyId,
    required this.ticketId,
    required this.escalationLevel,
    this.escalatedFromRole,
    this.escalatedToRole,
    this.reason,
    this.escalatedBy,
    required this.escalatedAt,
    required this.isAutomatic,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String companyId;
  final String ticketId;
  final int escalationLevel;
  final String? escalatedFromRole;
  final String? escalatedToRole;
  final String? reason;
  final String? escalatedBy;
  final DateTime escalatedAt;
  final bool isAutomatic;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get escalationLevelDisplay {
    switch (escalationLevel) {
      case 1:
        return 'Level 1 (SUPERVISOR)';
      case 2:
        return 'Level 2 (SITE_COORDINATOR)';
      case 3:
        return 'Level 3 (ADMIN)';
      default:
        return 'Level $escalationLevel';
    }
  }

  String get escalationType => isAutomatic ? 'Automatic' : 'Manual';

  @override
  List<Object?> get props => [
        id,
        companyId,
        ticketId,
        escalationLevel,
        escalatedFromRole,
        escalatedToRole,
        reason,
        escalatedBy,
        escalatedAt,
        isAutomatic,
        createdAt,
        updatedAt,
      ];
}
