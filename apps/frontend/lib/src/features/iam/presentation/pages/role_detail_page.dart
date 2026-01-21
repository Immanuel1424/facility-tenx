import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../data/dto/role_dto.dart';
import '../../data/repositories/iam_repository.dart';
import '../../domain/entities/role_entity.dart';
import '../bloc/permission/permission_bloc.dart';
import '../bloc/permission/permission_event.dart';
import '../bloc/permission/permission_state.dart';
import '../bloc/role/role_bloc.dart';
import '../bloc/role/role_event.dart';
import '../bloc/role/role_state.dart';

class RoleDetailPage extends StatelessWidget {
  const RoleDetailPage({
    super.key,
    required this.roleId,
  });

  final String roleId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RoleBloc>(
          create: (context) => RoleBloc(
            repository: getIt<IamRepository>(),
          )..add(LoadRoleDetail(roleId)),
        ),
        BlocProvider<PermissionBloc>(
          create: (context) => PermissionBloc(
            repository: getIt<IamRepository>(),
          )..add(const LoadPermissionList()),
        ),
      ],
      child: _RoleDetailContent(roleId: roleId),
    );
  }
}

class _RoleDetailContent extends StatefulWidget {
  const _RoleDetailContent({required this.roleId});

  final String roleId;

  @override
  State<_RoleDetailContent> createState() => _RoleDetailContentState();
}

class _RoleDetailContentState extends State<_RoleDetailContent> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<RoleBloc, RoleState>(
      listener: (context, state) {
        state.maybeWhen(
          updated: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Role updated successfully'),
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
                content: Text('Role deleted successfully'),
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
          title: const Text('Role Details'),
          actions: [
            BlocBuilder<RoleBloc, RoleState>(
              builder: (context, state) {
                final roleWidget = state.maybeWhen(
                  detailLoaded: (role) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_isEditing)
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            setState(() {
                              _isEditing = true;
                            });
                            _formKey.currentState?.fields['name']
                                ?.didChange(role.name);
                            _formKey.currentState?.fields['description']
                                ?.didChange(role.description ?? '');
                            _formKey.currentState?.fields['hierarchyLevel']
                                ?.didChange(role.hierarchyLevel.toString());
                          },
                          tooltip: 'Edit Role',
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
                              final dto = UpdateRoleDto(
                                name: formData['name'] as String?,
                                description:
                                    formData['description'] as String?,
                                hierarchyLevel: formData['hierarchyLevel'] !=
                                        null
                                    ? int.tryParse(
                                        formData['hierarchyLevel'] as String)
                                    : null,
                              );

                              context.read<RoleBloc>().add(
                                    UpdateRole(role.id, dto),
                                  );
                            }
                          },
                          tooltip: 'Save',
                        ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'delete') {
                            _showDeleteConfirmation(context, role.id);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete Role'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  orElse: () => const SizedBox.shrink(),
                );
                return roleWidget ?? const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocBuilder<RoleBloc, RoleState>(
          builder: (context, state) {
            return state.when(
              initial: () => const Center(
                child: CircularProgressIndicator(),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              detailLoaded: (role) => SingleChildScrollView(
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
                              name: 'name',
                              decoration: const InputDecoration(
                                labelText: 'Role Name *',
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
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                              validator:
                                  FormBuilderValidators.maxLength(500),
                            ),
                            const SizedBox(height: 16),
                            FormBuilderTextField(
                              name: 'hierarchyLevel',
                              decoration: const InputDecoration(
                                labelText: 'Hierarchy Level',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.integer(),
                                FormBuilderValidators.min(0),
                                FormBuilderValidators.max(100),
                              ]),
                            ),
                          ],
                        ),
                      )
                    else
                      _RoleInfoCard(role: role),
                    const SizedBox(height: 24),
                    _PermissionsSection(roleId: widget.roleId),
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
                        context.read<RoleBloc>().add(
                              LoadRoleDetail(widget.roleId),
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

  void _showDeleteConfirmation(BuildContext context, String roleId) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Role'),
        content: const Text(
          'Are you sure you want to delete this role? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<RoleBloc>().add(DeleteRole(roleId));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _RoleInfoCard extends StatelessWidget {
  const _RoleInfoCard({required this.role});

  final RoleEntity role;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow(label: 'Name', value: role.name),
            if (role.description != null)
              _InfoRow(label: 'Description', value: role.description!),
            _InfoRow(
              label: 'Hierarchy Level',
              value: role.hierarchyLevel.toString(),
            ),
            if (role.parentRoleId != null)
              _InfoRow(
                label: 'Parent Role ID',
                value: role.parentRoleId!,
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

class _PermissionsSection extends StatelessWidget {
  const _PermissionsSection({required this.roleId});

  final String roleId;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Permissions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showAssignPermissionDialog(context),
                  tooltip: 'Assign Permission',
                ),
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<PermissionBloc, PermissionState>(
              builder: (context, permissionState) {
                final currentRoleId = roleId;
                final permissionsWidget = permissionState.maybeWhen(
                  listLoaded: (permissions) {
                    // TODO: Show assigned permissions for this role
                    // For now, show all permissions with assign button
                    if (permissions.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No permissions available'),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: permissions.length,
                      itemBuilder: (context, index) {
                        final permission = permissions[index];
                        return ListTile(
                          title: Text(permission.permissionString),
                          subtitle: permission.description != null
                              ? Text(permission.description!)
                              : null,
                          trailing: IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              context.read<RoleBloc>().add(
                                    AssignPermissionToRole(
                                      currentRoleId,
                                      permission.id,
                                    ),
                                  );
                            },
                            tooltip: 'Assign Permission',
                          ),
                        );
                      },
                    );
                  },
                  orElse: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
                return permissionsWidget ?? const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignPermissionDialog(BuildContext context) {
    // This could show a dialog to select and assign permissions
    // For now, permissions can be assigned via the list items
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Click the + icon next to a permission to assign it'),
      ),
    );
  }
}

