import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../data/repositories/iam_repository.dart';
import '../../domain/entities/permission_entity.dart';
import '../bloc/permission/permission_bloc.dart';
import '../bloc/permission/permission_event.dart';
import '../bloc/permission/permission_state.dart';

class PermissionListPage extends StatelessWidget {
  const PermissionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PermissionBloc(
        repository: getIt<IamRepository>(),
      )..add(const LoadPermissionList()),
      child: const _PermissionListContent(),
    );
  }
}

class _PermissionListContent extends StatelessWidget {
  const _PermissionListContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permissions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/iam/permissions/create'),
            tooltip: 'Create Permission',
          ),
        ],
      ),
      body: BlocConsumer<PermissionBloc, PermissionState>(
        listener: (context, state) {
          state.maybeWhen(
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: Colors.red,
                ),
              );
            },
            created: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Permission created successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              context.pop();
              context.read<PermissionBloc>().add(const LoadPermissionList());
            },
            updated: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Permission updated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              context.read<PermissionBloc>().add(const LoadPermissionList());
            },
            deleted: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Permission deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              context.read<PermissionBloc>().add(const LoadPermissionList());
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            listLoaded: (permissions) {
              if (permissions.isEmpty) {
                return const Center(
                  child: Text('No permissions found'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: permissions.length,
                itemBuilder: (context, index) {
                  return _PermissionListItem(
                    permission: permissions[index],
                    onTap: () => context.push(
                      '/iam/permissions/${permissions[index].id}',
                    ),
                    onDelete: () {
                      _showDeleteConfirmation(
                        context,
                        permissions[index].id,
                      );
                    },
                  );
                },
              );
            },
            detailLoaded: (_) => const SizedBox.shrink(),
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
                      context.read<PermissionBloc>().add(
                            const LoadPermissionList(),
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
    );
  }
}

class _PermissionListItem extends StatelessWidget {
  const _PermissionListItem({
    required this.permission,
    this.onTap,
    this.onDelete,
  });

  final PermissionEntity permission;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(permission.permissionString),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resource: ${permission.resource}'),
            Text('Action: ${permission.action}'),
            if (permission.description != null)
              Text(permission.description!),
          ],
        ),
        isThreeLine: permission.description != null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
                tooltip: 'Delete',
              ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
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
            context.read<PermissionBloc>().add(DeletePermission(permissionId));
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}

