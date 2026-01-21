import 'package:flutter/material.dart';
import '../widgets/dashboard_charts_section.dart';
import '../widgets/dashboard_quick_navigation.dart';
import '../widgets/dashboard_recent_activity.dart';
import '../widgets/dashboard_stats_grid.dart';
import '../../domain/entities/dashboard_stats_entity.dart';

class DashboardLayoutUtils {
  static Widget buildResponsiveLayout({
    required DashboardStatsEntity stats,
    required BuildContext context,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1200) {
          // Large screens: Multi-column layout with charts
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DashboardStatsGrid(stats: stats),
                      const SizedBox(height: 24),
                      DashboardChartsSection(stats: stats),
                      const SizedBox(height: 24),
                      const DashboardQuickNavigation(),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: const DashboardRecentActivity(),
              ),
            ],
          );
        } else {
          // Tablets and Mobile: Stacked layout
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DashboardStatsGrid(stats: stats),
                const SizedBox(height: 24),
                DashboardChartsSection(stats: stats),
                const SizedBox(height: 24),
                const DashboardQuickNavigation(),
                const SizedBox(height: 24),
                const DashboardRecentActivity(),
              ],
            ),
          );
        }
      },
    );
  }
}

