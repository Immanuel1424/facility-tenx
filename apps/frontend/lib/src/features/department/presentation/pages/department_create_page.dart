import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_client.dart';
import '../../data/repositories/department_repository.dart';
import '../bloc/department_bloc.dart';
import '../bloc/department_event.dart';
import '../bloc/department_state.dart';

class DepartmentCreatePage extends StatelessWidget {
  const DepartmentCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DepartmentBloc(
        repository: DepartmentRepository(
          apiClient: getIt<ApiClient>(),
        ),
      ),
      child: const _DepartmentCreateContent(),
    );
  }
}

class _DepartmentCreateContent extends StatelessWidget {
  const _DepartmentCreateContent();

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormBuilderState>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        
        final formState = formKey.currentState;
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
            context.pop();
          }
        } else {
          if (context.mounted) {
            context.pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Department'),
        ),
        body: BlocListener<DepartmentBloc, DepartmentState>(
        listener: (context, state) {
          state.maybeWhen(
            created: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Department created successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              context.pop();
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
          padding: const EdgeInsets.all(16),
          child: FormBuilder(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FormBuilderTextField(
                  name: 'name',
                  decoration: const InputDecoration(
                    labelText: 'Department Name',
                    hintText: 'Enter department name',
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
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter department description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: FormBuilderValidators.maxLength(500),
                ),
                const SizedBox(height: 24),
                BlocBuilder<DepartmentBloc, DepartmentState>(
                  builder: (context, state) {
                    final isLoading = state.maybeWhen<bool>(
                      loading: () => true,
                      orElse: () => false,
                    ) ?? false;

                    return ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              final formState = formKey.currentState;
                              if (formState != null && formState.saveAndValidate()) {
                                final formData = formState.value;
                                context.read<DepartmentBloc>().add(
                                      CreateDepartment(
                                        name: formData['name'] as String,
                                        description: formData['description'] as String?,
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
                          : const Text('Create Department'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

