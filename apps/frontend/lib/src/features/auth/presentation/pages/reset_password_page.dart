import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/standard_button.dart';
import '../../../../core/widgets/standard_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({
    super.key,
    required this.email,
    required this.token,
    required this.companyId,
  });

  final String email;
  final String token;
  final String companyId;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        state.maybeWhen(
          passwordResetSuccess: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Password reset successfully!'),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            // Navigate to login after a short delay
            Future.delayed(const Duration(seconds: 1), () {
              context.go('/login');
            });
          },
          error: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
          orElse: () {},
        );
      },
      child: Scaffold(
        body: ResponsiveLayout(
          mobileBuilder: _buildMobileLayout,
          desktopBuilder: _buildDesktopLayout,
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Column(
      children: [
        _buildTopNavBar(context),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildMainHeading(context),
                    const SizedBox(height: 24),
                    _buildResetPasswordCard(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildTopNavBar(context),
        Expanded(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  _buildMainHeading(context),
                  const SizedBox(height: 24),
                  _buildResetPasswordCard(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopNavBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface, // Use theme color for dark mode support
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withOpacity(0.2), // Use theme color for dark mode
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: AppColors.primary,
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Reset Password',
              style: AppTypography.title(context).copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainHeading(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create new password',
          style: AppTypography.headline(context).copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface, // Use theme color for dark mode visibility
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your new password must be different from your previous password.',
          style: AppTypography.body(context).copyWith(
            color: colorScheme.onSurfaceVariant, // Use theme color for dark mode visibility
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildResetPasswordCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2), // Use theme color for dark mode
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New Password',
              style: AppTypography.headline(context).copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface, // Use theme color for dark mode visibility
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose a strong password to secure your account.',
              style: AppTypography.body(context).copyWith(
                color: colorScheme.onSurfaceVariant, // Use theme color for dark mode visibility
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            _buildForm(context),
            const SizedBox(height: 24),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final isLoading = state.maybeWhen(
                      loading: () => true,
                      orElse: () => false,
                    ) ??
                    false;

                return StandardButton(
                  label: 'Reset Password',
                  onPressed: isLoading ? null : _handleSubmit,
                  isLoading: isLoading,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StandardTextField(
            name: 'newPassword',
            label: 'New Password',
            helperText: 'Minimum 8 characters',
            icon: Icons.lock,
            hintText: 'Enter new password',
            obscureText: _obscurePassword,
            onTogglePassword: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
            autofillHints: [AutofillHints.newPassword],
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
          const SizedBox(height: 24),
          StandardTextField(
            name: 'confirmPassword',
            label: 'Confirm Password',
            helperText: 'Re-enter your new password',
            icon: Icons.lock_outline,
            hintText: 'Confirm new password',
            obscureText: _obscureConfirmPassword,
            onTogglePassword: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
            autofillHints: [AutofillHints.newPassword],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              final newPassword = _formKey.currentState?.value['newPassword'] as String?;
              if (value != newPassword) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final newPassword = _formKey.currentState!.value['newPassword'] as String;

      context.read<AuthBloc>().add(
            ResetPasswordEvent(
              email: widget.email,
              token: widget.token,
              newPassword: newPassword,
              companyId: widget.companyId,
            ),
          );
    }
  }
}

