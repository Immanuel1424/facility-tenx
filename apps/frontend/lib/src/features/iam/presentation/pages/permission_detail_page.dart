import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../data/dto/permission_dto.dart';
import '../../data/repositories/iam_repository.dart';
import '../../domain/entities/permission_entity.dart';
import '../bloc/permission/permission_bloc.dart';
import '../bloc/permission/permission_event.dart';
import '../bloc/permission/permission_state.dart';

class PermissionDetailPage extends StatelessWidget {
  const PermissionDetailPage({
    super.key,
    required this.permissionId,
  });

  final String permissionId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PermissionBloc(
        repository: getIt<IamRepository>(),
      )..add(LoadPermissionDetail(permissionId)),
      child: const _PermissionDetailContent(),
    );
  }
}

class _PermissionDetailContent extends StatefulWidget {
  const _PermissionDetailContent();

  @override
  State<_PermissionDetailContent> createState() =>
      _PermissionDetailContentState();
}

class _PermissionDetailContentState extends State<_PermissionDetailContent> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<PermissionBloc, PermissionState>(
      listener: (context, state) {
        state.maybeWhen(
          updated: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Permission updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
            setState(() {
              _isEditing = false;
            });
          },
          deleted: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Permission deleted successfully'),
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
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Permission Details'),
          actions: [
            BlocBuilder<PermissionBloc, PermissionState>(
              builder: (context, state) {
                final permissionWidget = state.maybeWhen(
                  detailLoaded: (permission) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_isEditing)
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            setState(() {
                              _isEditing = true;
                            });
                            _formKey.currentState?.fields['resource']
                                ?.didChange(permission.resource);
                            _formKey.currentState?.fields['action']
                                ?.didChange(permission.action);
                            _formKey.currentState?.fields['description']
                                ?.didChange(permission.description ?? '');
                          },
                          tooltip: 'Edit Permission',
                        ),
                      if (_isEditing)
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _isEditing = false;
                            });
                          },
                          tooltip: 'Cancel',
                        ),
                      if (_isEditing)
                        IconButton(
                          icon: const Icon(Icons.save),
                          onPressed: () {
                            if (_formKey.currentState?.saveAndValidate() ??
                                false) {
                              final formData =
                                  _formKey.currentState!.value;
                              final dto = UpdatePermissionDto(
                                resource: formData['resource'] as String?,
                                action: formData['action'] as String?,
                                description:
                                    formData['description'] as String?,
                              );

                              context.read<PermissionBloc>().add(
                                    UpdatePermission(permission.id, dto),
                                  );
                            }
                          },
                          tooltip: 'Save',
                        ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'delete') {
                            _showDeleteConfirmation(context, permission.id);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete Permission'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  orElse: () => const SizedBox.shrink(),
                );
                return permissionWidget ?? const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocBuilder<PermissionBloc, PermissionState>(
          builder: (context, state) {
            return state.when(
              initial: () => const Center(
                child: CircularProgressIndicator(),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              detailLoaded: (permission) => SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_isEditing)
                      FormBuilder(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            FormBuilderTextField(
                              name: 'resource',
                              decoration: const InputDecoration(
                                labelText: 'Resource *',
                                hintText: 'e.g., service_request, user',
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
                                labelText: 'Action *',
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
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                              validator:
                                  FormBuilderValidators.maxLength(500),
                            ),
                          ],
                        ),
                      )
                    else
                      _PermissionInfoCard(permission: permission),
                  ],
                ),
              ),
              listLoaded: (_) => const SizedBox.shrink(),
              created: (_) => const SizedBox.shrink(),
              updated: (_) => const SizedBox.shrink(),
              deleted: () => const SizedBox.shrink(),
              error: (message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: $message',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final permissionId = state.maybeWhen(
                          detailLoaded: (p) => p.id,
                          orElse: () => null,
                        );
                        if (permissionId != null && permissionId.isNotEmpty) {
                          context.read<PermissionBloc>().add(
                                LoadPermissionDetail(permissionId),
                              );
                        }
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

  void _showDeleteConfirmation(BuildContext context, String permissionId) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Permission'),
        content: const Text(
          'Are you sure you want to delete this permission? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<PermissionBloc>().add(
                    DeletePermission(permissionId),
                  );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _PermissionInfoCard extends StatelessWidget {
  const _PermissionInfoCard({required this.permission});

  final PermissionEntity permission;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow(
              label: 'Permission',
              value: permission.permissionString,
            ),
            _InfoRow(label: 'Resource', value: permission.resource),
            _InfoRow(label: 'Action', value: permission.action),
            if (permission.description != null)
              _InfoRow(
                label: 'Description',
                value: permission.description!,
              ),
          ],
        ),
      ),
    );
  }

}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

