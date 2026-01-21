import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../../../core/di/service_locator.dart';
import '../../../../../core/network/api_client.dart';
import '../../../data/repositories/sla_configuration_repository.dart';
import '../../../domain/entities/maintenance_ticket_entity.dart';
import '../../../domain/entities/sla_configuration_entity.dart';
import '../../bloc/sla_configuration/sla_configuration_bloc.dart';
import '../../bloc/sla_configuration/sla_configuration_event.dart';
import '../../bloc/sla_configuration/sla_configuration_state.dart';

class SlaConfigurationCreatePage extends StatelessWidget {
  const SlaConfigurationCreatePage({
    super.key,
    this.existingConfiguration,
  });

  final SlaConfigurationEntity? existingConfiguration;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = SlaConfigurationBloc(
          repository: SlaConfigurationRepository(
            apiClient: getIt<ApiClient>(),
          ),
        );
        if (existingConfiguration != null) {
          bloc.add(LoadSlaConfigurationById(existingConfiguration!.id));
        }
        return bloc;
      },
      child: SlaConfigurationCreateFormContent(
        existingConfiguration: existingConfiguration,
      ),
    );
  }
}

/// Dialog version - shows as modal dialog
class SlaConfigurationCreateDialog extends StatelessWidget {
  const SlaConfigurationCreateDialog({
    super.key,
    this.existingConfiguration,
  });

  final SlaConfigurationEntity? existingConfiguration;

