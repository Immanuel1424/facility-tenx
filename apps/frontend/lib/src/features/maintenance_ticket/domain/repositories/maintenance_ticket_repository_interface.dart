import 'package:fpdart/fpdart.dart';

import '../entities/maintenance_ticket_entity.dart';
import '../entities/villa_entity.dart';
import '../entities/team_entity.dart';
import '../entities/site_entity.dart';
import '../entities/space_entity.dart';
import '../entities/ticket_category_entity.dart';
import '../entities/escalation_history_entity.dart';
import '../entities/escalation_matrix_entity.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../data/models/paginated_tickets_result.dart';

abstract class MaintenanceTicketRepositoryInterface {
  // Existing ticket CRUD methods
  Future<Either<String, PaginatedTicketsResult>> getTickets({
    String? status,
    String? priority,
    List<String>? villaNumbers,
    String? departmentId,
    String? assignedTechnicianId,
    String? search,
    String? ticketType,
    String? siteId,
    String? teamId,
    bool? isEscalated,
    int page = 1,
    int limit = 20,
    String? sortBy,
    String? sortOrder,
  });

  Future<Either<String, MaintenanceTicketEntity>> getTicket(String id);

  Future<Either<String, MaintenanceTicketEntity>> createTicket({
    required String title,
    String? description,
    String? ticketType,
    String? villaNumber,
    String? villaId,
    String? siteId,
    String? spaceId,
    String? categoryId,
    String priority = 'MEDIUM',
    String? contactNumber,
    String? alternateContact,
    String? preferredTime,
    String? category,
    String? locationDescription,
  });

  Future<Either<String, MaintenanceTicketEntity>> updateTicket(
    String id, {
    String? title,
    String? description,
    String? priority,
    String? categoryId,
    String? siteId,
    String? spaceId,
  });

  Future<Either<String, MaintenanceTicketEntity>> changeStatus(
    String id,
    String status,
    String? notes,
  );

  Future<Either<String, MaintenanceTicketEntity>> assignTechnician(
    String ticketId,
    String technicianId,
  );

  Future<Either<String, MaintenanceTicketEntity>> acknowledgeTicket(String id);

  Future<Either<String, MaintenanceTicketEntity>> cancelTicket(String id);

  Future<Either<String, MaintenanceTicketEntity>> addTechnicianNotes(
    String id,
    String notes,
  );

  Future<Either<String, MaintenanceTicketEntity>> addResolutionNotes(
    String id,
    String notes,
  );

  Future<Either<String, MaintenanceTicketEntity>> confirmCompletion(String id);

  Future<Either<String, MaintenanceTicketEntity>> submitRating(
    String ticketId,
    int rating,
    String? comment,
  );

  Future<Either<String, List<DepartmentEntity>>> getDepartments();

  // New methods for villas, teams, sites, spaces, categories
  Future<Either<String, List<VillaEntity>>> getVillas({
    String? siteId,
    bool? isActive,
  });

  Future<Either<String, List<VillaEntity>>> getTenantVillasForCurrentUser();

  Future<Either<String, List<TeamEntity>>> getTeams({
    String? departmentId,
    bool? isActive,
  });

  Future<Either<String, List<UserEntity>>> getTechnicians();

  Future<Either<String, List<SiteEntity>>> getSites({
    String? companyId,
  });

  Future<Either<String, List<SpaceEntity>>> getSpaces({
    String? siteId,
    String? categoryId,
  });

  Future<Either<String, List<TicketCategoryEntity>>> getCategories({
    String? parentCategoryId,
  });

  // Escalation operations
  Future<Either<String, EscalationHistoryEntity>> escalateTicket(
    String ticketId, {
    required int escalationLevel,
    String? reason,
  });

  Future<Either<String, List<EscalationHistoryEntity>>> getEscalationHistory(
    String ticketId,
  );

  Future<Either<String, List<EscalationMatrixEntity>>> getEscalationMatrix();

  Future<Either<String, PaginatedTicketsResult>> getEscalatedTickets({
    int page = 1,
    int limit = 20,
  });

  // New ticket operations
  Future<Either<String, MaintenanceTicketEntity>> linkTicket(
    String ticketId,
    String parentTicketId,
  );

  Future<Either<String, MaintenanceTicketEntity>> assignTeam(
    String ticketId,
    String teamId,
  );

  Future<Either<String, List<MaintenanceTicketEntity>>> getChildTickets(
    String parentTicketId,
  );
}
