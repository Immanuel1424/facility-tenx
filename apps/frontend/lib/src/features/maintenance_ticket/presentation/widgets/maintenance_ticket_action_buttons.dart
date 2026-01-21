import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/role_access_control.dart';
import '../../../../core/widgets/common_dialogs.dart';
import '../../../../features/auth/domain/entities/user_entity.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/maintenance_ticket_entity.dart';
import '../../domain/entities/team_entity.dart';
import '../bloc/maintenance_ticket_bloc.dart';
import '../bloc/maintenance_ticket_event.dart';
import '../bloc/maintenance_ticket_state.dart';

class MaintenanceTicketActionButtons extends StatelessWidget {
  const MaintenanceTicketActionButtons({
    super.key,
    required this.ticket,
  });

  final MaintenanceTicketEntity ticket;

  UserEntity? _getUser(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return authState.maybeWhen<UserEntity?>(
      authenticated: (user) => user,
      orElse: () => null,
    );
  }

  bool _canAcknowledge(BuildContext context) {
    final user = _getUser(context);
    return user != null &&
        RoleAccessControl.canAcknowledgeTickets(user) &&
        ticket.status == TicketStatus.new_;
  }

  bool _canAssign(BuildContext context) {
    final user = _getUser(context);
    return user != null &&
        RoleAccessControl.canAssignTickets(user) &&
        (ticket.status == TicketStatus.new_ ||
            ticket.status == TicketStatus.acknowledged);
  }

  bool _canAssignTechnician(BuildContext context) {
    if (ticket.status == TicketStatus.completed ||
        ticket.status == TicketStatus.cancelled) {
      return false;
    }

    // Require acknowledgment before allowing technician assignment
    // Ticket must be acknowledged (acknowledgedAt is not null) or status is beyond NEW
    if (ticket.acknowledgedAt == null && ticket.status == TicketStatus.new_) {
      return false;
    }

    final user = _getUser(context);
    if (user == null) return false;

    // Admin can assign/reassign technicians after acknowledgment
    if (RoleAccessControl.isAdmin(user)) {
      return true;
    }

    // Site coordinators and supervisors can assign technicians
    // when ticket is not in terminal states and has been acknowledged
    if (RoleAccessControl.canAssignTickets(user)) {
      return true;
    }

    return false;
  }

  bool _canChangeStatus(BuildContext context) {
    if (ticket.status == TicketStatus.completed ||
        ticket.status == TicketStatus.cancelled) {
      return false;
    }
    final user = _getUser(context);
    return user != null && RoleAccessControl.canUpdateTicketStatus(user);
  }

  bool _canCancel(BuildContext context) {
    if (ticket.status == TicketStatus.completed ||
        ticket.status == TicketStatus.cancelled) {
      return false;
    }
    final user = _getUser(context);
    return user != null && RoleAccessControl.canCancelTickets(user);
  }

  bool _canAddNotes(BuildContext context) {
    final user = _getUser(context);
    return user != null && RoleAccessControl.canAddWorkNotes(user);
  }

