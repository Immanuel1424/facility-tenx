import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_client.dart';
import '../../data/dto/create_villa_type_config_dto.dart';
import '../../data/repositories/villa_type_config_repository.dart';
import '../bloc/villa_type_config/villa_type_config_bloc.dart';
import '../bloc/villa_type_config/villa_type_config_event.dart';
import '../bloc/villa_type_config/villa_type_config_state.dart';

class VillaTypeConfigCreatePage extends StatelessWidget {
  const VillaTypeConfigCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VillaTypeConfigBloc(
        repository: VillaTypeConfigRepository(
          apiClient: getIt<ApiClient>(),
        ),
      ),
      child: const VillaTypeConfigCreateFormContent(),
    );
  }
}

/// Dialog version - shows as modal dialog
class VillaTypeConfigCreateDialog extends StatelessWidget {
  const VillaTypeConfigCreateDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => BlocProvider(
        create: (context) => VillaTypeConfigBloc(
          repository: VillaTypeConfigRepository(
            apiClient: getIt<ApiClient>(),
          ),
        ),
        child: const VillaTypeConfigCreateDialog(),
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
          maxWidth: isWeb ? 800 : double.infinity,
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
                    Icons.home_work,
                    color: theme.colorScheme.onPrimary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Create Villa Type',
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
              child: BlocListener<VillaTypeConfigBloc, VillaTypeConfigState>(
                listener: (context, state) {
                  state.maybeWhen(
                    created: (_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Villa type created successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.of(context).pop(true);
                    },
                    error: (message) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                    orElse: () {},
                  );
                },
                child: const VillaTypeConfigCreateFormContent(isDialog: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable form content widget that can be used in both page and dialog
class VillaTypeConfigCreateFormContent extends StatefulWidget {
  const VillaTypeConfigCreateFormContent({
    super.key,
    this.isDialog = false,
  });

  final bool isDialog;

  @override
  State<VillaTypeConfigCreateFormContent> createState() =>
      _VillaTypeConfigCreateFormContentState();
}

class _VillaTypeConfigCreateFormContentState
    extends State<VillaTypeConfigCreateFormContent> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    // For dialog mode, just show the form content without Scaffold/AppBar
    // For page mode, wrap in Scaffold with AppBar
    final formContent = PopScope(
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
      child: BlocListener<VillaTypeConfigBloc, VillaTypeConfigState>(
        listener: (context, state) {
          state.maybeWhen(
            created: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Villa type created successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              if (!widget.isDialog && context.mounted) {
                context.pop(true);
              }
            },
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: Colors.red,
                ),
              );
            },
            orElse: () {},
          );
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(
            MediaQuery.of(context).size.width >= 768 ? 24 : 16,
          ),
          child: FormBuilder(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Builder(
              builder: (context) {
                final screenWidth = MediaQuery.of(context).size.width;
                final isDesktop = screenWidth >= 768;
                return isDesktop
                    ? _buildDesktopForm(context)
                    : _buildMobileForm(context);
              },
            ),
          ),
        ),
      ),
    );

    if (widget.isDialog) {
      // For dialog mode, just return the form content without Scaffold/AppBar
      return formContent;
    }

    // For page mode, wrap in Scaffold with AppBar
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Villa Type'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
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
        ),
      ),
      body: formContent,
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

  Widget _buildMobileForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFieldLabel('Villa Type Code', isRequired: true),
        FormBuilderTextField(
          name: 'villaType',
                  decoration: const InputDecoration(
                    hintText: 'e.g., 1BHK, 2BHK, Studio, Duplex',
                    border: OutlineInputBorder(),
                  ),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(
              errorText: 'Villa type code is required',
            ),
            FormBuilderValidators.maxLength(
              50,
              errorText: 'Villa type code must be 50 characters or less',
            ),
          ]),
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Display Name', isRequired: true),
        FormBuilderTextField(
          name: 'displayName',
                  decoration: const InputDecoration(
                    hintText: 'e.g., 1 Bedroom Hall Kitchen',
                    border: OutlineInputBorder(),
                  ),
          validator: FormBuilderValidators.maxLength(
            255,
            errorText: 'Display name must be 255 characters or less',
          ),
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Default Bedroom Count', isRequired: true),
        FormBuilderTextField(
          name: 'defaultBedroomCount',
                  decoration: const InputDecoration(
                    hintText: 'e.g., 1, 2, 3',
                    border: OutlineInputBorder(),
                  ),
          keyboardType: TextInputType.number,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.numeric(
              errorText: 'Must be a valid number',
            ),
            FormBuilderValidators.min(
              0,
              errorText: 'Cannot be negative',
            ),
          ]),
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Default Floor Count', isRequired: true),
        FormBuilderTextField(
          name: 'defaultFloorCount',
                  decoration: const InputDecoration(
                    hintText: 'e.g., 1, 2',
                    border: OutlineInputBorder(),
                  ),
          keyboardType: TextInputType.number,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.numeric(
              errorText: 'Must be a valid number',
            ),
            FormBuilderValidators.min(
              0,
              errorText: 'Cannot be negative',
            ),
          ]),
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Default Area (sqm)', isRequired: true),
        FormBuilderTextField(
          name: 'defaultAreaSqm',
                  decoration: const InputDecoration(
                    hintText: 'e.g., 50.5, 75.0',
                    border: OutlineInputBorder(),
                  ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.numeric(
              errorText: 'Must be a valid number',
            ),
            FormBuilderValidators.min(
              0,
              errorText: 'Cannot be negative',
            ),
          ]),
        ),
        const SizedBox(height: 16),
        FormBuilderSwitch(
          name: 'isActive',
          title: const Text('Active'),
          initialValue: true,
          decoration: const InputDecoration(),
        ),
        const SizedBox(height: 24),
        _buildSubmitButton(context),
      ],
    );
  }

  Widget _buildDesktopForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Row 1: Villa Type Code | Display Name
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFieldLabel('Villa Type Code', isRequired: true),
                  FormBuilderTextField(
                    name: 'villaType',
                    decoration: const InputDecoration(
                      hintText: 'e.g., 1BHK, 2BHK, Studio, Duplex',
                      border: OutlineInputBorder(),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                        errorText: 'Villa type code is required',
                      ),
                      FormBuilderValidators.maxLength(
                        50,
                        errorText: 'Villa type code must be 50 characters or less',
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFieldLabel('Display Name', isRequired: true),
                  FormBuilderTextField(
                    name: 'displayName',
                    decoration: const InputDecoration(
                      hintText: 'e.g., 1 Bedroom Hall Kitchen',
                      border: OutlineInputBorder(),
                    ),
                    validator: FormBuilderValidators.maxLength(
                      255,
                      errorText: 'Display name must be 255 characters or less',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Row 2: Default Bedroom Count | Default Floor Count
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFieldLabel('Default Bedroom Count', isRequired: true),
                  FormBuilderTextField(
                    name: 'defaultBedroomCount',
                    decoration: const InputDecoration(
                      hintText: 'e.g., 1, 2, 3',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.numeric(
                        errorText: 'Must be a valid number',
                      ),
                      FormBuilderValidators.min(
                        0,
                        errorText: 'Cannot be negative',
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFieldLabel('Default Floor Count', isRequired: true),
                  FormBuilderTextField(
                    name: 'defaultFloorCount',
                    decoration: const InputDecoration(
                      hintText: 'e.g., 1, 2',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.numeric(
                        errorText: 'Must be a valid number',
                      ),
                      FormBuilderValidators.min(
                        0,
                        errorText: 'Cannot be negative',
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Row 3: Default Area (sqm) - Full width
        _buildFieldLabel('Default Area (sqm)', isRequired: true),
        FormBuilderTextField(
          name: 'defaultAreaSqm',
          decoration: const InputDecoration(
            hintText: 'e.g., 50.5, 75.0',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.numeric(
              errorText: 'Must be a valid number',
            ),
            FormBuilderValidators.min(
              0,
              errorText: 'Cannot be negative',
            ),
          ]),
        ),
        const SizedBox(height: 16),
        // Active Switch
        FormBuilderSwitch(
          name: 'isActive',
          title: const Text('Active'),
          initialValue: true,
          decoration: const InputDecoration(),
        ),
        const SizedBox(height: 24),
        // Submit Button
        _buildSubmitButton(context),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return BlocBuilder<VillaTypeConfigBloc, VillaTypeConfigState>(
      builder: (context, state) {
        final isLoading = state.when(
          initial: () => false,
          loading: () => true,
          listLoaded: (_) => false,
          loaded: (_) => false,
          created: (_) => false,
          updated: (_) => false,
          deleted: () => false,
          activated: (_) => false,
          deactivated: (_) => false,
          error: (_) => false,
        );
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : _submitForm,
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create Villa Type'),
          ),
        );
      },
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      final dto = CreateVillaTypeConfigDto(
        villaType: formData['villaType'] as String,
        displayName: formData['displayName'] as String?,
        defaultBedroomCount: formData['defaultBedroomCount'] != null
            ? int.tryParse(formData['defaultBedroomCount'].toString())
            : null,
        defaultFloorCount: formData['defaultFloorCount'] != null
            ? int.tryParse(formData['defaultFloorCount'].toString())
            : null,
        defaultAreaSqm: formData['defaultAreaSqm'] != null
            ? double.tryParse(formData['defaultAreaSqm'].toString())
            : null,
        isActive: formData['isActive'] as bool? ?? true,
      );
      context.read<VillaTypeConfigBloc>().add(CreateVillaTypeConfig(dto));
    }
  }
}