  static Future<bool?> show(
    BuildContext context, {
    SlaConfigurationEntity? existingConfiguration,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => BlocProvider(
        create: (context) {
          final bloc = SlaConfigurationBloc(
            repository: SlaConfigurationRepository(
              apiClient: getIt<ApiClient>(),
            ),
          );
          if (existingConfiguration != null) {
            bloc.add(LoadSlaConfigurationById(existingConfiguration.id));
          }
          return bloc;
        },
        child: SlaConfigurationCreateDialog(
          existingConfiguration: existingConfiguration,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth >= 768;
    final isEdit = existingConfiguration != null;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isWeb ? 40 : 16,
        vertical: isWeb ? 40 : 24,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isWeb ? 900 : double.infinity,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dialog Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    color: theme.colorScheme.onPrimary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEdit
                          ? 'Edit SLA Configuration'
                          : 'Create SLA Configuration',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: theme.colorScheme.onPrimary,
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            // Dialog Body with form
            Expanded(
              child: BlocListener<SlaConfigurationBloc, SlaConfigurationState>(
                listener: (context, state) {
                  if (state is SlaConfigurationCreated ||
                      state is SlaConfigurationUpdated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('SLA configuration saved successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pop(true);
                  } else if (state is SlaConfigurationError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: SlaConfigurationCreateFormContent(
                  existingConfiguration: existingConfiguration,
                  isInDialog: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable form content widget that can be used in both page and dialog
class SlaConfigurationCreateFormContent extends StatefulWidget {
  const SlaConfigurationCreateFormContent({
    super.key,
    this.existingConfiguration,
    this.isInDialog = false,
  });

  final SlaConfigurationEntity? existingConfiguration;
  final bool isInDialog;

  @override
  State<SlaConfigurationCreateFormContent> createState() =>
      _SlaConfigurationCreateFormContentState();
}

class _SlaConfigurationCreateFormContentState
    extends State<SlaConfigurationCreateFormContent> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _applyBusinessHours = true;
  SlaConfigurationEntity? _loadedConfiguration;

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isRequired)
            const Text(
              ' *',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Future<bool> _handlePop() async {
    final formState = _formKey.currentState;
    final isDirty = formState?.isDirty ?? false;

    if (!isDirty) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to leave?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return shouldPop == true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.existingConfiguration != null;

    final formWidget = BlocBuilder<SlaConfigurationBloc, SlaConfigurationState>(
      builder: (context, state) {
        // If loading configuration for edit, show loading
        if (widget.existingConfiguration != null &&
            state is SlaConfigurationLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Get the configuration to use (from state if loaded, otherwise from prop)
        if (state is SlaConfigurationLoaded) {
          if (_loadedConfiguration != state.configuration) {
            setState(() {
              _loadedConfiguration = state.configuration;
            });
          }
        } else if (widget.existingConfiguration != null &&
            _loadedConfiguration == null) {
          _loadedConfiguration = widget.existingConfiguration;
        }

        final currentConfig =
            _loadedConfiguration ?? widget.existingConfiguration;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: FormBuilder(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Basic Information Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Basic Information',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel('Configuration Name', isRequired: true),
                        FormBuilderTextField(
                          name: 'name',
                          initialValue: currentConfig?.name,
                          decoration: const InputDecoration(
                            hintText: 'e.g., Standard SLA for High Priority',
                            helperText:
                                'A unique name to identify this SLA configuration',
                            border: OutlineInputBorder(),
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                                errorText: 'Configuration name is required'),
                            FormBuilderValidators.maxLength(100),
                          ]),
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel('Description'),
                        FormBuilderTextField(
                          name: 'description',
                          initialValue: currentConfig?.description,
                          decoration: const InputDecoration(
                            hintText:
                                'Brief description of this SLA configuration and when it should be used',
                            helperText:
                                'Optional: Provide context about when this configuration applies',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel('Ticket Priority', isRequired: true),
                        FormBuilderDropdown<TicketPriority>(
                          name: 'priority',
                          initialValue: currentConfig?.priority,
                          decoration: const InputDecoration(
                            hintText: 'Select priority level',
                            helperText:
                                'Select the priority level this SLA configuration applies to',
                            border: OutlineInputBorder(),
                          ),
                          style: Theme.of(context).textTheme.bodyMedium,
                          items: TicketPriority.values.map((priority) {
                            return DropdownMenuItem<TicketPriority>(
                              value: priority,
                              child: Text(priority.displayName),
                            );
                          }).toList(),
                          validator: FormBuilderValidators.required(
                              errorText: 'Priority selection is required'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // SLA Time Targets Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SLA Time Targets (in minutes)',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel('First Response Time', isRequired: true),
                        FormBuilderTextField(
                          name: 'first_response_time',
                          initialValue: currentConfig?.firstResponseTimeMinutes
                              .toString(),
                          decoration: const InputDecoration(
                            hintText: 'e.g., 30',
                            suffixText: 'minutes',
                            border: OutlineInputBorder(),
                            helperText:
                                'Maximum time (in minutes) to provide the first response to the ticket',
                          ),
                          keyboardType: TextInputType.number,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                                errorText: 'First response time is required'),
                            FormBuilderValidators.integer(
                                errorText: 'Must be a whole number'),
                            FormBuilderValidators.min(1,
                                errorText: 'Must be at least 1 minute'),
                          ]),
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel('Acknowledgement Time', isRequired: true),
                        FormBuilderTextField(
                          name: 'acknowledgement_time',
                          initialValue: currentConfig
                              ?.acknowledgementTimeMinutes
                              .toString(),
                          decoration: const InputDecoration(
                            hintText: 'e.g., 60',
                            suffixText: 'minutes',
                            border: OutlineInputBorder(),
                            helperText:
                                'Maximum time (in minutes) for a technician to acknowledge the assigned ticket',
                          ),
                          keyboardType: TextInputType.number,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                                errorText: 'Acknowledgement time is required'),
                            FormBuilderValidators.integer(
                                errorText: 'Must be a whole number'),
                            FormBuilderValidators.min(1,
                                errorText: 'Must be at least 1 minute'),
                          ]),
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel('Resolution Time', isRequired: true),
                        FormBuilderTextField(
                          name: 'resolution_time',
                          initialValue:
                              currentConfig?.resolutionTimeMinutes.toString(),
                          decoration: const InputDecoration(
                            hintText: 'e.g., 480',
                            suffixText: 'minutes',
                            border: OutlineInputBorder(),
                            helperText:
                                'Maximum time (in minutes) to completely resolve and close the ticket',
                          ),
                          keyboardType: TextInputType.number,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                                errorText: 'Resolution time is required'),
                            FormBuilderValidators.integer(
                                errorText: 'Must be a whole number'),
                            FormBuilderValidators.min(1,
                                errorText: 'Must be at least 1 minute'),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Escalation Thresholds Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.trending_up,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Escalation Thresholds (in minutes)',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Configure when tickets should automatically escalate to different levels',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel('Escalation Level 1 - Supervisor'),
                        FormBuilderTextField(
                          name: 'escalation_level_1',
                          initialValue: currentConfig?.escalationLevel1Minutes
                              ?.toString(),
                          decoration: const InputDecoration(
                            hintText: 'e.g., 120',
                            suffixText: 'minutes',
                            border: OutlineInputBorder(),
                            helperText:
                                'Optional: Time (in minutes) before automatically escalating to Supervisor. Leave empty to disable Level 1 escalation.',
                          ),
                          keyboardType: TextInputType.number,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.integer(
                                errorText: 'Must be a whole number'),
                            FormBuilderValidators.min(1,
                                errorText: 'Must be at least 1 minute'),
                          ]),
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel('Escalation Level 2 - Site Coordinator'),
                        FormBuilderTextField(
                          name: 'escalation_level_2',
                          initialValue: currentConfig?.escalationLevel2Minutes
                              ?.toString(),
                          decoration: const InputDecoration(
                            hintText: 'e.g., 240',
                            suffixText: 'minutes',
                            border: OutlineInputBorder(),
                            helperText:
                                'Optional: Time (in minutes) before automatically escalating to Site Coordinator. Leave empty to disable Level 2 escalation.',
                          ),
                          keyboardType: TextInputType.number,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.integer(
                                errorText: 'Must be a whole number'),
                            FormBuilderValidators.min(1,
                                errorText: 'Must be at least 1 minute'),
                          ]),
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel('Escalation Level 3 - Admin'),
                        FormBuilderTextField(
                          name: 'escalation_level_3',
                          initialValue: currentConfig?.escalationLevel3Minutes
                              ?.toString(),
                          decoration: const InputDecoration(
                            hintText: 'e.g., 480',
                            suffixText: 'minutes',
                            border: OutlineInputBorder(),
                            helperText:
                                'Optional: Time (in minutes) before automatically escalating to Admin. Leave empty to disable Level 3 escalation.',
                          ),
                          keyboardType: TextInputType.number,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.integer(
                                errorText: 'Must be a whole number'),
                            FormBuilderValidators.min(1,
                                errorText: 'Must be at least 1 minute'),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Business Hours Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FormBuilderSwitch(
                              name: 'apply_business_hours',
                              initialValue:
                                  currentConfig?.applyBusinessHours ?? true,
                              title: const Text('Apply Business Hours'),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _applyBusinessHours = value ?? true;
                                });
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 48, top: 4),
                              child: Text(
                                'When enabled, SLA timers pause outside business hours',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_applyBusinessHours) ...[
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel('Business Start Time', isRequired: true),
                                    FormBuilderTextField(
                                      name: 'business_start_time',
                                      initialValue:
                                          currentConfig?.businessStartTime,
                                      decoration: const InputDecoration(
                                        hintText: '09:00',
                                        border: OutlineInputBorder(),
                                        helperText:
                                            'Start time for business hours (24-hour format: HH:MM)',
                                      ),
                                      validator: (value) {
                                        if (_applyBusinessHours) {
                                          if (value == null ||
                                              value.toString().isEmpty) {
                                            return 'Business start time is required when business hours are enabled';
                                          }
                                          if (!RegExp(
                                                  r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$')
                                              .hasMatch(value.toString())) {
                                            return 'Must be in HH:MM format (e.g., 09:00)';
                                          }
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel('Business End Time', isRequired: true),
                                    FormBuilderTextField(
                                      name: 'business_end_time',
                                      initialValue:
                                          currentConfig?.businessEndTime,
                                      decoration: const InputDecoration(
                                        hintText: '18:00',
                                        border: OutlineInputBorder(),
                                        helperText:
                                            'End time for business hours (24-hour format: HH:MM)',
                                      ),
                                      validator: (value) {
                                        if (_applyBusinessHours) {
                                          if (value == null ||
                                              value.toString().isEmpty) {
                                            return 'Business end time is required when business hours are enabled';
                                          }
                                          if (!RegExp(
                                                  r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$')
                                              .hasMatch(value.toString())) {
                                            return 'Must be in HH:MM format (e.g., 18:00)';
                                          }
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildFieldLabel('Working Days', isRequired: true),
                          FormBuilderTextField(
                            name: 'working_days',
                            initialValue: currentConfig?.workingDays,
                            decoration: const InputDecoration(
                              hintText: '1,2,3,4,5',
                              border: OutlineInputBorder(),
                              helperText:
                                  'Comma-separated day numbers: 1=Monday, 2=Tuesday, 3=Wednesday, 4=Thursday, 5=Friday, 6=Saturday, 7=Sunday. Example: 1,2,3,4,5 for weekdays only',
                            ),
                            validator: (value) {
                              if (_applyBusinessHours) {
                                if (value == null || value.toString().isEmpty) {
                                  return 'Working days are required when business hours are enabled';
                                }
                                if (!RegExp(r'^[1-7](,[1-7])*$')
                                    .hasMatch(value.toString())) {
                                  return 'Must be comma-separated day numbers (1-7), e.g., 1,2,3,4,5';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FormBuilderSwitch(
                                name: 'exclude_holidays',
                                initialValue:
                                    currentConfig?.excludeHolidays ?? true,
                                title: const Text('Exclude Holidays'),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 48, top: 4),
                                child: Text(
                                  'When enabled, SLA timers pause on holidays configured in the system',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Status Section
                if (isEdit)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FormBuilderSwitch(
                            name: 'is_active',
                            initialValue: currentConfig?.isActive ?? true,
                            title: const Text('Configuration Status'),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 48, top: 4),
                            child: Text(
                              'Active configurations are automatically applied to matching tickets. Inactive configurations are saved but not used.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                // Submit Button
                BlocBuilder<SlaConfigurationBloc, SlaConfigurationState>(
                  builder: (context, state) {
                    final isLoading = state is SlaConfigurationLoading;
                    return ElevatedButton(
                      onPressed: isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isEdit
                              ? 'Update Configuration'
                              : 'Create Configuration'),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (widget.isInDialog) {
      return formWidget;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        if (await _handlePop() && context.mounted) {
          Navigator.of(context).pop(false);
        }
      },
      child: BlocListener<SlaConfigurationBloc, SlaConfigurationState>(
        listener: (context, state) {
          if (state is SlaConfigurationCreated ||
              state is SlaConfigurationUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('SLA configuration saved successfully'),
                backgroundColor: Colors.green,
              ),
            );
            if (context.mounted) {
              Navigator.of(context).pop(true);
            }
          } else if (state is SlaConfigurationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
                isEdit ? 'Edit SLA Configuration' : 'Create SLA Configuration'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                if (await _handlePop() && context.mounted) {
                  Navigator.of(context).pop(false);
                }
              },
            ),
          ),
          body: formWidget,
        ),
      ),
    );
  }

  void _submitForm() {
    final formState = _formKey.currentState;
    if (formState?.saveAndValidate() ?? false) {
      final formData = formState!.value;
      final now = DateTime.now();
      final currentConfig =
          _loadedConfiguration ?? widget.existingConfiguration;

      final configuration = SlaConfigurationEntity(
        id: currentConfig?.id ?? '',
        companyId: currentConfig?.companyId ?? '',
        name: formData['name'] as String,
        description: formData['description'] as String?,
        priority: formData['priority'] as TicketPriority,
        firstResponseTimeMinutes:
            int.parse(formData['first_response_time'].toString()),
        acknowledgementTimeMinutes:
            int.parse(formData['acknowledgement_time'].toString()),
        resolutionTimeMinutes:
            int.parse(formData['resolution_time'].toString()),
        escalationLevel1Minutes: formData['escalation_level_1'] != null &&
                formData['escalation_level_1'].toString().isNotEmpty
            ? int.tryParse(formData['escalation_level_1'].toString())
            : null,
        escalationLevel2Minutes: formData['escalation_level_2'] != null &&
                formData['escalation_level_2'].toString().isNotEmpty
            ? int.tryParse(formData['escalation_level_2'].toString())
            : null,
        escalationLevel3Minutes: formData['escalation_level_3'] != null &&
                formData['escalation_level_3'].toString().isNotEmpty
            ? int.tryParse(formData['escalation_level_3'].toString())
            : null,
        applyBusinessHours: formData['apply_business_hours'] as bool? ?? true,
        businessStartTime: formData['business_start_time'] as String?,
        businessEndTime: formData['business_end_time'] as String?,
        workingDays: formData['working_days'] as String?,
        excludeHolidays: formData['exclude_holidays'] as bool? ?? true,
        isActive: formData['is_active'] as bool? ?? true,
        createdById: currentConfig?.createdById,
        createdAt: currentConfig?.createdAt ?? now,
        updatedAt: now,
      );

      final configId = currentConfig?.id;
      if (configId != null && configId.isNotEmpty) {
        context.read<SlaConfigurationBloc>().add(
              UpdateSlaConfiguration(
                configId,
                configuration,
              ),
            );
      } else {
        context.read<SlaConfigurationBloc>().add(
              CreateSlaConfiguration(configuration),
            );
      }
    }
  }
}
