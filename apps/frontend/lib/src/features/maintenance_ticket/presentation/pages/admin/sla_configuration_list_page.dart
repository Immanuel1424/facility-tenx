import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../../core/di/service_locator.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/theme_helpers.dart';
import '../../../../../core/widgets/pluto_grid_config.dart';
import '../../../data/repositories/sla_configuration_repository.dart';
import '../../../data/repositories/escalation_scheduler_config_repository.dart';
import '../../../domain/entities/maintenance_ticket_entity.dart';
import '../../../domain/entities/sla_configuration_entity.dart';
import '../../bloc/sla_configuration/sla_configuration_bloc.dart';
import '../../bloc/sla_configuration/sla_configuration_event.dart';
import '../../bloc/sla_configuration/sla_configuration_state.dart';
import '../../bloc/escalation_scheduler_config/escalation_scheduler_config_bloc.dart';
import '../../bloc/escalation_scheduler_config/escalation_scheduler_config_event.dart';
import '../../bloc/escalation_scheduler_config/escalation_scheduler_config_state.dart';
import 'sla_configuration_create_page.dart' show SlaConfigurationCreateDialog;

class SlaConfigurationListPage extends StatelessWidget {
  const SlaConfigurationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SlaConfigurationBloc(
        repository: SlaConfigurationRepository(
          apiClient: getIt<ApiClient>(),
        ),
      )..add(const LoadSlaConfigurationList()),
      child: const _SlaConfigurationListContent(),
    );
  }
}

class _SlaConfigurationListContent extends StatefulWidget {
  const _SlaConfigurationListContent();

  @override
  State<_SlaConfigurationListContent> createState() =>
      _SlaConfigurationListContentState();
}

