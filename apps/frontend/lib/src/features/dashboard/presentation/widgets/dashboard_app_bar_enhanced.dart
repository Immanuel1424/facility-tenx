import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../notification/presentation/bloc/notification_bloc.dart';
import '../../../notification/presentation/bloc/notification_state.dart';

class DashboardAppBarEnhanced extends StatelessWidget
    implements PreferredSizeWidget {
  const DashboardAppBarEnhanced({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isWeb = MediaQuery.of(context).size.width >= 768;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 1,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isWeb ? 24 : 16,
          vertical: 8,
        ),
        child: Row(
          children: [
            // Logo/Brand Section
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.dashboard,
                color: colorScheme.onPrimaryContainer,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            if (isWeb) ...[
              const Spacer(),
              // Search Bar
              _SearchBar(colorScheme: colorScheme),
              const SizedBox(width: 16),
            ],
          ],
        ),
      ),
      actions: [
        if (isWeb) ...[
          // Quick Actions (hidden for technicians)
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              final user = authState.maybeWhen(
                authenticated: (user) => user,
                orElse: () => null,
              );

              // Hide Quick Actions if user is null or is a technician
              if (user == null) {
                return const SizedBox.shrink();
              }

              // Check if user is a technician (case-insensitive, handles variations)
              final isTechnician = user.roles.any(
                (role) {
                  final normalizedRole = role.trim().toUpperCase();
                  return normalizedRole == 'TECHNICIAN' ||
                      normalizedRole.contains('TECHNICIAN');
                },
              );

              if (isTechnician) {
                return const SizedBox.shrink();
              }

              return _QuickActions(colorScheme: colorScheme);
            },
          ),
          const SizedBox(width: 8),
        ],
        // Notifications
        _NotificationButton(colorScheme: colorScheme),
        const SizedBox(width: 8),
        // User Profile Menu
        _UserProfileMenu(colorScheme: colorScheme),
        SizedBox(width: isWeb ? 24 : 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchBar extends StatefulWidget {
  const _SearchBar({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 40,
      decoration: BoxDecoration(
        color: widget.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: TextStyle(
            color: widget.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: widget.colorScheme.onSurface.withValues(alpha: 0.6),
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    size: 18,
                    color: widget.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    // Controller updates trigger rebuild automatically
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
        ),
        style: TextStyle(
          fontSize: 14,
          color: widget.colorScheme.onSurface,
        ),
        // Controller updates trigger rebuild automatically
        onChanged: (_) {},
        onSubmitted: (value) {
          // TODO: Implement search functionality
          if (value.isNotEmpty) {
            // Navigate to search results or perform search
          }
        },
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _QuickActionButton(
          icon: Icons.add,
          label: 'New Ticket',
          colorScheme: colorScheme,
          onPressed: () => context.push('/maintenance-tickets/create'),
        ),
        const SizedBox(width: 8),
        _QuickActionButton(
          icon: Icons.refresh,
          label: 'Refresh',
          colorScheme: colorScheme,
          onPressed: () {
            // TODO: Implement refresh
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Refreshing...')),
            );
          },
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.colorScheme,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final ColorScheme colorScheme;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        final unreadCount = state.maybeWhen(
              listLoaded: (notifications) =>
                  notifications.where((n) => !n.isRead).length,
              orElse: () => 0,
            ) ??
            0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              tooltip: 'Notifications',
              onPressed: () => context.push('/notifications'),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      (unreadCount > 9) ? '9+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _UserProfileMenu extends StatelessWidget {
  const _UserProfileMenu({required this.colorScheme});

  final ColorScheme colorScheme;

  String _getUserDisplayName(UserEntity user) {
    if (user.firstName != null || user.lastName != null) {
      return '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();
    }
    return user.email.split('@').first;
  }

  String _getUserInitials(UserEntity user) {
    if (user.firstName != null && user.lastName != null) {
      final first = user.firstName!;
      final last = user.lastName!;
      if (first.isNotEmpty && last.isNotEmpty) {
        return '${first[0]}${last[0]}'.toUpperCase();
      }
    }
    if (user.firstName != null && user.firstName!.isNotEmpty) {
      return user.firstName![0].toUpperCase();
    }
    if (user.email.isNotEmpty) {
      return user.email[0].toUpperCase();
    }
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.maybeWhen(
          authenticated: (user) => user,
          orElse: () => null,
        );

        if (user == null) {
          return const SizedBox.shrink();
        }

        return _buildUserMenu(context, user);
      },
    );
  }

  Widget _buildUserMenu(BuildContext context, UserEntity user) {
    final displayName = _getUserDisplayName(user);
    final initials = _getUserInitials(user);
    final primaryRole = user.roles.isNotEmpty ? user.roles.first : 'User';

    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                initials,
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  primaryRole,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 20,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 12),
              const Text('Profile'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(
                Icons.logout,
                size: 20,
                color: colorScheme.error,
              ),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: TextStyle(color: colorScheme.error),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'profile':
            // TODO: Navigate to profile page
            break;
          case 'logout':
            context.read<AuthBloc>().add(const LogoutEvent());
            break;
        }
      },
    );
  }
}
