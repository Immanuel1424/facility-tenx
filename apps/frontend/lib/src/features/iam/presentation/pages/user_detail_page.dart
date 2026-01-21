import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/theme_helpers.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/common_dialogs.dart';
import '../../../department/data/repositories/department_repository.dart';
import '../../../department/domain/entities/department_entity.dart';
import '../../../department/presentation/bloc/department_bloc.dart';
import '../../../department/presentation/bloc/department_event.dart';
import '../../../department/presentation/bloc/department_state.dart';
import '../../data/dto/user_dto.dart';
import '../../data/repositories/iam_repository.dart';
import '../bloc/user/user_bloc.dart';
import '../bloc/user/user_event.dart';
import '../bloc/user/user_state.dart';

class UserDetailPage extends StatelessWidget {
  const UserDetailPage({
    super.key,
    required this.userId,
    this.companyId,
  });

  final String userId;
  final String? companyId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => UserBloc(
            repository: getIt<IamRepository>(),
          )..add(LoadUserDetail(userId, companyId: companyId)),
        ),
        BlocProvider(
          create: (context) => DepartmentBloc(
            repository: DepartmentRepository(
              apiClient: getIt<ApiClient>(),
            ),
          )..add(const LoadDepartmentList()),
        ),
      ],
      child: const _UserDetailContent(),
    );
  }
}

class _UserDetailContent extends StatefulWidget {
  const _UserDetailContent();

  @override
  State<_UserDetailContent> createState() => _UserDetailContentState();
}

