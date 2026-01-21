import 'package:flutter/material.dart';

import '../../domain/entities/dashboard_analytics_entity.dart';

class PerformanceMetricsCard extends StatelessWidget {
  const PerformanceMetricsCard({
    super.key,
    required this.performance,
  });

  final PerformanceMetricsEntity performance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.speed_outlined,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Performance Metrics',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _MetricRow(
              label: 'Avg Resolution Time',
              value: '${performance.averageResolutionTime.toStringAsFixed(1)} hrs',
              icon: Icons.timer_outlined,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 12),
            _MetricRow(
              label: 'Avg First Response',
              value: '${performance.averageFirstResponseTime.toStringAsFixed(1)} hrs',
              icon: Icons.reply_outlined,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _MetricRow(
              label: 'SLA Compliance',
              value: '${performance.slaCompliance.toStringAsFixed(1)}%',
              icon: Icons.check_circle_outline,
              color: performance.slaCompliance >= 90
                  ? Colors.green
                  : performance.slaCompliance >= 70
                      ? Colors.orange
                      : Colors.red,
            ),
            const SizedBox(height: 12),
            _MetricRow(
              label: 'Tickets Resolved',
              value: '${performance.ticketsResolved}',
              icon: Icons.assignment_turned_in_outlined,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SLA Compliance',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        '${performance.slaCompliance.toStringAsFixed(1)}%',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: performance.slaCompliance >= 90
                              ? Colors.green
                              : performance.slaCompliance >= 70
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: performance.slaCompliance / 100,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      performance.slaCompliance >= 90
                          ? Colors.green
                          : performance.slaCompliance >= 70
                              ? Colors.orange
                              : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

