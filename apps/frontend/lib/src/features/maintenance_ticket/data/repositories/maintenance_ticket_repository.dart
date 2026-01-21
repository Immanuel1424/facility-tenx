import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/maintenance_ticket_entity.dart';
import '../../domain/entities/villa_entity.dart';
import '../../domain/entities/team_entity.dart';
import '../../domain/entities/site_entity.dart';
import '../../domain/entities/space_entity.dart';
import '../../domain/entities/ticket_category_entity.dart';
import '../../domain/entities/escalation_history_entity.dart';
import '../../domain/entities/escalation_matrix_entity.dart';
import '../../domain/repositories/maintenance_ticket_repository_interface.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../iam/data/dto/user_dto.dart' as iam_dto;
import '../dto/maintenance_ticket_dto.dart';
import '../models/paginated_tickets_result.dart';
import '../mappers/maintenance_ticket_mapper.dart';
import '../mappers/villa_mapper.dart';
import '../mappers/team_mapper.dart';
import '../mappers/site_mapper.dart';
import '../mappers/space_mapper.dart';
import '../mappers/ticket_category_mapper.dart';
import '../mappers/escalation_history_mapper.dart';
import '../mappers/escalation_matrix_mapper.dart';

class MaintenanceTicketRepository
    implements MaintenanceTicketRepositoryInterface {
  MaintenanceTicketRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
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
  }) async {
    try {
      print(
        '📋 Loading maintenance tickets - page: $page, limit: $limit, status: $status',
      );
      final response = await _apiClient.getMaintenanceTickets(
        status: status,
        priority: priority,
        villaNumbers: villaNumbers,
        departmentId: departmentId,
        assignedTechnicianId: assignedTechnicianId,
        search: search,
        ticketType: ticketType,
        siteId: siteId,
        teamId: teamId,
        isEscalated: isEscalated,
        page: page,
        limit: limit,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      print(
        '✅ Received ${response.tickets.length} tickets, total: ${response.total}',
      );

      // Backend returns { tickets: [], total: number }
      final tickets = response.tickets
          .map((dto) => MaintenanceTicketMapper.toEntity(dto))
          .toList();

      print('✅ Mapped ${tickets.length} ticket entities');
      // Return paginated result with both tickets and total
      return Right(
        PaginatedTicketsResult(
          tickets: tickets,
          total: response.total,
        ),
      );
    } catch (e, stackTrace) {
      print('❌ Error loading maintenance tickets: $e');
      print('Stack trace: $stackTrace');
      if (e is DioException) {
        print('❌ DioException details:');
        print('  - Status: ${e.response?.statusCode}');
        print('  - Message: ${e.message}');
        print('  - Response data: ${e.response?.data}');
      }
      return Left('Failed to load tickets: ${e.toString()}');
    }
  }

  /// Get the list of villas available to the current tenant user,
  /// using the backend user_villas mapping. This will typically be
  /// used to power a villa selector when a tenant has multiple villas.
  @override
  Future<Either<String, List<VillaEntity>>>
      getTenantVillasForCurrentUser() async {
    try {
      final dtos = await _apiClient.getTenantVillas();
      final villas = <VillaEntity>[
        for (final VillaDto dto in dtos)
          if (VillaMapper.toEntity(dto) != null) VillaMapper.toEntity(dto)!,
      ];
      return Right(villas);
    } catch (e) {
      return Left('Failed to load tenant villas: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, MaintenanceTicketEntity>> getTicket(String id) async {
    try {
      final dto = await _apiClient.getMaintenanceTicket(id);
      return Right(MaintenanceTicketMapper.toEntity(dto));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
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
  }) async {
    try {
      final dto = CreateTicketDto(
        title: title,
        description: description,
        ticket_type: ticketType,
        villa_number: villaNumber,
        villa_id: villaId,
        site_id: siteId,
        space_id: spaceId,
        category_id: categoryId,
        priority: priority,
        contact_number: contactNumber,
        alternate_contact: alternateContact,
        preferred_time: preferredTime,
        category: category,
        location_detail: locationDescription,
      );
      final response = await _apiClient.createMaintenanceTicket(dto);
      return Right(MaintenanceTicketMapper.toEntity(response));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, MaintenanceTicketEntity>> updateTicket(
    String id, {
    String? title,
    String? description,
    String? priority,
    String? categoryId,
    String? siteId,
    String? spaceId,
  }) async {
    try {
      final dto = UpdateTicketDto(
        title: title,
        description: description,
        priority: priority,
        category_id: categoryId,
        site_id: siteId,
        space_id: spaceId,
      );
      final response = await _apiClient.updateMaintenanceTicket(id, dto);
      return Right(MaintenanceTicketMapper.toEntity(response));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, MaintenanceTicketEntity>> changeStatus(
    String id,
    String status,
    String? notes,
  ) async {
    try {
      final dto = ChangeStatusDto(status: status, notes: notes);
      final response = await _apiClient.changeMaintenanceTicketStatus(id, dto);
      return Right(MaintenanceTicketMapper.toEntity(response));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, MaintenanceTicketEntity>> assignTechnician(
    String ticketId,
    String technicianId,
  ) async {
    try {
      final response = await _apiClient.assignTechnicianToMaintenanceTicket(
        ticketId,
        technicianId,
      );
      return Right(MaintenanceTicketMapper.toEntity(response));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, MaintenanceTicketEntity>> acknowledgeTicket(
    String id,
  ) async {
    try {
      final response = await _apiClient.acknowledgeMaintenanceTicket(id);
      return Right(MaintenanceTicketMapper.toEntity(response));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, MaintenanceTicketEntity>> cancelTicket(
    String id,
  ) async {
    try {
      final response = await _apiClient.cancelMaintenanceTicket(id);
      return Right(MaintenanceTicketMapper.toEntity(response));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, MaintenanceTicketEntity>> addTechnicianNotes(
    String id,
    String notes,
  ) async {
    try {
      final dto = AddNotesDto(notes: notes);
      final response =
          await _apiClient.addMaintenanceTicketTechnicianNotes(id, dto);
      return Right(MaintenanceTicketMapper.toEntity(response));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, MaintenanceTicketEntity>> addResolutionNotes(
    String id,
    String notes,
  ) async {
    try {
      final dto = AddNotesDto(notes: notes);
      final response =
          await _apiClient.addMaintenanceTicketResolutionNotes(id, dto);
      return Right(MaintenanceTicketMapper.toEntity(response));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, MaintenanceTicketEntity>> confirmCompletion(
    String id,
  ) async {
    try {
      final response = await _apiClient.confirmMaintenanceTicketCompletion(id);
      return Right(MaintenanceTicketMapper.toEntity(response));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, MaintenanceTicketEntity>> submitRating(
    String ticketId,
    int rating,
    String? comment,
  ) async {
    try {
      final response =
          await _apiClient.submitTicketRating(ticketId, rating, comment);
      return Right(MaintenanceTicketMapper.toEntity(response));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<DepartmentEntity>>> getDepartments() async {
    try {
      final dtos = await _apiClient.getDepartments();
      final departments = dtos.map((dto) {
        // Convert new DepartmentDto (dept_dto.DepartmentDto) to maintenance ticket's DepartmentEntity
        return DepartmentEntity(
          id: dto.id,
          name: dto.name,
          description: dto.description,
          isActive: dto.isActive,
        );
      }).toList();
      return Right(departments);
    } catch (e) {
      return Left(e.toString());
    }
  }

  // New methods for villas, teams, sites, spaces, categories
  @override
  Future<Either<String, List<VillaEntity>>> getVillas({
    String? siteId,
    bool? isActive,
  }) async {
    try {
      final dtos = await _apiClient.getVillas(
        siteId: siteId,
        isActive: isActive,
      );
      final villas = <VillaEntity>[
        for (final VillaDto dto in dtos)
          if (VillaMapper.toEntity(dto) != null) VillaMapper.toEntity(dto)!,
      ];
      return Right(villas);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<TeamEntity>>> getTeams({
    String? departmentId,
    bool? isActive,
  }) async {
    try {
      final dtos = await _apiClient.getTeams(
        departmentId: departmentId,
        isActive: isActive,
      );
      print('📦 Parsing ${dtos.length} team DTOs');
      final teams = dtos
          .map<TeamEntity?>((TeamDto dto) {
            final entity = TeamMapper.toEntity(dto);
            if (entity == null) {
              print('⚠️ Failed to map team DTO: ${dto.id} - ${dto.name}');
            } else {
              print(
                '✅ Mapped team: ${entity.id} - ${entity.name} - displayName: ${entity.displayName}',
              );
            }
            return entity;
          })
          .whereType<TeamEntity>()
          .toList();
      print('✅ Total teams after mapping: ${teams.length}');
      return Right(teams);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const Right([]);
      }
      return Left(e.toString());
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<UserEntity>>> getTechnicians() async {
    try {
      print('📞 Calling getTechnicians API (independent - no filters)');
      final dtos = await _apiClient.getTechnicians();
      print('📦 Received ${dtos.length} technician DTOs');
      final technicians = dtos
          .map((dto) {
            final entity = _userDtoToEntity(dto);
            if (entity == null) {
              print(
                '⚠️ Failed to map technician DTO: ${dto.id} - ${dto.email}',
              );
            } else {
              print(
                '✅ Mapped technician: ${entity.id} - ${entity.email} - ${entity.firstName} ${entity.lastName}',
              );
            }
            return entity;
          })
          .whereType<UserEntity>()
          .toList();
      print('✅ Total technicians after mapping: ${technicians.length}');
      return Right(technicians);
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] as String? ??
          e.message ??
          'Failed to load technicians';
      return Left(errorMessage);
    } catch (e) {
      return Left('Failed to load technicians: ${e.toString()}');
    }
  }

  UserEntity? _userDtoToEntity(iam_dto.UserDto dto) {
    return UserEntity(
      id: dto.id,
      email: dto.email,
      companyId: dto.companyId,
      siteId: '', // Site info not available in iam UserDto
      siteCode: '', // Site info not available in iam UserDto
      firstName: dto.firstName,
      lastName: dto.lastName,
      villaNumber: dto.villaNumber,
      roles: dto.roles ?? [],
      permissions: const [],
    );
  }

  @override
  Future<Either<String, List<SiteEntity>>> getSites({
    String? companyId,
  }) async {
    try {
      // Backend lookup for sites no longer requires an explicit companyId
      // The current tenant/company context is derived from the authenticated user.
      // We still accept companyId in the interface for backward compatibility,
      // but it is not passed through to the API.
      final dtos = await _apiClient.getSites();
      final sites = dtos
          .map<SiteEntity?>((SiteDto dto) => SiteMapper.toEntity(dto))
          .whereType<SiteEntity>()
          .toList();
      return Right(sites);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<SpaceEntity>>> getSpaces({
    String? siteId,
    String? categoryId,
  }) async {
    try {
      final dtos = await _apiClient.getSpaces(
        siteId: siteId,
        categoryId: categoryId,
      );
      final spaces = dtos
          .map<SpaceEntity?>((SpaceDto dto) => SpaceMapper.toEntity(dto))
          .whereType<SpaceEntity>()
          .toList();
      return Right(spaces);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<TicketCategoryEntity>>> getCategories({
    String? parentCategoryId,
  }) async {
    try {
      final dtos = await _apiClient.getTicketCategories(
        parentCategoryId: parentCategoryId,
      );
      final categories = dtos
          .map<TicketCategoryEntity?>(
              (TicketCategoryDto dto) => TicketCategoryMapper.toEntity(dto))
          .whereType<TicketCategoryEntity>()
          .toList();
      return Right(categories);
    } catch (e) {
      return Left(e.toString());
    }
  }

  // Escalation operations
  @override
  Future<Either<String, EscalationHistoryEntity>> escalateTicket(
    String ticketId, {
    required int escalationLevel,
    String? reason,
  }) async {
    try {
      final dto = EscalateTicketDto(
        escalation_level: escalationLevel,
        reason: reason,
      );
      final response =
          await _apiClient.escalateMaintenanceTicket(ticketId, dto);
      return Right(EscalationHistoryMapper.toEntity(response));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<EscalationHistoryEntity>>> getEscalationHistory(
    String ticketId,
  ) async {
    try {
      final dtos = await _apiClient.getEscalationHistory(ticketId);
      final history =
          dtos.map((dto) => EscalationHistoryMapper.toEntity(dto)).toList();
      return Right(history);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<EscalationMatrixEntity>>>
      getEscalationMatrix() async {
    try {
      final dtos = await _apiClient.getEscalationMatrix();
      final matrix =
          dtos.map((dto) => EscalationMatrixMapper.toEntity(dto)).toList();
      return Right(matrix);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, PaginatedTicketsResult>> getEscalatedTickets({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.getEscalatedTickets(
        queryParams: {
          'is_escalated': true,
          'page': page,
          'limit': limit,
        },
      );
      final tickets = response.tickets
          .map((dto) => MaintenanceTicketMapper.toEntity(dto))
          .toList();
      return Right(
        PaginatedTicketsResult(
          tickets: tickets,
          total: response.total,
        ),
      );
    } catch (e) {
      return Left(e.toString());
    }
  }

  // New ticket operations

  @override
  Future<Either<String, MaintenanceTicketEntity>> linkTicket(
    String ticketId,
    String parentTicketId,
  ) async {
    try {
      final dto = LinkTicketDto(parent_ticket_id: parentTicketId);
      final response = await _apiClient.linkMaintenanceTicket(ticketId, dto);
      return Right(MaintenanceTicketMapper.toEntity(response));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, MaintenanceTicketEntity>> assignTeam(
    String ticketId,
    String teamId,
  ) async {
    try {
      final response =
          await _apiClient.assignTeamToMaintenanceTicket(ticketId, teamId);
      return Right(MaintenanceTicketMapper.toEntity(response));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<MaintenanceTicketEntity>>> getChildTickets(
    String parentTicketId,
  ) async {
    try {
      final dtos = await _apiClient.getChildTickets(parentTicketId);
      final tickets =
          dtos.map((dto) => MaintenanceTicketMapper.toEntity(dto)).toList();
      // Return empty list if endpoint not available (handled gracefully in API client)
      return Right(tickets);
    } on DioException catch (e) {
      // If 404, return empty list (endpoint doesn't exist yet)
      if (e.response?.statusCode == 404) {
        print('⚠️ Child tickets endpoint not available, returning empty list');
        return const Right([]);
      }
      return Left(e.toString());
    } catch (e) {
      return Left(e.toString());
    }
  }
}