class _UserDetailContentState extends State<_UserDetailContent> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        state.maybeWhen(
          updated: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
            final userId = state.maybeWhen(
              updated: (u) => u.id,
              orElse: () => null,
            );
            if (userId != null) {
              final page = context.findAncestorWidgetOfExactType<
                  UserDetailPage>();
              context.read<UserBloc>().add(
                    LoadUserDetail(
                      userId,
                      companyId: page?.companyId,
                    ),
                  );
            }
          },
          deleted: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          },
          activated: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User activated successfully'),
                backgroundColor: Colors.green,
              ),
            );
            final userId = state.maybeWhen(
              activated: (u) => u.id,
              orElse: () => null,
            );
            if (userId != null) {
              final page = context.findAncestorWidgetOfExactType<
                  UserDetailPage>();
              context.read<UserBloc>().add(
                    LoadUserDetail(
                      userId,
                      companyId: page?.companyId,
                    ),
                  );
            }
          },
          deactivated: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User deactivated successfully'),
                backgroundColor: Colors.orange,
              ),
            );
            final userId = state.maybeWhen(
              deactivated: (u) => u.id,
              orElse: () => null,
            );
            if (userId != null) {
              final page = context.findAncestorWidgetOfExactType<
                  UserDetailPage>();
              context.read<UserBloc>().add(
                    LoadUserDetail(
                      userId,
                      companyId: page?.companyId,
                    ),
                  );
            }
          },
          passwordReset: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password reset successfully'),
                backgroundColor: Colors.green,
              ),
            );
            // Reload user detail to restore the detailLoaded state
            final page = context.findAncestorWidgetOfExactType<
                UserDetailPage>();
            if (page != null) {
              context.read<UserBloc>().add(
                    LoadUserDetail(
                      page.userId,
                      companyId: page.companyId,
                    ),
                  );
            }
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
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          final user = state.maybeWhen(
            detailLoaded: (u) => u,
            created: (u) => u,
            updated: (u) => u,
            activated: (u) => u,
            deactivated: (u) => u,
            orElse: () => null,
          );

          return Scaffold(
            appBar: AppBar(
              title: user != null
                  ? Text(
                      user.firstName != null && user.firstName!.isNotEmpty
                          ? '${user.firstName} ${user.lastName ?? ''}'.trim()
                          : user.email,
                      style: const TextStyle(fontSize: 18),
                    )
                  : const Text('User Details'),
              actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                final state = context.read<UserBloc>().state;
                final userId = state.maybeWhen(
                  detailLoaded: (u) => u.id,
                  created: (u) => u.id,
                  updated: (u) => u.id,
                  activated: (u) => u.id,
                  deactivated: (u) => u.id,
                  orElse: () => null,
                );
                if (userId != null) {
                  final page = context.findAncestorWidgetOfExactType<
                      UserDetailPage>();
                  context.read<UserBloc>().add(
                        LoadUserDetail(
                          userId,
                          companyId: page?.companyId,
                        ),
                      );
                }
              },
              tooltip: 'Refresh',
            ),
              ],
            ),
            body: user != null
                ? _buildResponsiveContent(context, user)
                : BlocBuilder<UserBloc, UserState>(
                    builder: (context, state) {
                      return state.maybeWhen(
              loading: () => const Center(child: CircularProgressIndicator()),
              detailLoaded: (user) => _buildResponsiveContent(context, user),
              created: (user) => _buildResponsiveContent(context, user),
              updated: (user) => _buildResponsiveContent(context, user),
              activated: (user) => _buildResponsiveContent(context, user),
              deactivated: (user) => _buildResponsiveContent(context, user),
              error: (message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('Error: $message'),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        final page = context.findAncestorWidgetOfExactType<
                            UserDetailPage>();
                        if (page != null) {
                          context.read<UserBloc>().add(
                                LoadUserDetail(
                                  page.userId,
                                  companyId: page.companyId,
                                ),
                              );
                        }
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              orElse: () => const Center(child: CircularProgressIndicator()),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }

  Widget _buildResponsiveContent(BuildContext context, UserDto user) {
    return ResponsiveLayout(
      mobileBuilder: (context) => _buildMobileLayout(context, user),
      desktopBuilder: (context) => _buildDesktopLayout(context, user),
    );
  }

  Widget _buildMobileLayout(BuildContext context, UserDto user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(context, user),
          const SizedBox(height: 12),
          _BasicInfoSection(user: user),
          const SizedBox(height: 12),
          _ContactInfoSection(user: user),
          const SizedBox(height: 12),
          _AssignmentInfoSection(user: user),
          const SizedBox(height: 12),
          _RolesSection(user: user),
          const SizedBox(height: 12),
          _SystemInfoSection(user: user),
          const SizedBox(height: 12),
          _buildActionButtonsCard(context, user),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, UserDto user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCard(context, user),
                    const SizedBox(height: 16),
                    _BasicInfoSection(user: user),
                    const SizedBox(height: 16),
                    _ContactInfoSection(user: user),
                    const SizedBox(height: 16),
                    _SystemInfoSection(user: user),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AssignmentInfoSection(user: user),
                    const SizedBox(height: 16),
                    _RolesSection(user: user),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              SizedBox(
                width: 320,
                child: Column(
                  children: [
                    _buildActionButtonsCard(context, user),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, UserDto user) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fullName = [
      user.firstName,
      user.lastName,
    ].where((n) => n != null && n.isNotEmpty).join(' ');

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: context.cardBorderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                (user.firstName?.isNotEmpty == true
                        ? user.firstName![0]
                        : user.email[0])
                    .toUpperCase(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName.isNotEmpty ? fullName : 'No Name',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _StatusBadge(status: user.status),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtonsCard(BuildContext context, UserDto user) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: context.cardBorderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings_outlined,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Actions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                final currentUser = state.maybeWhen(
                  detailLoaded: (u) => u,
                  created: (u) => u,
                  updated: (u) => u,
                  activated: (u) => u,
                  deactivated: (u) => u,
                  orElse: () => user,
                );
                return SwitchListTile(
                  title: const Text('Active Status'),
                  subtitle: Text(
                    currentUser.status.toLowerCase() == 'active'
                        ? 'User is currently active and operational.'
                        : 'User is currently inactive.',
                  ),
                  value: currentUser.status.toLowerCase() == 'active',
                  onChanged: (value) {
                    _showStatusChangeDialog(
                      context,
                      currentUser.id,
                      currentUser.status.toLowerCase() == 'active',
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _showResetPasswordDialog(context, user.id),
              icon: const Icon(Icons.lock_reset),
              label: const Text('Reset Password'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _showDeleteConfirmationDialog(context, user),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete User'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusChangeDialog(
    BuildContext context,
    String userId,
    bool isActive,
  ) {
    final userBloc = context.read<UserBloc>();

    CommonDialogs.showConfirmationDialog(
      context: context,
      title: isActive ? 'Deactivate User' : 'Activate User',
      content: isActive
          ? 'Are you sure you want to deactivate this user? They will not be able to access the system.'
          : 'Are you sure you want to activate this user?',
      confirmText: isActive ? 'Deactivate' : 'Activate',
      onConfirm: () {
        if (isActive) {
          userBloc.add(DeactivateUser(userId));
        } else {
          userBloc.add(ActivateUser(userId));
        }
      },
    );
  }

  void _showResetPasswordDialog(BuildContext context, String userId) {
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final userBloc = context.read<UserBloc>();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: userBloc,
        child: BlocListener<UserBloc, UserState>(
          listenWhen: (previous, current) {
            // Only listen to passwordReset and error states, and ignore if previous was also the same
            if (current is UserPasswordReset && previous is! UserPasswordReset) {
              return true;
            }
            if (current is UserError && previous is! UserError) {
              return true;
            }
            return false;
          },
          listener: (listenerContext, state) {
            if (state is UserPasswordReset) {
              // Close dialog after a brief delay to ensure state is processed
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop();
                }
              });
              // The main BlocListener will show the success SnackBar
            } else if (state is UserError) {
              // Close dialog first
              if (Navigator.of(dialogContext).canPop()) {
                Navigator.of(dialogContext).pop();
              }
              // Show error dialog after dialog closes
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  CommonDialogs.showConfirmationDialog(
                    context: context,
                    title: 'Error',
                    content: state.message,
                    confirmText: 'OK',
                    onConfirm: () {},
                  );
                }
              });
            }
          },
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width > 768 ? 700 : 500,
                maxHeight: 500,
              ),
              child: AlertDialog(
                title: Text(
                  'Reset Password',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Info section
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: colorScheme.primary.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 20,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Enter a new password for this user. The user will need to use this password to log in.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // New Password field
                        Text(
                          'New Password',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: 'Enter new password',
                            hintText: 'Minimum 8 characters',
                            helperText: 'Password must be at least 8 characters long',
                            helperMaxLines: 2,
                            border: const OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Confirm Password field
                        Text(
                          'Confirm Password',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Re-enter password',
                            hintText: 'Must match new password',
                            helperText: 'Enter the same password to confirm',
                            helperMaxLines: 2,
                            border: const OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm password';
                            }
                            if (value != passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                actionsAlignment: MainAxisAlignment.end,
                actions: [
                  BlocBuilder<UserBloc, UserState>(
                    builder: (builderContext, state) {
                      final isLoading = state.maybeWhen<bool>(
                        loading: () => true,
                        orElse: () => false,
                      );

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    Navigator.of(dialogContext).pop();
                                  },
                            style: TextButton.styleFrom(
                              minimumSize: const Size(0, 40),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (formKey.currentState?.validate() ?? false) {
                                      userBloc.add(
                                        ResetUserPassword(
                                          userId,
                                          ResetPasswordDto(
                                            newPassword: passwordController.text,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              minimumSize: const Size(0, 40),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text('Reset'),
                          ),
                        ],
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

  void _showDeleteConfirmationDialog(BuildContext context, UserDto user) {
    final userBloc = context.read<UserBloc>();
    final theme = Theme.of(context);

    CommonDialogs.showDeleteDialog(
      context: context,
      title: 'Delete User',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Are you sure you want to delete this user?'),
          const SizedBox(height: 8),
          Text(
            'Email: ${user.email}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Text(
            'This action cannot be undone. The user will be deactivated.',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ),
      onDelete: () {
        userBloc.add(DeleteUser(user.id));
      },
    );
  }
}

// Section Widgets
class _BasicInfoSection extends StatelessWidget {
  const _BasicInfoSection({required this.user});

  final UserDto user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fullName = [
      user.firstName,
      user.lastName,
    ].where((n) => n != null && n.isNotEmpty).join(' ');

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: context.cardBorderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Basic Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoRow(label: 'ID', value: user.id, canCopy: true),
            _InfoRow(label: 'Email', value: user.email, canCopy: true),
            if (fullName.isNotEmpty)
              _InfoRow(label: 'Full Name', value: fullName),
            _InfoRow(
              label: 'Auth Provider',
              value: (user.authProvider.isNotEmpty
                  ? user.authProvider.toUpperCase()
                  : 'N/A'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactInfoSection extends StatelessWidget {
  const _ContactInfoSection({required this.user});

  final UserDto user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasContactInfo =
        user.phoneNumber != null || user.alternatePhoneNumber != null;

    if (!hasContactInfo) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: context.cardBorderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Contact Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (user.phoneNumber != null)
              _InfoRow(label: 'Phone', value: user.phoneNumber!),
            if (user.alternatePhoneNumber != null)
              _InfoRow(
                label: 'Alternate Phone',
                value: user.alternatePhoneNumber!,
              ),
          ],
        ),
      ),
    );
  }
}

class _AssignmentInfoSection extends StatelessWidget {
  const _AssignmentInfoSection({required this.user});

  final UserDto user;

  bool get _isTenant {
    return user.roles?.any((r) => r.toUpperCase() == 'TENANT') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasAssignmentInfo = user.villaNumber != null ||
        (user.villaNumbers != null && user.villaNumbers!.isNotEmpty) ||
        user.departmentId != null ||
        (user.villas != null && user.villas!.isNotEmpty);

    if (!hasAssignmentInfo && !_isTenant) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: context.cardBorderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Assignment Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (user.villaNumber != null)
              _InfoRow(
                label: 'Villa Number',
                value: user.villaNumber.toString(),
              ),
            if (user.villaNumbers != null && user.villaNumbers!.isNotEmpty)
              _InfoRow(
                label: 'Villa Numbers',
                value: user.villaNumbers!.join(', '),
              ),
            if (user.villas != null && user.villas!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Villa Details',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              ...user.villas!.map((villa) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.home_outlined,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Villa ${villa['villaNumber'] ?? villa['villa_number'] ?? 'N/A'}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      if (villa['name'] != null)
                        Text(
                          villa['name'] as String,
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                );
              }),
            ],
            BlocBuilder<DepartmentBloc, DepartmentState>(
              builder: (context, deptState) {
                if (user.departmentId != null) {
                  if (deptState is DepartmentListLoaded) {
                    final department = deptState.departments.firstWhere(
                      (dept) => dept.id == user.departmentId,
                      orElse: () => DepartmentEntity(
                        id: user.departmentId!,
                        name: 'Unknown Department',
                        isActive: false,
                        companyId: user.companyId,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                    );
                    return _InfoRow(
                      label: 'Department',
                      value: department.name,
                    );
                  }
                  return _InfoRow(
                    label: 'Department ID',
                    value: user.departmentId!,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            if (user.leaseExpiryDate != null)
              _InfoRow(
                label: 'Lease Expiry',
                value: DateFormat('yyyy-MM-dd').format(user.leaseExpiryDate!),
                showIcon: true,
                icon: Icons.calendar_today_outlined,
              ),
          ],
        ),
      ),
    );
  }
}

class _RolesSection extends StatelessWidget {
  const _RolesSection({required this.user});

  final UserDto user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: context.cardBorderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security_outlined,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Roles & Permissions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (user.roles != null && user.roles!.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: user.roles!.map((roleName) {
                  return _RoleChip(
                    roleName: roleName,
                  );
                }).toList(),
              )
            else
              Text(
                'No roles assigned',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SystemInfoSection extends StatelessWidget {
  const _SystemInfoSection({required this.user});

  final UserDto user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: context.cardBorderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.computer_outlined,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'System Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (user.lastLoginAt != null)
              _InfoRow(
                label: 'Last Login',
                value: DateFormat('yyyy-MM-dd HH:mm').format(user.lastLoginAt!),
                showIcon: true,
                icon: Icons.login_outlined,
              ),
            _InfoRow(
              label: 'Created At',
              value: DateFormat('yyyy-MM-dd HH:mm').format(user.createdAt),
              showIcon: true,
              icon: Icons.add_circle_outline,
            ),
            _InfoRow(
              label: 'Updated At',
              value: DateFormat('yyyy-MM-dd HH:mm').format(user.updatedAt),
              showIcon: true,
              icon: Icons.update_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.isMultiline = false,
    this.showIcon = false,
    this.icon,
    this.canCopy = false,
  });

  final String label;
  final String value;
  final bool isMultiline;
  final bool showIcon;
  final IconData? icon;
  final bool canCopy;

  @override
  Widget build(BuildContext context) {
    if (isMultiline) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
          const SizedBox(height: 12),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showIcon && icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: showIcon ? 130 : 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.grey,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (canCopy)
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: value));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$label copied to clipboard'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    tooltip: 'Copy $label',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final statusUpper = status.toUpperCase();
    Color color;
    Color textColor;

    switch (statusUpper) {
      case 'ACTIVE':
        color = Colors.green.shade50;
        textColor = Colors.green.shade700;
        break;
      case 'INACTIVE':
        color = Colors.red.shade50;
        textColor = Colors.red.shade700;
        break;
      case 'SUSPENDED':
        color = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        break;
      default:
        color = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: context.cardBorderRadius,
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        statusUpper,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.roleName,
  });

  final String roleName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      label: Text(roleName),
      backgroundColor:
          theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
      labelStyle: TextStyle(
        color: theme.colorScheme.onSecondaryContainer,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
