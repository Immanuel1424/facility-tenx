import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/dashboard_stats_entity.dart';
import 'dashboard_chart_card.dart';

class DashboardChartsSection extends StatelessWidget {
  const DashboardChartsSection({
    super.key,
    required this.stats,
  });

  final DashboardStatsEntity stats;

  List<ChartDataPoint> _getRequestStatusData() {
    return [
      ChartDataPoint(label: 'Open', value: stats.openRequests.toDouble()),
      ChartDataPoint(label: 'In Progress', value: stats.inProgress.toDouble()),
      ChartDataPoint(label: 'Resolved', value: stats.resolved.toDouble()),
      ChartDataPoint(label: 'Completed', value: stats.completed.toDouble()),
      ChartDataPoint(label: 'Pending', value: stats.pendingApproval.toDouble()),
    ];
  }

  List<ChartDataPoint> _getRequestDistributionData() {
    return [
      ChartDataPoint(label: 'Open', value: stats.openRequests.toDouble()),
      ChartDataPoint(label: 'In Progress', value: stats.inProgress.toDouble()),
      ChartDataPoint(label: 'Resolved', value: stats.resolved.toDouble()),
      ChartDataPoint(label: 'Completed', value: stats.completed.toDouble()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 1200;

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: DashboardChartCard(
                  title: 'Request Status Overview',
                  data: _getRequestStatusData(),
                  colors: const [
                    Colors.blue,
                    Colors.orange,
                    Colors.green,
                    Colors.purple,
                    Colors.red,
                  ],
                  onTap: () => context.push('/maintenance-tickets'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DashboardPieChartCard(
                  title: 'Request Distribution',
                  data: _getRequestDistributionData(),
                  colors: const [
                    Colors.blue,
                    Colors.orange,
                    Colors.green,
                    Colors.purple,
                  ],
                  onTap: () => context.push('/maintenance-tickets'),
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              DashboardChartCard(
                title: 'Request Status Overview',
                data: _getRequestStatusData(),
                colors: const [
                  Colors.blue,
                  Colors.orange,
                  Colors.green,
                  Colors.purple,
                  Colors.red,
                ],
                onTap: () => context.push('/maintenance-tickets'),
              ),
              const SizedBox(height: 16),
              DashboardPieChartCard(
                title: 'Request Distribution',
                data: _getRequestDistributionData(),
                colors: const [
                  Colors.blue,
                  Colors.orange,
                  Colors.green,
                  Colors.purple,
                ],
                onTap: () => context.push('/maintenance-tickets'),
              ),
            ],
          );
        }
      },
    );
  }
}

