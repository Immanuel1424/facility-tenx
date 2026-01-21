import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../data/dto/permission_dto.dart';
import '../../data/repositories/iam_repository.dart';
import '../bloc/permission/permission_bloc.dart';
import '../bloc/permission/permission_event.dart';
import '../bloc/permission/permission_state.dart';

class PermissionCreatePage extends StatelessWidget {
  const PermissionCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PermissionBloc(
        repository: getIt<IamRepository>(),
      ),
      child: const _PermissionCreateContent(),
    );
  }
}

class _PermissionCreateContent extends StatelessWidget {
  const _PermissionCreateContent();

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormBuilderState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Permission'),
      ),
      body: BlocListener<PermissionBloc, PermissionState>(
        listener: (context, state) {
          state.maybeWhen(
            created: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Permission created successfully'),
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
                  name: 'resource',
                  decoration: const InputDecoration(
                    labelText: 'Resource',
                    hintText: 'e.g., service_request, user, role',
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
                  name: 'action',
                  decoration: const InputDecoration(
                    labelText: 'Action',
                    hintText: 'e.g., create, read, update, delete',
                    border: OutlineInputBorder(),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(2),
                    FormBuilderValidators.maxLength(50),
                  ]),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'description',
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter permission description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: FormBuilderValidators.maxLength(500),
                ),
                const SizedBox(height: 24),
                BlocBuilder<PermissionBloc, PermissionState>(
                  builder: (context, state) {
                    final isLoading = state.maybeWhen(
                      loading: () => true,
                      orElse: () => false,
                    ) ?? false;

                    return ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (formKey.currentState?.saveAndValidate() ?? false) {
                                final formData = formKey.currentState!.value;
                                final dto = CreatePermissionDto(
                                  resource: formData['resource'] as String,
                                  action: formData['action'] as String,
                                  description: formData['description'] as String?,
                                );

                                context.read<PermissionBloc>().add(
                                      CreatePermission(dto),
                                    );
                              }
                            },
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create Permission'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

