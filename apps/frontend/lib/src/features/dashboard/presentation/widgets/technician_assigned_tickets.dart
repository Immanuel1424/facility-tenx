import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../maintenance_ticket/data/repositories/maintenance_ticket_repository.dart';
import '../../../maintenance_ticket/presentation/bloc/maintenance_ticket_bloc.dart';
import '../../../maintenance_ticket/presentation/bloc/maintenance_ticket_event.dart';
import '../../../maintenance_ticket/presentation/bloc/maintenance_ticket_state.dart';
import '../../../maintenance_ticket/presentation/widgets/maintenance_ticket_list_item.dart';

class TechnicianAssignedTickets extends StatelessWidget {
  const TechnicianAssignedTickets({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState.maybeWhen(
          authenticated: (u) => u,
          orElse: () => null,
        );
        final userId = user?.id;

        if (userId == null) {
          return const SizedBox.shrink();
        }

        return BlocProvider<MaintenanceTicketBloc>(
          create: (context) => MaintenanceTicketBloc(
            repository: getIt<MaintenanceTicketRepository>(),
          )..add(
              LoadMaintenanceTickets(
                assignedTechnicianId: userId,
                page: 1,
                limit: 10,
              ),
            ),
          child: const _AssignedTicketsContent(),
        );
      },
    );
  }
}

class _AssignedTicketsContent extends StatelessWidget {
  const _AssignedTicketsContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assigned Tickets',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tickets assigned to you',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => context.push('/maintenance-tickets'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            BlocBuilder<MaintenanceTicketBloc, MaintenanceTicketState>(
              builder: (context, state) {
                return state.maybeWhen(
                      initial: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      listLoaded: (tickets, _) {
                        if (tickets.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.assignment_outlined,
                                    size: 48,
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No assigned tickets',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'You don\'t have any tickets assigned yet',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: tickets.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return MaintenanceTicketListItem(
                              ticket: tickets[index],
                              onTap: () => context.push(
                                '/maintenance-tickets/${tickets[index].id}',
                              ),
                            );
                          },
                        );
                      },
                      error: (message) => Center(
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
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                message,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      orElse: () => const SizedBox.shrink(),
                    ) ??
                    const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
