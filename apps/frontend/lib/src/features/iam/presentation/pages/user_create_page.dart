import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/presentation/widgets/multi_select_dropdown.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/permission_checker.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../department/data/repositories/department_repository.dart';
import '../../../department/domain/entities/department_entity.dart';
import '../../../department/presentation/bloc/department_bloc.dart';
import '../../../department/presentation/bloc/department_event.dart';
import '../../../department/presentation/bloc/department_state.dart';
import '../../../villa/data/repositories/villa_repository.dart';
import '../../../villa/domain/entities/villa_entity.dart';
import '../../../villa/presentation/bloc/villa_bloc.dart';
import '../../../villa/presentation/bloc/villa_event.dart';
import '../../../villa/presentation/bloc/villa_state.dart';
import '../../../company/presentation/bloc/company_bloc.dart';
import '../../../company/presentation/bloc/company_event.dart';
import '../../../company/presentation/bloc/company_state.dart';
import '../../../company/data/repositories/company_repository.dart';
import '../../data/repositories/iam_repository.dart';
import '../../domain/entities/role_entity.dart';
import '../bloc/role/role_bloc.dart';
import '../bloc/role/role_event.dart';
import '../bloc/role/role_state.dart';
import '../bloc/user/user_bloc.dart';
import '../bloc/user/user_event.dart';
import '../bloc/user/user_state.dart';

class UserCreatePage extends StatelessWidget {
  const UserCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => UserBloc(
            repository: getIt<IamRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => RoleBloc(
            repository: getIt<IamRepository>(),
          )..add(const LoadRoleList()),
        ),
        BlocProvider(
          create: (context) => DepartmentBloc(
            repository: DepartmentRepository(
              apiClient: getIt<ApiClient>(),
            ),
          )..add(const LoadDepartmentList()),
        ),
        BlocProvider(
          create: (context) => VillaBloc(
            repository: VillaRepository(
              apiClient: getIt<ApiClient>(),
            ),
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
      child: const UserCreateFormContent(),
    );
  }
}

