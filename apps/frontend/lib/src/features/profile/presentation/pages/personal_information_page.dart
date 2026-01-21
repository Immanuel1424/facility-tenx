import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../iam/data/repositories/iam_repository.dart';
import '../../../iam/data/dto/user_dto.dart';
import '../../../../core/di/service_locator.dart';

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({super.key});

  @override
  State<PersonalInformationPage> createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Refresh auth state to get latest user data from API
      context.read<AuthBloc>().add(const RefreshAuthEvent());
      // Load initial data
      _loadUserData();
    });
  }

  void _loadUserData() {
    if (!mounted) return;

    final authState = context.read<AuthBloc>().state;
    authState.maybeWhen(
      authenticated: (user) {
        print(
            '🔍 Loading user data: firstName=${user.firstName}, phoneNumber=${user.phoneNumber}');

        _nameController.text =
            '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();
        _emailController.text = user.email;
        _phoneController.text = user.phoneNumber ?? '';
      },
      orElse: () {},
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authState = context.read<AuthBloc>().state;
      final userId = authState.maybeWhen(
        authenticated: (user) => user.id,
        orElse: () => null,
      );

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not signed in')),
        );
        return;
      }

      final nameParts = _nameController.text.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final updateDto = UpdateUserDto(
        firstName: firstName,
        lastName: lastName,
      );

      final result = await getIt<IamRepository>().updateUser(userId, updateDto);

      result.fold(
        (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile: $error')),
          );
        },
        (user) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          // Refresh auth state to reflect changes without triggering loading state
          context.read<AuthBloc>().add(const RefreshAuthEvent());
          if (mounted) context.pop();
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Reload user data when auth state changes (e.g., after refresh)
        state.maybeWhen(
          authenticated: (user) {
            if (mounted) {
              print(
                  '🔄 Auth state changed, loading user data: firstName=${user.firstName}, phoneNumber=${user.phoneNumber}');
              _loadUserData();
            }
          },
          orElse: () {},
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Personal Info'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.surface,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                final user = state.maybeWhen(
                                  authenticated: (user) => user,
                                  orElse: () => null,
                                );
                                return CircleAvatar(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  child: Text(
                                    (user?.firstName ?? '').isNotEmpty
                                        ? (user?.firstName ?? '')[0]
                                            .toUpperCase()
                                        : 'T',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.onPrimary,
                                        ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                _buildLabel('Full Name'),
                _buildTextField(
                  controller: _nameController,
                  hintText: 'Sarah Jenkins',
                  icon: Icons.person_outline_rounded,
                ),

                const SizedBox(height: 16),

                _buildLabel('Email Address'),
                _buildTextField(
                  controller: _emailController,
                  hintText: 'sarah.jenkins@example.com',
                  icon: Icons.email_outlined,
                  readOnly: true,
                  suffixIcon: Icons.lock_outline_rounded,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),

                const SizedBox(height: 16),

                _buildLabel('Mobile Number'),
                _buildTextField(
                  controller: _phoneController,
                  hintText: '+971 50 123 4567',
                  icon: Icons.phone_android_rounded,
                  readOnly: true,
                  suffixIcon: Icons.lock_outline_rounded,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.onPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Save Changes',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface, // Ensure visibility in dark mode
            ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool readOnly = false,
    IconData? suffixIcon,
    Color? fillColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: fillColor ?? colorScheme.surface, // Use theme color for dark mode
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2), // Use theme color for dark mode
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: readOnly ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
            ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
          prefixIcon: Icon(
            icon,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
          suffixIcon: suffixIcon != null
              ? Icon(
                  suffixIcon,
                  color: colorScheme.onSurfaceVariant,
                  size: 18,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
