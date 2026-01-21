import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/standard_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class VerifyOtpPage extends StatefulWidget {
  const VerifyOtpPage({
    super.key,
    required this.email,
    required this.companyId,
  });

  final String email;
  final String companyId;

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        state.maybeWhen(
          otpVerified: (token, email) {
            context.push(
              '/forgot-password/reset',
              extra: {
                'email': email,
                'token': token,
                'companyId': widget.companyId,
              },
            );
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
                    _buildVerifyOtpCard(context),
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
                  _buildVerifyOtpCard(context),
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
              'Verify Code',
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
          'Enter verification code',
          style: AppTypography.headline(context).copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface, // Use theme color for dark mode visibility
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We\'ve sent a 6-digit code to ${widget.email}',
          style: AppTypography.body(context).copyWith(
            color: colorScheme.onSurfaceVariant, // Use theme color for dark mode visibility
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyOtpCard(BuildContext context) {
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
              'Verification Code',
              style: AppTypography.headline(context).copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface, // Use theme color for dark mode visibility
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Enter the 6-digit code sent to your email.',
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
                  label: 'Verify Code',
                  onPressed: isLoading ? null : _handleSubmit,
                  isLoading: isLoading,
                );
              },
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
                        ForgotPasswordEvent(
                          email: widget.email,
                          companyId: widget.companyId,
                        ),
                      );
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Resend code',
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
          FormBuilderTextField(
            name: 'otp',
            decoration: InputDecoration(
              labelText: 'Verification Code',
              helperText: 'Enter the 6-digit code',
              prefixIcon: const Icon(Icons.lock_outline),
              hintText: '000000',
            ),
            keyboardType: TextInputType.number,
            maxLength: 6,
            buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Verification code is required';
              }
              if (value.length != 6) {
                return 'Code must be 6 digits';
              }
              if (!RegExp(r'^\d+$').hasMatch(value)) {
                return 'Code must contain only numbers';
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
      final otp = _formKey.currentState!.value['otp'] as String;

      context.read<AuthBloc>().add(
            VerifyOtpEvent(
              email: widget.email,
              otp: otp,
              companyId: widget.companyId,
            ),
          );
    }
  }
}

