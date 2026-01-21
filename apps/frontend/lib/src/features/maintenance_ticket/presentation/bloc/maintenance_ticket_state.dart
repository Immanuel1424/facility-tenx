import 'package:equatable/equatable.dart';

import '../../domain/entities/maintenance_ticket_entity.dart';
import '../../domain/entities/villa_entity.dart';
import '../../domain/entities/team_entity.dart';
import '../../domain/entities/site_entity.dart';
import '../../domain/entities/space_entity.dart';
import '../../domain/entities/ticket_category_entity.dart';
import '../../domain/entities/escalation_history_entity.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../data/dto/ai_ticket_analysis_dto.dart';

abstract class MaintenanceTicketState extends Equatable {
  const MaintenanceTicketState();

  @override
  List<Object?> get props => [];

  /// Helper to get ticket from any state that has one
  MaintenanceTicketEntity? get ticket => null;
  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(List<MaintenanceTicketEntity> tickets, int total)
        listLoaded,
    required T Function(MaintenanceTicketEntity ticket) detailLoaded,
    required T Function(MaintenanceTicketEntity ticket) created,
    required T Function(MaintenanceTicketEntity ticket) updated,
    required T Function(MaintenanceTicketEntity ticket) statusChanged,
    required T Function(MaintenanceTicketEntity ticket) assigned,
    required T Function(MaintenanceTicketEntity ticket) acknowledged,
    required T Function(MaintenanceTicketEntity ticket) cancelled,
    required T Function(MaintenanceTicketEntity ticket) notesAdded,
    required T Function(MaintenanceTicketEntity ticket) completionConfirmed,
    required T Function(MaintenanceTicketEntity ticket) ratingSubmitted,
    required T Function(List<DepartmentEntity> departments) departmentsLoaded,
    required T Function(String message) error,
  }) {
    if (this is MaintenanceTicketInitial) {
      return initial();
    } else if (this is MaintenanceTicketLoading) {
      return loading();
    } else if (this is MaintenanceTicketListLoaded) {
      final state = this as MaintenanceTicketListLoaded;
      return listLoaded(state.tickets, state.total);
    } else if (this is MaintenanceTicketDetailLoaded) {
      return detailLoaded((this as MaintenanceTicketDetailLoaded).ticket);
    } else if (this is MaintenanceTicketCreated) {
      return created((this as MaintenanceTicketCreated).ticket);
    } else if (this is MaintenanceTicketUpdated) {
      return updated((this as MaintenanceTicketUpdated).ticket);
    } else if (this is MaintenanceTicketStatusChanged) {
      return statusChanged((this as MaintenanceTicketStatusChanged).ticket);
    } else if (this is MaintenanceTicketAssigned) {
      return assigned((this as MaintenanceTicketAssigned).ticket);
    } else if (this is MaintenanceTicketAcknowledged) {
      return acknowledged((this as MaintenanceTicketAcknowledged).ticket);
    } else if (this is MaintenanceTicketCancelled) {
      return cancelled((this as MaintenanceTicketCancelled).ticket);
    } else if (this is MaintenanceTicketNotesAdded) {
      return notesAdded((this as MaintenanceTicketNotesAdded).ticket);
    } else if (this is MaintenanceTicketCompletionConfirmed) {
      return completionConfirmed(
        (this as MaintenanceTicketCompletionConfirmed).ticket,
      );
    } else if (this is MaintenanceTicketRatingSubmitted) {
      return ratingSubmitted(
        (this as MaintenanceTicketRatingSubmitted).ticket,
      );
    } else if (this is DepartmentsLoaded) {
      return departmentsLoaded((this as DepartmentsLoaded).departments);
    } else if (this is MaintenanceTicketError) {
      return error((this as MaintenanceTicketError).message);
    }
    throw Exception('Unknown MaintenanceTicketState');
  }

  T? maybeWhen<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(List<MaintenanceTicketEntity> tickets, int total)? listLoaded,
    T Function(MaintenanceTicketEntity ticket)? detailLoaded,
    T Function(MaintenanceTicketEntity ticket)? created,
    T Function(MaintenanceTicketEntity ticket)? updated,
    T Function(MaintenanceTicketEntity ticket)? statusChanged,
    T Function(MaintenanceTicketEntity ticket)? assigned,
    T Function(MaintenanceTicketEntity ticket)? acknowledged,
    T Function(MaintenanceTicketEntity ticket)? cancelled,
    T Function(MaintenanceTicketEntity ticket)? notesAdded,
    T Function(MaintenanceTicketEntity ticket)? completionConfirmed,
    T Function(MaintenanceTicketEntity ticket)? ratingSubmitted,
    T Function(List<DepartmentEntity> departments)? departmentsLoaded,
    T Function(String message)? error,
    required T Function() orElse,
  }) {
    if (this is MaintenanceTicketInitial && initial != null) {
      return initial();
    } else if (this is MaintenanceTicketLoading && loading != null) {
      return loading();
    } else if (this is MaintenanceTicketListLoaded && listLoaded != null) {
      final state = this as MaintenanceTicketListLoaded;
      return listLoaded(state.tickets, state.total);
    } else if (this is MaintenanceTicketDetailLoaded && detailLoaded != null) {
      return detailLoaded((this as MaintenanceTicketDetailLoaded).ticket);
    } else if (this is MaintenanceTicketCreated && created != null) {
      return created((this as MaintenanceTicketCreated).ticket);
    } else if (this is MaintenanceTicketUpdated && updated != null) {
      return updated((this as MaintenanceTicketUpdated).ticket);
    } else if (this is MaintenanceTicketStatusChanged &&
        statusChanged != null) {
      return statusChanged((this as MaintenanceTicketStatusChanged).ticket);
    } else if (this is MaintenanceTicketAssigned && assigned != null) {
      return assigned((this as MaintenanceTicketAssigned).ticket);
    } else if (this is MaintenanceTicketAcknowledged && acknowledged != null) {
      return acknowledged((this as MaintenanceTicketAcknowledged).ticket);
    } else if (this is MaintenanceTicketCancelled && cancelled != null) {
      return cancelled((this as MaintenanceTicketCancelled).ticket);
    } else if (this is MaintenanceTicketNotesAdded && notesAdded != null) {
      return notesAdded((this as MaintenanceTicketNotesAdded).ticket);
    } else if (this is MaintenanceTicketCompletionConfirmed &&
        completionConfirmed != null) {
      return completionConfirmed(
        (this as MaintenanceTicketCompletionConfirmed).ticket,
      );
    } else if (this is MaintenanceTicketRatingSubmitted &&
        ratingSubmitted != null) {
      return ratingSubmitted(
        (this as MaintenanceTicketRatingSubmitted).ticket,
      );
    } else if (this is DepartmentsLoaded && departmentsLoaded != null) {
      return departmentsLoaded((this as DepartmentsLoaded).departments);
    } else if (this is MaintenanceTicketError && error != null) {
      return error((this as MaintenanceTicketError).message);
    }
    return orElse();
  }
}

