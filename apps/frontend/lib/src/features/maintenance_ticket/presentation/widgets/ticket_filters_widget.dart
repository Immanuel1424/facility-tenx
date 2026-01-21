import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/maintenance_ticket_bloc.dart';
import '../bloc/maintenance_ticket_event.dart';
import '../bloc/maintenance_ticket_state.dart';
import '../../domain/entities/ticket_type_entity.dart';
import '../../domain/entities/site_entity.dart';
import '../../domain/entities/team_entity.dart';

class TicketFiltersWidget extends StatefulWidget {
  const TicketFiltersWidget({
    super.key,
    this.onFiltersChanged,
  });

  final VoidCallback? onFiltersChanged;

  @override
  State<TicketFiltersWidget> createState() => _TicketFiltersWidgetState();
}

class _TicketFiltersWidgetState extends State<TicketFiltersWidget> {
  TicketType? _selectedTicketType;
  String? _selectedSiteId;
  String? _selectedTeamId;

  @override
  void initState() {
    super.initState();
    // Load sites and teams for filters
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MaintenanceTicketBloc>().add(const LoadSites());
      context.read<MaintenanceTicketBloc>().add(const LoadTeams());
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<MaintenanceTicketBloc, MaintenanceTicketState>(
      builder: (context, state) {
        List<SiteEntity> sites = [];
        List<TeamEntity> teams = [];

        if (state is SitesLoaded) {
          sites = state.sites;
        } else if (state is TeamsLoaded) {
          teams = state.teams;
        }

        final hasActiveFilters = _selectedTicketType != null ||
            _selectedSiteId != null ||
            _selectedTeamId != null;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.filter_list,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Filters',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    if (hasActiveFilters)
                      TextButton.icon(
                        onPressed: _clearFilters,
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text('Clear'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTicketTypeFilter(),
                    _buildSiteFilter(sites),
                    _buildTeamFilter(teams),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTicketTypeFilter() {
    return FilterChip(
      label: Text(_selectedTicketType?.displayName ?? 'Ticket Type'),
      selected: _selectedTicketType != null,
      onSelected: (selected) {
        if (selected) {
          _showTicketTypePicker();
        } else {
          setState(() {
            _selectedTicketType = null;
          });
          _applyFilters();
        }
      },
    );
  }

  Widget _buildSiteFilter(List<SiteEntity> sites) {
    return FilterChip(
      label: Text(
        _selectedSiteId != null
            ? sites.firstWhere((SiteEntity s) => s.id == _selectedSiteId).displayName
            : 'Site',
      ),
      selected: _selectedSiteId != null,
      onSelected: (selected) {
        if (selected) {
          _showSitePicker(sites);
        } else {
          setState(() {
            _selectedSiteId = null;
          });
          _applyFilters();
        }
      },
    );
  }

  Widget _buildTeamFilter(List<TeamEntity> teams) {
    return FilterChip(
      label: Text(
        _selectedTeamId != null
            ? teams.firstWhere((TeamEntity t) => t.id == _selectedTeamId).displayName
            : 'Team',
      ),
      selected: _selectedTeamId != null,
      onSelected: (selected) {
        if (selected) {
          _showTeamPicker(teams);
        } else {
          setState(() {
            _selectedTeamId = null;
          });
          _applyFilters();
        }
      },
    );
  }

  void _showTicketTypePicker() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select Ticket Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: TicketType.values.map((TicketType type) {
            return ListTile(
              leading: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Color(type.colorValue),
                  shape: BoxShape.circle,
                ),
              ),
              title: Text(type.displayName),
              onTap: () {
                setState(() {
                  _selectedTicketType = type;
                });
                Navigator.of(dialogContext).pop();
                _applyFilters();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showSitePicker(List<SiteEntity> sites) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select Site'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: sites.map((SiteEntity site) {
            return ListTile(
              title: Text(site.displayName),
              onTap: () {
                setState(() {
                  _selectedSiteId = site.id;
                });
                Navigator.of(dialogContext).pop();
                _applyFilters();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showTeamPicker(List<TeamEntity> teams) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select Team'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: teams.map((TeamEntity team) {
            return ListTile(
              leading: team.colorCode != null
                  ? Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _parseColor(team.colorCode!),
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
              title: Text(team.displayName),
              onTap: () {
                setState(() {
                  _selectedTeamId = team.id;
                });
                Navigator.of(dialogContext).pop();
                _applyFilters();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _applyFilters() {
    if (_selectedTicketType != null) {
      context.read<MaintenanceTicketBloc>().add(
            FilterByTicketType(ticketType: _selectedTicketType),
          );
    }
    if (_selectedSiteId != null) {
      context.read<MaintenanceTicketBloc>().add(
            FilterBySite(siteId: _selectedSiteId),
          );
    }
    if (_selectedTeamId != null) {
      context.read<MaintenanceTicketBloc>().add(
            FilterByTeam(teamId: _selectedTeamId),
          );
    }
    widget.onFiltersChanged?.call();
  }

  void _clearFilters() {
    setState(() {
      _selectedTicketType = null;
      _selectedSiteId = null;
      _selectedTeamId = null;
    });
    _applyFilters();
  }

  static Color _parseColor(String colorCode) {
    try {
      final hex = colorCode.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }
}

