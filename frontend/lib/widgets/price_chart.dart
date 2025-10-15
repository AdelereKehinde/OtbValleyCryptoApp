import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cheeseball/theme/colors.dart';

class PriceChart extends StatefulWidget {
  final Map<String, dynamic>? chartData;
  final String coinId;

  const PriceChart({
    super.key,
    required this.chartData,
    required this.coinId,
  });

  @override
  _PriceChartState createState() => _PriceChartState();
}

class _PriceChartState extends State<PriceChart> {
  List<FlSpot> _spots = [];

  @override
  void initState() {
    super.initState();
    _processChartData();
  }

  void _processChartData() {
    final prices = widget.chartData?['prices'] as List<dynamic>? ?? [];
    List<FlSpot> spots = [];

    for (int i = 0; i < prices.length; i++) {
      final priceData = prices[i] as List<dynamic>;
      if (priceData.length >= 2) {
        spots.add(FlSpot(i.toDouble(), (priceData[1] as num).toDouble()));
      }
    }

    setState(() {
      _spots = spots;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price Chart',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _spots.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData:  FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _spots,
                            isCurved: true,
                            color: AppColors.primaryBlue,
                            barWidth: 2,
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.primaryBlue.withOpacity(0.1),
                            ),
                            dotData:  FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}