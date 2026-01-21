import 'package:flutter/material.dart';

import '../../domain/entities/dashboard_analytics_entity.dart';

class PredictionCard extends StatelessWidget {
  const PredictionCard({
    super.key,
    required this.prediction,
  });

  final PredictionEntity prediction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    IconData trendIcon;
    Color trendColor;
    String trendText;

    switch (prediction.trend.toLowerCase()) {
      case 'increasing':
        trendIcon = Icons.trending_up;
        trendColor = Colors.red;
        trendText = 'Increasing';
        break;
      case 'decreasing':
        trendIcon = Icons.trending_down;
        trendColor = Colors.green;
        trendText = 'Decreasing';
        break;
      default:
        trendIcon = Icons.trending_flat;
        trendColor = Colors.orange;
        trendText = 'Stable';
    }

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
                  Icons.analytics_outlined,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Predictions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _PredictionRow(
              label: 'Predicted Volume (Next 7 Days)',
              value: '${prediction.predictedVolume} tickets',
              icon: Icons.assignment_outlined,
            ),
            const SizedBox(height: 12),
            _PredictionRow(
              label: 'Trend',
              value: trendText,
              icon: trendIcon,
              iconColor: trendColor,
            ),
            const SizedBox(height: 12),
            _PredictionRow(
              label: 'Confidence',
              value: '${prediction.confidence}%',
              icon: Icons.verified_outlined,
            ),
            const SizedBox(height: 12),
            _PredictionRow(
              label: 'Expected Resolution Time',
              value: '${prediction.expectedResolutionTime.toStringAsFixed(1)} hours',
              icon: Icons.access_time,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: prediction.confidence / 100,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
            const SizedBox(height: 4),
            Text(
              'Confidence: ${prediction.confidence}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PredictionRow extends StatelessWidget {
  const _PredictionRow({
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: iconColor ?? colorScheme.onSurface.withValues(alpha: 0.6),
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
          ),
        ),
      ],
    );
  }
}

