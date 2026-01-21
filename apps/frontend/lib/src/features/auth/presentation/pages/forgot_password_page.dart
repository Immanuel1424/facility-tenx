import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/standard_button.dart';
import '../../../../core/widgets/standard_text_field.dart';
import '../../../../core/storage/company_id_storage.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({
    super.key,
    this.companyId,
    this.companyName,
  });

  final String? companyId;
  final String? companyName;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        state.maybeWhen(
          forgotPasswordSent: (email) async {
            final companyId = widget.companyId ?? await CompanyIdStorage.getCompanyId() ?? '';
            if (mounted) {
              context.push(
                '/forgot-password/verify-otp',
                extra: {
                  'email': email,
                  'companyId': companyId,
                },
              );
            }
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
                    _buildForgotPasswordCard(context),
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
                  _buildForgotPasswordCard(context),
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
              widget.companyName ?? 'Company',
              style: AppTypography.title(context).copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
          'Reset your password',
          style: AppTypography.headline(context).copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface, // Use theme color for dark mode visibility
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your email address and we\'ll send you a verification code to reset your password.',
          style: AppTypography.body(context).copyWith(
            color: colorScheme.onSurfaceVariant, // Use theme color for dark mode visibility
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordCard(BuildContext context) {
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
              'Email Address',
              style: AppTypography.headline(context).copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface, // Use theme color for dark mode visibility
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'We\'ll send a 6-digit code to your email.',
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
                  label: 'Send Verification Code',
                  onPressed: isLoading ? null : _handleSubmit,
                  isLoading: isLoading,
                );
              },
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => context.pop(),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Back to login',
                  style: AppTypography.body(context).copyWith(
                    color: AppColors.primary,
                    fontSize: 14,
                  ),
                ),
              ),
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
            name: 'email',
            label: 'Email',
            helperText: 'Enter your registered email address',
            icon: Icons.email,
            hintText: 'Enter email address',
            keyboardType: TextInputType.emailAddress,
            autofillHints: [AutofillHints.email],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              final emailRegex =
                  RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    print('🔵 Forgot password submit button clicked');
    
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      print('✅ Form validation passed');
      final email = _formKey.currentState!.value['email'] as String;
      // Get company ID from parameter or SharedPreferences
      String? companyId = widget.companyId;
      if (companyId == null || companyId.isEmpty) {
        companyId = await CompanyIdStorage.getCompanyId();
      }

      print('📧 Email: $email');
      print('🏢 Company ID: $companyId');

      if (companyId == null || companyId.isEmpty) {
        print('❌ Company ID is empty');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Site ID is required. Please go back and enter it.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }

      // At this point, companyId is guaranteed to be non-null and non-empty
      final nonNullCompanyId = companyId;

      print('🚀 Dispatching ForgotPasswordEvent');
      context.read<AuthBloc>().add(
            ForgotPasswordEvent(
              email: email,
              companyId: nonNullCompanyId,
            ),
          );
    } else {
      print('❌ Form validation failed');
      final errors = _formKey.currentState?.errors;
      print('📋 Form errors: $errors');
    }
  }
}

