import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_client.dart';
import '../../data/repositories/department_repository.dart';
import '../bloc/department_bloc.dart';
import '../bloc/department_event.dart';
import '../bloc/department_state.dart';

class DepartmentDetailPage extends StatelessWidget {
  const DepartmentDetailPage({
    super.key,
    required this.departmentId,
  });

  final String departmentId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DepartmentBloc(
        repository: DepartmentRepository(
          apiClient: getIt<ApiClient>(),
        ),
      )..add(LoadDepartmentDetail(departmentId)),
      child: _DepartmentDetailContent(departmentId: departmentId),
    );
  }
}

class _DepartmentDetailContent extends StatelessWidget {
  const _DepartmentDetailContent({required this.departmentId});

  final String departmentId;

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormBuilderState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Department Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Show edit dialog
              _showEditDialog(context, formKey);
            },
            tooltip: 'Edit Department',
          ),
        ],
      ),
      body: BlocListener<DepartmentBloc, DepartmentState>(
        listener: (context, state) {
          state.maybeWhen(
            updated: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Department updated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              context.read<DepartmentBloc>().add(LoadDepartmentDetail(departmentId));
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
        child: BlocBuilder<DepartmentBloc, DepartmentState>(
          builder: (context, state) {
            return state.when(
              initial: () => const Center(child: CircularProgressIndicator()),
              loading: () => const Center(child: CircularProgressIndicator()),
              listLoaded: (_) => const SizedBox.shrink(),
              detailLoaded: (department) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      department.name,
                                      style: Theme.of(context).textTheme.headlineSmall,
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      department.isActive ? 'Active' : 'Inactive',
                                    ),
                                    backgroundColor: department.isActive
                                        ? Colors.green
                                        : Colors.red,
                                    labelStyle: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                              if (department.description != null) ...[
                                const SizedBox(height: 16),
                                Text(
                                  'Description',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(department.description!),
                              ],
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 8),
                              _DetailRow(
                                label: 'Created',
                                value: _formatDate(department.createdAt),
                              ),
                              const SizedBox(height: 8),
                              _DetailRow(
                                label: 'Last Updated',
                                value: _formatDate(department.updatedAt),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              created: (_) => const SizedBox.shrink(),
              updated: (_) => const SizedBox.shrink(),
              deleted: () => const SizedBox.shrink(),
              error: (message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading department',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<DepartmentBloc>().add(
                              LoadDepartmentDetail(departmentId),
                            );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, GlobalKey<FormBuilderState> formKey) {
    final bloc = context.read<DepartmentBloc>();
    final state = bloc.state;

    String? initialName;
    String? initialDescription;

    state.maybeWhen(
      detailLoaded: (department) {
        initialName = department.name;
        initialDescription = department.description;
      },
      orElse: () {},
    );

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Department'),
        content: FormBuilder(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FormBuilderTextField(
                name: 'name',
                initialValue: initialName,
                decoration: const InputDecoration(
                  labelText: 'Department Name',
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(2),
                  FormBuilderValidators.maxLength(100),
                ]),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'description',
                initialValue: initialDescription,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: FormBuilderValidators.maxLength(500),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          BlocBuilder<DepartmentBloc, DepartmentState>(
            bloc: bloc,
            builder: (context, state) {
              final isLoading = state.maybeWhen<bool>(
                loading: () => true,
                orElse: () => false,
              ) ?? false;

              return TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        final formState = formKey.currentState;
                        if (formState != null && formState.saveAndValidate()) {
                          final formData = formState.value;
                          bloc.add(
                            UpdateDepartment(
                              id: departmentId,
                              name: formData['name'] as String?,
                              description: formData['description'] as String?,
                            ),
                          );
                          Navigator.of(dialogContext).pop();
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