class MaintenanceTicketInitial extends MaintenanceTicketState {
  const MaintenanceTicketInitial();
}

class MaintenanceTicketLoading extends MaintenanceTicketState {
  const MaintenanceTicketLoading();
}

class MaintenanceTicketListLoaded extends MaintenanceTicketState {
  const MaintenanceTicketListLoaded({
    required this.tickets,
    required this.total,
  });

  final List<MaintenanceTicketEntity> tickets;
  final int total;

  @override
  List<Object?> get props => [tickets, total];
}

class MaintenanceTicketDetailLoaded extends MaintenanceTicketState {
  const MaintenanceTicketDetailLoaded(this.ticket);

  @override
  final MaintenanceTicketEntity ticket;

  @override
  List<Object?> get props => [ticket];
}

class MaintenanceTicketCreated extends MaintenanceTicketState {
  const MaintenanceTicketCreated(this.ticket);

  @override
  final MaintenanceTicketEntity ticket;

  @override
  List<Object?> get props => [ticket];
}

class MaintenanceTicketUpdated extends MaintenanceTicketState {
  const MaintenanceTicketUpdated(this.ticket);

  @override
  final MaintenanceTicketEntity ticket;

  @override
  List<Object?> get props => [ticket];
}

class MaintenanceTicketStatusChanged extends MaintenanceTicketState {
  const MaintenanceTicketStatusChanged(this.ticket);

  @override
  final MaintenanceTicketEntity ticket;

  @override
  List<Object?> get props => [ticket];
}

class MaintenanceTicketAssigned extends MaintenanceTicketState {
  const MaintenanceTicketAssigned(this.ticket);

  @override
  final MaintenanceTicketEntity ticket;

