import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../domain/entities/dashboard_analytics_entity.dart';

class PriorityDistributionChart extends StatelessWidget {
  const PriorityDistributionChart({
    super.key,
    required this.priorityDistribution,
  });

  final List<PriorityDistributionEntity> priorityDistribution;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Filter out zero counts and invalid data
    final filteredData = priorityDistribution
        .where((item) => item.count > 0 && item.priority.isNotEmpty)
        .toList()
      ..sort((a, b) {
        // Sort by priority: URGENT > HIGH > MEDIUM > LOW
        const priorityOrder = ['URGENT', 'HIGH', 'MEDIUM', 'LOW'];
        final aIndex = priorityOrder.indexOf(a.priority);
        final bIndex = priorityOrder.indexOf(b.priority);
        // Handle priorities not in the list
        if (aIndex == -1 && bIndex == -1) return 0;
        if (aIndex == -1) return 1;
        if (bIndex == -1) return -1;
        return aIndex.compareTo(bIndex);
      });

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

    // Color mapping for priorities
    final priorityColors = {
      'LOW': Colors.green,
      'MEDIUM': Colors.orange,
      'HIGH': Colors.red,
      'URGENT': Colors.purple,
    };

    final maxCount = filteredData
        .map((e) => e.count)
        .reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority Distribution',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: RepaintBoundary(
            child: IgnorePointer(
              ignoring: true, // Completely disable all pointer events
              child: BarChart(
                key: ValueKey('priority_bar_${filteredData.length}'),
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxCount * 1.2,
                  barTouchData: BarTouchData(
                    enabled: false, // Disable all touch/mouse interactions
                    touchTooltipData: BarTouchTooltipData(
                      tooltipRoundedRadius: 8,
                    ),
                  ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= filteredData.length) {
                        return const Text('');
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          filteredData[value.toInt()].priority,
                          style: theme.textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: theme.textTheme.bodySmall,
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(show: false),
              barGroups: filteredData.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final color = priorityColors[item.priority] ?? colorScheme.primary;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: item.count.toDouble(),
                      color: color,
                      width: 32,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: filteredData.map((item) {
            final color = priorityColors[item.priority] ?? colorScheme.primary;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${item.priority}: ${item.count} (${item.percentage.toStringAsFixed(1)}%)',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