  bool _canConfirmCompletion(BuildContext context) {
    final user = _getUser(context);
    return user != null &&
        (RoleAccessControl.isAdmin(user) || RoleAccessControl.isTenant(user)) &&
        ticket.status == TicketStatus.completed &&
        !ticket.tenantConfirmed;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final canAcknowledge = _canAcknowledge(context);
    final canAssign = _canAssign(context);
    final canAssignTechnician = _canAssignTechnician(context);
    final canChangeStatus = _canChangeStatus(context);
    final canCancel = _canCancel(context);
    final canAddNotes = _canAddNotes(context);
    final canConfirmCompletion = _canConfirmCompletion(context);

    if (!canAcknowledge &&
        !canAssign &&
        !canAssignTechnician &&
        !canChangeStatus &&
        !canCancel &&
        !canAddNotes &&
        !canConfirmCompletion) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Acknowledge - Quick action button (simple action)
        if (canAcknowledge) ...[
          _buildLabel(context, 'Acknowledgement'),
          ElevatedButton.icon(
            onPressed: () => _acknowledgeTicket(context),
            icon: const Icon(Icons.check_circle, size: 18),
            label: const Text('Acknowledge'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Assign Team - Dropdown (HIDDEN - Team assignment not used in current workflow)
        // if (canAssign) ...[
        //   _buildLabel(context, 'Team Assignment'),
        //   _buildAssignTeamDropdown(context, colorScheme),
        //   const SizedBox(height: 16),
        // ],

        // Assign Technician - Dropdown
        if (canAssignTechnician) ...[
          _buildLabel(context, 'Technician Assignment'),
          _buildAssignTechnicianDropdown(context, colorScheme),
          const SizedBox(height: 16),
        ],

        // Change Status - Dropdown
        if (canChangeStatus) ...[
          _buildLabel(context, 'Status Update'),
          _buildStatusDropdown(context, colorScheme),
          const SizedBox(height: 16),
        ],

        // Add Notes - Button (opens dialog)
        // HIDDEN: User requested to hide notes functionality
        // if (canAddNotes) ...[
        //   _buildLabel(context, 'Notes'),
        //   OutlinedButton.icon(
        //     onPressed: () => _addNotes(context),
        //     icon: const Icon(Icons.note_add, size: 18),
        //     label: const Text('Add Notes'),
        //     style: OutlinedButton.styleFrom(
        //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        //     ),
        //   ),
        //   const SizedBox(height: 16),
        // ],

        // Confirm Completion - Button
        if (canConfirmCompletion) ...[
          _buildLabel(context, 'Completion'),
          ElevatedButton.icon(
            onPressed: () => _confirmCompletion(context),
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Confirm Completion'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Cancel - Outlined button
        if (canCancel) ...[
          _buildLabel(context, 'Cancellation'),
          OutlinedButton.icon(
            onPressed: () => _cancelTicket(context),
            icon: const Icon(Icons.cancel, size: 18),
            label: const Text('Cancel Ticket'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 2.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
      ),
    );
  }

  Widget _buildAssignTeamDropdown(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return BlocBuilder<MaintenanceTicketBloc, MaintenanceTicketState>(
      builder: (context, state) {
        final bloc = context.read<MaintenanceTicketBloc>();

        // Get current ticket from state if available, otherwise use prop
        final currentTicket =
            state is MaintenanceTicketDetailLoaded ? state.ticket : ticket;

        // Get teams from cache or state
        final teams = state is TeamsLoaded
            ? state.teams
            : (bloc.cachedTeams.isNotEmpty ? bloc.cachedTeams : <TeamEntity>[]);

        // Load teams if needed
        if (teams.isEmpty && currentTicket.siteId != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!bloc.cachedTeams.isNotEmpty) {
              bloc.add(const LoadTeams());
            }
          });
        }

        final currentTeamId = currentTicket.assignedTeam?.id;

        // Check if assigned team is in the loaded list
        final bool hasAssignedTeam = currentTeamId != null;
        final bool assignedTeamInList =
            hasAssignedTeam && teams.any((t) => t.id == currentTeamId);

        // Build dropdown items
        final List<DropdownMenuItem<String?>> dropdownItems = [
          const DropdownMenuItem<String?>(
            value: null,
            child: Text(
              '-- No Team Assigned --',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          // Add teams from loaded list
          ...teams.map<DropdownMenuItem<String?>>((TeamEntity team) {
            return DropdownMenuItem<String?>(
              value: team.id,
              child: Text(team.displayName),
            );
          }),
        ];

        // If there's an assigned team but not in the list yet (still loading),
        // add a placeholder item to prevent Flutter assertion error
        if (hasAssignedTeam &&
            !assignedTeamInList &&
            currentTicket.assignedTeam != null) {
          dropdownItems.add(
            DropdownMenuItem<String?>(
              value: currentTeamId,
              child: Text(
                currentTicket.assignedTeam!.displayName,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
              ),
            ),
          );
        }

        // Ensure the value matches an item in the list, otherwise set to null
        // This prevents Flutter assertion error: "There should be exactly one item"
        final String? safeValue = hasAssignedTeam &&
                dropdownItems.any((item) => item.value == currentTeamId)
            ? currentTeamId
            : null;

        return DropdownButtonFormField<String?>(
          initialValue: safeValue,
          decoration: InputDecoration(
            labelText: 'Assign Team',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            prefixIcon: const Icon(Icons.group, size: 20),
          ),
          items: dropdownItems,
          onChanged: (String? teamId) {
            if (teamId != null) {
              context.read<MaintenanceTicketBloc>().add(
                    AssignTeam(ticketId: currentTicket.id, teamId: teamId),
                  );
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Team assigned successfully'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          isExpanded: true,
        );
      },
    );
  }

  Widget _buildAssignTechnicianDropdown(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return BlocBuilder<MaintenanceTicketBloc, MaintenanceTicketState>(
      builder: (context, state) {
        final bloc = context.read<MaintenanceTicketBloc>();

        // Get current ticket from state if available, otherwise use prop
        final currentTicket =
            state is MaintenanceTicketDetailLoaded ? state.ticket : ticket;

        // Get technicians from cache or state
        // Note: When ticket detail is loaded, BLoC emits MaintenanceTicketDetailLoaded (not TechniciansLoaded)
        // So we always check cache first, then state
        final technicians = bloc.cachedTechnicians.isNotEmpty
            ? bloc.cachedTechnicians
            : (state is TechniciansLoaded ? state.technicians : <UserEntity>[]);

        // Check if technicians have been loaded (uses BLoC flag to distinguish "never loaded" from "loaded but empty")
        final bool hasLoadedTechnicians =
            bloc.hasLoadedTechnicians || state is TechniciansLoaded;

        // Only attempt to load if:
        // 1. Technicians list is empty
        // 2. We haven't already loaded technicians (check BLoC flag)
        // 3. Not currently in loading or error state
        final bool shouldLoadTechnicians = technicians.isEmpty &&
            !hasLoadedTechnicians &&
            state is! MaintenanceTicketLoading &&
            state is! MaintenanceTicketError;

        // Load technicians if not already loaded
        // Technicians are loaded independently - no dependency on teams, siteId, or any other filters
        // Backend returns all active technicians with technician/maintenance/staff roles for the company
        if (shouldLoadTechnicians) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final currentBloc = context.read<MaintenanceTicketBloc>();
            // Double-check we haven't loaded yet before triggering load (prevent duplicate loads)
            if (!currentBloc.hasLoadedTechnicians) {
              print('🔄 Loading technicians (independent of teams/site)');
              currentBloc.add(const LoadTechnicians());
            }
          });
        }

        final currentTechnicianId = currentTicket.assignedTechnicianId;

        // Show loading indicator only when we're actually loading:
        // - Technicians are empty AND
        // - We haven't loaded technicians yet AND
        // - (State is MaintenanceTicketLoading OR we just triggered a load)
        final bool isLoading = technicians.isEmpty &&
            !hasLoadedTechnicians &&
            (state is MaintenanceTicketLoading || shouldLoadTechnicians);

        if (isLoading) {
          return DropdownButtonFormField<String?>(
            initialValue: null,
            decoration: const InputDecoration(
              labelText: 'Loading Technicians...',
              prefixIcon: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            items: const [],
            onChanged: null,
          );
        }

        // Log technicians count for debugging
        if (technicians.isNotEmpty) {
          print('✅ Technicians available: ${technicians.length} technicians');
        } else if (!isLoading && !shouldLoadTechnicians) {
          print('⚠️ No technicians available');
        }

        // Check if assigned technician is in the loaded list
        final bool hasAssignedTechnician = currentTechnicianId != null;
        final bool assignedTechnicianInList = hasAssignedTechnician &&
            technicians.any((t) => t.id == currentTechnicianId);

        // Build dropdown items
        final List<DropdownMenuItem<String?>> dropdownItems = [
          const DropdownMenuItem<String?>(
            value: null,
            child: Text(
              '-- No Technician Assigned --',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          // Add technicians from loaded list
          ...technicians
              .map<DropdownMenuItem<String?>>((UserEntity technician) {
            final name =
                '${technician.firstName ?? ''} ${technician.lastName ?? ''}'
                    .trim();
            final displayName = name.isNotEmpty ? name : technician.email;

            return DropdownMenuItem<String?>(
              value: technician.id,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (name.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      technician.email,
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            );
          }),
        ];

        // If there's an assigned technician but not in the list yet (still loading),
        // add a placeholder item to prevent Flutter assertion error
        if (hasAssignedTechnician && !assignedTechnicianInList) {
          dropdownItems.add(
            DropdownMenuItem<String?>(
              value: currentTechnicianId,
              child: Row(
                children: [
                  if (isLoading) ...[
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      currentTicket.assignedTechnicianDisplayName ??
                          currentTicket.assignedTechnicianName ??
                          'Loading technician...',
                      style: TextStyle(
                        fontStyle:
                            isLoading ? FontStyle.italic : FontStyle.normal,
                        color: isLoading
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Ensure the value matches an item in the list, otherwise set to null
        // This prevents Flutter assertion error: "There should be exactly one item"
        // We check if currentTechnicianId exists in dropdownItems after building the list
        final String? safeValue = hasAssignedTechnician &&
                dropdownItems.any((item) => item.value == currentTechnicianId)
            ? currentTechnicianId
            : null;

        // Check if ticket has been acknowledged
        final isAcknowledged = currentTicket.acknowledgedAt != null ||
            currentTicket.status != TicketStatus.new_;

        return DropdownButtonFormField<String?>(
          key: ValueKey('technician_dropdown_${currentTicket.id}_${currentTechnicianId ?? 'none'}'),
          value: safeValue,
          decoration: InputDecoration(
            labelText: currentTechnicianId != null
                ? 'Assigned Technician'
                : technicians.isEmpty && !isLoading
                    ? 'No Technicians Available'
                    : 'Assign Technician',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            prefixIcon: const Icon(Icons.person, size: 20),
            helperText: !isAcknowledged
                ? 'Please acknowledge the ticket first'
                : null,
            helperMaxLines: 2,
          ),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isAcknowledged
                    ? null
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
              ),
          items: dropdownItems,
          selectedItemBuilder: (BuildContext context) {
            // Return widgets for each dropdown item, showing only name when selected
            return dropdownItems.map<Widget>((DropdownMenuItem<String?> item) {
              if (item.value == null || technicians.isEmpty) {
                return Text(
                  '-- No Technician Assigned --',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                  overflow: TextOverflow.ellipsis,
                );
              }
              try {
                final technician = technicians.firstWhere(
                  (t) => t.id == item.value,
                  orElse: () {
                    if (currentTechnicianId != null) {
                      return technicians.firstWhere(
                        (t) => t.id == currentTechnicianId,
                        orElse: () => technicians.first,
                      );
                    }
                    return technicians.first;
                  },
                );
                final name =
                    '${technician.firstName ?? ''} ${technician.lastName ?? ''}'.trim();
                final displayName = name.isNotEmpty ? name : technician.email;
                // Show only name (no email) when selected
                return Text(
                  displayName,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                );
              } catch (e) {
                return Text(
                  item.value?.toString() ?? '--',
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                );
              }
            }).toList();
          },
          onChanged: isAcknowledged
              ? (String? technicianId) {
                  // Allow both assignment and unassignment (null value)
                  if (technicianId == null) {
                    // Unassign technician - you may want to implement a separate event for this
                    // For now, we'll just show a message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'To unassign technician, please contact an administrator',
                        ),
                        backgroundColor: Colors.orange,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }

                  // Assign technician
                  context.read<MaintenanceTicketBloc>().add(
                        AssignTechnician(
                          ticketId: currentTicket.id,
                          technicianId: technicianId,
                        ),
                      );
                  // Success message will be shown by the BlocListener in the detail page
                }
              : null,
          isExpanded: true,
        );
      },
    );
  }

  Widget _buildStatusDropdown(BuildContext context, ColorScheme colorScheme) {
    return BlocBuilder<MaintenanceTicketBloc, MaintenanceTicketState>(
      builder: (context, state) {
        // Get current ticket from state if available, otherwise use prop
        final currentTicket =
            state is MaintenanceTicketDetailLoaded ? state.ticket : ticket;

        // Get user for role-based filtering
        final user = _getUser(context);

        // Get valid next statuses based on current status and user role
        final availableStatuses =
            _getValidNextStatuses(currentTicket.status, user);

        // Hide dropdown if there are no valid transitions (terminal states)
        if (availableStatuses.isEmpty) {
          return const SizedBox.shrink();
        }

        // Create dropdown items - include current status to match the selected value,
        // plus valid next statuses
        final dropdownItems = <DropdownMenuItem<String>>[
          // Include current status as the selected value (marked as current)
          DropdownMenuItem<String>(
            value: currentTicket.status.name,
            enabled: false, // Disable selecting current status
            child: Text(
              'Current: ${currentTicket.status.displayName}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          // Add valid next statuses
          ...availableStatuses.map<DropdownMenuItem<String>>((status) {
            return DropdownMenuItem<String>(
              value: status.name,
              child: Text(status.displayName),
            );
          }),
        ];

        return DropdownButtonFormField<String>(
          key: ValueKey(
            currentTicket.status.name,
          ), // Force rebuild when ticket status changes
          initialValue: currentTicket.status.name,
          decoration: InputDecoration(
            labelText: 'Change Status',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            prefixIcon: const Icon(Icons.swap_horiz, size: 20),
          ),
          style: Theme.of(context).textTheme.bodyMedium,
          items: dropdownItems,
          onChanged: (String? value) {
            if (value == null) return;
            // Don't allow selecting the current status (already disabled, but double-check)
            if (value == currentTicket.status.name) return;
            final newStatus = TicketStatus.values.firstWhere(
              (s) => s.name == value,
              orElse: () => currentTicket.status,
            );
            if (newStatus != currentTicket.status) {
              _showStatusChangeConfirmation(
                context,
                currentTicket.id,
                newStatus,
              );
            }
          },
          isExpanded: true,
        );
      },
    );
  }

  /// Get valid next statuses based on current status and user role
  /// Based on backend StatusTransitionService rules
  List<TicketStatus> _getValidNextStatuses(
    TicketStatus currentStatus,
    UserEntity? user,
  ) {
    // Get all possible transitions based on current status
    List<TicketStatus> possibleStatuses;
    switch (currentStatus) {
      case TicketStatus.new_:
        possibleStatuses = [TicketStatus.acknowledged];
        break;
      case TicketStatus.acknowledged:
        possibleStatuses = [TicketStatus.assigned];
        break;
      case TicketStatus.assigned:
        possibleStatuses = [
          TicketStatus.inProgress,
          TicketStatus.onHold,
        ];
        break;
      case TicketStatus.inProgress:
        possibleStatuses = [
          TicketStatus.onHold,
          TicketStatus.completed,
        ];
        break;
      case TicketStatus.onHold:
        possibleStatuses = [
          TicketStatus.inProgress,
          TicketStatus.assigned,
        ];
        break;
      case TicketStatus.completed:
        possibleStatuses = [TicketStatus.inProgress];
        break;
      case TicketStatus.cancelled:
        return []; // Terminal state
    }

    // Filter by user role permissions if user is available
    if (user == null) {
      return possibleStatuses;
    }

    return possibleStatuses.where((status) {
      return _canUserSetStatus(user, status);
    }).toList();
  }

  /// Check if user can set a specific status based on role permissions
  /// Based on backend StatusTransitionService rolePermissions
  bool _canUserSetStatus(UserEntity user, TicketStatus status) {
    // ADMIN can set any status
    if (RoleAccessControl.isAdmin(user)) {
      return true;
    }

    switch (status) {
      case TicketStatus.new_:
        return RoleAccessControl.hasAnyRole(
          user,
          ['ADMIN', 'SITE_COORDINATOR'],
        );
      case TicketStatus.acknowledged:
        return RoleAccessControl.hasAnyRole(
          user,
          ['ADMIN', 'SITE_COORDINATOR', 'SUPERVISOR'],
        );
      case TicketStatus.assigned:
        return RoleAccessControl.hasAnyRole(
          user,
          ['ADMIN', 'SITE_COORDINATOR', 'SUPERVISOR'],
        );
      case TicketStatus.inProgress:
        return RoleAccessControl.hasAnyRole(
          user,
          ['ADMIN', 'SUPERVISOR', 'TECHNICIAN'],
        );
      case TicketStatus.onHold:
        return RoleAccessControl.hasAnyRole(
          user,
          ['ADMIN', 'SUPERVISOR', 'TECHNICIAN'],
        );
      case TicketStatus.completed:
        return RoleAccessControl.hasAnyRole(
          user,
          ['ADMIN', 'SUPERVISOR', 'TECHNICIAN'],
        );
      case TicketStatus.cancelled:
        return RoleAccessControl.hasAnyRole(user, ['ADMIN', 'TENANT']);
    }
  }

  void _acknowledgeTicket(BuildContext context) {
    context.read<MaintenanceTicketBloc>().add(
          AcknowledgeMaintenanceTicket(ticket.id),
        );
  }

  // HIDDEN: User requested to hide notes functionality
  // void _addNotes(BuildContext context) {
  //   _showAddNotesDialog(context);
  // }

  void _confirmCompletion(BuildContext context) {
    // Get BLoC reference before showing dialog
    final bloc = context.read<MaintenanceTicketBloc>();

    CommonDialogs.showConfirmationDialog(
      context: context,
      title: 'Confirm Completion',
      content:
          'Are you sure you want to confirm completion and close this ticket?',
      confirmText: 'Confirm',
      cancelText: 'Cancel',
      onConfirm: () {
        // Wrap in BlocProvider to handle state changes
        showDialog<void>(
          context: context,
          builder: (dialogContext) => BlocProvider.value(
            value: bloc,
            child: BlocListener<MaintenanceTicketBloc, MaintenanceTicketState>(
              listener: (listenerContext, state) {
                state.maybeWhen(
                  error: (message) {
                    // Close confirmation dialog and show error
                    Navigator.of(listenerContext).pop();
                    // Use the original context to show error dialog
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      CommonDialogs.showConfirmationDialog(
                        context: context,
                        title: 'Error',
                        content: message,
                        confirmText: 'OK',
                        onConfirm: () {},
                      );
                    });
                  },
                  completionConfirmed: (ticket) {
                    // Success - close dialog and show success message
                    Navigator.of(listenerContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ticket completion confirmed'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  orElse: () {},
                );
              },
              child: const SizedBox.shrink(), // Dialog already shown by showConfirmationDialog
            ),
          ),
        );

        // Trigger the completion confirmation action
        bloc.add(
          ConfirmMaintenanceTicketCompletion(ticket.id),
        );
      },
    );
  }

  void _cancelTicket(BuildContext context) {
    // Get BLoC reference before showing dialog
    final bloc = context.read<MaintenanceTicketBloc>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    CommonDialogs.showCustomDialog<void>(
      context: context,
      title: 'Cancel Ticket',
      content: BlocProvider.value(
        value: bloc,
        child: BlocListener<MaintenanceTicketBloc, MaintenanceTicketState>(
          listener: (listenerContext, state) {
            state.maybeWhen(
              error: (message) {
                // Close confirmation dialog and show error
                Navigator.of(listenerContext).pop();
                // Use the original context to show error dialog
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  CommonDialogs.showConfirmationDialog(
                    context: context,
                    title: 'Error',
                    content: message,
                    confirmText: 'OK',
                    onConfirm: () {},
                  );
                });
              },
              cancelled: (ticket) {
                // Success - close dialog and show success message
                Navigator.of(listenerContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ticket cancelled successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              orElse: () {},
            );
          },
          child: const Text(
            'Are you sure you want to cancel this ticket? This action cannot be undone.',
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('No'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            bloc.add(
              CancelMaintenanceTicket(ticket.id),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          child: const Text('Yes, Cancel'),
        ),
      ],
    );
  }

  void _showStatusChangeConfirmation(
    BuildContext context,
    String ticketId,
    TicketStatus newStatus,
  ) {
    // Get BLoC reference before showing dialog
    final bloc = context.read<MaintenanceTicketBloc>();
    final notesController = TextEditingController();

    CommonDialogs.showCustomDialog<void>(
      context: context,
      title: 'Change Status to ${newStatus.displayName}',
      content: BlocProvider.value(
        value: bloc,
        child: BlocListener<MaintenanceTicketBloc, MaintenanceTicketState>(
          listener: (listenerContext, state) {
            state.maybeWhen(
              error: (message) {
                // Close confirmation dialog and show error
                Navigator.of(listenerContext).pop();
                // Use the original context to show error dialog
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  CommonDialogs.showConfirmationDialog(
                    context: context,
                    title: 'Error',
                    content: message,
                    confirmText: 'OK',
                    onConfirm: () {},
                  );
                });
              },
              statusChanged: (ticket) {
                // Success - close dialog and show success message
                Navigator.of(listenerContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Status updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              orElse: () {},
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'Add any notes about this status change',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            bloc.add(
              ChangeMaintenanceTicketStatus(
                id: ticketId,
                status: newStatus.toBackendValue,
                notes: notesController.text.isEmpty
                    ? null
                    : notesController.text,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          child: const Text('Change'),
        ),
      ],
    );
  }
}