  @override
  List<Object?> get props => [ticket];
}

class MaintenanceTicketAcknowledged extends MaintenanceTicketState {
  const MaintenanceTicketAcknowledged(this.ticket);

  @override
  final MaintenanceTicketEntity ticket;

  @override
  List<Object?> get props => [ticket];
}

class MaintenanceTicketCancelled extends MaintenanceTicketState {
  const MaintenanceTicketCancelled(this.ticket);

  @override
  final MaintenanceTicketEntity ticket;

  @override
  List<Object?> get props => [ticket];
}

class MaintenanceTicketNotesAdded extends MaintenanceTicketState {
  const MaintenanceTicketNotesAdded(this.ticket);

  @override
  final MaintenanceTicketEntity ticket;

  @override
  List<Object?> get props => [ticket];
}

class MaintenanceTicketCompletionConfirmed extends MaintenanceTicketState {
  const MaintenanceTicketCompletionConfirmed(this.ticket);

  @override
  final MaintenanceTicketEntity ticket;

  @override
  List<Object?> get props => [ticket];
}

class MaintenanceTicketRatingSubmitted extends MaintenanceTicketState {
  const MaintenanceTicketRatingSubmitted(this.ticket);

  @override
  final MaintenanceTicketEntity ticket;

  @override
  List<Object?> get props => [ticket];
}

class DepartmentsLoaded extends MaintenanceTicketState {
  const DepartmentsLoaded(this.departments);

  final List<DepartmentEntity> departments;

  @override
  List<Object?> get props => [departments];
}

class MaintenanceTicketError extends MaintenanceTicketState {
  const MaintenanceTicketError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// New states for villas, teams, sites, spaces, categories
class VillasLoaded extends MaintenanceTicketState {
  const VillasLoaded({required this.villas});

  final List<VillaEntity> villas;

  @override
  List<Object?> get props => [villas];
}

class TeamsLoaded extends MaintenanceTicketState {
  const TeamsLoaded({required this.teams});

  final List<TeamEntity> teams;

  @override
  List<Object?> get props => [teams];
}

class TechniciansLoaded extends MaintenanceTicketState {
  const TechniciansLoaded({required this.technicians});

  final List<UserEntity> technicians;

  @override
  List<Object?> get props => [technicians];
}

class SitesLoaded extends MaintenanceTicketState {
  const SitesLoaded({required this.sites});

  final List<SiteEntity> sites;

  @override
  List<Object?> get props => [sites];
}

class SpacesLoaded extends MaintenanceTicketState {
  const SpacesLoaded({required this.spaces});

  final List<SpaceEntity> spaces;

  @override
  List<Object?> get props => [spaces];
}

class CategoriesLoaded extends MaintenanceTicketState {
  const CategoriesLoaded({required this.categories});

  final List<TicketCategoryEntity> categories;

  @override
  List<Object?> get props => [categories];
}

class ChildTicketsLoaded extends MaintenanceTicketState {
  const ChildTicketsLoaded({required this.childTickets});

  final List<MaintenanceTicketEntity> childTickets;

  @override
  List<Object?> get props => [childTickets];
}

class MaintenanceTicketEscalated extends MaintenanceTicketState {
  const MaintenanceTicketEscalated(this.escalationHistory);

  final EscalationHistoryEntity escalationHistory;

  @override
  List<Object?> get props => [escalationHistory];
}

class MaintenanceTicketLinked extends MaintenanceTicketState {
  const MaintenanceTicketLinked(this.ticket);

  @override
  final MaintenanceTicketEntity ticket;

  @override
  List<Object?> get props => [ticket];
}

class MaintenanceTicketTeamAssigned extends MaintenanceTicketState {
  const MaintenanceTicketTeamAssigned(this.ticket);

  @override
  final MaintenanceTicketEntity ticket;

  @override
  List<Object?> get props => [ticket];
}

class MaintenanceTicketAiAnalysisReady extends MaintenanceTicketState {
  const MaintenanceTicketAiAnalysisReady({
    required this.analysis,
    required this.originalDescription,
    required this.villaNumber,
    this.userContactNumber,
  });

  final AiTicketAnalysisDto analysis;
  final String originalDescription;
  final String? villaNumber;
  final String? userContactNumber;

  @override
  List<Object?> get props => [
        analysis,
        originalDescription,
        villaNumber,
        userContactNumber,
      ];
}
