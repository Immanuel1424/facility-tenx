import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/maintenance_ticket_entity.dart';
import '../../domain/entities/team_entity.dart';
import '../../domain/entities/ticket_category_entity.dart';
import '../../domain/entities/villa_entity.dart';
import '../../domain/entities/site_entity.dart';
import '../../domain/entities/space_entity.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/repositories/maintenance_ticket_repository_interface.dart';
import '../../domain/services/ai_ticket_service_interface.dart';
import '../../../dashboard/domain/services/dashboard_event_service.dart';
import 'maintenance_ticket_event.dart';
import 'maintenance_ticket_state.dart';

class MaintenanceTicketBloc
    extends Bloc<MaintenanceTicketEvent, MaintenanceTicketState> {
  MaintenanceTicketBloc({
    required MaintenanceTicketRepositoryInterface repository,
    AiTicketServiceInterface? aiService,
  })  : _repository = repository,
        _aiService = aiService,
        super(const MaintenanceTicketInitial()) {
    // Existing handlers
    on<LoadMaintenanceTickets>(_onLoadTickets);
    on<LoadMaintenanceTicketDetail>(_onLoadDetail);
    on<CreateMaintenanceTicket>(_onCreate);
    on<CreateMaintenanceTicketWithAi>(_onCreateWithAi);
    on<ConfirmAiAnalysisTicket>(_onConfirmAiAnalysis);
    on<UpdateMaintenanceTicket>(_onUpdate);
    on<ChangeMaintenanceTicketStatus>(_onChangeStatus);
    on<AcknowledgeMaintenanceTicket>(_onAcknowledge);
    on<CancelMaintenanceTicket>(_onCancel);
    on<AddTechnicianNotes>(_onAddTechnicianNotes);
    on<AddResolutionNotes>(_onAddResolutionNotes);
    on<ConfirmMaintenanceTicketCompletion>(_onConfirmCompletion);
    on<SubmitTicketRating>(_onSubmitRating);
    on<LoadDepartments>(_onLoadDepartments);

    // New handlers for villas, teams, sites, spaces, categories
    on<LoadVillas>(_onLoadVillas);
    on<LoadTeams>(_onLoadTeams);
    on<LoadTechnicians>(_onLoadTechnicians);
    on<LoadSites>(_onLoadSites);
    on<LoadSpaces>(_onLoadSpaces);
    on<LoadCategories>(_onLoadCategories);

    // New ticket operation handlers
    on<EscalateTicket>(_onEscalateTicket);
    on<LinkTicket>(_onLinkTicket);
    on<AssignTeam>(_onAssignTeam);
    on<AssignTechnician>(_onAssignTechnician);
    on<LoadChildTickets>(_onLoadChildTickets);

    // Filter handlers
    on<FilterByTicketType>(_onFilterByTicketType);
    on<FilterBySite>(_onFilterBySite);
    on<FilterByTeam>(_onFilterByTeam);
  }

  final MaintenanceTicketRepositoryInterface _repository;
  final AiTicketServiceInterface? _aiService;

  // Cache teams and technicians to persist across state changes
  List<TeamEntity> _cachedTeams = [];
  List<UserEntity> _cachedTechnicians = [];
  // Track if technicians have been loaded (to distinguish between "never loaded" and "loaded but empty")
  bool _techniciansLoaded = false;
  // Cache child tickets by parent ticket ID
  final Map<String, List<MaintenanceTicketEntity>> _cachedChildTickets = {};
  // Cache categories to persist across state changes
  List<TicketCategoryEntity> _cachedCategories = [];
  // Cache villas, sites, and spaces to persist across state changes
  List<VillaEntity> _cachedVillas = [];
  List<SiteEntity> _cachedSites = [];
  final Map<String, List<SpaceEntity>> _cachedSpaces = {}; // Keyed by siteId

  // Getters to access cached data
  List<TeamEntity> get cachedTeams => _cachedTeams;
  List<UserEntity> get cachedTechnicians => _cachedTechnicians;
  bool get hasLoadedTechnicians => _techniciansLoaded;
  List<MaintenanceTicketEntity> getCachedChildTickets(String parentTicketId) =>
      _cachedChildTickets[parentTicketId] ?? [];
  bool hasCachedChildTickets(String parentTicketId) =>
      _cachedChildTickets.containsKey(parentTicketId);
  List<TicketCategoryEntity> get cachedCategories => _cachedCategories;
  List<VillaEntity> get cachedVillas => _cachedVillas;
  List<SiteEntity> get cachedSites => _cachedSites;
  List<SpaceEntity> getCachedSpaces(String siteId) => _cachedSpaces[siteId] ?? [];

  Future<void> _onLoadTickets(
    LoadMaintenanceTickets event,
    Emitter<MaintenanceTicketState> emit,
  ) async {
    emit(const MaintenanceTicketLoading());

    final result = await _repository.getTickets(
      status: event.status,
      priority: event.priority,
      villaNumbers: event.villaNumbers,
      departmentId: event.departmentId,
      assignedTechnicianId: event.assignedTechnicianId,
      search: event.search,
      ticketType: event.ticketType,
      siteId: event.siteId,
      teamId: event.teamId,
      isEscalated: event.isEscalated,
      page: event.page,
      limit: event.limit,
      sortBy: event.sortBy,
      sortOrder: event.sortOrder,
    );

    result.fold(
      (error) => emit(MaintenanceTicketError(error)),
      (paginatedResult) {
        emit(
          MaintenanceTicketListLoaded(
            tickets: paginatedResult.tickets,
            total: paginatedResult.total,
          ),
        );
      },
    );
  }

  Future<void> _onLoadDetail(
    LoadMaintenanceTicketDetail event,
    Emitter<MaintenanceTicketState> emit,
  ) async {
    emit(const MaintenanceTicketLoading());

    final result = await _repository.getTicket(event.id);

    result.fold(
      (error) => emit(MaintenanceTicketError(error)),
      (ticket) => emit(MaintenanceTicketDetailLoaded(ticket)),
    );
  }

  Future<void> _onCreate(
    CreateMaintenanceTicket event,
    Emitter<MaintenanceTicketState> emit,
  ) async {
    emit(const MaintenanceTicketLoading());

    final result = await _repository.createTicket(
      title: event.title,
      description: event.description,
      ticketType: event.ticketType,
      villaNumber: event.villaNumber,
      villaId: event.villaId,
      siteId: event.siteId,
      spaceId: event.spaceId,
      categoryId: event.categoryId,
      priority: event.priority,
      contactNumber: event.contactNumber,
      alternateContact: event.alternateContact,
      preferredTime: event.preferredTime,
      category: event.category,
      locationDescription: event.location,
    );

    result.fold(
      (error) => emit(MaintenanceTicketError(error)),
      (ticket) => emit(MaintenanceTicketCreated(ticket)),
    );
  }

  Future<void> _onCreateWithAi(
    CreateMaintenanceTicketWithAi event,
    Emitter<MaintenanceTicketState> emit,
  ) async {
    emit(const MaintenanceTicketLoading());

    // Try AI analysis if service is available
    if (_aiService != null) {
      print('🔍 AI service available. Starting analysis...');
      final analysisResult =
          await _aiService!.analyzeDescription(event.description);

      await analysisResult.fold(
        (error) async {
          // If AI fails, emit error state - don't automatically create ticket
          print(
            '⚠️ AI analysis failed: $error. User can continue filling form manually.',
          );
          emit(
            MaintenanceTicketError(
              'AI analysis failed. Please fill the form manually and click "Create Ticket".',
            ),
          );
        },
        (analysis) async {
          // Emit review state instead of directly creating ticket
          print('✅ AI analysis successful. Emitting review state...');
          print('   Title: ${analysis.title}');
          print('   Category: ${analysis.category}');
          print('   Priority: ${analysis.priority}');
          emit(
            MaintenanceTicketAiAnalysisReady(
              analysis: analysis,
              originalDescription: event.description,
              villaNumber: event.villaNumber,
              userContactNumber: event.contactNumber,
            ),
          );
          print('✅ Review state emitted successfully');
        },
      );
    } else {
      // No AI service available, emit error state - don't automatically create ticket
      print('⚠️ AI service not available. User can continue filling form manually.');
      emit(
        const MaintenanceTicketError(
          'AI service is not available. Please fill the form manually and click "Create Ticket".',
        ),
      );
    }
  }

  Future<void> _onConfirmAiAnalysis(
    ConfirmAiAnalysisTicket event,
    Emitter<MaintenanceTicketState> emit,
  ) async {
    emit(const MaintenanceTicketLoading());

    final result = await _repository.createTicket(
      title: event.title,
      description: event.description,
      villaNumber: event.villaNumber,
      priority: event.priority,
      categoryId: event.categoryId,
      category: event.category,
      contactNumber: event.contactNumber,
      preferredTime: event.preferredTime,
      locationDescription: event.location,
    );

    result.fold(
      (error) => emit(MaintenanceTicketError(error)),
      (ticket) {
        emit(MaintenanceTicketCreated(ticket));
        // Notify dashboard to refresh when ticket is created via AI
        if (ticket.companyId != null) {
          DashboardEventService.instance.notifyTicketCreated(
            companyId: ticket.companyId!,
            ticketId: ticket.id,
          );
        }
      },
    );
  }


  Future<void> _onUpdate(
    UpdateMaintenanceTicket event,
    Emitter<MaintenanceTicketState> emit,
  ) async {
    // Preserve current ticket detail if loaded
    final currentTicket = state is MaintenanceTicketDetailLoaded
        ? (state as MaintenanceTicketDetailLoaded).ticket
        : null;

    // Only emit loading if we don't have a detail loaded state
    if (currentTicket == null) {
      emit(const MaintenanceTicketLoading());
    }

    final result = await _repository.updateTicket(
      event.id,
      title: event.title,
      description: event.description,
      priority: event.priority,
      categoryId: event.categoryId,
      siteId: event.siteId,
      spaceId: event.spaceId,
    );

    result.fold(
      (error) {
        // Restore previous state on error
        if (currentTicket != null) {
          emit(MaintenanceTicketDetailLoaded(currentTicket));
        }
        emit(MaintenanceTicketError(error));
      },
      (ticket) {
        // Preserve detail view with updated ticket
        if (currentTicket != null || state is MaintenanceTicketDetailLoaded) {
          emit(MaintenanceTicketDetailLoaded(ticket));
        }
        // Also emit updated state for listeners
        emit(MaintenanceTicketUpdated(ticket));
      },
    );
  }

  Future<void> _onChangeStatus(
    ChangeMaintenanceTicketStatus event,
    Emitter<MaintenanceTicketState> emit,
  ) async {
    // Preserve current state
    final currentState = state;
    final currentTicket = currentState is MaintenanceTicketDetailLoaded
        ? currentState.ticket
        : null;
    List<MaintenanceTicketEntity>? currentTickets;
    int? currentTotal;

    if (currentState is MaintenanceTicketListLoaded) {
      currentTickets = List.from(currentState.tickets);
      currentTotal = currentState.total;
    }

    // Only emit loading if we don't have a detail loaded state
    if (currentTicket == null) {
      emit(const MaintenanceTicketLoading());
    }

    final result = await _repository.changeStatus(
      event.id,
      event.status,
      event.notes,
    );

    result.fold(
      (error) {
        // Restore previous state on error
        if (currentTicket != null) {
          emit(MaintenanceTicketDetailLoaded(currentTicket));
        }
        emit(MaintenanceTicketError(error));
      },
      (updatedTicket) {
        // If we have a current list, update the ticket in it
        if (currentTickets != null && updatedTicket.id.isNotEmpty) {
          final index =
              currentTickets.indexWhere((t) => t.id == updatedTicket.id);
          if (index != -1) {
            // Update the ticket in the list
            currentTickets[index] = updatedTicket;
          } else {
            // Ticket not in list, add it if it should be visible (assigned to technician)
            if (updatedTicket.assignedTechnicianId != null &&
                updatedTicket.assignedTechnicianId!.isNotEmpty) {
              currentTickets.add(updatedTicket);
              currentTotal = (currentTotal ?? 0) + 1;
            }
          }
          // Emit updated list state
          emit(
            MaintenanceTicketListLoaded(
              tickets: currentTickets,
              total: currentTotal ?? currentTickets.length,
            ),
          );
        }
        // If we were viewing detail, preserve it with updated ticket
        if (currentTicket != null ||
            currentState is MaintenanceTicketDetailLoaded) {
          emit(MaintenanceTicketDetailLoaded(updatedTicket));
        }
        // Also emit status changed event for listeners (snackbars, etc.)
        emit(MaintenanceTicketStatusChanged(updatedTicket));
        // Notify dashboard to refresh when ticket status changes
        if (updatedTicket.companyId != null) {
          DashboardEventService.instance.notifyTicketStatusChanged(
            companyId: updatedTicket.companyId!,
            ticketId: updatedTicket.id,
          );
          // Also notify if ticket was completed
          if (updatedTicket.status == TicketStatus.completed) {
            DashboardEventService.instance.notifyTicketCompleted(
              companyId: updatedTicket.companyId!,
              ticketId: updatedTicket.id,
            );
          }
        }
      },
    );
  }

  Future<void> _onAcknowledge(
    AcknowledgeMaintenanceTicket event,
    Emitter<MaintenanceTicketState> emit,
  ) async {
    // Preserve current ticket detail if loaded
    final currentTicket = state is MaintenanceTicketDetailLoaded
        ? (state as MaintenanceTicketDetailLoaded).ticket
        : null;

    // Only emit loading if we don't have a detail loaded state
    if (currentTicket == null) {
      emit(const MaintenanceTicketLoading());
    }

    final result = await _repository.acknowledgeTicket(event.id);

    result.fold(
      (error) {
        // Restore previous state on error
        if (currentTicket != null) {
          emit(MaintenanceTicketDetailLoaded(currentTicket));
        }
        emit(MaintenanceTicketError(error));
      },
      (ticket) {
        // Preserve detail view with updated ticket
        if (currentTicket != null || state is MaintenanceTicketDetailLoaded) {
          emit(MaintenanceTicketDetailLoaded(ticket));
        }
        // Also emit acknowledged state for listeners
        emit(MaintenanceTicketAcknowledged(ticket));
      },
    );
  }

  Future<void> _onCancel(
    CancelMaintenanceTicket event,
    Emitter<MaintenanceTicketState> emit,
  ) async {
    // Preserve current ticket detail if loaded
    final currentTicket = state is MaintenanceTicketDetailLoaded
        ? (state as MaintenanceTicketDetailLoaded).ticket
        : null;

    // Only emit loading if we don't have a detail loaded state
    if (currentTicket == null) {
      emit(const MaintenanceTicketLoading());
    }

    final result = await _repository.cancelTicket(event.id);

    result.fold(
      (error) {
        // Restore previous state on error
        if (currentTicket != null) {
          emit(MaintenanceTicketDetailLoaded(currentTicket));
        }
        emit(MaintenanceTicketError(error));
      },
      (ticket) {
        // Preserve detail view with updated ticket
        if (currentTicket != null || state is MaintenanceTicketDetailLoaded) {
          emit(MaintenanceTicketDetailLoaded(ticket));
        }
        // Also emit cancelled state for listeners
        emit(MaintenanceTicketCancelled(ticket));
        // Notify dashboard to refresh when ticket is cancelled
        if (ticket.companyId != null) {
          DashboardEventService.instance.notifyTicketCancelled(
            companyId: ticket.companyId!,
            ticketId: ticket.id,
          );
        }
      },
    );
  }

  Future<void> _onAddTechnicianNotes(
    AddTechnicianNotes event,
    Emitter<MaintenanceTicketState> emit,
  ) async {
    // Preserve current state
    final currentState = state;
    final currentTicket = currentState is MaintenanceTicketDetailLoaded
        ? currentState.ticket
        : null;
    List<MaintenanceTicketEntity>? currentTickets;
    int? currentTotal;

    if (currentState is MaintenanceTicketListLoaded) {
      currentTickets = List.from(currentState.tickets);
      currentTotal = currentState.total;
    }

    // Only emit loading if we don't have a detail loaded state
    if (currentTicket == null) {
      emit(const MaintenanceTicketLoading());
    }

    final result = await _repository.addTechnicianNotes(event.id, event.notes);

    result.fold(
      (error) {
        // Restore previous state on error
        if (currentTicket != null) {
          emit(MaintenanceTicketDetailLoaded(currentTicket));
        }
        emit(MaintenanceTicketError(error));
      },
      (updatedTicket) {
        // If we have a current list, update the ticket in it
        if (currentTickets != null && updatedTicket.id.isNotEmpty) {
          final index =
              currentTickets.indexWhere((t) => t.id == updatedTicket.id);
          if (index != -1) {
            // Update the ticket in the list
            currentTickets[index] = updatedTicket;
          }
          // Emit updated list state
          emit(
            MaintenanceTicketListLoaded(
              tickets: currentTickets,
              total: currentTotal ?? currentTickets.length,
            ),
          );
        }
        // If we were viewing detail, preserve it with updated ticket
        if (currentTicket != null ||
            currentState is MaintenanceTicketDetailLoaded) {
          emit(MaintenanceTicketDetailLoaded(updatedTicket));
        }
        // Also emit notes added event for listeners
        emit(MaintenanceTicketNotesAdded(updatedTicket));
      },
    );
  }

  Future<void> _onAddResolutionNotes(
    AddResolutionNotes event,
    Emitter<MaintenanceTicketState> emit,
  ) async {
    emit(const MaintenanceTicketLoading());

    final result = await _repository.addResolutionNotes(event.id, event.notes);

    result.fold(
      (error) => emit(MaintenanceTicketError(error)),
      (ticket) => emit(MaintenanceTicketNotesAdded(ticket)),
    );
  }

  Future<void> _onConfirmCompletion(
    ConfirmMaintenanceTicketCompletion event,
    Emitter<MaintenanceTicketState> emit,
  ) async {
    // Preserve current ticket detail if loaded
    final currentTicket = state is MaintenanceTicketDetailLoaded
        ? (state as MaintenanceTicketDetailLoaded).ticket
        : null;

    // Only emit loading if we don't have a detail loaded state
    if (currentTicket == null) {
      emit(const MaintenanceTicketLoading());
    }

    final result = await _repository.confirmCompletion(event.id);

    result.fold(
      (error) {
        // Restore previous state on error
        if (currentTicket != null) {
          emit(MaintenanceTicketDetailLoaded(currentTicket));
        }
        emit(MaintenanceTicketError(error));
      },
      (ticket) {
        // Preserve detail view with updated ticket
        if (currentTicket != null || state is MaintenanceTicketDetailLoaded) {
          emit(MaintenanceTicketDetailLoaded(ticket));
        }
        // Also emit completion confirmed state for listeners
        emit(MaintenanceTicketCompletionConfirmed(ticket));
      },
    );
  }

  Future<void> _onSubmitRating(
    SubmitTicketRating event,
    Emitter<MaintenanceTicketState> emit,
  ) async {
    // Preserve current ticket detail if loaded
    final currentTicket = state is MaintenanceTicketDetailLoaded
        ? (state as MaintenanceTicketDetailLoaded).ticket
        : null;

    // Only emit loading if we don't have a detail loaded state
    if (currentTicket == null) {
      emit(const MaintenanceTicketLoading());
    }

    final result = await _repository.submitRating(
      event.ticketId,
      event.rating,
      event.comment,
    );

    result.fold(
      (error) {
        // Restore previous state on error
        if (currentTicket != null) {
          emit(MaintenanceTicketDetailLoaded(currentTicket));
        }
        emit(MaintenanceTicketError(error));
      },
      (ticket) {
        // Always emit detail loaded state to preserve the UI
        // The rating submitted state is only for listeners (snackbars, etc.)
        // but we need to keep the detail view visible
        emit(MaintenanceTicketDetailLoaded(ticket));
        // Note: We don't emit MaintenanceTicketRatingSubmitted here because
        // it would overwrite the detail loaded state and cause UI to disappear.
        // The widget already shows success feedback via SnackBar.
      },
    );
  }

  Future<void> _onLoadDepartments(
    LoadDepartments event,
    Emitter<MaintenanceTicketState> emit,
  ) async {
    emit(const MaintenanceTicketLoading());

    final result = await _repository.getDepartments();

    result.fold(
      (error) => emit(MaintenanceTicketError(error)),
      (departments) => emit(DepartmentsLoaded(departments)),
    );
  }

  // New handlers for villas, teams, sites, spaces, categories
  Future<void> _onLoadVillas(
    LoadVillas event,
    Emitter<MaintenanceTicketState> emit,
  ) async {
    emit(const MaintenanceTicketLoading());

    final result = await _repository.getVillas(
      siteId: event.siteId,
      isActive: event.isActive,
    );

    result.fold(
      (error) => emit(MaintenanceTicketError(error)),
      (villas) {
        // Cache villas for persistence across state changes
        _cachedVillas = villas;
        emit(VillasLoaded(villas: villas));
      },
    );
  }

  Future<void> _onLoadTeams(
    LoadTeams event,
    Emitter<MaintenanceTicketState> emit,
  ) async {
    // Preserve current ticket if loaded
    final currentTicket = state is MaintenanceTicketDetailLoaded
        ? (state as MaintenanceTicketDetailLoaded).ticket
        : null;

    // Don't emit loading state if we have a ticket detail loaded
    // This preserves the ticket state while loading teams
    if (currentTicket == null) {
      emit(const MaintenanceTicketLoading());
    }

    final result = await _repository.getTeams(
      departmentId: event.departmentId,
      isActive: event.isActive,
    );

    result.fold(
      (error) {
        // If we have a ticket, preserve it even if teams fail to load
        print('❌ Failed to load teams: $error');
        if (currentTicket != null) {
          print('✅ Preserving ticket detail state despite teams load error');
          emit(MaintenanceTicketDetailLoaded(currentTicket));
        } else {
          emit(MaintenanceTicketError(error));
        }
      },
      (teams) {
        // Cache teams for persistence across state changes
        _cachedTeams = teams;
        print('✅ Teams loaded: ${teams.length} teams');
        if (teams.isEmpty) {
          print('⚠️ Warning: Teams list is empty');
        }
        // If we have a ticket, preserve it and reload to include teams
        if (currentTicket != null) {
          print('✅ Reloading ticket detail to preserve teams state');
          // Reload ticket detail which will preserve the cached teams
          add(LoadMaintenanceTicketDetail(currentTicket.id));
        } else {
          emit(TeamsLoaded(teams: teams));
        }
      },
    );
  }

  Future<void> _onLoadTechnicians(
    LoadTechnicians event,
    Emitter<MaintenanceTicketState> emit,
  ) async {
    // Preserve current ticket if loaded
    final currentTicket = state is MaintenanceTicketDetailLoaded
        ? (state as MaintenanceTicketDetailLoaded).ticket
        : null;

    // Don't emit loading state to preserve current ticket state
    // Load technicians independently - no filters (teams, siteId, etc.)
    final result = await _repository.getTechnicians();

    result.fold(
      (error) {
        // Only emit error if we don't have a ticket loaded
        // Otherwise, technicians just won't load but ticket remains visible
        print('❌ Failed to load technicians: $error');
        if (currentTicket == null) {
          emit(MaintenanceTicketError(error));
        }
        // If we have a ticket, keep it loaded even if technicians fail
        else {
          print(
            '✅ Preserving ticket detail state despite technicians load error',
          );
          emit(MaintenanceTicketDetailLoaded(currentTicket));
        }
      },
      (technicians) {
        // Cache technicians for persistence across state changes
        _cachedTechnicians = technicians;
        _techniciansLoaded = true; // Mark as loaded (even if empty)
        print(
          '✅ Technicians loaded and cached: ${technicians.length} technicians',
        );
        if (technicians.isEmpty) {
          print('⚠️ Warning: Technicians list is empty');
        }
        // Always emit TechniciansLoaded state so widgets can detect when technicians are loaded
        // If we have a ticket, also preserve it by emitting detail state after
        if (currentTicket != null) {
          print(
            '✅ Preserving ticket detail state with ${technicians.length} cached technicians',
          );
          // Emit TechniciansLoaded first so widgets can detect the load
          emit(TechniciansLoaded(technicians: technicians));
          // Then emit ticket detail to preserve the ticket view
          emit(MaintenanceTicketDetailLoaded(currentTicket));
        } else {
          emit(TechniciansLoaded(technicians: technicians));
        }
      },
    );
  }

  Future<void> _onLoadSites(
    LoadSites event,
    Emitter<MaintenanceTicketState> emit,
  ) async {
    emit(const MaintenanceTicketLoading());

    final result = await _repository.getSites(
      companyId: event.companyId,
    );

    result.fold(
      (error) => emit(MaintenanceTicketError(error)),
      (sites) {
        // Cache sites for persistence across state changes
        _cachedSites = sites;
        emit(SitesLoaded(sites: sites));
      },
    );
  }

  Future<void> _onLoadSpaces(
    LoadSpaces event,
    Emitter<MaintenanceTicketState> emit,
  ) async {
    emit(const MaintenanceTicketLoading());

    final result = await _repository.getSpaces(
      siteId: event.siteId,
      categoryId: event.categoryId,
    );

    result.fold(
      (error) => emit(MaintenanceTicketError(error)),
      (spaces) {
        // Cache spaces by siteId for persistence across state changes
        _cachedSpaces[event.siteId] = spaces;
        emit(SpacesLoaded(spaces: spaces));
      },
    );
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<MaintenanceTicketState> emit,
  ) async {
    // Don't reload if we already have cached categories
    if (_cachedCategories.isNotEmpty) {
      // Just emit the current state (categories already cached)
      return;
    }

    // Preserve current state if it's not initial/loading
    final currentState = state;
    final preserveState = currentState is! MaintenanceTicketInitial &&
        currentState is! MaintenanceTicketLoading &&
        currentState is! CategoriesLoaded;

    // Only emit loading if we're in initial state or don't need to preserve
    if (!preserveState) {
      emit(const MaintenanceTicketLoading());
    }

    final result = await _repository.getCategories(
      parentCategoryId: event.parentCategoryId,
    );

    result.fold(
      (error) {
        // If we need to preserve state, restore it
        if (preserveState) {
          emit(currentState);
        } else {
          emit(MaintenanceTicketError(error));
        }
      },
      (categories) {
        // Cache categories for persistence across state changes
        _cachedCategories = categories;
        // If we need to preserve state, restore it (categories are now cached)
        if (preserveState) {
          emit(currentState);
        } else {
          emit(CategoriesLoaded(categories: categories));
        }
      },
    );
  }

  // New ticket operation handlers
  Future<void> _onEscalateTicket(
    EscalateTicket event,
    Emitter<MaintenanceTicketState> emit,
  ) async {
    emit(const MaintenanceTicketLoading());

    final result = await _repository.escalateTicket(
      event.ticketId,
      escalationLevel: event.escalationLevel,
      reason: event.reason,
    );

    result.fold(
      (error) => emit(MaintenanceTicketError(error)),
      (escalationHistory) => emit(MaintenanceTicketEscalated(escalationHistory)),
    );
  }

  Future<void> _onLinkTicket(
    LinkTicket event,
    Emitter<MaintenanceTicketState> emit,
  ) async {
    emit(const MaintenanceTicketLoading());

    final result = await _repository.linkTicket(
      event.ticketId,
      event.parentTicketId,
    );

    result.fold(
      (error) => emit(MaintenanceTicketError(error)),
      (ticket) => emit(MaintenanceTicketLinked(ticket)),
    );
  }

  Future<void> _onAssignTeam(
    AssignTeam event,
    Emitter<MaintenanceTicketState> emit,
  ) async {
    // Preserve current ticket if loaded - don't show loading screen
    final currentTicket = state is MaintenanceTicketDetailLoaded
        ? (state as MaintenanceTicketDetailLoaded).ticket
        : null;

    // Only emit loading if we don't have a ticket loaded
    if (currentTicket == null) {
      emit(const MaintenanceTicketLoading());
    }

    final result = await _repository.assignTeam(
      event.ticketId,
      event.teamId,
    );

    result.fold(
      (error) {
        // If we had a ticket loaded, restore it on error
        if (currentTicket != null) {
          emit(MaintenanceTicketDetailLoaded(currentTicket));
        }
        emit(MaintenanceTicketError(error));
      },
      (ticket) {
        // Emit detail loaded to preserve UI state and show updated ticket
        emit(MaintenanceTicketDetailLoaded(ticket));
      },
    );
  }

  Future<void> _onAssignTechnician(
    AssignTechnician event,
    Emitter<MaintenanceTicketState> emit,
  ) async {
    // Preserve current ticket detail if loaded
    final currentTicket = state is MaintenanceTicketDetailLoaded
        ? (state as MaintenanceTicketDetailLoaded).ticket
        : null;

    // Only emit loading if we don't have a detail loaded state
    if (currentTicket == null) {
      emit(const MaintenanceTicketLoading());
    }

    final result = await _repository.assignTechnician(
      event.ticketId,
      event.technicianId,
    );

    result.fold(
      (error) {
        // Restore previous state on error
        if (currentTicket != null) {
          emit(MaintenanceTicketDetailLoaded(currentTicket));
        }
        emit(MaintenanceTicketError(error));
      },
      (ticket) {
        // Preserve detail view with updated ticket
        if (currentTicket != null || state is MaintenanceTicketDetailLoaded) {
          emit(MaintenanceTicketDetailLoaded(ticket));
        }
        // Also emit assigned state for listeners
        emit(MaintenanceTicketAssigned(ticket));
        // Notify dashboard to refresh when ticket is assigned
        if (ticket.companyId != null) {
          DashboardEventService.instance.notifyTicketAssigned(
            companyId: ticket.companyId!,
            ticketId: ticket.id,
          );
        }
      },
    );
  }

  Future<void> _onLoadChildTickets(
    LoadChildTickets event,
    Emitter<MaintenanceTicketState> emit,
  ) async {
    // Preserve current ticket if loaded
    final currentTicket = state is MaintenanceTicketDetailLoaded
        ? (state as MaintenanceTicketDetailLoaded).ticket
        : null;

    // Don't emit loading state if we have a ticket detail loaded
    // This preserves the ticket state while loading child tickets
    if (currentTicket == null) {
      emit(const MaintenanceTicketLoading());
    }

    final result = await _repository.getChildTickets(event.parentTicketId);

    result.fold(
      (error) {
        // If we have a ticket, preserve it even if child tickets fail to load
        if (currentTicket != null) {
          print(
            '⚠️ Failed to load child tickets, preserving ticket detail state',
          );
          emit(MaintenanceTicketDetailLoaded(currentTicket));
        } else {
          emit(MaintenanceTicketError(error));
        }
      },
      (childTickets) {
        // Cache child tickets by parent ticket ID
        _cachedChildTickets[event.parentTicketId] = childTickets;
        print(
          '✅ Child tickets loaded and cached: ${childTickets.length} tickets for parent ${event.parentTicketId}',
        );
        // If we have a ticket, preserve it with cached child tickets
        if (currentTicket != null) {
          print('✅ Preserving ticket detail state with cached child tickets');
          emit(MaintenanceTicketDetailLoaded(currentTicket));
        } else {
          emit(ChildTicketsLoaded(childTickets: childTickets));
        }
      },
    );
  }

  // Filter handlers (these can trigger a reload with filters)
  Future<void> _onFilterByTicketType(
    FilterByTicketType event,
    Emitter<MaintenanceTicketState> emit,
  ) async {
    // This could reload tickets with the filter, or just store the filter
    // For now, we'll just reload tickets with the filter
    add(
      LoadMaintenanceTickets(
        ticketType: event.ticketType?.backendValue,
      ),
    );
  }

  Future<void> _onFilterBySite(
    FilterBySite event,
    Emitter<MaintenanceTicketState> emit,
  ) async {
    add(LoadMaintenanceTickets(siteId: event.siteId));
  }

  Future<void> _onFilterByTeam(
    FilterByTeam event,
    Emitter<MaintenanceTicketState> emit,
  ) async {
    add(LoadMaintenanceTickets(teamId: event.teamId));
  }
}
