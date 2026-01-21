import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../../core/di/service_locator.dart';
import '../../../../../core/utils/date_formatter.dart';
import '../../../../../core/utils/role_access_control.dart';
import '../../../../../core/utils/theme_helpers.dart';
import '../../../../../core/widgets/pluto_grid_config.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../data/repositories/maintenance_ticket_repository.dart';
import '../../../domain/entities/maintenance_ticket_entity.dart';
import '../../bloc/maintenance_ticket_bloc.dart';
import '../../bloc/maintenance_ticket_event.dart';
import '../../bloc/maintenance_ticket_state.dart';
import 'admin_ticket_create_ai_page.dart';
import 'maintenance_ticket_list_filters.dart';

class MaintenanceTicketListPage extends StatelessWidget {
  const MaintenanceTicketListPage({
    super.key,
    this.statusFilter,
    this.priorityFilter,
    this.villaNumbersFilter,
  });

  final String? statusFilter;
  final String? priorityFilter;
  final List<String>? villaNumbersFilter;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MaintenanceTicketBloc(
        repository: getIt<MaintenanceTicketRepository>(),
      )..add(
          LoadMaintenanceTickets(
            status: statusFilter != null
                ? TicketStatus.fromString(statusFilter!).toBackendValue
                : null,
            priority: priorityFilter?.toUpperCase(),
            villaNumbers: villaNumbersFilter,
            page: 1,
            limit: 50,
          ),
        ),
      child: _MaintenanceTicketListContent(
        statusFilter: statusFilter,
        priorityFilter: priorityFilter,
        villaNumbersFilter: villaNumbersFilter,
      ),
    );
  }
}

class _MaintenanceTicketListContent extends StatefulWidget {
  const _MaintenanceTicketListContent({
    this.statusFilter,
    this.priorityFilter,
    this.villaNumbersFilter,
  });

  final String? statusFilter;
  final String? priorityFilter;
  final List<String>? villaNumbersFilter;

  @override
  State<_MaintenanceTicketListContent> createState() =>
      _MaintenanceTicketListContentState();
}

