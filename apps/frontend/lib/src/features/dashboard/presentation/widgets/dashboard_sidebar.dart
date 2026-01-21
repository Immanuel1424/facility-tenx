import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/permission_checker.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/domain/entities/user_entity.dart';

class DashboardSidebar extends StatelessWidget {
  const DashboardSidebar({
    super.key,
    required this.currentRoute,
    this.isExpanded = true,
  });

  final String currentRoute;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Use AppBar color (darker shade of primary) for sidebar background
    final sidebarBackground = theme.appBarTheme.backgroundColor ?? colorScheme.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isExpanded ? 280 : 80,
      decoration: BoxDecoration(
        color: sidebarBackground,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1), // Use theme color for dark mode
            blurRadius: 4,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Enhanced Logo and App Name Section
          Container(
            padding: EdgeInsets.all(isExpanded ? 28 : 20),
            child: Row(
              mainAxisAlignment: isExpanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.business,
                    color: colorScheme.onPrimary,
                    size: 26,
                  ),
                ),
                if (isExpanded) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'TENX',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tenant Experience Layer for Residential Communities by HelixSense',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimary,
                            fontSize: 9,
                            letterSpacing: 0.2,
                            height: 1.4,
                          ),
                          softWrap: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Divider(
            color: colorScheme.onPrimary.withValues(alpha: 0.15),
            height: 1,
            thickness: 1,
          ),
          // Navigation Items
          Expanded(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final user = state.maybeWhen(
                  authenticated: (user) => user,
                  orElse: () => null,
                );

                final isSuperAdmin = user != null &&
                    PermissionChecker.isSuperAdmin(user);
                final canManageUsers = user != null &&
                    PermissionChecker.canPerform(user, 'user', 'read');
                final canViewAnnouncements = user != null &&
                    PermissionChecker.canPerform(user, 'announcement', 'read');
                final canManageCompanies = user != null &&
                    PermissionChecker.canPerform(user, 'company', 'read');

                return ListView(
                  padding: EdgeInsets.symmetric(
                    vertical: isExpanded ? 20 : 16,
                    horizontal: isExpanded ? 12 : 8,
                  ),
                  children: [
                    _NavItem(
                      icon: Icons.dashboard,
                      label: 'Dashboard',
                      route: '/dashboard',
                      isSelected: currentRoute == '/dashboard',
                      isExpanded: isExpanded,
                    ),
                    // Super Admin sees company management instead of company-specific items
                    if (isSuperAdmin) ...[
                      _NavItem(
                        icon: Icons.business,
                        label: 'Companies',
                        route: '/companies',
                        isSelected: currentRoute == '/companies',
                        isExpanded: isExpanded,
                      ),
                      _NavItem(
                        icon: Icons.domain,
                        label: 'Sites',
                        route: '/sites',
                        isSelected: currentRoute == '/sites' ||
                            currentRoute.contains('/companies/') &&
                                currentRoute.contains('/sites'),
                        isExpanded: isExpanded,
                      ),
                      _NavItem(
                        icon: Icons.people,
                        label: 'Users',
                        route: '/iam/users',
                        isSelected: currentRoute == '/iam/users',
                        isExpanded: isExpanded,
                      ),
                      _NavItem(
                        icon: Icons.admin_panel_settings,
                        label: 'Roles & Permissions',
                        route: '/iam/roles',
                        isSelected: currentRoute.startsWith('/iam/roles') ||
                            currentRoute.startsWith('/iam/permissions'),
                        isExpanded: isExpanded,
                      ),
                    ] else if (user != null) ...[
                      // Regular company-scoped users (ADMIN, SITE_COORDINATOR, etc.)
                      _NavItem(
                        icon: Icons.description,
                        label: 'All Tickets',
                        route: '/maintenance-tickets',
                        isSelected: currentRoute == '/maintenance-tickets',
                        isExpanded: isExpanded,
                      ),
                      if (canViewAnnouncements)
                        _NavItem(
                          icon: Icons.campaign,
                          label: 'Announcements',
                          route: '/announcements',
                          isSelected: currentRoute == '/announcements',
                          isExpanded: isExpanded,
                        ),
                      if (canManageUsers)
                        _NavItem(
                          icon: Icons.people,
                          label: 'Users',
                          route: '/iam/users',
                          isSelected: currentRoute == '/iam/users',
                          isExpanded: isExpanded,
                        ),
                      if (canManageCompanies)
                        _NavItem(
                          icon: Icons.domain,
                          label: 'Sites',
                          route: '/companies/${user.companyId}/sites',
                          isSelected: currentRoute.contains('/companies/') &&
                              currentRoute.contains('/sites'),
                          isExpanded: isExpanded,
                        ),
                      _NavItem(
                        icon: Icons.home,
                        label: 'Villas',
                        route: '/villas',
                        isSelected: currentRoute == '/villas',
                        isExpanded: isExpanded,
                      ),
                      _NavItem(
                        icon: Icons.home_work,
                        label: 'Villa Types',
                        route: '/villa-types',
                        isSelected: currentRoute.startsWith('/villa-types'),
                        isExpanded: isExpanded,
                      ),
                      _NavItem(
                        icon: Icons.category,
                        label: 'Ticket Categories',
                        route: '/ticket-categories',
                        isSelected: currentRoute.startsWith('/ticket-categories'),
                        isExpanded: isExpanded,
                      ),
                      _NavItem(
                        icon: Icons.timer_outlined,
                        label: 'SLA & Escalation',
                        route: '/sla-configurations',
                        isSelected: currentRoute.startsWith('/sla-configurations'),
                        isExpanded: isExpanded,
                      ),
                    ] else ...[],
                    _NavItem(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      route: '/settings',
                      isSelected: currentRoute == '/settings',
                      isExpanded: isExpanded,
                    ),
                  ],
                );
              },
            ),
          ),
          Divider(
            color: colorScheme.onPrimary.withValues(alpha: 0.15),
            height: 1,
            thickness: 1,
          ),
          // User Profile Section
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final user = state.maybeWhen(
                authenticated: (user) => user,
                orElse: () => null,
              );
              if (user == null) {
                return const SizedBox.shrink();
              }
              return _UserProfileSection(
                user: user,
                isExpanded: isExpanded,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isSelected,
    required this.isExpanded,
  });

  final IconData icon;
  final String label;
  final String route;
  final bool isSelected;
  final bool isExpanded;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Tooltip(
        message: widget.isExpanded ? '' : widget.label,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: InkWell(
            onTap: () {
              // If we're on a pushed route and not already on the target route,
              // pop back to reveal the sidebar, then navigate
              if (context.canPop() && !widget.isSelected) {
                context.pop();
                // Navigate after pop completes
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    context.go(widget.route);
                  }
                });
              } else {
                // Normal navigation
                context.go(widget.route);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(
                horizontal: widget.isExpanded ? 18 : 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? colorScheme.primary.withValues(alpha: 0.2)
                    : _isHovered
                        ? colorScheme.onPrimary.withValues(alpha: 0.08)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: widget.isSelected
                    ? Border(
                        left: BorderSide(
                          color: colorScheme.primary,
                          width: 3,
                        ),
                      )
                    : null,
              ),
              child: Row(
                mainAxisAlignment: widget.isExpanded
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onPrimary.withValues(
                              alpha: _isHovered ? 0.9 : 0.7,
                            ),
                      size: 22,
                    ),
                  ),
                  if (widget.isExpanded) ...[
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        widget.label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: widget.isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onPrimary.withValues(
                                  alpha: _isHovered ? 0.9 : 0.7,
                                ),
                          fontWeight: widget.isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UserProfileSection extends StatelessWidget {
  const _UserProfileSection({
    required this.user,
    required this.isExpanded,
  });

  final UserEntity user;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final firstName = user.firstName ?? '';
    final lastName = user.lastName ?? '';
    final fullName = '$firstName $lastName'.trim();
    final displayName = fullName.isNotEmpty ? fullName : user.email;
    final initials = _getInitials(displayName);
    final role = user.roles.isNotEmpty ? user.roles.first : 'User';

    return Container(
      padding: EdgeInsets.all(isExpanded ? 20 : 16),
      decoration: BoxDecoration(
        color: colorScheme.onPrimary.withValues(alpha: 0.05),
        border: Border(
          top: BorderSide(
            color: colorScheme.onPrimary.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: isExpanded ? 24 : 20,
                  backgroundColor: colorScheme.primary,
                  child: Text(
                    initials,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: isExpanded ? 16 : 14,
                    ),
                  ),
                ),
              ),
              if (isExpanded) ...[
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.onPrimary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          role.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimary.withValues(
                              alpha: 0.8,
                            ),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (isExpanded) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.read<AuthBloc>().add(const LogoutEvent());
                },
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      colorScheme.onPrimary.withValues(alpha: 0.8),
                  side: BorderSide(
                    color: colorScheme.onPrimary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            Tooltip(
              message: 'Sign Out',
              child: IconButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const LogoutEvent());
                },
                icon: Icon(Icons.logout_rounded, size: 22),
                color: colorScheme.onPrimary.withValues(alpha: 0.8),
                style: IconButton.styleFrom(
                  side: BorderSide(
                    color: colorScheme.onPrimary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return '${parts[0].substring(0, 1)}${parts[parts.length - 1].substring(0, 1)}'
        .toUpperCase();
  }
}