/// Dialog version for web - shows as modal dialog
class UserCreateDialog extends StatelessWidget {
  const UserCreateDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => UserBloc(
              repository: getIt<IamRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => RoleBloc(
              repository: getIt<IamRepository>(),
            )..add(const LoadRoleList()),
          ),
          BlocProvider(
            create: (context) => DepartmentBloc(
              repository: DepartmentRepository(
                apiClient: getIt<ApiClient>(),
              ),
            )..add(const LoadDepartmentList()),
          ),
          BlocProvider(
            create: (context) => VillaBloc(
              repository: VillaRepository(
                apiClient: getIt<ApiClient>(),
              ),
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
        child: const UserCreateDialog(),
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
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isWeb ? 900 : double.infinity,
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
                    Icons.person_add,
                    color: theme.colorScheme.onPrimary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Create User',
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
              child: BlocListener<UserBloc, UserState>(
                listener: (context, state) {
                  state.maybeWhen(
                    created: (user) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('User created successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.of(context).pop(true);
                    },
                    error: (message) {
                      String displayMessage = message;
                      if (message.toLowerCase().contains('villa number') &&
                          message.toLowerCase().contains('already assigned')) {
                        displayMessage =
                            'Villa assignment conflict: $message\n\nPlease refresh the villa list and select a different villa.';
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(displayMessage),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 5),
                        ),
                      );
                    },
                    orElse: () {},
                  );
                },
                child: const UserCreateFormContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable form content widget that can be used in both page and dialog
class UserCreateFormContent extends StatefulWidget {
  const UserCreateFormContent({super.key});

  @override
  State<UserCreateFormContent> createState() => _UserCreateContentState();
}

class _UserCreateContentState extends State<UserCreateFormContent> {
  final _formKey = GlobalKey<FormBuilderState>();
  String? _selectedRoleId;
  String?
      _clearedRoleName; // Track role name when cleared due to company change
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _autoGeneratePassword = false;
  bool _sendCredentialsViaEmail = false;
  String? _generatedPassword;
  bool _credentialsSentViaEmail = false;

  /// Format role name from UPPER_CASE_WITH_UNDERSCORES to Title Case
  String _formatRoleName(String roleName) {
    return roleName
        .split('_')
        .map((word) => word.isEmpty
            ? ''
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
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

  // Expose private fields for dialog access
  String? get generatedPassword => _generatedPassword;
  bool get credentialsSentViaEmail => _credentialsSentViaEmail;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        final formState = _formKey.currentState;
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
            // Pop with refresh flag to trigger list reload
            context.pop(true);
          }
        } else {
          if (context.mounted) {
            // Pop with refresh flag to trigger list reload
            context.pop(true);
          }
        }
      },
      child: Scaffold(
        body: BlocListener<UserBloc, UserState>(
          listener: (context, state) {
            state.maybeWhen(
              created: (user) {
                // Show generated password dialog only if:
                // 1. Password was auto-generated AND
                // 2. Email was NOT sent (credentials were not sent via email)
                if (_generatedPassword != null && !_credentialsSentViaEmail) {
                  _showGeneratedPasswordDialog(
                    context,
                    user.email,
                    _generatedPassword!,
                  );
                } else {
                  // Show success message
                  final message = _credentialsSentViaEmail
                      ? 'User created successfully. Credentials have been sent via email.'
                      : 'User created successfully';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Pop with refresh flag to trigger list reload
                  context.pop(true);
                }
              },
              error: (message) {
                // Enhanced error handling for villa assignment conflicts
                String displayMessage = message;
                if (message.toLowerCase().contains('villa number') &&
                    message.toLowerCase().contains('already assigned')) {
                  displayMessage =
                      'Villa assignment conflict: $message\n\nPlease refresh the villa list and select a different villa.';
                  // Optionally refresh villa list on this error
                  context.read<VillaBloc>().add(const LoadActiveVillaList());
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(displayMessage),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 5),
                  ),
                );
              },
              orElse: () {},
            );
          },
          child: ResponsiveLayout(
            mobileBreakpoint: 768.0,
            mobileBuilder: (context) => _buildForm(context, isMobile: true),
            desktopBuilder: (context) => _buildForm(context, isMobile: false),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, {required bool isMobile}) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: FormBuilder(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: BlocBuilder<RoleBloc, RoleState>(
          builder: (context, roleState) {
            // Check if current user is admin
            final authState = context.read<AuthBloc>().state;
            final isCurrentUserAdmin = authState.maybeWhen<bool>(
                  authenticated: (user) => PermissionChecker.isAdmin(user),
                  orElse: () => false,
                ) ??
                false;

            // Determine visibility based on selected role
            bool isTenant = false;
            bool isTechnicianOrSupervisor = false;
            bool isCoordinator = false;

            if (roleState is RoleListLoaded && _selectedRoleId != null) {
              final selectedRole = roleState.roles.firstWhere(
                (r) => r.id == _selectedRoleId,
                orElse: () => const RoleEntity(id: '', name: '', companyId: ''),
              );

              final roleName = selectedRole.name.toUpperCase();
              isTenant = roleName == 'TENANT';
              isTechnicianOrSupervisor =
                  roleName.contains('TECHNICIAN') || roleName == 'SUPERVISOR';
              isCoordinator = roleName == 'SITE_COORDINATOR';
            }

            return isMobile
                ? _buildMobileForm(
                    context,
                    roleState,
                    isTenant,
                    isTechnicianOrSupervisor,
                    isCoordinator,
                    isCurrentUserAdmin,
                  )
                : _buildDesktopForm(
                    context,
                    roleState,
                    isTenant,
                    isTechnicianOrSupervisor,
                    isCoordinator,
                    isCurrentUserAdmin,
                  );
          },
        ),
      ),
    );
  }

  Widget _buildMobileForm(
    BuildContext context,
    RoleState roleState,
    bool isTenant,
    bool isTechnicianOrSupervisor,
    bool isCoordinator,
    bool isCurrentUserAdmin,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFieldLabel('Role', isRequired: true),
        _buildRoleDropdown(context, roleState),
        const SizedBox(height: 16),

        // Dynamic Fields - Tenant
        if (isTenant) ...[
          BlocBuilder<VillaBloc, VillaState>(
            builder: (context, villaState) {
              // Load available villas when tenant role is selected
              if (villaState is! VillaListLoaded &&
                  villaState is! VillaLoading) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    context
                        .read<VillaBloc>()
                        .add(const LoadAvailableVillaList());
                  }
                });
              }

              if (villaState is VillaListLoaded) {
                // Use the villas directly (already filtered by backend to be available)
                final availableVillas = villaState.villas;

                if (availableVillas.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No available villas. All villas are currently occupied.',
                            style: TextStyle(color: Colors.orange.shade900),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Villa Numbers', isRequired: true),
                    MultiSelectDropdown<String>(
                      name: 'villaNumbers',
                      decoration: const InputDecoration(
                        labelText: 'Select Villas',
                        border: OutlineInputBorder(),
                      ),
                      items: availableVillas.map((v) => v.villaNumber).toList(),
                      itemAsString: (String villaNumber) {
                        final villa = availableVillas.firstWhere(
                          (v) => v.villaNumber == villaNumber,
                          orElse: () => VillaEntity(
                            id: '',
                            villaNumber: '',
                            isActive: false,
                            isOccupied: false,
                            companyId: '',
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          ),
                        );
                        return 'Villa ${villa.villaNumber} - ${villa.tenantName ?? "Vacant"}';
                      },
                      validator: FormBuilderValidators.required(
                        errorText: 'Please select at least one villa',
                      ),
                    ),
                  ],
                );
              } else if (villaState is VillaLoading) {
                return const LinearProgressIndicator();
              }
              // Fallback if loading fails or initial
              return FormBuilderTextField(
                name: 'villaNumber',
                decoration: const InputDecoration(
                  labelText: 'Villa Number',
                  hintText: 'Enter villa number (e.g., 101)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'Villa number is required',
                  ),
                  FormBuilderValidators.numeric(
                    errorText: 'Villa number must be a number',
                  ),
                  FormBuilderValidators.min(
                    1,
                    errorText: 'Villa number must be greater than 0',
                  ),
                ]),
              );
            },
          ),
          const SizedBox(height: 16),
        ],

        // Dynamic Fields - Technician/Supervisor/Coordinator
        if (isTechnicianOrSupervisor || isCoordinator) ...[
          BlocBuilder<DepartmentBloc, DepartmentState>(
            builder: (context, deptState) {
              if (deptState is DepartmentListLoaded) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Department', isRequired: true),
                    FormBuilderDropdown<String>(
                      name: 'departmentId',
                      decoration: const InputDecoration(
                        labelText: 'Select Department',
                        hintText: 'Select a department',
                        border: OutlineInputBorder(),
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                      validator: FormBuilderValidators.required(
                        errorText: 'Please select a department',
                      ),
                      items: deptState.departments
                          .map(
                            (DepartmentEntity dept) => DropdownMenuItem(
                              value: dept.id,
                              child: Text(dept.name),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'leaseExpiryDate',
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Lease Expiry Date',
                        hintText: 'Select date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 3650)),
                        );
                        if (picked != null) {
                          _formKey.currentState?.fields['leaseExpiryDate']
                              ?.didChange(
                            picked.toIso8601String(),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Employee ID
                    _buildFieldLabel('Employee ID'),
                    FormBuilderTextField(
                      name: 'employeeId',
                      decoration: const InputDecoration(
                        hintText: 'Enter employee ID',
                        border: OutlineInputBorder(),
                      ),
                      validator: FormBuilderValidators.maxLength(50),
                    ),
                    const SizedBox(height: 16),
                    // Designation/Job Title
                    _buildFieldLabel('Designation / Job Title'),
                    FormBuilderTextField(
                      name: 'designation',
                      decoration: const InputDecoration(
                        hintText: 'Enter job title',
                        border: OutlineInputBorder(),
                      ),
                      validator: FormBuilderValidators.maxLength(100),
                    ),
                    const SizedBox(height: 16),
                    // Joining Date
                    _buildFieldLabel('Joining Date'),
                    FormBuilderTextField(
                      name: 'joiningDate',
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Joining Date',
                        hintText: 'Select date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          _formKey.currentState?.fields['joiningDate']
                              ?.didChange(
                            picked.toIso8601String(),
                          );
                        }
                      },
                    ),
                  ],
                );
              } else if (deptState is DepartmentLoading) {
                return const LinearProgressIndicator();
              }
              return Container();
            },
          ),
          const SizedBox(height: 16),
        ],

        _buildFieldLabel('First Name', isRequired: true),
        FormBuilderTextField(
          name: 'firstName',
          decoration: const InputDecoration(
            hintText: 'Enter first name',
            border: OutlineInputBorder(),
          ),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(
              errorText: 'First name is required',
            ),
            FormBuilderValidators.maxLength(
              100,
              errorText: 'First name must be 100 characters or less',
            ),
          ]),
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Last Name'),
        FormBuilderTextField(
          name: 'lastName',
          decoration: const InputDecoration(
            hintText: 'Enter last name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Email', isRequired: true),
        FormBuilderTextField(
          name: 'email',
          decoration: const InputDecoration(
            hintText: 'Enter email address',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(
              errorText: 'Email is required',
            ),
            FormBuilderValidators.email(
              errorText: 'Please enter a valid email address',
            ),
          ]),
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Phone Number', isRequired: true),
        FormBuilderTextField(
          name: 'phoneNumber',
          decoration: const InputDecoration(
            hintText: 'Enter phone number',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(
              errorText: 'Phone number is required',
            ),
            FormBuilderValidators.numeric(
              errorText: 'Phone number must contain only numbers',
            ),
            FormBuilderValidators.maxLength(
              15,
              errorText: 'Phone number must be 15 digits or less',
            ),
          ]),
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Alternate Phone Number (Optional)'),
        FormBuilderTextField(
          name: 'alternatePhoneNumber',
          decoration: const InputDecoration(
            hintText: 'Enter alternate phone number (optional)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),

        // Emergency Contact (for internal staff - technician/supervisor/coordinator)
        if (isTechnicianOrSupervisor || isCoordinator) ...[
          _buildFieldLabel('Emergency Contact Name'),
          FormBuilderTextField(
            name: 'emergencyContactName',
            decoration: const InputDecoration(
              hintText: 'Enter emergency contact name',
              border: OutlineInputBorder(),
            ),
            validator: FormBuilderValidators.maxLength(
              100,
              errorText: 'Contact name must be 100 characters or less',
            ),
          ),
          const SizedBox(height: 16),
          _buildFieldLabel('Emergency Contact Phone'),
          FormBuilderTextField(
            name: 'emergencyContactPhone',
            decoration: const InputDecoration(
              hintText: 'Enter emergency contact phone',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.numeric(
                errorText: 'Phone number must contain only numbers',
              ),
              FormBuilderValidators.maxLength(
                20,
                errorText: 'Phone number must be 20 digits or less',
              ),
            ]),
          ),
          const SizedBox(height: 16),
        ],

        if (!_autoGeneratePassword) ...[
          _buildFieldLabel('Password', isRequired: true),
          FormBuilderTextField(
            name: 'password',
            decoration: InputDecoration(
              hintText: 'Enter password',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            obscureText: _obscurePassword,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(
                errorText: 'Password is required',
              ),
              FormBuilderValidators.minLength(
                8,
                errorText: 'Password must be at least 8 characters',
              ),
            ]),
          ),
          const SizedBox(height: 16),
          _buildFieldLabel('Confirm Password', isRequired: true),
          FormBuilderTextField(
            name: 'confirmPassword',
            decoration: InputDecoration(
              hintText: 'Re-enter password',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
            obscureText: _obscureConfirmPassword,
            validator: (value) {
              if (value != _formKey.currentState?.fields['password']?.value) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'A secure password will be automatically generated for this user.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        FormBuilderCheckbox(
          name: 'sendCredentialsViaEmail',
          title: const Text('Send credentials via email'),
          initialValue: _sendCredentialsViaEmail,
          onChanged: (value) {
            setState(() {
              _sendCredentialsViaEmail = value ?? false;
            });
          },
        ),
        const SizedBox(height: 24),
        _buildSubmitButton(context),
      ],
    );
  }

  Widget _buildDesktopForm(
    BuildContext context,
    RoleState roleState,
    bool isTenant,
    bool isTechnicianOrSupervisor,
    bool isCoordinator,
    bool isCurrentUserAdmin,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // First row: Role
        _buildFieldLabel('Role', isRequired: true),
        _buildRoleDropdown(context, roleState),
        const SizedBox(height: 16),

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
                      _buildFieldLabel('Company'),
                      FormBuilderDropdown<String>(
                        name: 'companyId',
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
                          // Trigger role reload for the selected company
                          context
                              .read<RoleBloc>()
                              .add(LoadRoleList(companyId: value));

                          // No setState needed - BlocListener will handle updates
                        },
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

        // Dynamic Fields - Tenant
        if (isTenant) ...[
          BlocBuilder<VillaBloc, VillaState>(
            builder: (context, villaState) {
              // Load available villas when tenant role is selected
              if (villaState is! VillaListLoaded &&
                  villaState is! VillaLoading) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    context
                        .read<VillaBloc>()
                        .add(const LoadAvailableVillaList());
                  }
                });
              }

              if (villaState is VillaListLoaded) {
                // Use the villas directly (already filtered by backend to be available)
                final availableVillas = villaState.villas;

                if (availableVillas.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No available villas. All villas are currently occupied.',
                            style: TextStyle(color: Colors.orange.shade900),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Villa Numbers', isRequired: true),
                    MultiSelectDropdown<String>(
                      name: 'villaNumbers',
                      decoration: const InputDecoration(
                        labelText: 'Select Villas',
                        border: OutlineInputBorder(),
                      ),
                      items: availableVillas.map((v) => v.villaNumber).toList(),
                      itemAsString: (String villaNumber) {
                        final villa = availableVillas.firstWhere(
                          (v) => v.villaNumber == villaNumber,
                          orElse: () => VillaEntity(
                            id: '',
                            villaNumber: '',
                            isActive: false,
                            isOccupied: false,
                            companyId: '',
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          ),
                        );
                        return 'Villa ${villa.villaNumber} - ${villa.tenantName ?? "Vacant"}';
                      },
                      validator: FormBuilderValidators.required(
                        errorText: 'Please select at least one villa',
                      ),
                    ),
                  ],
                );
              } else if (villaState is VillaLoading) {
                return const LinearProgressIndicator();
              }
              // Fallback if loading fails or initial
              return FormBuilderTextField(
                name: 'villaNumber',
                decoration: const InputDecoration(
                  labelText: 'Villa Number',
                  hintText: 'Enter villa number (e.g., 101)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'Villa number is required',
                  ),
                  FormBuilderValidators.numeric(
                    errorText: 'Villa number must be a number',
                  ),
                  FormBuilderValidators.min(
                    1,
                    errorText: 'Villa number must be greater than 0',
                  ),
                ]),
              );
            },
          ),
          const SizedBox(height: 16),
        ],

        // Dynamic Fields - Technician/Supervisor/Coordinator
        if (isTechnicianOrSupervisor || isCoordinator) ...[
          BlocBuilder<DepartmentBloc, DepartmentState>(
            builder: (context, deptState) {
              if (deptState is DepartmentListLoaded) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Department', isRequired: true),
                    FormBuilderDropdown<String>(
                      name: 'departmentId',
                      decoration: const InputDecoration(
                        labelText: 'Select Department',
                        hintText: 'Select a department',
                        border: OutlineInputBorder(),
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                      validator: FormBuilderValidators.required(
                        errorText: 'Please select a department',
                      ),
                      items: deptState.departments
                          .map(
                            (DepartmentEntity dept) => DropdownMenuItem(
                              value: dept.id,
                              child: Text(dept.name),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'leaseExpiryDate',
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Lease Expiry Date',
                        hintText: 'Select date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 3650)),
                        );
                        if (picked != null) {
                          _formKey.currentState?.fields['leaseExpiryDate']
                              ?.didChange(
                            picked.toIso8601String(),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Employee ID
                    _buildFieldLabel('Employee ID'),
                    FormBuilderTextField(
                      name: 'employeeId',
                      decoration: const InputDecoration(
                        hintText: 'Enter employee ID',
                        border: OutlineInputBorder(),
                      ),
                      validator: FormBuilderValidators.maxLength(50),
                    ),
                    const SizedBox(height: 16),
                    // Designation/Job Title
                    _buildFieldLabel('Designation / Job Title'),
                    FormBuilderTextField(
                      name: 'designation',
                      decoration: const InputDecoration(
                        hintText: 'Enter job title',
                        border: OutlineInputBorder(),
                      ),
                      validator: FormBuilderValidators.maxLength(100),
                    ),
                    const SizedBox(height: 16),
                    // Joining Date
                    _buildFieldLabel('Joining Date'),
                    FormBuilderTextField(
                      name: 'joiningDate',
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Joining Date',
                        hintText: 'Select date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          _formKey.currentState?.fields['joiningDate']
                              ?.didChange(
                            picked.toIso8601String(),
                          );
                        }
                      },
                    ),
                  ],
                );
              } else if (deptState is DepartmentLoading) {
                return const LinearProgressIndicator();
              }
              return Container();
            },
          ),
          const SizedBox(height: 16),
        ],

        // Second row: First Name, Last Name, Email (3 columns)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('First Name', isRequired: true),
                  FormBuilderTextField(
                    name: 'firstName',
                    decoration: const InputDecoration(
                      hintText: 'Enter first name',
                      border: OutlineInputBorder(),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                        errorText: 'First name is required',
                      ),
                      FormBuilderValidators.maxLength(
                        100,
                        errorText: 'First name must be 100 characters or less',
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Last Name'),
                  FormBuilderTextField(
                    name: 'lastName',
                    decoration: const InputDecoration(
                      hintText: 'Enter last name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Email', isRequired: true),
                  FormBuilderTextField(
                    name: 'email',
                    decoration: const InputDecoration(
                      hintText: 'Enter email address',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.email(),
                    ]),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Emergency Contact and Notes row (for internal staff)
        if (isTechnicianOrSupervisor || isCoordinator) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Emergency Contact Name'),
                    FormBuilderTextField(
                      name: 'emergencyContactName',
                      decoration: const InputDecoration(
                        hintText: 'Enter emergency contact name',
                        border: OutlineInputBorder(),
                      ),
                      validator: FormBuilderValidators.maxLength(
                        100,
                        errorText:
                            'Contact name must be 100 characters or less',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Emergency Contact Phone'),
                    FormBuilderTextField(
                      name: 'emergencyContactPhone',
                      decoration: const InputDecoration(
                        hintText: 'Enter emergency contact phone',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.numeric(
                          errorText: 'Phone number must contain only numbers',
                        ),
                        FormBuilderValidators.maxLength(
                          20,
                          errorText: 'Phone number must be 20 digits or less',
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Third row: Phone Number, Alternate Phone Number (2 columns)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Phone Number', isRequired: true),
                  FormBuilderTextField(
                    name: 'phoneNumber',
                    decoration: const InputDecoration(
                      hintText: 'Enter phone number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                        errorText: 'Phone number is required',
                      ),
                      FormBuilderValidators.numeric(
                        errorText: 'Phone number must contain only numbers',
                      ),
                      FormBuilderValidators.maxLength(
                        15,
                        errorText: 'Phone number must be 15 digits or less',
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Alternate Phone Number (Optional)'),
                  FormBuilderTextField(
                    name: 'alternatePhoneNumber',
                    decoration: const InputDecoration(
                      hintText: 'Enter alternate phone number (optional)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Password section
        FormBuilderCheckbox(
          name: 'autoGeneratePassword',
          title: const Text('Auto-generate secure password'),
          initialValue: _autoGeneratePassword,
          onChanged: (value) {
            setState(() {
              _autoGeneratePassword = value ?? false;
              if (_autoGeneratePassword) {
                // Clear password fields when auto-generate is enabled
                _formKey.currentState?.fields['password']?.didChange(null);
                _formKey.currentState?.fields['confirmPassword']
                    ?.didChange(null);
              }
            });
          },
        ),
        const SizedBox(height: 16),
        if (!_autoGeneratePassword) ...[
          // Password row: Password, Confirm Password (2 columns)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Password', isRequired: true),
                    FormBuilderTextField(
                      name: 'password',
                      decoration: InputDecoration(
                        hintText: 'Enter password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscurePassword,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(
                          errorText: 'Password is required',
                        ),
                        FormBuilderValidators.minLength(
                          8,
                          errorText: 'Password must be at least 8 characters',
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Confirm Password', isRequired: true),
                    FormBuilderTextField(
                      name: 'confirmPassword',
                      decoration: InputDecoration(
                        hintText: 'Re-enter password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscureConfirmPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value !=
                            _formKey.currentState?.fields['password']?.value) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'A secure password will be automatically generated for this user.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        // Options row: 3 columns layout
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FormBuilderCheckbox(
                name: 'sendCredentialsViaEmail',
                title: const Text('Send credentials via email'),
                initialValue: _sendCredentialsViaEmail,
                onChanged: (value) {
                  setState(() {
                    _sendCredentialsViaEmail = value ?? false;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(child: SizedBox()), // Empty second column
            const SizedBox(width: 16),
            const Expanded(child: SizedBox()), // Empty third column
          ],
        ),
        const SizedBox(height: 24),
        _buildSubmitButton(context),
      ],
    );
  }

  Widget _buildRoleDropdown(BuildContext context, RoleState roleState) {
    if (roleState is RoleListLoaded) {
      // Check if current user is SUPER_ADMIN
      final authState = context.read<AuthBloc>().state;
      final isSuperAdmin = authState.maybeWhen<bool>(
            authenticated: (UserEntity user) =>
                PermissionChecker.isSuperAdmin(user),
            orElse: () => false,
          ) ??
          false;

      // Get selected companyId from form (for SUPER_ADMIN)
      // Use a ValueListenableBuilder to rebuild when company field changes
      final companyField = _formKey.currentState?.fields['companyId'];
      final selectedCompanyId = companyField?.value as String?;

      // Filter roles by selected company (if company is selected)
      final roles = selectedCompanyId != null && selectedCompanyId.isNotEmpty
          ? roleState.roles
              .where((role) => role.companyId == selectedCompanyId)
              .toList()
          : roleState.roles;

      // Check if currently selected role belongs to the selected company
      bool isSelectedRoleValid = true;
      if (_selectedRoleId != null && selectedCompanyId != null) {
        final selectedRole = roleState.roles.firstWhere(
          (r) => r.id == _selectedRoleId,
          orElse: () => const RoleEntity(id: '', name: '', companyId: ''),
        );
        isSelectedRoleValid = selectedRole.companyId == selectedCompanyId;

        // Only clear if role doesn't belong to selected company
        if (!isSelectedRoleValid && selectedRole.id.isNotEmpty) {
          final clearedRoleName = _formatRoleName(selectedRole.name);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _selectedRoleId = null;
                _clearedRoleName = clearedRoleName; // Store for UI display
                _formKey.currentState?.fields['roleId']?.didChange(null);
              });
              // Show user-friendly feedback explaining why role was cleared
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Role "$clearedRoleName" was cleared because it belongs to a different company. Please select a role for the selected company.',
                  ),
                  backgroundColor: Colors.orange.shade700,
                  duration: const Duration(seconds: 4),
                  action: SnackBarAction(
                    label: 'OK',
                    textColor: Colors.white,
                    onPressed: () {},
                  ),
                ),
              );
            }
          });
        } else if (isSelectedRoleValid) {
          // Clear the cleared role name if a valid role is selected
          _clearedRoleName = null;
        }
      } else if (_selectedRoleId == null && _clearedRoleName != null) {
        // Keep cleared role name visible until user selects a new role
      }

      // Use the selected role ID only if it's valid for the current company
      final effectiveRoleId = isSelectedRoleValid ? _selectedRoleId : null;

      // For SUPER_ADMIN: Allow creating users without roles, show helpful message
      if (selectedCompanyId != null && roles.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: null,
              decoration: InputDecoration(
                labelText: 'Role (Optional)',
                hintText: isSuperAdmin
                    ? 'No roles available - you can create user without role'
                    : 'No roles available',
                border: const OutlineInputBorder(),
                helperText: isSuperAdmin
                    ? 'As SUPER_ADMIN, you can create users without roles. Role can be assigned later.'
                    : 'No roles available for selected company',
              ),
              style: Theme.of(context).textTheme.bodyMedium,
              items: const [],
              onChanged: isSuperAdmin ? (value) {} : null,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSuperAdmin
                    ? Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.3)
                    : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSuperAdmin
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                      : Colors.orange.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isSuperAdmin
                            ? Icons.admin_panel_settings
                            : Icons.info_outline,
                        color: isSuperAdmin
                            ? Theme.of(context).colorScheme.primary
                            : Colors.orange.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isSuperAdmin
                                  ? 'No roles found for this company.'
                                  : 'No roles found for this company.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSuperAdmin
                                    ? Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                    : Colors.orange.shade900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isSuperAdmin
                                  ? 'You can create the user without a role now, and assign a role later. Or create an ADMIN role first using the button below.'
                                  : 'Please create roles for this company first: IAM → Roles → Create Role (select the company).',
                              style: TextStyle(
                                fontSize: 12,
                                color: isSuperAdmin
                                    ? Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                    : Colors.orange.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (isSuperAdmin) ...[
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to role creation page with company pre-selected
                        context.push(
                            '/iam/roles/create?companyId=$selectedCompanyId');
                      },
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text('Create ADMIN Role for This Company'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      }

      return DropdownButtonFormField<String>(
        value: effectiveRoleId,
        decoration: InputDecoration(
          labelText: 'Role',
          hintText:
              roles.isEmpty ? 'No roles for selected company' : 'Select a role',
          border: const OutlineInputBorder(),
          helperText: _clearedRoleName != null
              ? 'Previous role "$_clearedRoleName" was cleared - it belongs to a different company'
              : null,
          helperMaxLines: 2,
        ),
        style: Theme.of(context).textTheme.bodyMedium,
        items: roles
            .map(
              (RoleEntity role) => DropdownMenuItem(
                value: role.id,
                child: Text(_formatRoleName(role.name)),
              ),
            )
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedRoleId = value;
            _clearedRoleName =
                null; // Clear the cleared role name when new role is selected
            // Clear conditional fields when role changes
            _formKey.currentState?.fields['villaNumbers']?.didChange(null);
            _formKey.currentState?.fields['villaNumber']?.didChange(null);
            _formKey.currentState?.fields['departmentId']?.didChange(null);
          });
        },
      );
    } else if (roleState is RoleLoading) {
      return TextFormField(
        enabled: false,
        decoration: const InputDecoration(
          labelText: 'Role',
          hintText: 'Loading roles...',
          border: OutlineInputBorder(),
          suffixIcon: SizedBox(
            width: 20,
            height: 20,
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      );
    } else if (roleState is RoleError) {
      return TextFormField(
        enabled: false,
        decoration: InputDecoration(
          labelText: 'Role',
          hintText: 'Error loading roles',
          border: const OutlineInputBorder(),
          errorText: roleState.message,
        ),
      );
    }
    return TextFormField(
      enabled: false,
      decoration: const InputDecoration(
        labelText: 'Role',
        hintText: 'No roles available',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        return ElevatedButton(
          onPressed: isLoading
              ? null
              : () {
                  if (_formKey.currentState?.saveAndValidate() ?? false) {
                    final formData = _formKey.currentState!.value;

                    // Generate password if auto-generate is enabled
                    String password;
                    final sendEmail =
                        formData['sendCredentialsViaEmail'] as bool? ?? false;

                    if (_autoGeneratePassword ||
                        formData['autoGeneratePassword'] == true) {
                      password = _generateSecurePassword();
                      _generatedPassword = password;
                    } else {
                      password = formData['password'] as String;
                      _generatedPassword = null;
                    }

                    // Track if credentials were sent via email
                    _credentialsSentViaEmail = sendEmail;

                    // Parse villa numbers
                    List<String>? villaNumbers;
                    final rawVillas = formData['villaNumbers'];
                    if (rawVillas != null && rawVillas is List) {
                      villaNumbers = rawVillas
                          .map((e) => e.toString())
                          .toList()
                          .cast<String>();
                    }

                    // For fallback (if loading failed and we used text field)
                    String? villaNumber;
                    if (formData['villaNumber'] != null &&
                        formData['villaNumber'].toString().isNotEmpty) {
                      villaNumber = formData['villaNumber'].toString();
                    }

                    // Parse lease expiry date
                    DateTime? leaseExpiryDate;
                    if (formData['leaseExpiryDate'] != null &&
                        formData['leaseExpiryDate'].toString().isNotEmpty) {
                      leaseExpiryDate = DateTime.tryParse(
                        formData['leaseExpiryDate'] as String,
                      );
                    }

                    // Parse joining date
                    DateTime? joiningDate;
                    if (formData['joiningDate'] != null &&
                        formData['joiningDate'].toString().isNotEmpty) {
                      joiningDate = DateTime.tryParse(
                        formData['joiningDate'] as String,
                      );
                    }

                    // Users are always created as 'active' by default
                    // Status can be changed later in the user detail/edit page

                    context.read<UserBloc>().add(
                          CreateUser(
                            CreateUserDto(
                              email: formData['email'] as String,
                              password: password,
                              firstName: formData['firstName'] as String?,
                              lastName: formData['lastName'] as String?,
                              phoneNumber: formData['phoneNumber'] as String?,
                              alternatePhoneNumber:
                                  formData['alternatePhoneNumber'] as String?,
                              leaseExpiryDate: leaseExpiryDate,
                              roleId: _selectedRoleId,
                              villaNumber: villaNumber,
                              villaNumbers: villaNumbers,
                              departmentId: formData['departmentId'] as String?,
                              sendCredentialsViaEmail: sendEmail,
                              forcePasswordChangeOnFirstLogin:
                                  false, // Hidden from UI, default to false
                              // status is omitted - backend defaults to 'active'
                              employeeId: formData['employeeId'] as String?,
                              designation: formData['designation'] as String?,
                              joiningDate: joiningDate,
                              emergencyContactName:
                                  formData['emergencyContactName'] as String?,
                              emergencyContactPhone:
                                  formData['emergencyContactPhone'] as String?,
                              companyId: formData['companyId'] as String?,
                              // notes field removed from UI
                            ),
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
              : const Text('Create User'),
        );
      },
    );
  }

  /// Generates a secure random password
  /// Format: 12 characters with uppercase, lowercase, numbers, and special chars
  String _generateSecurePassword() {
    const length = 12;
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const numbers = '0123456789';
    const special = '!@#\$%^&*()_+-=[]{}|;:,.<>?';
    const allChars = uppercase + lowercase + numbers + special;

    final random = Random.secure();
    final password = StringBuffer();

    // Ensure at least one character from each category
    password
        .writeCharCode(uppercase.codeUnitAt(random.nextInt(uppercase.length)));
    password
        .writeCharCode(lowercase.codeUnitAt(random.nextInt(lowercase.length)));
    password.writeCharCode(numbers.codeUnitAt(random.nextInt(numbers.length)));
    password.writeCharCode(special.codeUnitAt(random.nextInt(special.length)));

    // Fill the rest randomly
    for (int i = password.length; i < length; i++) {
      password
          .writeCharCode(allChars.codeUnitAt(random.nextInt(allChars.length)));
    }

    // Shuffle the password characters
    final passwordList = password.toString().split('')..shuffle(random);
    return passwordList.join();
  }

  void _showGeneratedPasswordDialog(
    BuildContext context,
    String email,
    String password,
  ) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Expanded(
              child: Text('User Created Successfully'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User account has been created for:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                email,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Generated Password:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      password,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: password));
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text('Password copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    tooltip: 'Copy password',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Please save this password securely. It will not be shown again.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Pop with refresh flag to trigger list reload
              context.pop(true);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
