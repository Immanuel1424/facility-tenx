import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../data/repositories/iam_repository.dart';
import '../../domain/entities/role_entity.dart';
import '../bloc/role/role_bloc.dart';
import '../bloc/role/role_event.dart';
import '../bloc/role/role_state.dart';

class RoleListPage extends StatelessWidget {
  const RoleListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RoleBloc(
        repository: getIt<IamRepository>(),
      )..add(const LoadRoleList()),
      child: const _RoleListContent(),
    );
  }
}

class _RoleListContent extends StatelessWidget {
  const _RoleListContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/iam/roles/create'),
            tooltip: 'Create Role',
          ),
        ],
      ),
      body: BlocConsumer<RoleBloc, RoleState>(
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
                  content: Text('Role created successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              context.pop();
              context.read<RoleBloc>().add(const LoadRoleList());
            },
            updated: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Role updated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              context.read<RoleBloc>().add(const LoadRoleList());
            },
            deleted: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Role deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              context.read<RoleBloc>().add(const LoadRoleList());
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            listLoaded: (roles) {
              if (roles.isEmpty) {
                return const Center(
                  child: Text('No roles found'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: roles.length,
                itemBuilder: (context, index) {
                  return _RoleListItem(
                    role: roles[index],
                    onTap: () => context.push('/iam/roles/${roles[index].id}'),
                    onDelete: () {
                      _showDeleteConfirmation(context, roles[index].id);
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
                      context.read<RoleBloc>().add(const LoadRoleList());
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

class _RoleListItem extends StatelessWidget {
  const _RoleListItem({
    required this.role,
    this.onTap,
    this.onDelete,
  });

  final RoleEntity role;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(role.name),
        subtitle: role.description != null
            ? Text(role.description!)
            : Text('Level: ${role.hierarchyLevel}'),
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

