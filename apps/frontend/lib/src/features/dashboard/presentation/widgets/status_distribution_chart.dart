import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../domain/entities/dashboard_analytics_entity.dart';

class StatusDistributionChart extends StatelessWidget {
  const StatusDistributionChart({
    super.key,
    required this.statusDistribution,
  });

  final List<StatusDistributionEntity> statusDistribution;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Filter out zero counts and invalid data, then sort by count descending
    final filteredData = statusDistribution
        .where((item) => item.count > 0 && item.status.isNotEmpty)
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    if (filteredData.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    // Color mapping for statuses
    final statusColors = {
      'NEW': colorScheme.primary,
      'ACKNOWLEDGED': colorScheme.secondary,
      'ASSIGNED': Colors.orange,
      'IN_PROGRESS': Colors.blue,
      'ON_HOLD': Colors.grey,
      'COMPLETED': Colors.green,
      'CLOSED': Colors.green.shade700,
      'CANCELLED': Colors.red,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status Distribution',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: RepaintBoundary(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: IgnorePointer(
                    ignoring: true, // Completely disable all pointer events
                    child: PieChart(
                      key: ValueKey('status_pie_${filteredData.length}'),
                      PieChartData(
                        pieTouchData: PieTouchData(
                          enabled: false, // Disable all touch/mouse interactions
                        ),
                        sections: filteredData.map((item) {
                      final color = statusColors[item.status] ?? colorScheme.primary;
                      return PieChartSectionData(
                        value: item.count.toDouble(),
                        title: '${item.count}',
                        color: color,
                        radius: 60,
                        titleStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      );
                      }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: filteredData.map((item) {
                    final color = statusColors[item.status] ?? colorScheme.primary;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.status.replaceAll('_', ' '),
                              style: theme.textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${item.percentage.toStringAsFixed(1)}%',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

