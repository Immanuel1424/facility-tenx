import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/di/service_locator.dart';
import '../../../maintenance_ticket/domain/entities/maintenance_ticket_entity.dart';
import '../../../maintenance_ticket/domain/repositories/maintenance_ticket_repository_interface.dart';
import '../../../maintenance_ticket/presentation/bloc/maintenance_ticket_bloc.dart';
import '../../../maintenance_ticket/presentation/bloc/maintenance_ticket_event.dart';
import '../../../maintenance_ticket/presentation/bloc/maintenance_ticket_state.dart';

/// PlutoGrid widget for displaying maintenance tickets in a simple data grid format
/// Features: Sorting, Column Resizing, Keyboard Navigation
class MaintenanceTicketsGrid extends StatefulWidget {
  const MaintenanceTicketsGrid({
    super.key,
    this.initialLimit = 50,
    this.onRowDoubleTap,
    this.fullPage = false,
  });

  final int initialLimit;
  final void Function(MaintenanceTicketEntity ticket)? onRowDoubleTap;
  final bool fullPage; // If true, removes Card wrapper and fills entire space

  @override
  State<MaintenanceTicketsGrid> createState() => _MaintenanceTicketsGridState();
}

class _MaintenanceTicketsGridState extends State<MaintenanceTicketsGrid> {
  PlutoGridStateManager? _stateManager;
  final List<PlutoRow> _rows = [];
  final List<MaintenanceTicketEntity> _tickets = [];
  final int _currentPage = 1;
  int _totalCount = 0;
  bool _isLoading = false;

