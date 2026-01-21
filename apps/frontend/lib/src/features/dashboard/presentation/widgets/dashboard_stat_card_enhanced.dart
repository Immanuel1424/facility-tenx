import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/theme_helpers.dart';

class DashboardStatCardEnhanced extends StatelessWidget {
  const DashboardStatCardEnhanced({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.trend,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final String? trend;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use MediaQuery for consistent sizing across all cards
        final screenWidth = MediaQuery.of(context).size.width;
        final isLargeScreen = screenWidth > 1200;
        final isMediumScreen = screenWidth > 768 && screenWidth <= 1200;
        
        // Dynamic sizing based on card height (for layout only)
        final cardHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : double.infinity;
        // Very compact mode for cards with height < 80px (like 70.2px)
        final isVeryCompact = cardHeight < 80 && cardHeight.isFinite;
        // Compact mode for cards with height < 100px but >= 80px
        final isCompact = cardHeight < 100 && !isVeryCompact && cardHeight.isFinite;
        
        // Consistent font sizes for ALL cards - same as "Total Tickets" card
        // Based on screen size only, NOT card height
        // Use theme typography sizes
        final titleFontSize = isLargeScreen 
            ? AppFontSizes.labelSmall 
            : AppFontSizes.tiny;
        final valueFontSize = isLargeScreen 
            ? AppFontSizes.headlineSmall 
            : AppFontSizes.headlineSmall;
        
        // Adjust icon size based on card width and height
        final iconSize = isVeryCompact
            ? 18.0 // Smaller icon for very compact cards
            : isCompact
                ? (isLargeScreen ? 28.0 : 24.0)
                : (isLargeScreen
                    ? 36.0
                    : isMediumScreen
                        ? 32.0
                        : 28.0);
        
        // Adjust padding based on card width and height
        final horizontalPadding = isVeryCompact
            ? 10.0 // Reduced padding for very compact
            : isCompact
                ? (isLargeScreen ? 16.0 : 12.0)
                : (isLargeScreen
                    ? 20.0
                    : isMediumScreen
                        ? 16.0
                        : 12.0);
        final verticalPadding = isVeryCompact
            ? 4.0 // Minimal vertical padding for very compact
            : isCompact
                ? (isLargeScreen ? 10.0 : 8.0)
                : (isLargeScreen
                    ? 16.0
                    : isMediumScreen
                        ? 14.0
                        : 12.0);
        
        // Adjust spacing between icon and text
        final iconSpacing = isVeryCompact
            ? 6.0 // Reduced spacing for very compact
            : isCompact
                ? (isLargeScreen ? 12.0 : 10.0)
                : (isLargeScreen
                    ? 16.0
                    : isMediumScreen
                        ? 12.0
                        : 10.0);

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: context.cardBorderRadius,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            // Bottom border accent
            border: Border(
              bottom: BorderSide(
                color: color,
                width: 4,
              ),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: context.cardBorderRadius,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Dynamic Icon Size
                    Icon(
                      icon,
                      size: iconSize,
                      color: color,
                    ),
                    SizedBox(width: iconSpacing),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Title - consistent size across ALL cards
                          Text(
                            title.toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.0, // Consistent letter spacing for all
                                  fontSize: titleFontSize,
                                ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          SizedBox(
                            height: isVeryCompact
                                ? 0.5
                                : isCompact
                                    ? 2
                                    : (isLargeScreen ? 4 : 2),
                          ),
                          // Value - consistent size across ALL cards, NO FittedBox to prevent scaling
                          Text(
                            value,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface,
                                  height: 1.0,
                                  fontSize: valueFontSize,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Subtitle - hide in compact mode if space is tight
                          if (subtitle != null && !isCompact && !isVeryCompact) ...[
                            SizedBox(height: isLargeScreen ? 4 : 2),
                            Text(
                              subtitle!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          // Trend - hide in compact mode
                          if (trend != null && !isCompact && !isVeryCompact) ...[
                            SizedBox(height: isLargeScreen ? 8 : 6),
                            _TrendBadge(trend: trend!),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TrendBadge extends StatelessWidget {
  const _TrendBadge({required this.trend});

  final String trend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPositive = trend.contains('↑');
    final isNegative = trend.contains('↓');
    final trendColor = isPositive
        ? colorScheme.primary // Use theme success color if available, otherwise primary
        : isNegative
            ? colorScheme.error
            : colorScheme.onSurfaceVariant;
    final icon = isPositive
        ? Icons.trending_up
        : isNegative
            ? Icons.trending_down
            : Icons.remove;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: trendColor.withValues(alpha: 0.1),
        borderRadius: context.cardBorderRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: trendColor,
          ),
          const SizedBox(width: 4),
          Text(
            trend,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: trendColor,
            ),
          ),
        ],
      ),
    );
  }
}