class _SlaConfigurationListContentState
    extends State<_SlaConfigurationListContent> {
  PlutoGridStateManager? _stateManager;

  void _reload() {
    if (!mounted) return;
    context.read<SlaConfigurationBloc>().add(const LoadSlaConfigurationList());
  }

  void _updateGridRows(List<SlaConfigurationEntity> configurations) {
    if (_stateManager == null) return;
    final rows = configurations
        .map(
          (config) => PlutoRow(
            cells: <String, PlutoCell>{
              'actions': PlutoCell(value: config),
              'name': PlutoCell(value: config.name),
              'priority': PlutoCell(value: config.priority),
              'first_response':
                  PlutoCell(value: '${config.firstResponseTimeMinutes} min'),
              'acknowledgement':
                  PlutoCell(value: '${config.acknowledgementTimeMinutes} min'),
              'resolution':
                  PlutoCell(value: '${config.resolutionTimeMinutes} min'),
              'escalation_1': PlutoCell(
                  value: config.escalationLevel1Minutes != null
                      ? '${config.escalationLevel1Minutes} min'
                      : '—'),
              'escalation_2': PlutoCell(
                  value: config.escalationLevel2Minutes != null
                      ? '${config.escalationLevel2Minutes} min'
                      : '—'),
              'escalation_3': PlutoCell(
                  value: config.escalationLevel3Minutes != null
                      ? '${config.escalationLevel3Minutes} min'
                      : '—'),
              'is_active': PlutoCell(value: config.isActive),
            },
          ),
        )
        .toList();
    _stateManager!.removeAllRows();
    _stateManager!.appendRows(rows);
  }

  List<PlutoColumn> _buildColumns(double availableWidth) {
    final minWidths = {
      'name': 200.0,
      'priority': 120.0,
      'first_response': 140.0,
      'acknowledgement': 140.0,
      'resolution': 140.0,
      'escalation_1': 120.0,
      'escalation_2': 120.0,
      'escalation_3': 120.0,
      'is_active': 100.0,
      'actions': 80.0,
    };

    final totalMinWidth =
        minWidths.values.fold(0.0, (sum, width) => sum + width);
    final widthMultiplier =
        availableWidth < totalMinWidth ? 1.0 : (availableWidth / totalMinWidth);

    final theme = Theme.of(context);

    return [
      PlutoColumn(
        title: 'Name',
        field: 'name',
        type: PlutoColumnType.text(),
        width: (minWidths['name']! * widthMultiplier)
            .clamp(200.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
        frozen: PlutoColumnFrozen.start,
        renderer: (rendererContext) {
          final value = rendererContext.cell.value.toString();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Priority',
        field: 'priority',
        type: PlutoColumnType.text(),
        width: (minWidths['priority']! * widthMultiplier)
            .clamp(120.0, double.infinity),
        enableSorting: true,
        enableFilterMenuItem: true,
        renderer: (rendererContext) {
          final priority = rendererContext.cell.value as TicketPriority;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPriorityBackgroundColor(context, priority),
                  borderRadius: context.cardBorderRadius,
                  border: Border.all(
                    color: _getPriorityTextColor(context, priority)
                        .withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  priority.displayName,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _getPriorityTextColor(context, priority),
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'First Response',
        field: 'first_response',
        type: PlutoColumnType.text(),
        width: (minWidths['first_response']! * widthMultiplier)
            .clamp(140.0, double.infinity),
        enableSorting: true,
        renderer: (rendererContext) {
          final value = rendererContext.cell.value.toString();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Acknowledgement',
        field: 'acknowledgement',
        type: PlutoColumnType.text(),
        width: (minWidths['acknowledgement']! * widthMultiplier)
            .clamp(140.0, double.infinity),
        enableSorting: true,
        renderer: (rendererContext) {
          final value = rendererContext.cell.value.toString();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Resolution',
        field: 'resolution',
        type: PlutoColumnType.text(),
        width: (minWidths['resolution']! * widthMultiplier)
            .clamp(140.0, double.infinity),
        enableSorting: true,
        renderer: (rendererContext) {
          final value = rendererContext.cell.value.toString();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Escalation L1',
        field: 'escalation_1',
        type: PlutoColumnType.text(),
        width: (minWidths['escalation_1']! * widthMultiplier)
            .clamp(120.0, double.infinity),
        enableSorting: true,
        renderer: (rendererContext) {
          final value = rendererContext.cell.value.toString();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: value == '—'
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onSurface,
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Escalation L2',
        field: 'escalation_2',
        type: PlutoColumnType.text(),
        width: (minWidths['escalation_2']! * widthMultiplier)
            .clamp(120.0, double.infinity),
        enableSorting: true,
        renderer: (rendererContext) {
          final value = rendererContext.cell.value.toString();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: value == '—'
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onSurface,
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Escalation L3',
        field: 'escalation_3',
        type: PlutoColumnType.text(),
        width: (minWidths['escalation_3']! * widthMultiplier)
            .clamp(120.0, double.infinity),
        enableSorting: true,
        renderer: (rendererContext) {
          final value = rendererContext.cell.value.toString();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: value == '—'
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onSurface,
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Active',
        field: 'is_active',
        type: PlutoColumnType.text(),
        width: (minWidths['is_active']! * widthMultiplier)
            .clamp(100.0, double.infinity),
        enableSorting: true,
        enableFilterMenuItem: true,
        renderer: (rendererContext) {
          final isActive = rendererContext.cell.value as bool;
          final status = isActive ? 'ACTIVE' : 'INACTIVE';
          final bgColor = isActive
              ? (Theme.of(context).brightness == Brightness.dark
                  ? Colors.green.shade900.withOpacity(0.3)
                  : Colors.green.shade50)
              : (Theme.of(context).brightness == Brightness.dark
                  ? Colors.red.shade900.withOpacity(0.3)
                  : Colors.red.shade50);
          final textColor = isActive
              ? (Theme.of(context).brightness == Brightness.dark
                  ? Colors.green.shade300
                  : Colors.green.shade700)
              : (Theme.of(context).brightness == Brightness.dark
                  ? Colors.red.shade300
                  : Colors.red.shade700);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: context.cardBorderRadius,
                  border: Border.all(
                    color: textColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  status,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Actions',
        field: 'actions',
        type: PlutoColumnType.text(),
        width: minWidths['actions']!,
        enableSorting: false,
        enableColumnDrag: false,
        enableFilterMenuItem: false,
        renderer: (rendererContext) {
          final config = rendererContext.cell.value as SlaConfigurationEntity;
          return Center(
            child: IconButton(
              icon: Icon(
                Icons.edit_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              onPressed: () => _showEditDialog(context, config),
              tooltip: 'Edit Configuration',
            ),
          );
        },
      ),
    ];
  }

  Color _getPriorityBackgroundColor(
    BuildContext context,
    TicketPriority priority,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (priority) {
      case TicketPriority.low:
        return isDark
            ? Colors.green.shade900.withValues(alpha: 0.3)
            : Colors.green.shade50;
      case TicketPriority.medium:
        return isDark
            ? Colors.blue.shade900.withValues(alpha: 0.3)
            : Colors.blue.shade50;
      case TicketPriority.high:
        return isDark
            ? Colors.orange.shade900.withValues(alpha: 0.3)
            : Colors.orange.shade50;
      case TicketPriority.urgent:
        return isDark
            ? Colors.red.shade900.withValues(alpha: 0.3)
            : Colors.red.shade50;
    }
  }

  Color _getPriorityTextColor(
    BuildContext context,
    TicketPriority priority,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (priority) {
      case TicketPriority.low:
        return isDark ? Colors.green.shade300 : Colors.green.shade700;
      case TicketPriority.medium:
        return isDark ? Colors.blue.shade300 : Colors.blue.shade700;
      case TicketPriority.high:
        return isDark ? Colors.orange.shade300 : Colors.orange.shade700;
      case TicketPriority.urgent:
        return isDark ? Colors.red.shade300 : Colors.red.shade700;
    }
  }

  void _showEditDialog(BuildContext context, SlaConfigurationEntity config) {
    SlaConfigurationCreateDialog.show(
      context,
      existingConfiguration: config,
    ).then((created) {
      if (created == true && mounted) {
        _reload();
      }
    });
  }

  void _showEscalationSchedulerConfigDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => BlocProvider(
        create: (context) => EscalationSchedulerConfigBloc(
          repository: EscalationSchedulerConfigRepository(
            apiClient: getIt<ApiClient>(),
          ),
        )..add(const LoadEscalationSchedulerConfig()),
        child: const _EscalationSchedulerConfigDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.go('/dashboard');
        }
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: const Text('SLA & Escalation Configuration'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/dashboard'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Escalation Scheduler Settings',
              onPressed: () => _showEscalationSchedulerConfigDialog(context),
            ),
          ],
        ),
        body: BlocConsumer<SlaConfigurationBloc, SlaConfigurationState>(
          listener: (context, state) {
            if (state is SlaConfigurationError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is SlaConfigurationListLoaded) {
              if (_stateManager != null) {
                _updateGridRows(state.configurations);
              }
            } else if (state is SlaConfigurationCreated ||
                state is SlaConfigurationUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('SLA configuration saved successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              _reload();
            } else if (state is SlaConfigurationDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('SLA configuration deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              _reload();
            }
          },
          builder: (context, state) {
            if (state is SlaConfigurationInitial ||
                state is SlaConfigurationLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SlaConfigurationListLoaded) {
              final configurations = state.configurations;
              if (configurations.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 64,
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No SLA configurations found',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final created =
                                await SlaConfigurationCreateDialog.show(
                                    context);
                            if (created == true && context.mounted) {
                              _reload();
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Create SLA Configuration'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  // Action Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                          // Refresh Button
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _reload,
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 56),
                              ),
                              child: const Text('Refresh'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Create Button
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final created =
                                    await SlaConfigurationCreateDialog.show(
                                        context);
                                if (created == true && context.mounted) {
                                  _reload();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(0, 56),
                              ),
                              child: const Text('Create SLA Configuration'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Grid
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: context.cardBorderRadius,
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final availableWidth = constraints.maxWidth;
                          final columns = _buildColumns(availableWidth);
                          final rows = configurations
                              .map(
                                (config) => PlutoRow(
                                  cells: <String, PlutoCell>{
                                    'actions': PlutoCell(value: config),
                                    'name': PlutoCell(value: config.name),
                                    'priority':
                                        PlutoCell(value: config.priority),
                                    'first_response': PlutoCell(
                                        value:
                                            '${config.firstResponseTimeMinutes} min'),
                                    'acknowledgement': PlutoCell(
                                        value:
                                            '${config.acknowledgementTimeMinutes} min'),
                                    'resolution': PlutoCell(
                                        value:
                                            '${config.resolutionTimeMinutes} min'),
                                    'escalation_1': PlutoCell(
                                        value: config.escalationLevel1Minutes !=
                                                null
                                            ? '${config.escalationLevel1Minutes} min'
                                            : '—'),
                                    'escalation_2': PlutoCell(
                                        value: config.escalationLevel2Minutes !=
                                                null
                                            ? '${config.escalationLevel2Minutes} min'
                                            : '—'),
                                    'escalation_3': PlutoCell(
                                        value: config.escalationLevel3Minutes !=
                                                null
                                            ? '${config.escalationLevel3Minutes} min'
                                            : '—'),
                                    'is_active':
                                        PlutoCell(value: config.isActive),
                                  },
                                ),
                              )
                              .toList();

                          return Theme(
                            data: PlutoGridConfig.buildGridTheme(context),
                            child: PlutoGrid(
                              key: const ValueKey('sla_configurations'),
                              columns: columns,
                              rows: rows,
                              onLoaded: (PlutoGridOnLoadedEvent event) {
                                setState(() {
                                  _stateManager = event.stateManager;
                                });
                                final stateManager = event.stateManager;
                                stateManager.setSelectingMode(
                                  PlutoGridSelectingMode.row,
                                );
                                stateManager.setShowColumnFilter(true);
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  stateManager.scroll.horizontal?.jumpTo(0);
                                });
                              },
                              configuration:
                                  PlutoGridConfig.buildConfiguration(context),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            } else if (state is SlaConfigurationError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${state.message}',
                        style: TextStyle(color: theme.colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _reload,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class _EscalationSchedulerConfigDialog extends StatefulWidget {
  const _EscalationSchedulerConfigDialog();

  @override
  State<_EscalationSchedulerConfigDialog> createState() =>
      _EscalationSchedulerConfigDialogState();
}

class _EscalationSchedulerConfigDialogState
    extends State<_EscalationSchedulerConfigDialog> {
  final _formKey = GlobalKey<FormState>();
  int _intervalMinutes = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<EscalationSchedulerConfigBloc,
        EscalationSchedulerConfigState>(
      listener: (context, state) {
        if (state is EscalationSchedulerConfigError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is EscalationSchedulerConfigLoaded) {
          setState(() {
            _intervalMinutes = state.config.intervalMinutes;
          });
        } else if (state is EscalationSchedulerConfigUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Escalation scheduler configuration updated successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final isLoading = state is EscalationSchedulerConfigLoading;

        return AlertDialog(
          title: const Text('Escalation Scheduler Configuration'),
          content: SizedBox(
            width: 400,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configure how often the system checks for ticket escalations.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    initialValue: _intervalMinutes.toString(),
                    decoration: InputDecoration(
                      labelText: 'Check Interval (minutes)',
                      hintText: 'Enter interval between 1 and 60',
                      helperText:
                          'The system will check for escalations every N minutes',
                      suffixText: 'minutes',
                    ),
                    keyboardType: TextInputType.number,
                    enabled: !isLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an interval';
                      }
                      final interval = int.tryParse(value);
                      if (interval == null) {
                        return 'Please enter a valid number';
                      }
                      if (interval < 1 || interval > 60) {
                        return 'Interval must be between 1 and 60 minutes';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _intervalMinutes = int.parse(value ?? '1');
                    },
                    onChanged: (value) {
                      final interval = int.tryParse(value);
                      if (interval != null && interval >= 1 && interval <= 60) {
                        setState(() {
                          _intervalMinutes = interval;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Current setting: Every $_intervalMinutes minute(s)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _formKey.currentState?.save();
                        context.read<EscalationSchedulerConfigBloc>().add(
                              UpdateEscalationSchedulerConfig(_intervalMinutes),
                            );
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
