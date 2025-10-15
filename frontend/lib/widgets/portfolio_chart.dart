import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cheeseball/theme/colors.dart';

class PortfolioChart extends StatelessWidget {
  const PortfolioChart({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock portfolio chart data
    final List<FlSpot> spots = [
      const FlSpot(0, 10000),
      const FlSpot(1, 10500),
      const FlSpot(2, 9800),
      const FlSpot(3, 11000),
      const FlSpot(4, 11500),
      const FlSpot(5, 11200),
      const FlSpot(6, 12000),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData:  FlGridData(show: false),
          titlesData:  FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primaryBlue,
              barWidth: 3,
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primaryBlue.withOpacity(0.1),
              ),
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}