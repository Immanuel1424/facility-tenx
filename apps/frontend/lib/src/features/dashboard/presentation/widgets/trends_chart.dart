import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/dashboard_analytics_entity.dart';

class TrendsChart extends StatelessWidget {
  const TrendsChart({
    super.key,
    required this.trends,
  });

  final List<TrendDataPointEntity> trends;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (trends.isEmpty) {
      return Center(
        child: Text(
          'No trend data available',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    // Safely calculate max value
    final allValues = trends
        .map((e) => [e.created, e.resolved, e.inProgress])
        .expand((e) => e)
        .toList();
    
    if (allValues.isEmpty) {
      return Center(
        child: Text(
          'No valid trend data available',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      );
    }
    
    final maxValue = allValues.reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ticket Trends',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: RepaintBoundary(
            child: IgnorePointer(
              ignoring: true, // Completely disable all pointer events
              child: LineChart(
                key: ValueKey('trends_line_${trends.length}'),
                LineChartData(
                  lineTouchData: LineTouchData(
                    enabled: false, // Disable all touch/mouse interactions
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
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: trends.length > 7 ? 2 : 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < trends.length) {
                        final date = DateTime.parse(trends[index].date);
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat('MMM d').format(date),
                            style: theme.textTheme.bodySmall,
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    interval: maxValue > 10 ? (maxValue / 5).ceilToDouble() : 1,
                    getTitlesWidget: (value, meta) {
                      if (value % 1 != 0) {
                        return const Text('');
                      }
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          value.toInt().toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.right,
                        ),
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
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                  ),
                  left: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              lineBarsData: [
                // Created line
                LineChartBarData(
                  spots: trends.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value.created.toDouble());
                  }).toList(),
                  isCurved: true,
                  color: colorScheme.primary,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
                // Resolved line
                LineChartBarData(
                  spots: trends.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value.resolved.toDouble());
                  }).toList(),
                  isCurved: true,
                  color: Colors.green,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
                // In Progress line
                LineChartBarData(
                  spots: trends.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value.inProgress.toDouble());
                  }).toList(),
                  isCurved: true,
                  color: Colors.orange,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
                  minY: 0,
                  maxY: maxValue * 1.2,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendItem(
              color: colorScheme.primary,
              label: 'Created',
            ),
            const SizedBox(width: 16),
            _LegendItem(
              color: Colors.green,
              label: 'Resolved',
            ),
            const SizedBox(width: 16),
            _LegendItem(
              color: Colors.orange,
              label: 'In Progress',
            ),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

