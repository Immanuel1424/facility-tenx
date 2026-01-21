import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/service_locator.dart';
import '../../../data/repositories/maintenance_ticket_repository.dart';
import '../../../domain/entities/maintenance_ticket_entity.dart';
import '../../../domain/entities/site_entity.dart';
import '../../bloc/maintenance_ticket_bloc.dart';
import '../../bloc/maintenance_ticket_event.dart';
import '../../bloc/maintenance_ticket_state.dart';

class MaintenanceTicketListFilters extends StatefulWidget {
  const MaintenanceTicketListFilters({
    super.key,
    this.statusFilter,
    this.priorityFilter,
    this.villaNumberFilter,
    this.departmentFilter,
    this.siteFilter,
    this.technicianFilter,
    this.isEscalatedFilter,
    required this.onApply,
  });

  final String? statusFilter;
  final String? priorityFilter;
  final String? villaNumberFilter;
  final String? departmentFilter;
  final String? siteFilter;
  final String? technicianFilter;
  final bool? isEscalatedFilter;
  final void Function(FilterResult) onApply;

  @override
  State<MaintenanceTicketListFilters> createState() =>
      _MaintenanceTicketListFiltersState();
}

class _MaintenanceTicketListFiltersState
    extends State<MaintenanceTicketListFilters> {
  String? _statusFilter;
  String? _priorityFilter;
  String? _villaNumberFilter;
  String? _departmentFilter;
  String? _siteFilter;
  String? _technicianFilter;
  bool? _isEscalatedFilter;
  late final TextEditingController _villaNumberController;

  @override
  void initState() {
    super.initState();
    _statusFilter = widget.statusFilter;
    _priorityFilter = widget.priorityFilter;
    _villaNumberFilter = widget.villaNumberFilter;
    _departmentFilter = widget.departmentFilter;
    _siteFilter = widget.siteFilter;
    _technicianFilter = widget.technicianFilter;
    _isEscalatedFilter = widget.isEscalatedFilter;
    _villaNumberController = TextEditingController(
      text: _villaNumberFilter?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _villaNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MaintenanceTicketBloc(
        repository: getIt<MaintenanceTicketRepository>(),
      )..add(const LoadDepartments()),
      child: Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 768, maxHeight: 700),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Filter Tickets',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Status filter
                      DropdownButtonFormField<String>(
                        value: _statusFilter,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        style: Theme.of(context).textTheme.bodyMedium,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Statuses'),
                          ),
                          ...TicketStatus.values.map(
                            (status) => DropdownMenuItem(
                              value: status.toBackendValue,
                              child: Text(status.displayName),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _statusFilter = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Priority filter
                      DropdownButtonFormField<String>(
                        value: _priorityFilter,
                        decoration: const InputDecoration(
                          labelText: 'Priority',
                          border: OutlineInputBorder(),
                        ),
                        style: Theme.of(context).textTheme.bodyMedium,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Priorities'),
                          ),
                          ...TicketPriority.values.map(
                            (priority) => DropdownMenuItem(
                              value: priority.toBackendValue,
                              child: Text(priority.displayName),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _priorityFilter = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Villa number filter
                      TextField(
                        controller: _villaNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Villa Number',
                          border: OutlineInputBorder(),
                          hintText: 'Enter villa number',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _villaNumberFilter = value.isEmpty ? null : value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Department filter
                      BlocBuilder<MaintenanceTicketBloc,
                          MaintenanceTicketState>(
                        builder: (context, state) {
                          List<DepartmentEntity> departments = [];
                          state.maybeWhen(
                            departmentsLoaded: (depts) => departments = depts,
                            orElse: () {},
                          );

                          if (state is MaintenanceTicketInitial ||
                              state is MaintenanceTicketLoading) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          return DropdownButtonFormField<String>(
                            value: _departmentFilter,
                            decoration: const InputDecoration(
                              labelText: 'Department',
                              border: OutlineInputBorder(),
                            ),
                            style: Theme.of(context).textTheme.bodyMedium,
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('All Departments'),
                              ),
                              ...departments.map(
                                (dept) => DropdownMenuItem(
                                  value: dept.id,
                                  child: Text(dept.name),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _departmentFilter = value;
                              });
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Site filter
                      BlocBuilder<MaintenanceTicketBloc,
                          MaintenanceTicketState>(
                        builder: (context, state) {
                          // Load sites if not already loaded
                          if (state is MaintenanceTicketInitial) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              context.read<MaintenanceTicketBloc>().add(
                                    const LoadSites(),
                                  );
                            });
                          }

                          List<SiteEntity> sites = [];
                          if (state is SitesLoaded) {
                            sites = state.sites;
                          }

                          if (state is MaintenanceTicketLoading) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          return DropdownButtonFormField<String>(
                            value: _siteFilter,
                            decoration: const InputDecoration(
                              labelText: 'Site',
                              border: OutlineInputBorder(),
                            ),
                            style: Theme.of(context).textTheme.bodyMedium,
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('All Sites'),
                              ),
                              ...sites.map(
                                (site) => DropdownMenuItem(
                                  value: site.id,
                                  child: Text(site.displayName),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _siteFilter = value;
                              });
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Technician filter
                      BlocBuilder<MaintenanceTicketBloc,
                          MaintenanceTicketState>(
                        builder: (context, state) {
                          // Load technicians if not already loaded
                          if (state is MaintenanceTicketInitial) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              context.read<MaintenanceTicketBloc>().add(
                                    const LoadTechnicians(),
                                  );
                            });
                          }

                          // Access cached technicians from bloc
                          final bloc = context.read<MaintenanceTicketBloc>();
                          final technicians = bloc.cachedTechnicians;

                          if (technicians.isEmpty &&
                              !bloc.hasLoadedTechnicians) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          return DropdownButtonFormField<String>(
                            value: _technicianFilter,
                            decoration: const InputDecoration(
                              labelText: 'Assigned Technician',
                              border: OutlineInputBorder(),
                            ),
                            style: Theme.of(context).textTheme.bodyMedium,
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('All Technicians'),
                              ),
                              ...technicians.map(
                                (tech) => DropdownMenuItem(
                                  value: tech.id,
                                  child: Text(
                                    '${tech.firstName ?? ''} ${tech.lastName ?? ''}'
                                            .trim()
                                            .isEmpty
                                        ? tech.email
                                        : '${tech.firstName ?? ''} ${tech.lastName ?? ''}'
                                            .trim(),
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _technicianFilter = value;
                              });
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Escalated filter
                      DropdownButtonFormField<bool>(
                        value: _isEscalatedFilter,
                        decoration: const InputDecoration(
                          labelText: 'Escalation Status',
                          border: OutlineInputBorder(),
                        ),
                        style: Theme.of(context).textTheme.bodyMedium,
                        items: const [
                          DropdownMenuItem(
                            value: null,
                            child: Text('All Tickets'),
                          ),
                          DropdownMenuItem(
                            value: true,
                            child: Text('Escalated Only'),
                          ),
                          DropdownMenuItem(
                            value: false,
                            child: Text('Not Escalated'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _isEscalatedFilter = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _statusFilter = null;
                        _priorityFilter = null;
                        _villaNumberFilter = null;
                        _departmentFilter = null;
                        _siteFilter = null;
                        _technicianFilter = null;
                        _isEscalatedFilter = null;
                      });
                    },
                    child: const Text('Clear All'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      widget.onApply(
                        FilterResult(
                          status: _statusFilter,
                          priority: _priorityFilter,
                          villaNumber: _villaNumberFilter,
                          departmentId: _departmentFilter,
                          siteId: _siteFilter,
                          technicianId: _technicianFilter,
                          isEscalated: _isEscalatedFilter,
                        ),
                      );
                    },
                    child: const Text('Apply Filters'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FilterResult {
  const FilterResult({
    this.status,
    this.priority,
    this.villaNumber,
    this.departmentId,
    this.siteId,
    this.technicianId,
    this.isEscalated,
  });

  final String? status;
  final String? priority;
  final String? villaNumber;
  final String? departmentId;
  final String? siteId;
  final String? technicianId;
  final bool? isEscalated;
}
