import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_client.dart';
import '../../data/repositories/department_repository.dart';
import '../bloc/department_bloc.dart';
import '../bloc/department_event.dart';
import '../bloc/department_state.dart';

class DepartmentListPage extends StatelessWidget {
  const DepartmentListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DepartmentBloc(
        repository: DepartmentRepository(
          apiClient: getIt<ApiClient>(),
        ),
      )..add(const LoadDepartmentList()),
      child: const _DepartmentListContent(),
    );
  }
}

class _DepartmentListContent extends StatelessWidget {
  const _DepartmentListContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Departments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/departments/create'),
            tooltip: 'Create Department',
          ),
        ],
      ),
      body: BlocConsumer<DepartmentBloc, DepartmentState>(
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
                  content: Text('Department created successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              context.read<DepartmentBloc>().add(const LoadDepartmentList());
            },
            updated: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Department updated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              context.read<DepartmentBloc>().add(const LoadDepartmentList());
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: Text('No departments loaded')),
            loading: () => const Center(child: CircularProgressIndicator()),
            listLoaded: (departments) {
              if (departments.isEmpty) {
                return const Center(
                  child: Text('No departments found'),
                );
              }
              return ListView.builder(
                itemCount: departments.length,
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  final department = departments[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: ListTile(
                      title: Text(department.name),
                      subtitle: department.description != null
                          ? Text(department.description!)
                          : null,
                      trailing: department.isActive
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.cancel, color: Colors.red),
                      onTap: () => context.push('/departments/${department.id}'),
                    ),
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
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading departments',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DepartmentBloc>().add(const LoadDepartmentList());
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

