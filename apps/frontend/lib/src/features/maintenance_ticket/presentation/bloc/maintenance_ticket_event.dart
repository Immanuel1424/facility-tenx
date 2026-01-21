import 'package:equatable/equatable.dart';

import '../../domain/entities/ticket_type_entity.dart';

abstract class MaintenanceTicketEvent extends Equatable {
  const MaintenanceTicketEvent();

  @override
  List<Object?> get props => [];
}

class LoadMaintenanceTickets extends MaintenanceTicketEvent {
  const LoadMaintenanceTickets({
    this.status,
    this.priority,
    this.villaNumbers,
    this.departmentId,
    this.assignedTechnicianId,
    this.search,
    this.ticketType,
    this.siteId,
    this.teamId,
    this.isEscalated,
    this.page = 1,
    this.limit = 20,
    this.sortBy,
    this.sortOrder,
  });

  final String? status;
  final String? priority;
  final List<String>? villaNumbers;
  final String? departmentId;
  final String? assignedTechnicianId;
  final String? search;
  final String? ticketType;
  final String? siteId;
  final String? teamId;
  final bool? isEscalated;
  final int page;
  final int limit;
  final String? sortBy;
  final String? sortOrder;

  @override
  List<Object?> get props => [
        status,
        priority,
        villaNumbers,
        departmentId,
        assignedTechnicianId,
        search,
        ticketType,
        siteId,
        teamId,
        isEscalated,
        page,
        limit,
        sortBy,
        sortOrder,
      ];
}

class LoadMaintenanceTicketDetail extends MaintenanceTicketEvent {
  const LoadMaintenanceTicketDetail(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class CreateMaintenanceTicket extends MaintenanceTicketEvent {
  const CreateMaintenanceTicket({
    required this.title,
    this.description,
    this.ticketType,
    this.villaNumber,
    this.villaId,
    this.siteId,
    this.spaceId,
    this.categoryId,
    this.priority = 'MEDIUM',
    this.contactNumber,
    this.alternateContact,
    this.preferredTime,
    this.category,
    this.location,
  });

  final String title;
  final String? description;
  final String? ticketType;
  final String? villaNumber;
  final String? villaId;
  final String? siteId;
  final String? spaceId;
  final String? categoryId;
  final String priority;
  final String? contactNumber;
  final String? alternateContact;
  final String? preferredTime;
  final String? category;

  /// Free-text location inside villa (e.g., Kitchen, Hall, Balcony)
  final String? location;

  @override
  List<Object?> get props => [
        title,
        description,
        ticketType,
        villaNumber,
        villaId,
        siteId,
        spaceId,
        categoryId,
        priority,
        contactNumber,
        alternateContact,
        preferredTime,
        category,
        location,
      ];
}

class CreateMaintenanceTicketWithAi extends MaintenanceTicketEvent {
  const CreateMaintenanceTicketWithAi({
    required this.description,
    this.villaNumber,
    this.contactNumber,
    this.alternateContact,
    this.preferredTime,
    this.location,
  });

  final String description;
  final String? villaNumber;
  final String? contactNumber;
  final String? alternateContact;
  final String? preferredTime;
  final String? location;

  @override
  List<Object?> get props => [
        description,
        villaNumber,
        contactNumber,
        alternateContact,
        preferredTime,
        location,
      ];
}

class UpdateMaintenanceTicket extends MaintenanceTicketEvent {
  const UpdateMaintenanceTicket({
    required this.id,
    this.title,
    this.description,
    this.priority,
    this.categoryId,
    this.siteId,
    this.spaceId,
  });

  final String id;
  final String? title;
  final String? description;
  final String? priority;
  final String? categoryId;
  final String? siteId;
  final String? spaceId;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        priority,
        categoryId,
        siteId,
        spaceId,
      ];
}

class ChangeMaintenanceTicketStatus extends MaintenanceTicketEvent {
  const ChangeMaintenanceTicketStatus({
    required this.id,
    required this.status,
    this.notes,
  });

  final String id;
  final String status;
  final String? notes;

