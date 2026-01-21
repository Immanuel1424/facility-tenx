import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/di/service_locator.dart';
import '../../../../../core/network/api_client.dart';
import '../../../data/dto/create_ticket_category_dto.dart';
import '../../../data/repositories/ticket_category_repository.dart';
import '../../bloc/ticket_category/ticket_category_bloc.dart';
import '../../bloc/ticket_category/ticket_category_event.dart';
import '../../bloc/ticket_category/ticket_category_state.dart';

class TicketCategoryCreatePage extends StatelessWidget {
  const TicketCategoryCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TicketCategoryBloc(
        repository: TicketCategoryRepository(
          apiClient: getIt<ApiClient>(),
        ),
      ),
      child: const TicketCategoryCreateFormContent(),
    );
  }
}

/// Dialog version - shows as modal dialog
class TicketCategoryCreateDialog extends StatelessWidget {
  const TicketCategoryCreateDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => BlocProvider(
        create: (context) => TicketCategoryBloc(
          repository: TicketCategoryRepository(
            apiClient: getIt<ApiClient>(),
          ),
        ),
        child: const TicketCategoryCreateDialog(),
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
                    Icons.category,
                    color: theme.colorScheme.onPrimary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Create Category',
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
              child: const TicketCategoryCreateFormContent(isDialog: true),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable form content widget that can be used in both page and dialog
class TicketCategoryCreateFormContent extends StatefulWidget {
  const TicketCategoryCreateFormContent({
    super.key,
    this.isDialog = false,
  });

  final bool isDialog;

  @override
  State<TicketCategoryCreateFormContent> createState() =>
      _TicketCategoryCreateFormContentState();
}

class _TicketCategoryCreateFormContentState
    extends State<TicketCategoryCreateFormContent> {
  final _formKey = GlobalKey<FormBuilderState>();

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
    final formContent = PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        if (await _handlePop() && context.mounted) {
          context.pop(true);
        }
      },
      child: BlocListener<TicketCategoryBloc, TicketCategoryState>(
        listener: (context, state) {
          if (state is TicketCategoryCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Category created successfully'),
                backgroundColor: Colors.green,
              ),
            );
            if (context.mounted) {
              context.pop(true);
            }
          } else if (state is TicketCategoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildFieldLabel('Category Name', isRequired: true),
                FormBuilderTextField(
                  name: 'name',
                  decoration: const InputDecoration(
                    hintText: 'e.g., Plumbing, Electrical, HVAC',
                    border: OutlineInputBorder(),
                    helperText: 'Category code will be generated automatically',
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(
                      errorText: 'Category name is required',
                    ),
                    FormBuilderValidators.maxLength(100),
                  ]),
                ),
                const SizedBox(height: 16),
                _buildFieldLabel('Description'),
                FormBuilderTextField(
                  name: 'description',
                  decoration: const InputDecoration(
                    hintText: 'Brief description of this category (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                BlocBuilder<TicketCategoryBloc, TicketCategoryState>(
                  builder: (context, state) {
                    final isLoading = state is TicketCategoryLoading;
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
                          : const Text('Create Category'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (widget.isDialog) {
      return formContent;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Category'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            if (await _handlePop() && context.mounted) {
              context.pop(true);
            }
          },
        ),
      ),
      body: formContent,
    );
  }

  void _submitForm() {
    final formState = _formKey.currentState;
    if (formState?.saveAndValidate() ?? false) {
      final formData = formState!.value;
      final dto = CreateTicketCategoryDto(
        name: formData['name'] as String,
        description: formData['description'] as String?,
      );
      context.read<TicketCategoryBloc>().add(CreateTicketCategory(dto));
    }
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
}
