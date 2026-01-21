import 'package:flutter/material.dart';
import '../../domain/entities/dashboard_stats_entity.dart';

class StatConfig {
  const StatConfig({
    required this.title,
    required this.icon,
    required this.color,
    required this.getValue,
    required this.route,
  });

  final String title;
  final IconData icon;
  final Color color;
  final int Function(DashboardStatsEntity) getValue;
  final String route;
}

class AdminDashboardStatConfigs {
  static final List<StatConfig> configs = [
    StatConfig(
      title: 'Total Tickets',
      icon: Icons.description,
      color: Colors.blue,
      getValue: (stats) => stats.totalRequests,
      route: '/maintenance-tickets',
    ),
    StatConfig(
      title: 'New Requests',
      icon: Icons.refresh,
      color: Colors.blue,
      getValue: (stats) => stats.openRequests,
      route: '/maintenance-tickets?status=NEW',
    ),
    StatConfig(
      title: 'In Progress',
      icon: Icons.play_arrow,
      color: Colors.orange,
      getValue: (stats) => stats.inProgress,
      route: '/maintenance-tickets?status=IN_PROGRESS',
    ),
    StatConfig(
      title: 'Completed',
      icon: Icons.check_circle,
      color: Colors.green,
      getValue: (stats) => stats.completed,
      route: '/maintenance-tickets?status=COMPLETED',
    ),
    StatConfig(
      title: 'On Hold',
      icon: Icons.pause,
      color: Colors.grey,
      getValue: (stats) => stats.onHold,
      route: '/maintenance-tickets?status=ON_HOLD',
    ),
  ];
}

class QuickNavConfig {
  const QuickNavConfig({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
  });

  final String title;
  final IconData icon;
  final Color color;
  final String route;
}

class TenantDashboardStatConfigs {
  // Summary card (shown separately as hero card)
  static final StatConfig totalRequests = StatConfig(
    title: 'Total Requests',
    icon: Icons.receipt_long_rounded,
    color: Colors.indigo,
    getValue: (stats) => stats.totalRequests,
    route: '/tenant/complaints',
  );

  // Active tickets workflow (in order: NEW → ACKNOWLEDGED → ASSIGNED → IN_PROGRESS)
  static final List<StatConfig> activeTickets = [
    StatConfig(
      title: 'Open Requests',
      icon: Icons.folder_open_rounded,
      color: Colors.blue,
      getValue: (stats) => stats.openRequests,
      route: '/tenant/complaints?status=NEW',
    ),
    StatConfig(
      title: 'Acknowledged',
      icon: Icons.check_circle_outline,
      color: Colors.teal,
      getValue: (stats) => stats.acknowledged,
      route: '/tenant/complaints?status=ACKNOWLEDGED',
    ),
    StatConfig(
      title: 'Assigned',
      icon: Icons.assignment,
      color: Colors.purple,
      getValue: (stats) => stats.assigned,
      route: '/tenant/complaints?status=ASSIGNED',
    ),
    StatConfig(
      title: 'In Progress',
      icon: Icons.sync_rounded,
      color: Colors.orange,
      getValue: (stats) => stats.inProgress,
      route: '/tenant/complaints?status=IN_PROGRESS',
    ),
  ];

  // Completed tickets
  static final List<StatConfig> completedTickets = [
    StatConfig(
      title: 'Resolved',
      icon: Icons.check_circle_rounded,
      color: Colors.green,
      getValue: (stats) => stats.resolved,
      route: '/tenant/complaints?status=COMPLETED',
    ),
  ];

  // All configs (for backward compatibility)
  static List<StatConfig> get configs => [
        totalRequests,
        ...activeTickets,
        ...completedTickets,
      ];
}

class AdminDashboardQuickNavConfigs {
  static final List<QuickNavConfig> configs = [
    QuickNavConfig(
      title: 'Maintenance Tickets',
      icon: Icons.description,
      color: Colors.blue,
      route: '/maintenance-tickets',
    ),
    QuickNavConfig(
      title: 'Roles',
      icon: Icons.people_outline,
      color: Colors.purple,
      route: '/iam/roles',
    ),
    QuickNavConfig(
      title: 'Permissions',
      icon: Icons.security,
      color: Colors.teal,
      route: '/iam/permissions',
    ),
    QuickNavConfig(
      title: 'Notifications',
      icon: Icons.notifications,
      color: Colors.red,
      route: '/notifications',
    ),
  ];
}

class SuperAdminDashboardStatConfigs {
  static final List<StatConfig> configs = [
    StatConfig(
      title: 'Total Companies',
      icon: Icons.business,
      color: const Color(0xFF007be5),
      getValue: (stats) => 0, // Will be overridden by CompanyBloc count
      route: '/companies',
    ),
    StatConfig(
      title: 'Active Users',
      icon: Icons.people,
      color: Colors.green,
      getValue: (stats) => stats.activeUsers,
      route: '/users',
    ),
    StatConfig(
      title: 'Total Tickets',
      icon: Icons.description,
      color: Colors.blue,
      getValue: (stats) => stats.totalRequests,
      route: '/maintenance-tickets',
    ),
    StatConfig(
      title: 'Open Requests',
      icon: Icons.folder_open,
      color: Colors.orange,
      getValue: (stats) => stats.openRequests,
      route: '/maintenance-tickets?status=NEW',
    ),
    StatConfig(
      title: 'In Progress',
      icon: Icons.sync,
      color: Colors.purple,
      getValue: (stats) => stats.inProgress,
      route: '/maintenance-tickets?status=IN_PROGRESS',
    ),
    StatConfig(
      title: 'Completed',
      icon: Icons.check_circle,
      color: Colors.green,
      getValue: (stats) => stats.completed,
      route: '/maintenance-tickets?status=COMPLETED',
    ),
  ];
}

class SuperAdminDashboardQuickNavConfigs {
  static final List<QuickNavConfig> configs = [
    QuickNavConfig(
      title: 'Companies',
      icon: Icons.business,
      color: const Color(0xFF007be5),
      route: '/companies',
    ),
    QuickNavConfig(
      title: 'Users',
      icon: Icons.people_outline,
      color: Colors.green,
      route: '/users',
    ),
    QuickNavConfig(
      title: 'Roles',
      icon: Icons.admin_panel_settings,
      color: Colors.purple,
      route: '/iam/roles',
    ),
    QuickNavConfig(
      title: 'Permissions',
      icon: Icons.security,
      color: Colors.teal,
      route: '/iam/permissions',
    ),
    QuickNavConfig(
      title: 'Tickets',
      icon: Icons.description,
      color: Colors.blue,
      route: '/maintenance-tickets',
    ),
    QuickNavConfig(
      title: 'Notifications',
      icon: Icons.notifications,
      color: Colors.red,
      route: '/notifications',
    ),
  ];
}

