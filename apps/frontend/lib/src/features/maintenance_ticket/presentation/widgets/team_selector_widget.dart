import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/maintenance_ticket_bloc.dart';
import '../bloc/maintenance_ticket_event.dart';
import '../bloc/maintenance_ticket_state.dart';
import '../../domain/entities/team_entity.dart';

class TeamSelectorWidget extends StatelessWidget {
  const TeamSelectorWidget({
    super.key,
    this.selectedTeamId,
    this.departmentId,
    this.onChanged,
    this.enabled = true,
  });

  final String? selectedTeamId;
  final String? departmentId;
  final ValueChanged<String?>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    // Load teams when widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MaintenanceTicketBloc>().add(
            LoadTeams(departmentId: departmentId),
          );
    });

    return BlocBuilder<MaintenanceTicketBloc, MaintenanceTicketState>(
      builder: (context, state) {
        List<TeamEntity> teams = [];
        bool isLoading = false;

        if (state is MaintenanceTicketLoading) {
          isLoading = true;
        } else if (state is TeamsLoaded) {
          teams = state.teams;
        }

        if (isLoading) {
          return DropdownButtonFormField<String>(
            items: const [],
            onChanged: null,
            decoration: const InputDecoration(
              labelText: 'Loading teams...',
              border: OutlineInputBorder(),
              suffixIcon: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        return DropdownButtonFormField<String?>(
          value: selectedTeamId,
          decoration: const InputDecoration(
            labelText: 'Select Team',
            border: OutlineInputBorder(),
          ),
          items: [
            ...teams.map((TeamEntity team) {
              return DropdownMenuItem<String?>(
                value: team.id,
                child: Row(
                  children: [
                    if (team.colorCode != null)
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _parseColor(team.colorCode!),
                          shape: BoxShape.circle,
                        ),
                      ),
                    if (team.colorCode != null) const SizedBox(width: 8),
                    Expanded(child: Text(team.displayName)),
                  ],
                ),
              );
            }),
          ],
          onChanged: enabled
              ? (String? value) {
                  onChanged?.call(value);
                }
              : null,
        );
      },
    );
  }

  static Color _parseColor(String colorCode) {
    try {
      // Handle hex colors like "#FF0000" or "FF0000"
      final hex = colorCode.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }
}

