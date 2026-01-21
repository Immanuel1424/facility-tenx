import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/dashboard_analytics_entity.dart';

class VillaDistributionChart extends StatelessWidget {
  const VillaDistributionChart({
    super.key,
    required this.villaDistribution,
  });

  final List<VillaDistributionEntity> villaDistribution;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (villaDistribution.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No villa data available',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    // Sort by count descending and take top 10
    final sortedVillas = List<VillaDistributionEntity>.from(villaDistribution)
      ..sort((a, b) => b.count.compareTo(a.count));
    final topVillas = sortedVillas.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Villas by Ticket Count',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: RepaintBoundary(
            child: IgnorePointer(
              ignoring: true, // Completely disable all pointer events
              child: BarChart(
                key: ValueKey('villa_bar_${topVillas.length}'),
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: topVillas.isNotEmpty
                      ? (topVillas.first.count * 1.2).ceilToDouble()
                      : 10,
                  barTouchData: BarTouchData(
                    enabled: false, // Disable all touch/mouse interactions
                    touchTooltipData: BarTouchTooltipData(
                  tooltipRoundedRadius: 8,
                  tooltipPadding: const EdgeInsets.all(8),
                  tooltipMargin: 8,
                  tooltipBgColor: colorScheme.surfaceContainerHighest,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    if (groupIndex >= 0 && 
                        groupIndex < topVillas.length && 
                        topVillas[groupIndex].villaNumber.isNotEmpty) {
                      final villa = topVillas[groupIndex];
                      return BarTooltipItem(
                        'Villa ${villa.villaNumber}\n${villa.count} tickets\n${villa.percentage.toStringAsFixed(1)}%',
                        TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    }
                    return BarTooltipItem('', const TextStyle());
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 &&
                          value.toInt() < topVillas.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'V${topVillas[value.toInt()].villaNumber}',
                            style: TextStyle(
                              color: colorScheme.onSurface.withValues(alpha: 0.7),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                    reservedSize: 40,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      if (value % 1 == 0) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                            fontSize: 10,
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  left: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
              barGroups: topVillas.asMap().entries.map((entry) {
                final index = entry.key;
                final villa = entry.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: villa.count.toDouble(),
                      color: _getColorForIndex(index, colorScheme),
                      width: 20,
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
      ],
    );
  }

  Color _getColorForIndex(int index, ColorScheme colorScheme) {
    final colors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      colorScheme.primaryContainer,
      colorScheme.secondaryContainer,
      colorScheme.tertiaryContainer,
    ];
    return colors[index % colors.length];
  }
}

