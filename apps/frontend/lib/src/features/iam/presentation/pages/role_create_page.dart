import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/permission_checker.dart';
import '../../data/dto/role_dto.dart';
import '../../data/repositories/iam_repository.dart';
import '../bloc/role/role_bloc.dart';
import '../bloc/role/role_event.dart';
import '../bloc/role/role_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../company/presentation/bloc/company_bloc.dart';
import '../../../company/presentation/bloc/company_event.dart';
import '../../../company/presentation/bloc/company_state.dart';
import '../../../company/data/repositories/company_repository.dart';

class RoleCreatePage extends StatelessWidget {
  const RoleCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => RoleBloc(
            repository: getIt<IamRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => CompanyBloc(
            repository: CompanyRepository(
              apiClient: getIt<ApiClient>(),
            ),
          )..add(const LoadCompanyList()),
        ),
      ],
      child: const _RoleCreateContent(),
    );
  }
}

class _RoleCreateContent extends StatefulWidget {
  const _RoleCreateContent();

  @override
  State<_RoleCreateContent> createState() => _RoleCreateContentState();
}

class _RoleCreateContentState extends State<_RoleCreateContent> {
  final formKey = GlobalKey<FormBuilderState>();
  String? _selectedCompanyId;

  @override
  void initState() {
    super.initState();
    // Check for companyId in query parameters
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final route = GoRouterState.of(context);
      final companyIdFromQuery = route.uri.queryParameters['companyId'];
      if (companyIdFromQuery != null) {
        setState(() {
          _selectedCompanyId = companyIdFromQuery;
        });
        // Pre-fill the form field if it exists
        formKey.currentState?.fields['companyId']?.didChange(companyIdFromQuery);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Role'),
      ),
      body: BlocListener<RoleBloc, RoleState>(
        listener: (context, state) {
          state.maybeWhen(
            created: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Role created successfully'),
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
                // Company dropdown (SUPER_ADMIN only)
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    final isSuperAdmin = authState.maybeWhen<bool>(
                          authenticated: (UserEntity user) =>
                              PermissionChecker.isSuperAdmin(user),
                          orElse: () => false,
                        ) ??
                        false;

                    if (!isSuperAdmin) {
                      return const SizedBox.shrink();
                    }

                    return BlocBuilder<CompanyBloc, CompanyState>(
                      builder: (context, companyState) {
                        if (companyState is CompanyListLoaded) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Company',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              FormBuilderDropdown<String>(
                                name: 'companyId',
                                initialValue: _selectedCompanyId,
                                decoration: const InputDecoration(
                                  labelText: 'Select Company',
                                  hintText: 'Select a company',
                                  border: OutlineInputBorder(),
                                ),
                                style: Theme.of(context).textTheme.bodyMedium,
                                items: companyState.companies
                                    .map(
                                      (company) => DropdownMenuItem(
                                        value: company.id,
                                        child: Text(company.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCompanyId = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 8),
                              // Quick action to create ADMIN role for selected company
                              if (_selectedCompanyId != null)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                        .withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.admin_panel_settings,
                                        color: Theme.of(context).colorScheme.primary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Quick Create ADMIN Role',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'As SUPER_ADMIN, you can create ADMIN roles for any company. Click to pre-fill ADMIN template.',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // Pre-fill form with ADMIN defaults
                                          formKey.currentState?.fields['name']
                                              ?.didChange('ADMIN');
                                          formKey.currentState
                                              ?.fields['description']
                                              ?.didChange(
                                                'Administrator with full system access',
                                              );
                                          formKey.currentState
                                              ?.fields['hierarchyLevel']
                                              ?.didChange('100');
                                        },
                                        child: const Text('Use ADMIN Template'),
                                      ),
                                    ],
                                  ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    );
                  },
                ),
                FormBuilderTextField(
                  name: 'name',
                  decoration: const InputDecoration(
                    labelText: 'Role Name',
                    hintText: 'Enter role name',
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
                    hintText: 'Enter role description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: FormBuilderValidators.maxLength(500),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'hierarchyLevel',
                  decoration: const InputDecoration(
                    labelText: 'Hierarchy Level',
                    hintText: 'Enter hierarchy level (0-100)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: '0',
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.integer(),
                    FormBuilderValidators.min(0),
                    FormBuilderValidators.max(100),
                  ]),
                ),
                const SizedBox(height: 24),
                BlocBuilder<RoleBloc, RoleState>(
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
                                final dto = CreateRoleDto(
                                  name: formData['name'] as String,
                                  description: formData['description'] as String?,
                                  hierarchyLevel: int.parse(
                                    formData['hierarchyLevel'] as String? ?? '0',
                                  ),
                                  companyId: formData['companyId'] as String?,
                                );

                                context.read<RoleBloc>().add(
                                      CreateRole(dto),
                                    );
                              }
                            },
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create Role'),
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

