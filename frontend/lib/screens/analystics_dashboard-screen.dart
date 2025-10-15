import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cheeseball/providers/portfolio_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cheeseball/theme/app_theme.dart'; 
import 'package:cheeseball/theme/colors.dart';


class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  _AnalyticsDashboardScreenState createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = ['Overview', 'Performance', 'Allocation', 'Risk'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportAnalytics,
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab selector
          _buildTabSelector(),
          // Tab content
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: ChoiceChip(
              label: Text(_tabs[index]),
              selected: _selectedTab == index,
              onSelected: (selected) {
                setState(() {
                  _selectedTab = index;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildPerformanceTab();
      case 2:
        return _buildAllocationTab();
      case 3:
        return _buildRiskTab();
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Portfolio metrics
          _buildPortfolioMetrics(),
          const SizedBox(height: 24),
          // Asset allocation
          _buildAssetAllocation(),
          const SizedBox(height: 24),
          // Performance chart
          _buildPerformanceChart(),
        ],
      ),
    );
  }

  Widget _buildPortfolioMetrics() {
    return Consumer<PortfolioProvider>(
      builder: (context, portfolioProvider, child) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildMetricCard(
              'Total Return',
              '+12.5%',
              Icons.trending_up,
              AppTheme.positiveGreen,
            ),
            _buildMetricCard(
              'Volatility',
              'Medium',
              Icons.speed,
              Colors.orange,
            ),
            _buildMetricCard(
              'Sharpe Ratio',
              '1.8',
              Icons.auto_graph,
              AppTheme.primaryBlue,
            ),
            _buildMetricCard(
              'Max Drawdown',
              '-8.2%',
              Icons.trending_down,
              AppTheme.negativeRed,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.neutralGray,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetAllocation() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Asset Allocation',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: 40,
                      color: AppTheme.primaryBlue,
                      title: 'BTC\n40%',
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: 25,
                      color: AppTheme.secondaryBlue,
                      title: 'ETH\n25%',
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: 15,
                      color: AppTheme.accentBlue,
                      title: 'ADA\n15%',
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: 20,
                      color: AppTheme.neutralGray,
                      title: 'Other\n20%',
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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

  Widget _buildPerformanceChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance vs Market',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 100),
                        FlSpot(1, 105),
                        FlSpot(2, 98),
                        FlSpot(3, 110),
                        FlSpot(4, 115),
                        FlSpot(5, 112),
                        FlSpot(6, 120),
                      ],
                      isCurved: true,
                      color: AppTheme.primaryBlue,
                      barWidth: 3,
                      belowBarData: BarAreaData(show: false),
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 100),
                        FlSpot(1, 102),
                        FlSpot(2, 101),
                        FlSpot(3, 105),
                        FlSpot(4, 108),
                        FlSpot(5, 106),
                        FlSpot(6, 110),
                      ],
                      isCurved: true,
                      color: AppTheme.neutralGray,
                      barWidth: 2,
                      belowBarData: BarAreaData(show: false),
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 2,
                  color: AppTheme.primaryBlue,
                ),
                const SizedBox(width: 8),
                const Text('Your Portfolio'),
                const SizedBox(width: 24),
                Container(
                  width: 12,
                  height: 2,
                  color: AppTheme.neutralGray,
                ),
                const SizedBox(width: 8),
                const Text('Market Average'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceTab() {
    return const Center(
      child: Text('Performance Analytics'),
    );
  }

  Widget _buildAllocationTab() {
    return const Center(
      child: Text('Asset Allocation Analytics'),
    );
  }

  Widget _buildRiskTab() {
    return const Center(
      child: Text('Risk Analysis'),
    );
  }

  void _exportAnalytics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Analytics'),
        content: const Text('Export your portfolio analytics data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Analytics data exported successfully'),
                  backgroundColor: AppTheme.positiveGreen,
                ),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }
}