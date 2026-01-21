import 'dart:async';

/// Event types for dashboard refresh notifications
enum DashboardEventType {
  ticketCreated,
  ticketStatusChanged,
  ticketAssigned,
  ticketCompleted,
  ticketCancelled,
}

/// Event data for dashboard refresh
class DashboardEvent {
  const DashboardEvent({
    required this.type,
    required this.companyId,
    this.role,
    this.ticketId,
  });

  final DashboardEventType type;
  final String companyId;
  final String? role;
  final String? ticketId;
}

/// Service for broadcasting dashboard refresh events
/// 
/// This service enables event-driven dashboard updates when tickets are created
/// or modified, providing immediate feedback without polling delays.
/// 
/// Usage:
/// ```dart
/// // Notify when ticket is created
/// DashboardEventService.instance.notifyTicketCreated(
///   companyId: companyId,
///   role: 'ADMIN',
/// );
/// 
/// // Listen for events
/// DashboardEventService.instance.events.listen((event) {
///   // Refresh dashboard
/// });
/// ```
class DashboardEventService {
  DashboardEventService._internal();

  static final DashboardEventService instance = DashboardEventService._internal();

  final _eventController = StreamController<DashboardEvent>.broadcast();

  /// Stream of dashboard events
  Stream<DashboardEvent> get events => _eventController.stream;

  /// Notify that a ticket was created
  void notifyTicketCreated({
    required String companyId,
    String? role,
    String? ticketId,
  }) {
    _eventController.add(
      DashboardEvent(
        type: DashboardEventType.ticketCreated,
        companyId: companyId,
        role: role,
        ticketId: ticketId,
      ),
    );
  }

  /// Notify that a ticket status changed
  void notifyTicketStatusChanged({
    required String companyId,
    String? role,
    String? ticketId,
  }) {
    _eventController.add(
      DashboardEvent(
        type: DashboardEventType.ticketStatusChanged,
        companyId: companyId,
        role: role,
        ticketId: ticketId,
      ),
    );
  }

  /// Notify that a ticket was assigned
  void notifyTicketAssigned({
    required String companyId,
    String? role,
    String? ticketId,
  }) {
    _eventController.add(
      DashboardEvent(
        type: DashboardEventType.ticketAssigned,
        companyId: companyId,
        role: role,
        ticketId: ticketId,
      ),
    );
  }

  /// Notify that a ticket was completed
  void notifyTicketCompleted({
    required String companyId,
    String? role,
    String? ticketId,
  }) {
    _eventController.add(
      DashboardEvent(
        type: DashboardEventType.ticketCompleted,
        companyId: companyId,
        role: role,
        ticketId: ticketId,
      ),
    );
  }

  /// Notify that a ticket was cancelled
  void notifyTicketCancelled({
    required String companyId,
    String? role,
    String? ticketId,
  }) {
    _eventController.add(
      DashboardEvent(
        type: DashboardEventType.ticketCancelled,
        companyId: companyId,
        role: role,
        ticketId: ticketId,
      ),
    );
  }

  /// Dispose the service (should only be called in tests)
  void dispose() {
    _eventController.close();
  }
}