  List<PlutoColumn> _buildColumns(double availableWidth) {
    // Minimum widths for each column
    final minWidths = {
      'ticketNumber': 100.0,
      'title': 200.0,
      'status': 100.0,
      'priority': 90.0,
      'villa_number': 80.0,
      'department': 120.0,
      'assigned_technician': 130.0,
      'created_at': 110.0,
    };

    // Total minimum width
    final totalMinWidth =
        minWidths.values.fold(0.0, (sum, width) => sum + width);

    // Calculate proportional widths
    final widthMultiplier =
        availableWidth < totalMinWidth ? 1.0 : (availableWidth / totalMinWidth);

    return [
      PlutoColumn(
        title: 'Ticket #',
        field: 'ticketNumber',
        type: PlutoColumnType.text(),
        width: (minWidths['ticketNumber']! * widthMultiplier)
            .clamp(100.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
      ),
      PlutoColumn(
        title: 'Title',
        field: 'title',
        type: PlutoColumnType.text(),
        width: (minWidths['title']! * widthMultiplier)
            .clamp(200.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
      ),
      PlutoColumn(
        title: 'Status',
        field: 'status',
        type: PlutoColumnType.text(),
        width: (minWidths['status']! * widthMultiplier)
            .clamp(100.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
      ),
      PlutoColumn(
        title: 'Priority',
        field: 'priority',
        type: PlutoColumnType.text(),
        width: (minWidths['priority']! * widthMultiplier)
            .clamp(90.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
      ),
      PlutoColumn(
        title: 'Villa #',
        field: 'villa_number',
        type: PlutoColumnType.number(),
        width: (minWidths['villa_number']! * widthMultiplier)
            .clamp(80.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
      ),
      PlutoColumn(
        title: 'Department',
        field: 'department',
        type: PlutoColumnType.text(),
        width: (minWidths['department']! * widthMultiplier)
            .clamp(120.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
      ),
      PlutoColumn(
        title: 'Technician',
        field: 'assigned_technician',
        type: PlutoColumnType.text(),
        width: (minWidths['assigned_technician']! * widthMultiplier)
            .clamp(130.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
      ),
      PlutoColumn(
        title: 'Created',
        field: 'created_at',
        type: PlutoColumnType.date(),
        width: (minWidths['created_at']! * widthMultiplier)
            .clamp(110.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
      ),
    ];
  }

  List<PlutoRow> _convertTicketsToRows(List<MaintenanceTicketEntity> tickets) {
    return tickets.map((ticket) {
      return PlutoRow(
        cells: {
          'ticketNumber': PlutoCell(value: ticket.ticketNumber),
          'title': PlutoCell(value: ticket.title),
          'status': PlutoCell(value: ticket.status.name.toUpperCase()),
          'priority': PlutoCell(value: ticket.priority.name.toUpperCase()),
          'villa_number': PlutoCell(value: ticket.villaNumber ?? ''),
          'department': PlutoCell(value: ticket.departmentName ?? ''),
          'assigned_technician': PlutoCell(
            value: ticket.assigner?.firstName ?? 'Unassigned',
          ),
          'created_at': PlutoCell(value: ticket.createdAt),
        },
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocProvider<MaintenanceTicketBloc>(
      create: (context) => MaintenanceTicketBloc(
        repository: getIt<MaintenanceTicketRepositoryInterface>(),
      )..add(
          LoadMaintenanceTickets(
            page: _currentPage,
            limit: widget.initialLimit,
          ),
        ),
      child: BlocListener<MaintenanceTicketBloc, MaintenanceTicketState>(
        listener: (context, state) {
          if (state is MaintenanceTicketListLoaded) {
            setState(() {
              _tickets.clear();
              _tickets.addAll(state.tickets);
              _rows.clear();
              _rows.addAll(_convertTicketsToRows(state.tickets));
              _totalCount = state.total;
              _isLoading = false;
            });
            // Update grid rows if state manager is initialized
            _stateManager?.setShowLoading(false);
            _stateManager?.removeAllRows();
            _stateManager?.appendRows(_rows);
          } else if (state is MaintenanceTicketLoading) {
            setState(() {
              _isLoading = true;
            });
            _stateManager?.setShowLoading(true);
          } else if (state is MaintenanceTicketError) {
            setState(() {
              _isLoading = false;
            });
            _stateManager?.setShowLoading(false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to load tickets: ${state.message}'),
                backgroundColor: colorScheme.error,
              ),
            );
          }
        },
        child: BlocBuilder<MaintenanceTicketBloc, MaintenanceTicketState>(
          builder: (context, state) {
            if (state is MaintenanceTicketInitial ||
                state is MaintenanceTicketLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
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
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<MaintenanceTicketBloc>().add(
                                LoadMaintenanceTickets(
                                  page: _currentPage,
                                  limit: widget.initialLimit,
                                ),
                              );
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final content = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and actions (only show if not full page)
                if (!widget.fullPage)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Maintenance Tickets',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$_totalCount tickets',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Refresh',
                            onPressed: () {
                              context.read<MaintenanceTicketBloc>().add(
                                    LoadMaintenanceTickets(
                                      page: _currentPage,
                                      limit: widget.initialLimit,
                                    ),
                                  );
                            },
                          ),
                          TextButton.icon(
                            onPressed: () =>
                                context.push('/maintenance-tickets'),
                            icon: const Icon(Icons.open_in_new, size: 18),
                            label: const Text('View All'),
                          ),
                        ],
                      ),
                    ],
                  ),
                if (!widget.fullPage) const SizedBox(height: 20),

                // PlutoGrid - Takes all available space with dynamic width
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate available width (subtract padding)
                      final availableWidth = constraints.maxWidth - 20;

                      // Build columns dynamically based on available width
                      final dynamicColumns = _buildColumns(availableWidth);

                      return PlutoGrid(
                        columns: dynamicColumns,
                        rows: _rows,
                        onLoaded: (PlutoGridOnLoadedEvent event) {
                          _stateManager = event.stateManager;
                          _stateManager?.setShowLoading(_isLoading);
                          _stateManager?.setSelectingMode(
                            PlutoGridSelectingMode.row,
                          );
                          _stateManager?.setShowColumnFilter(true);

                          // Reset horizontal scroll to start (leftmost position)
                          // This ensures frozen columns are properly visible
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) {
                            _stateManager?.scroll.horizontal?.jumpTo(0);
                          });
                        },
                        onRowDoubleTap: (event) {
                          final row = event.row;
                          final ticketNumber =
                              row.cells['ticketNumber']?.value.toString();
                          if (ticketNumber != null) {
                            final ticket = _findTicketByNumber(ticketNumber);
                            if (ticket != null) {
                              if (widget.onRowDoubleTap != null) {
                                widget.onRowDoubleTap!(ticket);
                              } else {
                                context
                                    .push('/maintenance-tickets/${ticket.id}');
                              }
                            }
                          }
                        },
                        configuration: PlutoGridConfiguration(
                          columnSize: const PlutoGridColumnSizeConfig(
                            resizeMode: PlutoResizeMode.normal,
                          ),
                          style: PlutoGridStyleConfig(
                            activatedColor: colorScheme.primaryContainer,
                            activatedBorderColor: colorScheme.primary,
                            gridBorderColor:
                                colorScheme.outline.withValues(alpha: 0.1),
                            rowColor: colorScheme.surface,
                            evenRowColor:
                                colorScheme.surfaceContainerHighest.withValues(
                              alpha: 0.3,
                            ),
                            columnTextStyle:
                                theme.textTheme.bodyMedium ?? const TextStyle(),
                            cellTextStyle:
                                theme.textTheme.bodySmall ?? const TextStyle(),
                          ),
                          scrollbar: const PlutoGridScrollbarConfig(
                            isAlwaysShown: true,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );

            // Wrap in Card only if not full page
            if (widget.fullPage) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: content,
              );
            }

            return Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: content,
              ),
            );
          },
        ),
      ),
    );
  }

  MaintenanceTicketEntity? _findTicketByNumber(String ticketNumber) {
    try {
      return _tickets.firstWhere(
        (ticket) => ticket.ticketNumber == ticketNumber,
      );
    } catch (e) {
      return null;
    }
  }
}
