import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/dashboard_stats_entity.dart';
import '../utils/dashboard_stat_config.dart';
import 'dashboard_stat_card_enhanced.dart';

class DashboardStatsGrid extends StatelessWidget {
  const DashboardStatsGrid({
    super.key,
    required this.stats,
  });

  final DashboardStatsEntity stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Show all cards, even with zero values, so dashboard is never blank
        final visibleConfigs = AdminDashboardStatConfigs.configs;

        final isWeb = constraints.maxWidth > 768;
        
        // Dynamic grid calculation for better alignment on larger screens
        // Calculate optimal columns based on available width and number of cards
        final cardCount = visibleConfigs.length;
        final availableWidth = constraints.maxWidth;
        
        // Calculate optimal crossAxisCount based on screen size and card count
        int crossAxisCount;
        if (availableWidth > 1920) {
          // Ultra-wide screens: up to 5 columns
          crossAxisCount = cardCount >= 5 ? 5 : (cardCount >= 4 ? 4 : cardCount);
        } else if (availableWidth > 1600) {
          // Large desktop: up to 4 columns
          crossAxisCount = cardCount >= 4 ? 4 : (cardCount >= 3 ? 3 : cardCount);
        } else if (availableWidth > 1200) {
          // Medium desktop: up to 4 columns
          crossAxisCount = cardCount >= 4 ? 4 : (cardCount >= 3 ? 3 : cardCount);
        } else if (availableWidth > 800) {
          // Small desktop/tablet: 3 columns
          crossAxisCount = cardCount >= 3 ? 3 : cardCount;
        } else if (availableWidth >= 768) {
          // Tablet: 2 columns
          crossAxisCount = cardCount >= 2 ? 2 : 1;
        } else {
          // Mobile: 1 column
          crossAxisCount = 1;
        }

        // Calculate spacing based on screen size
        // Larger screens get more spacing for better visual separation
        final spacing = isWeb
            ? (availableWidth > 1920
                ? 28.0
                : availableWidth > 1600
                    ? 24.0
                    : availableWidth > 1200
                        ? 20.0
                        : 18.0)
            : 16.0;

        // Calculate dynamic aspect ratio based on screen width
        // Larger screens get wider cards (higher aspect ratio = wider, shorter cards)
        // This makes cards more compact and better proportioned on big screens
        // Higher aspect ratio = wider cards = shorter height = more compact
        // Note: Aspect ratio is width/height, so higher = wider/shorter cards
        final childAspectRatio = isWeb
            ? (availableWidth > 1920
                ? 4.0 // Ultra-wide: very wide, compact cards (prevents overflow)
                : availableWidth > 1600
                    ? 3.6 // Large desktop: wide, compact cards
                    : availableWidth > 1400
                        ? 3.3 // Medium-large desktop: wider cards
                        : availableWidth > 1200
                            ? 3.0 // Medium desktop: moderately wide
                            : availableWidth > 1000
                                ? 2.6 // Small desktop
                                : 2.4) // Tablet landscape
            : (availableWidth >= 768 ? 2.0 : 2.1); // Mobile/Tablet portrait

        return GridView.count(
          crossAxisCount: crossAxisCount,
          padding: EdgeInsets.zero,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: childAspectRatio,
          children: visibleConfigs.map((config) {
            final value = config.getValue(stats);
            return DashboardStatCardEnhanced(
              title: config.title,
              value: value.toString(),
              icon: config.icon,
              color: config.color,
              subtitle: _getSubtitle(config.title, stats),
              trend: _getTrend(config.title, stats),
              onTap: () => context.push(config.route),
            );
          }).toList(),
        );
      },
    );
  }

  String? _getSubtitle(String title, DashboardStatsEntity stats) {
    switch (title) {
      case 'Total Tickets':
        return 'All time tickets';
      case 'New Requests':
        return 'Awaiting action';
      case 'In Progress':
        return 'Currently active';
      case 'Completed':
        return 'Successfully closed';
      case 'On Hold':
        return 'Paused tickets';
      default:
        return null;
    }
  }

  String? _getTrend(String title, DashboardStatsEntity stats) {
    // Trend data removed - no longer showing last week performance
    return null;
  }
}
