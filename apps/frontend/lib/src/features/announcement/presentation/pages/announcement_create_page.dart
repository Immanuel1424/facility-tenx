import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../iam/data/repositories/iam_repository.dart';
import '../../../iam/presentation/bloc/role/role_bloc.dart';
import '../../../iam/presentation/bloc/role/role_event.dart';
import '../../../iam/presentation/bloc/role/role_state.dart';
import '../../domain/entities/announcement_entity.dart';
import '../bloc/announcement_bloc.dart';
import '../bloc/announcement_event.dart';
import '../bloc/announcement_state.dart';

class AnnouncementCreatePage extends StatelessWidget {
  const AnnouncementCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<AnnouncementBloc>(),
        ),
        BlocProvider(
          create: (context) => RoleBloc(
            repository: getIt<IamRepository>(),
          )..add(const LoadRoleList()),
        ),
      ],
      child: const _AnnouncementCreateContent(),
    );
  }
}

/// Dialog version for web - shows as modal dialog
class AnnouncementCreateDialog extends StatelessWidget {
  const AnnouncementCreateDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => getIt<AnnouncementBloc>(),
          ),
          BlocProvider(
            create: (context) => RoleBloc(
              repository: getIt<IamRepository>(),
            )..add(const LoadRoleList()),
          ),
        ],
        child: const AnnouncementCreateDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth >= 768;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isWeb ? 40 : 16,
        vertical: isWeb ? 40 : 24,
      ),
      child: ConstrainedBox(
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
                    Icons.campaign,
                    color: theme.colorScheme.onPrimary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Create Announcement',
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
              child: BlocListener<AnnouncementBloc, AnnouncementState>(
                listener: (context, state) {
                  if (state is AnnouncementCreated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Announcement created successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pop(true);
                  } else if (state is AnnouncementError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${state.message}'),
                        backgroundColor: theme.colorScheme.error,
                      ),
                    );
                  }
                },
                child: const _AnnouncementCreateContent(isDialog: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable form content widget that can be used in both page and dialog
class _AnnouncementCreateContent extends StatefulWidget {
  const _AnnouncementCreateContent({
    this.isDialog = false,
  });

  final bool isDialog;

  @override
  State<_AnnouncementCreateContent> createState() =>
      _AnnouncementCreateContentState();
}

class _AnnouncementCreateContentState
    extends State<_AnnouncementCreateContent> {
  final _formKey = GlobalKey<FormBuilderState>();
  AnnouncementTargetAudience _targetAudience = AnnouncementTargetAudience.all;
  List<String> _selectedRoles = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        final formState = _formKey.currentState;
        final isDirty = formState?.isDirty ?? false;

        if (isDirty) {
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

          if (shouldPop == true && context.mounted) {
            context.pop(true);
          }
        } else {
          if (context.mounted) {
            context.pop(true);
          }
        }
      },
      child: widget.isDialog
          ? SingleChildScrollView(
              padding: EdgeInsets.all(
                MediaQuery.of(context).size.width >= 768 ? 24 : 16,
              ),
              child: FormBuilder(
                key: _formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: ResponsiveLayout(
                  mobileBreakpoint: 768.0,
                  mobileBuilder: (context) => _buildFormFields(context, isMobile: true),
                  desktopBuilder: (context) => _buildFormFields(context, isMobile: false),
                ),
              ),
            )
          : Scaffold(
              backgroundColor: theme.colorScheme.surface,
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/announcements'),
                ),
                title: const Text('Create Announcement'),
              ),
              body: BlocListener<AnnouncementBloc, AnnouncementState>(
                listener: (context, state) {
                  if (state is AnnouncementCreated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Announcement created successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    context.pop(true);
                  } else if (state is AnnouncementError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${state.message}'),
                        backgroundColor: theme.colorScheme.error,
                      ),
                    );
                  }
                },
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(
                    MediaQuery.of(context).size.width >= 768 ? 24 : 16,
                  ),
                  child: FormBuilder(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: ResponsiveLayout(
                      mobileBreakpoint: 768.0,
                      mobileBuilder: (context) => _buildFormFields(context, isMobile: true),
                      desktopBuilder: (context) => _buildFormFields(context, isMobile: false),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

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

  /// Builds consistent dropdown decoration using theme
  InputDecoration _buildDropdownDecoration(
    BuildContext context, {
    required String hintText,
  }) {
    final theme = Theme.of(context);
    return InputDecoration(
      hintText: hintText,
      border: const OutlineInputBorder(),
      hintStyle: theme.textTheme.bodyMedium?.copyWith(
        color: theme.hintColor,
      ),
    );
  }

  /// Builds consistent dropdown text style using theme
  TextStyle _buildDropdownTextStyle(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.bodyMedium ?? const TextStyle();
  }

  Widget _buildFormFields(BuildContext context, {required bool isMobile}) {
    return isMobile
        ? _buildMobileForm(context)
        : _buildDesktopForm(context);
  }

  Widget _buildMobileForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title Field
        _buildFieldLabel('Title', isRequired: true),
        FormBuilderTextField(
          name: 'title',
          decoration: const InputDecoration(
            hintText: 'Enter announcement title',
            border: OutlineInputBorder(),
          ),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(
              errorText: 'Title is required',
            ),
            FormBuilderValidators.minLength(3),
            FormBuilderValidators.maxLength(255),
          ]),
        ),
        const SizedBox(height: 16),
        // Message Field
        _buildFieldLabel('Message', isRequired: true),
        FormBuilderTextField(
          name: 'message',
          decoration: const InputDecoration(
            hintText: 'Enter announcement message',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(
              errorText: 'Message is required',
            ),
            FormBuilderValidators.minLength(10),
          ]),
        ),
        const SizedBox(height: 16),
        // Category Field
        _buildFieldLabel('Category', isRequired: true),
        FormBuilderDropdown<AnnouncementCategory>(
          name: 'category',
          decoration: _buildDropdownDecoration(
            context,
            hintText: 'Select announcement category',
          ),
          style: _buildDropdownTextStyle(context),
          items: [
            DropdownMenuItem<AnnouncementCategory>(
              value: null,
              child: Text(
                'Select Category',
                style: _buildDropdownTextStyle(context).copyWith(
                  color: Theme.of(context).hintColor,
                ),
              ),
            ),
            ...AnnouncementCategory.values.map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category.displayName),
                )),
          ],
          validator: FormBuilderValidators.required(
            errorText: 'Please select a category',
          ),
        ),
        const SizedBox(height: 16),
        // Priority Field
        _buildFieldLabel('Priority', isRequired: true),
        FormBuilderDropdown<AnnouncementPriority>(
          name: 'priority',
          decoration: _buildDropdownDecoration(
            context,
            hintText: 'Select announcement priority',
          ),
          style: _buildDropdownTextStyle(context),
          items: [
            DropdownMenuItem<AnnouncementPriority>(
              value: null,
              child: Text(
                'Select Priority',
                style: _buildDropdownTextStyle(context).copyWith(
                  color: Theme.of(context).hintColor,
                ),
              ),
            ),
            ...AnnouncementPriority.values.map((priority) => DropdownMenuItem(
                  value: priority,
                  child: Text(priority.displayName),
                )),
          ],
          validator: FormBuilderValidators.required(
            errorText: 'Please select a priority',
          ),
        ),
        const SizedBox(height: 16),
        // Target Audience Field
        _buildFieldLabel('Target Audience', isRequired: true),
        FormBuilderDropdown<AnnouncementTargetAudience>(
          name: 'targetAudience',
          decoration: _buildDropdownDecoration(
            context,
            hintText: 'Select target audience',
          ),
          style: _buildDropdownTextStyle(context),
          initialValue: AnnouncementTargetAudience.all,
          items: AnnouncementTargetAudience.values
              .map((audience) => DropdownMenuItem(
                    value: audience,
                    child: Text(
                      audience == AnnouncementTargetAudience.all
                          ? 'All Users'
                          : 'Specific Roles',
                    ),
                  ))
              .toList(),
          validator: FormBuilderValidators.required(
            errorText: 'Please select target audience',
          ),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _targetAudience = value;
                if (value == AnnouncementTargetAudience.all) {
                  _selectedRoles = [];
                }
              });
            }
          },
        ),
        if (_targetAudience == AnnouncementTargetAudience.roles) ...[
          const SizedBox(height: 16),
          _buildFieldLabel('Select Roles', isRequired: true),
          _buildRoleSelector(context),
        ],
        const SizedBox(height: 16),
        // Schedule Date & Time Field
        _buildFieldLabel('Schedule Date & Time'),
        FormBuilderDateTimePicker(
          name: 'scheduledAt',
          decoration: const InputDecoration(
            hintText: 'Select schedule date and time',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today),
          ),
          inputType: InputType.both,
          format: DateFormat('yyyy-MM-dd HH:mm'),
          initialValue: null,
        ),
        const SizedBox(height: 16),
        // Expiration Date & Time Field
        _buildFieldLabel('Expiration Date & Time'),
        FormBuilderDateTimePicker(
          name: 'expiresAt',
          decoration: const InputDecoration(
            hintText: 'Select expiration date and time',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today),
          ),
          inputType: InputType.both,
          format: DateFormat('yyyy-MM-dd HH:mm'),
          initialValue: null,
        ),
        const SizedBox(height: 16),
        // Publish Immediately Checkbox
        FormBuilderCheckbox(
          name: 'publishImmediately',
          title: const Text('Publish immediately'),
          initialValue: false,
        ),
        const SizedBox(height: 24),
        // Submit Button
        _buildSubmitButton(context),
      ],
    );
  }

  Widget _buildDesktopForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Row 1: Title (full width)
        _buildFieldLabel('Title', isRequired: true),
        FormBuilderTextField(
          name: 'title',
          decoration: const InputDecoration(
            hintText: 'Enter announcement title',
            border: OutlineInputBorder(),
          ),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(
              errorText: 'Title is required',
            ),
            FormBuilderValidators.minLength(3),
            FormBuilderValidators.maxLength(255),
          ]),
        ),
        const SizedBox(height: 24),
        // Row 2: Message (full width)
        _buildFieldLabel('Message', isRequired: true),
        FormBuilderTextField(
          name: 'message',
          decoration: const InputDecoration(
            hintText: 'Enter announcement message',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(
              errorText: 'Message is required',
            ),
            FormBuilderValidators.minLength(10),
          ]),
        ),
        const SizedBox(height: 24),
        // Row 3: Category | Priority
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFieldLabel('Category', isRequired: true),
                  FormBuilderDropdown<AnnouncementCategory>(
                    name: 'category',
                    decoration: _buildDropdownDecoration(
                      context,
                      hintText: 'Select announcement category',
                    ),
                    style: _buildDropdownTextStyle(context),
                    items: [
                      DropdownMenuItem<AnnouncementCategory>(
                        value: null,
                        child: Text(
                          'Select Category',
                          style: _buildDropdownTextStyle(context).copyWith(
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ),
                      ...AnnouncementCategory.values.map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category.displayName),
                          )),
                    ],
                    validator: FormBuilderValidators.required(
                      errorText: 'Please select a category',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFieldLabel('Priority', isRequired: true),
                  FormBuilderDropdown<AnnouncementPriority>(
                    name: 'priority',
                    decoration: _buildDropdownDecoration(
                      context,
                      hintText: 'Select announcement priority',
                    ),
                    style: _buildDropdownTextStyle(context),
                    items: [
                      DropdownMenuItem<AnnouncementPriority>(
                        value: null,
                        child: Text(
                          'Select Priority',
                          style: _buildDropdownTextStyle(context).copyWith(
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ),
                      ...AnnouncementPriority.values.map((priority) => DropdownMenuItem(
                            value: priority,
                            child: Text(priority.displayName),
                          )),
                    ],
                    validator: FormBuilderValidators.required(
                      errorText: 'Please select a priority',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Row 4: Target Audience (full width)
        _buildFieldLabel('Target Audience', isRequired: true),
        FormBuilderDropdown<AnnouncementTargetAudience>(
          name: 'targetAudience',
          decoration: _buildDropdownDecoration(
            context,
            hintText: 'Select target audience',
          ),
          style: _buildDropdownTextStyle(context),
          initialValue: AnnouncementTargetAudience.all,
          items: AnnouncementTargetAudience.values
              .map((audience) => DropdownMenuItem(
                    value: audience,
                    child: Text(
                      audience == AnnouncementTargetAudience.all
                          ? 'All Users'
                          : 'Specific Roles',
                    ),
                  ))
              .toList(),
          validator: FormBuilderValidators.required(
            errorText: 'Please select target audience',
          ),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _targetAudience = value;
                if (value == AnnouncementTargetAudience.all) {
                  _selectedRoles = [];
                }
              });
            }
          },
        ),
        if (_targetAudience == AnnouncementTargetAudience.roles) ...[
          const SizedBox(height: 24),
          _buildFieldLabel('Select Roles', isRequired: true),
          _buildRoleSelector(context),
        ],
        const SizedBox(height: 24),
        // Row 5: Schedule Date & Time | Expiration Date & Time
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFieldLabel('Schedule Date & Time'),
                  FormBuilderDateTimePicker(
                    name: 'scheduledAt',
                    decoration: const InputDecoration(
                      hintText: 'Select schedule date and time',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    inputType: InputType.both,
                    format: DateFormat('yyyy-MM-dd HH:mm'),
                    initialValue: null,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFieldLabel('Expiration Date & Time'),
                  FormBuilderDateTimePicker(
                    name: 'expiresAt',
                    decoration: const InputDecoration(
                      hintText: 'Select expiration date and time',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    inputType: InputType.both,
                    format: DateFormat('yyyy-MM-dd HH:mm'),
                    initialValue: null,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Publish Immediately Checkbox
        FormBuilderCheckbox(
          name: 'publishImmediately',
          title: const Text('Publish immediately'),
          initialValue: false,
        ),
        const SizedBox(height: 24),
        // Submit Button
        _buildSubmitButton(context),
      ],
    );
  }

  Widget _buildRoleSelector(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<RoleBloc, RoleState>(
      builder: (context, roleState) {
        if (roleState is RoleLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (roleState is RoleError) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Error loading roles: ${roleState.message}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          );
        }

        final availableRoles = roleState is RoleListLoaded
            ? roleState.roles.map((role) => role.name).toList()
            : <String>[];

        if (availableRoles.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'No roles available',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableRoles.map((role) {
                final isSelected = _selectedRoles.contains(role);
                return FilterChip(
                  label: Text(role),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedRoles.add(role);
                      } else {
                        _selectedRoles.remove(role);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            if (_selectedRoles.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Please select at least one role',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AnnouncementBloc, AnnouncementState>(
      builder: (context, state) {
        final isLoading = state is AnnouncementLoading;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    if (_formKey.currentState?.saveAndValidate() ?? false) {
                      final formData = _formKey.currentState!.value;

                      if (_targetAudience ==
                              AnnouncementTargetAudience.roles &&
                          _selectedRoles.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Please select at least one role',
                            ),
                            backgroundColor: theme.colorScheme.error,
                          ),
                        );
                        return;
                      }

                      context.read<AnnouncementBloc>().add(
                            CreateAnnouncement(
                              title: formData['title'] as String,
                              message: formData['message'] as String,
                              category: (formData['category']
                                      as AnnouncementCategory)
                                  .name,
                              priority: (formData['priority']
                                      as AnnouncementPriority)
                                  .name,
                              targetAudience: (formData['targetAudience']
                                      as AnnouncementTargetAudience)
                                  .name,
                              targetRoles: _targetAudience ==
                                      AnnouncementTargetAudience.roles
                                  ? _selectedRoles
                                  : null,
                              scheduledAt: formData['scheduledAt'] as DateTime?,
                              expiresAt: formData['expiresAt'] as DateTime?,
                              publishImmediately:
                                  formData['publishImmediately'] as bool?,
                            ),
                          );
                    }
                  },
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create Announcement'),
          ),
        );
      },
    );
  }
}
