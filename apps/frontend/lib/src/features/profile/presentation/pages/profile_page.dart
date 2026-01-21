import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = 'v${packageInfo.version} (Build ${packageInfo.buildNumber})';
      });
    }
  }

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(const LogoutEvent());
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        state.maybeWhen(
          unauthenticated: () => context.go('/login'),
          orElse: () {},
        );
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state.maybeWhen(
            authenticated: (user) => user,
            orElse: () => null,
          );

          final List<String> villaNumbers = user?.villas.isNotEmpty == true
              ? user!.villas.map((v) => v.villaNumber).toList()
              : user?.villaNumber != null
                  ? [user!.villaNumber!]
                  : [];
          final String villaText = villaNumbers.isEmpty
              ? 'No Villa Assigned'
              : 'Villa ${villaNumbers.join(', ')}';

          final String userRole = user?.roles.isNotEmpty == true
              ? user!.roles.first
                  .split('_')
                  .map(
                    (word) =>
                        word[0].toUpperCase() + word.substring(1).toLowerCase(),
                  )
                  .join(' ')
              : 'Tenant';

          return Scaffold(
            appBar: AppBar(
              title: const Text('Profile'),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.surface,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(
                              (user?.firstName ?? '').isNotEmpty
                                  ? (user?.firstName ?? '')[0].toUpperCase()
                                  : 'T',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${user?.firstName ?? 'Tenant'} ${user?.lastName ?? ''}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface, // Ensure visibility in dark mode
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$villaText • $userRole',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant, // Ensure visibility in dark mode
                                  ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Group 1
                  _ProfileMenuSection(
                    children: [
                      _ProfileMenuItem(
                        icon: Icons.person_outline_rounded,
                        label: 'Personal Information',
                        iconColor: Colors.blue,
                        onTap: () => context.push('/profile/personal-info'),
                      ),
                      _ProfileMenuItem(
                        icon: Icons.lock_outline_rounded,
                        label: 'Change Password',
                        iconColor: Colors.blue,
                        onTap: () => context.push('/profile/security'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Group 2
                  _ProfileMenuSection(
                    children: [
                      _ProfileMenuItem(
                        icon: Icons.notifications_none_rounded,
                        label: 'Notifications',
                        iconColor: Colors.blue,
                        trailingText: 'On',
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Group 3
                  _ProfileMenuSection(
                    children: [
                      _ProfileMenuItem(
                        icon: Icons.help_outline_rounded,
                        label: 'Help & Support',
                        iconColor: Colors.blue,
                        onTap: () {},
                      ),
                      _ProfileMenuItem(
                        icon: Icons.logout_rounded,
                        label: 'Log Out',
                        iconColor: Colors.red,
                        textColor: Colors.red,
                        onTap: () => _showLogoutConfirmationDialog(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  Text(
                    _version,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant, // Ensure visibility in dark mode
                    ),
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

class _ProfileMenuSection extends StatelessWidget {
  final List<Widget> children;

  const _ProfileMenuSection({required this.children});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface, // Use theme color for dark mode support
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final widget = entry.value;
          return Column(
            children: [
              widget,
              if (index != children.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                  indent: 56,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
  final String? trailingText;
  final Widget? trailingWidget;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.textColor,
    this.trailingText,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        12,
      ), // Should ideally match container but clipping might be needed if separating items
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? colorScheme.onSurfaceVariant, // Use theme color for dark mode
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: textColor ?? colorScheme.onSurface, // Use theme color for dark mode
                    ),
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant, // Ensure visibility in dark mode
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (trailingWidget != null) ...[
              trailingWidget!,
              if (trailingWidget is! Text ||
                  (trailingWidget as Text).style?.color !=
                      Colors.green) // Don't show chevron if it's status
                const SizedBox(width: 8),
            ],
            if (trailingWidget == null ||
                (trailingWidget is Text &&
                    (trailingWidget as Text).style?.color != Colors.green))
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant, // Use theme color for dark mode
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
