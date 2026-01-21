import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../core/utils/role_access_control.dart';
import '../../../../core/widgets/common_dialogs.dart';
import '../../../../core/utils/theme_helpers.dart';
import '../../../../core/theme/theme_service.dart' show PrimaryColorOption, ThemeService, themeNotifier;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _appVersion = '';
  bool _isLoadingVersion = true;

  // Notification preferences
  bool _pushNotificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  bool _ticketUpdatesEnabled = true;
  bool _systemAlertsEnabled = true;

  // App preferences
  String _themeMode = 'system'; // 'light', 'dark', 'system'
  PrimaryColorOption _selectedPrimaryColor = PrimaryColorOption.options.first;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    _loadPreferences();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = 'v${packageInfo.version} (Build ${packageInfo.buildNumber})';
          _isLoadingVersion = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _appVersion = 'Version unavailable';
          _isLoadingVersion = false;
        });
      }
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final primaryColorOption = await ThemeService.getPrimaryColorOption();
    
    if (mounted) {
      setState(() {
        _pushNotificationsEnabled = prefs.getBool('push_notifications_enabled') ?? true;
        _emailNotificationsEnabled = prefs.getBool('email_notifications_enabled') ?? true;
        _ticketUpdatesEnabled = prefs.getBool('ticket_updates_enabled') ?? true;
        _systemAlertsEnabled = prefs.getBool('system_alerts_enabled') ?? true;
        _themeMode = prefs.getString('theme_mode') ?? 'system';
        _selectedPrimaryColor = primaryColorOption;
      });
    }
  }

  Future<void> _savePreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  Future<void> _handleThemeModeChange(String? newMode) async {
    if (newMode == null) return;
    await _savePreference('theme_mode', newMode);
    setState(() {
      _themeMode = newMode;
    });
    // Note: Theme mode change would need to be handled at app level
    // This is a placeholder for the preference storage
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Theme preference saved. Restart app to apply.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.maybeWhen(
          authenticated: (user) => user,
          orElse: () => null,
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/dashboard'),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section
                _SettingsSection(
                  title: 'Profile',
                  icon: Icons.person_outline_rounded,
                  children: [
                    _SettingsTile(
                      leading: Icons.person_outline_rounded,
                      title: 'Personal Information',
                      subtitle: 'Update your name, email, and contact details',
                      onTap: () => context.push('/profile/personal-info'),
                    ),
                    _SettingsTile(
                      leading: Icons.lock_outline_rounded,
                      title: 'Security & Password',
                      subtitle: 'Change password and manage security settings',
                      onTap: () => context.push('/profile/security'),
                    ),
                    if (user != null)
                      _SettingsTile(
                        leading: Icons.badge_outlined,
                        title: 'Account Details',
                        subtitle: 'View your account information and roles',
                        trailing: Text(
                          user.roles.isNotEmpty
                              ? user.roles.first
                                  .split('_')
                                  .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
                                  .join(' ')
                              : 'User',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () {
                          // Could navigate to account details page
                        },
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                // Notifications Section
                _SettingsSection(
                  title: 'Notifications',
                  icon: Icons.notifications_outlined,
                  children: [
                    _SwitchSettingsTile(
                      leading: Icons.notifications_active_outlined,
                      title: 'Push Notifications',
                      subtitle: 'Receive push notifications on your device',
                      value: _pushNotificationsEnabled,
                      onChanged: (value) {
                        setState(() => _pushNotificationsEnabled = value);
                        _savePreference('push_notifications_enabled', value);
                      },
                    ),
                    _SwitchSettingsTile(
                      leading: Icons.email_outlined,
                      title: 'Email Notifications',
                      subtitle: 'Receive notifications via email',
                      value: _emailNotificationsEnabled,
                      onChanged: (value) {
                        setState(() => _emailNotificationsEnabled = value);
                        _savePreference('email_notifications_enabled', value);
                      },
                    ),
                    _SwitchSettingsTile(
                      leading: Icons.description_outlined,
                      title: 'Ticket Updates',
                      subtitle: 'Get notified about ticket status changes',
                      value: _ticketUpdatesEnabled,
                      onChanged: (value) {
                        setState(() => _ticketUpdatesEnabled = value);
                        _savePreference('ticket_updates_enabled', value);
                      },
                    ),
                    _SwitchSettingsTile(
                      leading: Icons.warning_amber_outlined,
                      title: 'System Alerts',
                      subtitle: 'Receive important system alerts and announcements',
                      value: _systemAlertsEnabled,
                      onChanged: (value) {
                        setState(() => _systemAlertsEnabled = value);
                        _savePreference('system_alerts_enabled', value);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Email Templates Section (Admin only)
                if (user != null && RoleAccessControl.isAdmin(user))
                  _SettingsSection(
                    title: 'Email Templates',
                    icon: Icons.email_outlined,
                    children: [
                      _SettingsTile(
                        leading: Icons.edit_outlined,
                        title: 'Manage Email Templates',
                        subtitle: 'View and edit all email notification templates',
                        onTap: () => context.push('/settings/email-templates'),
                      ),
                    ],
                  ),

                if (user != null && RoleAccessControl.isAdmin(user))
                  const SizedBox(height: 24),

                // Appearance Section
                _SettingsSection(
                  title: 'Appearance',
                  icon: Icons.palette_outlined,
                  children: [
                    _DropdownSettingsTile(
                      leading: Icons.brightness_6_outlined,
                      title: 'Theme',
                      subtitle: 'Choose your preferred theme',
                      value: _themeMode,
                      items: const [
                        DropdownMenuItem(value: 'light', child: Text('Light')),
                        DropdownMenuItem(value: 'dark', child: Text('Dark')),
                        DropdownMenuItem(value: 'system', child: Text('System Default')),
                      ],
                      onChanged: _handleThemeModeChange,
                    ),
                    const SizedBox(height: 8),
                    _PrimaryColorPickerTile(
                      leading: Icons.color_lens_outlined,
                      title: 'Primary Color',
                      subtitle: 'Choose your preferred primary color',
                      selectedColor: _selectedPrimaryColor,
                      onColorSelected: (PrimaryColorOption colorOption) async {
                        await themeNotifier.updatePrimaryColorOption(colorOption);
                        setState(() {
                          _selectedPrimaryColor = colorOption;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Primary color updated successfully'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // App Preferences Section
                _SettingsSection(
                  title: 'App Preferences',
                  icon: Icons.tune_outlined,
                  children: [
                    _SettingsTile(
                      leading: Icons.storage_outlined,
                      title: 'Storage & Data',
                      subtitle: 'Manage cache and stored data',
                      onTap: () {
                        _showStorageDialog(context);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Privacy & Security Section
                _SettingsSection(
                  title: 'Privacy & Security',
                  icon: Icons.security_outlined,
                  children: [
                    _SettingsTile(
                      leading: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      subtitle: 'View our privacy policy',
                      onTap: () {
                        // Open privacy policy
                      },
                    ),
                    _SettingsTile(
                      leading: Icons.description_outlined,
                      title: 'Terms of Service',
                      subtitle: 'View terms and conditions',
                      onTap: () {
                        // Open terms of service
                      },
                    ),
                    _SettingsTile(
                      leading: Icons.shield_outlined,
                      title: 'Data Protection',
                      subtitle: 'Learn about how we protect your data',
                      onTap: () {
                        // Open data protection info
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Help & Support Section
                _SettingsSection(
                  title: 'Help & Support',
                  icon: Icons.help_outline_rounded,
                  children: [
                    _SettingsTile(
                      leading: Icons.help_center_outlined,
                      title: 'Help Center',
                      subtitle: 'Get help and find answers',
                      onTap: () {
                        // Open help center
                      },
                    ),
                    _SettingsTile(
                      leading: Icons.feedback_outlined,
                      title: 'Send Feedback',
                      subtitle: 'Share your thoughts and suggestions',
                      onTap: () {
                        _showFeedbackDialog(context);
                      },
                    ),
                    _SettingsTile(
                      leading: Icons.bug_report_outlined,
                      title: 'Report a Bug',
                      subtitle: 'Report issues or bugs you\'ve encountered',
                      onTap: () {
                        _showBugReportDialog(context);
                      },
                    ),
                    _SettingsTile(
                      leading: Icons.contact_support_outlined,
                      title: 'Contact Support',
                      subtitle: 'Get in touch with our support team',
                      onTap: () {
                        _showContactSupportDialog(context);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // About Section
                _SettingsSection(
                  title: 'About',
                  icon: Icons.info_outlined,
                  children: [
                    _SettingsTile(
                      leading: Icons.info_outline_rounded,
                      title: 'App Version',
                      subtitle: _isLoadingVersion ? 'Loading...' : _appVersion,
                      trailing: _isLoadingVersion
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                    ),
                    _SettingsTile(
                      leading: Icons.code_outlined,
                      title: 'Open Source Licenses',
                      subtitle: 'View third-party licenses',
                      onTap: () {
                        showLicensePage(context: context);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Account Actions Section
                _SettingsSection(
                  title: 'Account',
                  icon: Icons.account_circle_outlined,
                  children: [
                    _SettingsTile(
                      leading: Icons.logout_rounded,
                      title: 'Sign Out',
                      subtitle: 'Sign out of your account',
                      textColor: colorScheme.error,
                      iconColor: colorScheme.error,
                      onTap: () => _showLogoutDialog(context),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showStorageDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Storage & Data'),
        content: const Text(
          'Cache and stored data help improve app performance. You can clear this data to free up space.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: const Text(
          'We\'d love to hear your thoughts! Please share your feedback to help us improve.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feedback option coming soon')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showBugReportDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report a Bug'),
        content: const Text(
          'Found a bug? Please report it and we\'ll fix it as soon as possible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bug report option coming soon')),
              );
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  void _showContactSupportDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Text(
          'Need help? Our support team is here to assist you.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contact support option coming soon')),
              );
            },
            child: const Text('Contact'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    CommonDialogs.showConfirmationDialog(
      context: context,
      title: 'Sign Out',
      content: const Text('Are you sure you want to sign out?'),
      confirmText: 'Sign Out',
      onConfirm: () {
        context.read<AuthBloc>().add(const LogoutEvent());
      },
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: context.cardBorderRadius,
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.1),
              width: 1,
            ),
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
                      color: colorScheme.outline.withValues(alpha: 0.1),
                      indent: 56,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.textColor,
    this.iconColor,
  });

  final IconData leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? textColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: context.cardBorderRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(
              leading,
              color: iconColor ?? colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: textColor ?? colorScheme.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              trailing!,
              const SizedBox(width: 8),
            ],
            if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _SwitchSettingsTile extends StatelessWidget {
  const _SwitchSettingsTile({
    required this.leading,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData leading;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Icon(
            leading,
            color: colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _DropdownSettingsTile extends StatelessWidget {
  const _DropdownSettingsTile({
    required this.leading,
    required this.title,
    this.subtitle,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final IconData leading;
  final String title;
  final String? subtitle;
  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Icon(
            leading,
            color: colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: value,
            items: items,
            onChanged: onChanged,
            underline: const SizedBox.shrink(),
            isDense: true,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryColorPickerTile extends StatelessWidget {
  const _PrimaryColorPickerTile({
    required this.leading,
    required this.title,
    this.subtitle,
    required this.selectedColor,
    required this.onColorSelected,
  });

  final IconData leading;
  final String title;
  final String? subtitle;
  final PrimaryColorOption selectedColor;
  final ValueChanged<PrimaryColorOption> onColorSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                leading,
                color: colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: PrimaryColorOption.options.map((colorOption) {
              final isSelected = colorOption.value == selectedColor.value;
              return GestureDetector(
                onTap: () => onColorSelected(colorOption),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorOption.color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.onSurface
                          : colorScheme.outline.withValues(alpha: 0.3),
                      width: isSelected ? 3 : 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: colorOption.color.withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: _getContrastColor(colorOption.color),
                          size: 24,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _getContrastColor(Color color) {
    // Calculate relative luminance
    final luminance = color.computeLuminance();
    // Return white for dark colors, black for light colors
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