  @override
  List<Object?> get props => [id, status, notes];
}

class AcknowledgeMaintenanceTicket extends MaintenanceTicketEvent {
  const AcknowledgeMaintenanceTicket(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class CancelMaintenanceTicket extends MaintenanceTicketEvent {
  const CancelMaintenanceTicket(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class AddTechnicianNotes extends MaintenanceTicketEvent {
  const AddTechnicianNotes({
    required this.id,
    required this.notes,
  });

  final String id;
  final String notes;

  @override
  List<Object?> get props => [id, notes];
}

class AddResolutionNotes extends MaintenanceTicketEvent {
  const AddResolutionNotes({
    required this.id,
    required this.notes,
  });

  final String id;
  final String notes;

  @override
  List<Object?> get props => [id, notes];
}

class ConfirmMaintenanceTicketCompletion extends MaintenanceTicketEvent {
  const ConfirmMaintenanceTicketCompletion(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class SubmitTicketRating extends MaintenanceTicketEvent {
  const SubmitTicketRating({
    required this.ticketId,
    required this.rating,
    this.comment,
  });

  final String ticketId;
  final int rating;
  final String? comment;

  @override
  List<Object?> get props => [ticketId, rating, comment];
}

class LoadDepartments extends MaintenanceTicketEvent {
  const LoadDepartments();
}

// New events for villas, teams, sites, spaces, categories
class LoadVillas extends MaintenanceTicketEvent {
  const LoadVillas({
    this.siteId,
    this.isActive,
  });

  final String? siteId;
  final bool? isActive;

  @override
  List<Object?> get props => [siteId, isActive];
}

class LoadTeams extends MaintenanceTicketEvent {
  const LoadTeams({
    this.departmentId,
    this.isActive,
  });

  final String? departmentId;
  final bool? isActive;

  @override
  List<Object?> get props => [departmentId, isActive];
}

class LoadTechnicians extends MaintenanceTicketEvent {
  const LoadTechnicians();

  @override
  List<Object?> get props => [];
}

class LoadSites extends MaintenanceTicketEvent {
  const LoadSites({this.companyId});

  final String? companyId;

  @override
  List<Object?> get props => [companyId];
}

class LoadSpaces extends MaintenanceTicketEvent {
  const LoadSpaces({
    required this.siteId,
    this.categoryId,
  });

  final String siteId;
  final String? categoryId;

  @override
  List<Object?> get props => [siteId, categoryId];
}

class LoadCategories extends MaintenanceTicketEvent {
  const LoadCategories({this.parentCategoryId});

  final String? parentCategoryId;

  @override
  List<Object?> get props => [parentCategoryId];
}

// New ticket operations
class EscalateTicket extends MaintenanceTicketEvent {
  const EscalateTicket({
    required this.ticketId,
    required this.escalationLevel,
    this.reason,
  });

  final String ticketId;
  final int escalationLevel;
  final String? reason;

  @override
  List<Object?> get props => [ticketId, escalationLevel, reason];
}

class LinkTicket extends MaintenanceTicketEvent {
  const LinkTicket({
    required this.ticketId,
    required this.parentTicketId,
  });

  final String ticketId;
  final String parentTicketId;

  @override
  List<Object?> get props => [ticketId, parentTicketId];
}

class AssignTeam extends MaintenanceTicketEvent {
  const AssignTeam({
    required this.ticketId,
    required this.teamId,
  });

  final String ticketId;
  final String teamId;

  @override
  List<Object?> get props => [ticketId, teamId];
}

class AssignTechnician extends MaintenanceTicketEvent {
  const AssignTechnician({
    required this.ticketId,
    required this.technicianId,
  });

  final String ticketId;
  final String technicianId;

  @override
  List<Object?> get props => [ticketId, technicianId];
}

class LoadChildTickets extends MaintenanceTicketEvent {
  const LoadChildTickets({required this.parentTicketId});

  final String parentTicketId;

  @override
  List<Object?> get props => [parentTicketId];
}

// Filter events
class FilterByTicketType extends MaintenanceTicketEvent {
  const FilterByTicketType({this.ticketType});

  final TicketType? ticketType;

  @override
  List<Object?> get props => [ticketType];
}

class FilterBySite extends MaintenanceTicketEvent {
  const FilterBySite({this.siteId});

  final String? siteId;

  @override
  List<Object?> get props => [siteId];
}

class FilterByTeam extends MaintenanceTicketEvent {
  const FilterByTeam({this.teamId});

  final String? teamId;

  @override
  List<Object?> get props => [teamId];
}

class ConfirmAiAnalysisTicket extends MaintenanceTicketEvent {
  const ConfirmAiAnalysisTicket({
    required this.title,
    required this.description,
    this.category,
    this.categoryId,
    required this.priority,
    this.villaNumber,
    this.contactNumber,
    this.preferredTime,
    this.location,
  });

  final String title;
  final String description;
  final String? category;
  final String? categoryId;
  final String priority;
  final String? villaNumber;
  final String? contactNumber;
  final String? preferredTime;
  final String? location;

  @override
  List<Object?> get props => [
        title,
        description,
        category,
        categoryId,
        priority,
        villaNumber,
        contactNumber,
        preferredTime,
        location,
      ];
}