class _MaintenanceTicketListContentState
    extends State<_MaintenanceTicketListContent> {
  PlutoGridStateManager? _stateManager;

  // Only UI-only state (not business logic state)
  final int _pageSize = 50;
  int _currentPage = 1; // UI-only: tracks which page user is viewing

  // Filter state (UI-only filtering, not persisted)
  final _searchController = TextEditingController();

  // Note: Business data (_tickets, _totalCount, _isLoading) comes from BLoC state
  // Filter parameters that trigger API calls should be managed via BLoC events
  String? _statusFilter;
  String? _priorityFilter;
  List<String>? _villaNumbersFilter;
  String? _departmentFilter;
  String? _siteFilter;
  String? _technicianFilter;
  bool? _isEscalatedFilter;
  String? _sortBy;
  String? _sortOrder;

  @override
  void initState() {
    super.initState();
    _statusFilter = widget.statusFilter;
    _priorityFilter = widget.priorityFilter;
    _villaNumbersFilter = widget.villaNumbersFilter;

    // Listen to search controller changes for local filtering only
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    // Update grid when search changes (local filtering only)
    // Get tickets from current BLoC state
    if (_stateManager != null && mounted) {
      final bloc = context.read<MaintenanceTicketBloc>();
      final state = bloc.state;
      if (state is MaintenanceTicketListLoaded) {
        _updateGridData(state.tickets);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Helper method to get assigned technician display name
  String _getAssignedTechnicianDisplay(MaintenanceTicketEntity ticket) {
    // If no technician is assigned, show "Unassigned"
    if (ticket.assignedTechnicianId == null ||
        ticket.assignedTechnicianId!.isEmpty) {
      return 'Unassigned';
    }

    // Prefer firstName from the entity if available
    if (ticket.assignedTechnician != null) {
      if (ticket.assignedTechnician!.firstName != null &&
          ticket.assignedTechnician!.firstName!.isNotEmpty) {
        return ticket.assignedTechnician!.firstName!;
      }
      // If entity exists but firstName is null, try lastName or email
      if (ticket.assignedTechnician!.lastName != null &&
          ticket.assignedTechnician!.lastName!.isNotEmpty) {
        return ticket.assignedTechnician!.lastName!;
      }
      if (ticket.assignedTechnician!.email.isNotEmpty) {
        return ticket.assignedTechnician!.email;
      }
    }

    // Fallback to display name (full name or email) from getter
    final displayName = ticket.assignedTechnicianDisplayName;
    if (displayName != null && displayName.isNotEmpty) {
      // Try to extract firstName from full name (e.g., "John Technician" -> "John")
      final parts = displayName.trim().split(' ');
      if (parts.isNotEmpty && parts.first.isNotEmpty) {
        return parts.first;
      }
      return displayName;
    }

    // Fallback to stored name if entity is null
    final storedName = ticket.assignedTechnicianName;
    if (storedName != null && storedName.isNotEmpty) {
      // Try to extract firstName from stored name
      final parts = storedName.trim().split(' ');
      if (parts.isNotEmpty && parts.first.isNotEmpty) {
        return parts.first;
      }
      return storedName;
    }

    // Last resort: show "Assigned" if ID exists but no name available
    return 'Assigned';
  }

  /// Helper method to get assigned supervisor display name
  String _getAssignedSupervisorDisplay(MaintenanceTicketEntity ticket) {
    // If no supervisor is assigned, return empty string
    if (ticket.assignedSupervisorId == null ||
        ticket.assignedSupervisorId!.isEmpty) {
      return '';
    }

    // Prefer firstName from the entity if available
    if (ticket.assignedSupervisor != null) {
      if (ticket.assignedSupervisor!.firstName != null &&
          ticket.assignedSupervisor!.firstName!.isNotEmpty) {
        return ticket.assignedSupervisor!.firstName!;
      }
      // If entity exists but firstName is null, try lastName or email
      if (ticket.assignedSupervisor!.lastName != null &&
          ticket.assignedSupervisor!.lastName!.isNotEmpty) {
        return ticket.assignedSupervisor!.lastName!;
      }
      if (ticket.assignedSupervisor!.email.isNotEmpty) {
        return ticket.assignedSupervisor!.email;
      }
    }

    // Fallback to display name (full name or email) from getter
    final displayName = ticket.assignedSupervisorDisplayName;
    if (displayName != null && displayName.isNotEmpty) {
      // Try to extract firstName from full name (e.g., "John Supervisor" -> "John")
      final parts = displayName.trim().split(' ');
      if (parts.isNotEmpty && parts.first.isNotEmpty) {
        return parts.first;
      }
      return displayName;
    }

    // Fallback to stored name if entity is null
    final storedName = ticket.assignedSupervisorName;
    if (storedName != null && storedName.isNotEmpty) {
      // Try to extract firstName from stored name
      final parts = storedName.trim().split(' ');
      if (parts.isNotEmpty && parts.first.isNotEmpty) {
        return parts.first;
      }
      return storedName;
    }

    // Return empty string if no name available
    return '';
  }

  /// Helper method to get pagination range text (e.g., "1-50", "51-100")
  /// Reads from BLoC state, not local state
  String _getPaginationRangeText(
      MaintenanceTicketListLoaded state, int currentPage) {
    final totalCount = state.total;
    if (totalCount == 0) {
      return '0';
    }

    final startIndex = ((currentPage - 1) * _pageSize) + 1;
    final endIndex = (currentPage * _pageSize) < totalCount
        ? (currentPage * _pageSize)
        : totalCount;

    if (startIndex == endIndex) {
      return '$startIndex';
    }
    return '$startIndex-$endIndex';
  }

  List<MaintenanceTicketEntity> _getFilteredTickets(
      List<MaintenanceTicketEntity> tickets) {
    var filtered = List<MaintenanceTicketEntity>.from(tickets);

    // Filter by search query
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((ticket) {
        final ticketNumber = ticket.ticketNumber.toLowerCase();
        final title = ticket.title.toLowerCase();
        final location = ticket.locationDisplay.toLowerCase();
        final description = (ticket.description ?? '').toLowerCase();
        return ticketNumber.contains(query) ||
            title.contains(query) ||
            location.contains(query) ||
            description.contains(query);
      }).toList();
    }

    return filtered;
  }

  void _updateGridData(List<MaintenanceTicketEntity> tickets) {
    if (_stateManager == null) return;
    final filteredTickets = _getFilteredTickets(tickets);
    _stateManager!.removeAllRows();
    _stateManager!.appendRows(_convertTicketsToRows(filteredTickets));
  }

  /// Converts status filter value to backend format
  /// Handles both old format (status.name like "new_") and new format (toBackendValue like "NEW")
  String? _convertStatusFilterToBackend(String? statusFilter) {
    if (statusFilter == null) return null;
    // Try to parse it as a status enum to get the correct backend value
    // This handles both "new_", "NEW", "New", etc.
    try {
      final status = TicketStatus.fromString(statusFilter);
      return status.toBackendValue;
    } catch (e) {
      // If parsing fails, return uppercase (fallback for edge cases)
      return statusFilter.toUpperCase();
    }
  }

  void _loadTickets({int? page}) {
    final targetPage = page ?? 1;
    context.read<MaintenanceTicketBloc>().add(
          LoadMaintenanceTickets(
            status: _convertStatusFilterToBackend(_statusFilter),
            priority: _priorityFilter?.toUpperCase(),
            villaNumbers: _villaNumbersFilter,
            departmentId: _departmentFilter,
            assignedTechnicianId: _technicianFilter,
            isEscalated: _isEscalatedFilter,
            page: targetPage,
            limit: _pageSize,
            sortBy: _sortBy,
            sortOrder: _sortOrder,
          ),
        );
  }

  /// Navigate to ticket detail page and refresh list if needed
  Future<void> _navigateToTicketDetail(String ticketId) async {
    final result = await context.push('/maintenance-tickets/$ticketId');
    // If result is true, refresh the list
    if (result == true) {
      _loadTickets();
    }
  }

  List<PlutoColumn> _buildColumns(
    BuildContext context,
    double availableWidth,
    List<MaintenanceTicketEntity> tickets,
  ) {
    final user = context.read<AuthBloc>().state.maybeWhen(
          authenticated: (user) => user,
          orElse: () => null,
        );

    final isTenant = user != null && RoleAccessControl.isTenant(user);
    final isAdmin = user != null && RoleAccessControl.isAdmin(user);
    final isTechnician = user != null && RoleAccessControl.isTechnician(user);

    // Define minimum widths for each column
    final minWidths = <String, double>{
      'ticket_number': 120.0,
      'title': 200.0,
      'status': 110.0,
      'priority': 110.0,
      'location': 120.0,
      'category': 130.0,
      'assigned_technician': 140.0,
      'assigned_supervisor': 140.0,
      'created_at': 160.0,
      'updated_at': 160.0,
      'actions': 80.0,
    };

    // Calculate total minimum width for visible columns
    double totalMinWidth = minWidths['ticket_number']! +
        minWidths['title']! +
        minWidths['status']! +
        minWidths['priority']! +
        minWidths['location']! +
        minWidths['assigned_technician']! +
        minWidths['created_at']! +
        minWidths['actions']!;

    if (!isTenant) {
      totalMinWidth += minWidths['category']! + minWidths['updated_at']!;
    }
    if (isAdmin || !isTechnician) {
      totalMinWidth += minWidths['assigned_supervisor']!;
    }

    // Calculate width multiplier to fit screen
    final widthMultiplier =
        availableWidth < totalMinWidth ? 1.0 : (availableWidth / totalMinWidth);

    final columns = <PlutoColumn>[
      // Ticket Number (always visible, frozen)
      PlutoColumn(
        title: 'Ticket #',
        field: 'ticket_number',
        type: PlutoColumnType.text(),
        width: (minWidths['ticket_number']! * widthMultiplier)
            .clamp(120.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
        frozen: PlutoColumnFrozen.start,
      ),

      // Title
      PlutoColumn(
        title: 'Title',
        field: 'title',
        type: PlutoColumnType.text(),
        width: (minWidths['title']! * widthMultiplier)
            .clamp(200.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
      ),

      // Status with custom renderer
      PlutoColumn(
        title: 'Status',
        field: 'status',
        type: PlutoColumnType.text(),
        width: (minWidths['status']! * widthMultiplier)
            .clamp(110.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
        renderer: (rendererContext) {
          final statusStr = rendererContext.cell.value.toString();
          final status = TicketStatus.fromString(statusStr);
          final color = _getStatusColor(status);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              status.displayName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          );
        },
      ),

      // Priority with custom renderer (same design as status)
      PlutoColumn(
        title: 'Priority',
        field: 'priority',
        type: PlutoColumnType.text(),
        width: (minWidths['priority']! * widthMultiplier)
            .clamp(110.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
        renderer: (rendererContext) {
          final priorityStr = rendererContext.cell.value.toString();
          final priority = TicketPriority.fromString(priorityStr);
          final color = _getPriorityColor(priority);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              priority.displayName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          );
        },
      ),

      // Location/Villa - Show for all users
      PlutoColumn(
        title: 'Location',
        field: 'location',
        type: PlutoColumnType.text(),
        width: (minWidths['location']! * widthMultiplier)
            .clamp(120.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
      ),

      // Category - Hidden for tenants
      if (!isTenant)
        PlutoColumn(
          title: 'Category',
          field: 'category',
          type: PlutoColumnType.text(),
          width: (minWidths['category']! * widthMultiplier)
              .clamp(130.0, double.infinity),
          enableSorting: true,
          enableColumnDrag: true,
          enableFilterMenuItem: true,
        ),

      // Assigned Technician - Show for all but tenants see limited info
      if (!isTenant || isTenant)
        PlutoColumn(
          title: 'Assigned To',
          field: 'assigned_technician',
          type: PlutoColumnType.text(),
          width: (minWidths['assigned_technician']! * widthMultiplier)
              .clamp(140.0, double.infinity),
          enableSorting: true,
          enableColumnDrag: true,
          enableFilterMenuItem: !isTenant,
        ),

      // Supervisor - Admin and coordinators only
      if (isAdmin || !isTechnician)
        PlutoColumn(
          title: 'Supervisor',
          field: 'assigned_supervisor',
          type: PlutoColumnType.text(),
          width: (minWidths['assigned_supervisor']! * widthMultiplier)
              .clamp(140.0, double.infinity),
          enableSorting: true,
          enableColumnDrag: true,
          enableFilterMenuItem: true,
        ),

      // Created Date
      PlutoColumn(
        title: 'Created',
        field: 'created_at',
        type: PlutoColumnType.text(),
        width: (minWidths['created_at']! * widthMultiplier)
            .clamp(130.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
        renderer: (rendererContext) {
          final value = rendererContext.cell.value;
          DateTime date;

          if (value is DateTime) {
            date = value;
          } else if (value is String) {
            try {
              date = DateTime.parse(value);
            } catch (e) {
              return const SizedBox.shrink();
            }
          } else {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              DateFormatter.formatDateTimeForTable(date),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        },
      ),

      // Updated Date - Admin and coordinators only
      if (!isTenant)
        PlutoColumn(
          title: 'Updated',
          field: 'updated_at',
          type: PlutoColumnType.text(),
          width: (minWidths['updated_at']! * widthMultiplier)
              .clamp(160.0, double.infinity),
          enableSorting: true,
          enableColumnDrag: true,
          enableFilterMenuItem: true,
          renderer: (rendererContext) {
            final value = rendererContext.cell.value;
            DateTime date;

            if (value is DateTime) {
              date = value;
            } else if (value is String) {
              try {
                date = DateTime.parse(value);
              } catch (e) {
                return const SizedBox.shrink();
              }
            } else {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                DateFormatter.formatDateTimeForTable(date),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          },
        ),

      // Actions column (always last)
      PlutoColumn(
        title: 'Actions',
        field: 'actions',
        type: PlutoColumnType.text(),
        width: minWidths['actions']!,
        enableSorting: false,
        enableColumnDrag: false,
        enableFilterMenuItem: false,
        renderer: (rendererContext) {
          final ticketNumber =
              rendererContext.row.cells['ticket_number']?.value.toString();
          final ticket = _findTicketByNumber(ticketNumber!, tickets);
          return Center(
            child: IconButton(
              icon: Icon(
                Icons.visibility_outlined,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () => _navigateToTicketDetail(ticket!.id),
              tooltip: 'View Details',
            ),
          );
        },
      ),
    ];

    return columns;
  }

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.new_:
        return Colors.blue;
      case TicketStatus.acknowledged:
        return Colors.orange;
      case TicketStatus.assigned:
        return Colors.purple;
      case TicketStatus.inProgress:
        return Colors.indigo;
      case TicketStatus.onHold:
        return Colors.amber;
      case TicketStatus.completed:
        return Colors.green;
      case TicketStatus.cancelled:
        return Colors.red;
    }
  }

  Color _getPriorityColor(TicketPriority priority) {
    switch (priority) {
      case TicketPriority.low:
        return Colors.green;
      case TicketPriority.medium:
        return Colors.blue;
      case TicketPriority.high:
        return Colors.orange;
      case TicketPriority.urgent:
        return Colors.red;
    }
  }

  List<PlutoRow> _convertTicketsToRows(List<MaintenanceTicketEntity> tickets) {
    return tickets.map((ticket) {
      // Ensure dates are DateTime objects for proper sorting/filtering
      // Store as DateTime, renderer will handle formatting
      return PlutoRow(
        cells: {
          'ticket_number': PlutoCell(value: ticket.ticketNumber),
          'title': PlutoCell(value: ticket.title),
          'status': PlutoCell(value: ticket.status.name),
          'priority': PlutoCell(value: ticket.priority.name),
          'location': PlutoCell(value: ticket.locationDisplay),
          'category': PlutoCell(value: ticket.category?.name ?? ''),
          'assigned_technician': PlutoCell(
            value: _getAssignedTechnicianDisplay(ticket),
          ),
          'assigned_supervisor': PlutoCell(
            value: _getAssignedSupervisorDisplay(ticket),
          ),
          // Store DateTime directly - entity already has DateTime type
          'created_at': PlutoCell(value: ticket.createdAt),
          'updated_at': PlutoCell(value: ticket.updatedAt),
          'actions': PlutoCell(value: ''),
        },
      );
    }).toList();
  }

  MaintenanceTicketEntity? _findTicketByNumber(
    String ticketNumber,
    List<MaintenanceTicketEntity> tickets,
  ) {
    try {
      return tickets.firstWhere(
        (ticket) => ticket.ticketNumber == ticketNumber,
      );
    } catch (e) {
      return null;
    }
  }

  Widget _buildMobileView(
    BuildContext context,
    List<MaintenanceTicketEntity> tickets,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filteredTickets = _getFilteredTickets(tickets);

    if (filteredTickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No tickets found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or create a new ticket',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredTickets.length,
      itemBuilder: (context, index) {
        final ticket = filteredTickets[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text(
              ticket.title,
              style: theme.textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Ticket #${ticket.ticketNumber}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      ticket.status.displayName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(ticket.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ticket.priority.displayName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getPriorityColor(ticket.priority),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (ticket.locationDisplay.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    ticket.locationDisplay,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
                if (ticket.assignedTechnicianId != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Assigned: ${_getAssignedTechnicianDisplay(ticket)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  DateFormatter.formatDateTimeForTable(ticket.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => _navigateToTicketDetail(ticket.id),
            ),
            onTap: () => _navigateToTicketDetail(ticket.id),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Tickets'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: const [],
      ),
      body: BlocListener<MaintenanceTicketBloc, MaintenanceTicketState>(
        listener: (context, state) {
          state.maybeWhen(
            orElse: () {},
            listLoaded: (tickets, total) {
              // Update grid with tickets from BLoC state (no setState needed)
              _stateManager?.setShowLoading(false);
              _updateGridData(tickets);
            },
            loading: () {
              _stateManager?.setShowLoading(true);
            },
            error: (message) {
              _stateManager?.setShowLoading(false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: colorScheme.error,
                ),
              );
            },
          );
        },
        child: BlocBuilder<MaintenanceTicketBloc, MaintenanceTicketState>(
          builder: (context, state) {
            if (state is MaintenanceTicketInitial ||
                state is MaintenanceTicketLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Loading tickets...',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is MaintenanceTicketError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load tickets',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _loadTickets(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Extract tickets and total from BLoC state
            if (state is! MaintenanceTicketListLoaded) {
              // Should not happen, but handle gracefully
              return const SizedBox.shrink();
            }

            final listState = state as MaintenanceTicketListLoaded;
            final tickets = listState.tickets;
            final totalCount = listState.total;

            return Column(
              children: [
                // Modern Filter Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: context.cardBorderRadius,
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              labelText: 'Search',
                              hintText:
                                  'Search by ticket number, title, location...',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        // Grid will update via listener
                                      },
                                    )
                                  : null,
                              isDense: true,
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              // Remove background
                              filled: false,
                            ),
                            onChanged: (_) {
                              // Grid will update via listener
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _statusFilter,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.normal,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Status',
                              labelStyle: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              isDense: true,
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              // Remove background
                              filled: false,
                            ),
                            isExpanded: true,
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text(
                                  'All Status',
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              ...TicketStatus.values.map(
                                (status) => DropdownMenuItem(
                                  value: status.toBackendValue,
                                  child: Text(
                                    status.displayName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              _statusFilter = value;
                              _loadTickets(page: 1);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _priorityFilter,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.normal,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Priority',
                              labelStyle: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              isDense: true,
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              // Remove background
                              filled: false,
                            ),
                            isExpanded: true,
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text(
                                  'All Priority',
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              ...TicketPriority.values.map(
                                (priority) => DropdownMenuItem(
                                  value: priority.name,
                                  child: Text(
                                    priority.displayName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              _priorityFilter = value;
                              _loadTickets(page: 1);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Refresh Button
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _loadTickets(page: _currentPage);
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 56),
                            ),
                            child: const Text('Refresh'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Create Ticket Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final created =
                                  await AdminTicketCreateAiDialog.show(context);
                              if (created == true && context.mounted) {
                                // Refresh the ticket list
                                context.read<MaintenanceTicketBloc>().add(
                                      const LoadMaintenanceTickets(),
                                    );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 56),
                            ),
                            child: const Text('Create Ticket'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Clear All Button
                if (_hasActiveFilters())
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            _statusFilter = null;
                            _priorityFilter = null;
                            _villaNumbersFilter = null;
                            _departmentFilter = null;
                            _siteFilter = null;
                            _technicianFilter = null;
                            _searchController.clear();
                            _currentPage = 1;
                            _loadTickets(page: 1);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.error,
                            side: BorderSide(
                              color: colorScheme.error.withValues(alpha: 0.5),
                            ),
                          ),
                          child: const Text('Clear All Filters'),
                        ),
                      ],
                    ),
                  ),

                // Enhanced pagination and info bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.08),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 8),
                          RichText(
                            text: TextSpan(
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                              children: [
                                TextSpan(
                                  text: _getPaginationRangeText(
                                    MaintenanceTicketListLoaded(
                                      tickets: tickets,
                                      total: totalCount,
                                    ),
                                    _currentPage,
                                  ),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const TextSpan(text: ' of '),
                                TextSpan(
                                  text: '$totalCount',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const TextSpan(text: ' tickets'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Previous button
                          IconButton(
                            onPressed: _currentPage > 1
                                ? () {
                                    _currentPage--;
                                    _loadTickets(page: _currentPage);
                                  }
                                : null,
                            icon: const Icon(Icons.chevron_left, size: 20),
                            tooltip: 'Previous Page',
                            style: IconButton.styleFrom(
                              minimumSize: const Size(36, 36),
                              padding: const EdgeInsets.all(8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: colorScheme.outline
                                      .withValues(alpha: 0.2),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Page info with improved styling
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$_currentPage',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  child: Text(
                                    '/',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onPrimaryContainer
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                                Text(
                                  '${(totalCount / _pageSize).ceil()}',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Next button
                          IconButton(
                            onPressed: (_currentPage * _pageSize) < totalCount
                                ? () {
                                    _currentPage++;
                                    _loadTickets(page: _currentPage);
                                  }
                                : null,
                            icon: const Icon(Icons.chevron_right, size: 20),
                            tooltip: 'Next Page',
                            style: IconButton.styleFrom(
                              minimumSize: const Size(36, 36),
                              padding: const EdgeInsets.all(8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: colorScheme.outline
                                      .withValues(alpha: 0.2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // PlutoGrid - Responsive layout
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // On mobile, show simplified view
                      final isMobile = constraints.maxWidth < 768;

                      if (isMobile) {
                        // For mobile, use a simpler list view
                        return _buildMobileView(context, tickets);
                      }

                      // Desktop/Tablet view with full grid
                      final filteredTickets = _getFilteredTickets(tickets);
                      final rows = _convertTicketsToRows(filteredTickets);

                      if (rows.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: theme
                                      .colorScheme.surfaceContainerHighest
                                      .withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.search_off_rounded,
                                  size: 64,
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'No tickets found',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your search or filter criteria',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Theme(
                        data: PlutoGridConfig.buildGridTheme(context),
                        child: PlutoGrid(
                          columns: _buildColumns(
                            context,
                            constraints.maxWidth,
                            tickets,
                          ),
                          rows: rows,
                          onLoaded: (PlutoGridOnLoadedEvent event) {
                            _stateManager = event.stateManager;
                            // Loading state comes from BLoC, not local variable
                            _stateManager?.setShowLoading(false);
                            _stateManager?.setSelectingMode(
                              PlutoGridSelectingMode.row,
                            );
                            _stateManager?.setShowColumnFilter(true);

                            // Reset horizontal scroll to start (leftmost position)
                            // This ensures frozen columns are properly visible
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _stateManager?.scroll.horizontal?.jumpTo(0);
                            });
                          },
                          onChanged: (PlutoGridOnChangedEvent event) {
                            // Handle cell changes if needed
                          },
                          onSelected: (PlutoGridOnSelectedEvent event) {
                            // Handle selection changes if needed
                          },
                          onRowDoubleTap: (event) {
                            final row = event.row;
                            final ticketNumber =
                                row.cells['ticket_number']?.value.toString();
                            if (ticketNumber != null) {
                              final ticket =
                                  _findTicketByNumber(ticketNumber, tickets);
                              if (ticket != null) {
                                _navigateToTicketDetail(ticket.id);
                              }
                            }
                          },
                          configuration:
                              PlutoGridConfig.buildConfiguration(context),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      // floatingActionButton: canCreateTickets
      //     ? FloatingActionButton(
      //         onPressed: () => context.push('/maintenance-tickets/create'),
      //         child: const Icon(Icons.add),
      //       )
      //     : null,
    );
  }

  bool _hasActiveFilters() {
    return _searchController.text.isNotEmpty ||
        _statusFilter != null ||
        _priorityFilter != null ||
        _villaNumbersFilter != null ||
        _departmentFilter != null ||
        _siteFilter != null ||
        _technicianFilter != null;
  }

  void _showFiltersDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => MaintenanceTicketListFilters(
        statusFilter: _statusFilter,
        priorityFilter: _priorityFilter,
        villaNumberFilter: _villaNumbersFilter?.firstOrNull,
        departmentFilter: _departmentFilter,
        siteFilter: _siteFilter,
        technicianFilter: _technicianFilter,
        onApply: (filters) {
          setState(() {
            _statusFilter = filters.status;
            _priorityFilter = filters.priority;
            _villaNumbersFilter =
                filters.villaNumber != null ? [filters.villaNumber!] : null;
            _departmentFilter = filters.departmentId;
            _siteFilter = filters.siteId;
            _technicianFilter = filters.technicianId;
            _isEscalatedFilter = filters.isEscalated;
          });
          Navigator.pop(context);
          _currentPage = 1;
          _loadTickets(page: 1);
        },
      ),
    );
  }

  void _exportToCsv() {
    // TODO: Implement CSV export
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text('Export functionality coming soon'),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
