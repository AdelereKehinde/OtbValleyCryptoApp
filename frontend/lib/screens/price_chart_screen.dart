import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cheeseball/providers/crypto_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cheeseball/theme/colors.dart'; 



class PriceChartScreen extends StatefulWidget {
  final String coinId;
  final String coinName;

  const PriceChartScreen({
    super.key,
    required this.coinId,
    required this.coinName,
  });

  @override
  _PriceChartScreenState createState() => _PriceChartScreenState();
}

class _PriceChartScreenState extends State<PriceChartScreen> {
  int _selectedTimeFrame = 0;
  final List<String> _timeFrames = ['1H', '24H', '7D', '30D', '90D', '1Y'];
  bool _isLoading = true;
  List<FlSpot> _chartData = [];

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  void _loadChartData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final days = _getDaysForTimeFrame(_selectedTimeFrame);
      final data = await context.read<CryptoProvider>().fetchCoinChart(widget.coinId, days: days);
      
      setState(() {
        _chartData = _processChartData(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  int _getDaysForTimeFrame(int index) {
    switch (index) {
      case 0: return 1;   // 1H
      case 1: return 1;   // 24H
      case 2: return 7;   // 7D
      case 3: return 30;  // 30D
      case 4: return 90;  // 90D
      case 5: return 365; // 1Y
      default: return 7;
    }
  }

  List<FlSpot> _processChartData(Map<String, dynamic> data) {
    final prices = data['prices'] as List<dynamic>? ?? [];
    List<FlSpot> spots = [];

    for (int i = 0; i < prices.length; i++) {
      final priceData = prices[i] as List<dynamic>;
      if (priceData.length >= 2) {
        spots.add(FlSpot(i.toDouble(), (priceData[1] as num).toDouble()));
      }
    }

    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.coinName),
        actions: [
          IconButton(
            icon: const Icon(Icons.candlestick_chart),
            onPressed: _toggleChartType,
          ),
        ],
      ),
      body: Column(
        children: [
          // Time frame selector
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _timeFrames.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ChoiceChip(
                    label: Text(_timeFrames[index]),
                    selected: _selectedTimeFrame == index,
                    onSelected: (selected) {
                      setState(() {
                        _selectedTimeFrame = index;
                        _loadChartData();
                      });
                    },
                  ),
                );
              },
            ),
          ),
          // Chart
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _chartData,
                            isCurved: true,
                            color: AppTheme.primaryBlue,
                            barWidth: 2,
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppTheme.primaryBlue.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          // Additional chart info
          _buildChartInfo(),
        ],
      ),
    );
  }

  Widget _buildChartInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem('Open', '\$45,231.45'),
          _buildInfoItem('High', '\$46,123.67'),
          _buildInfoItem('Low', '\$44,987.23'),
          _buildInfoItem('Volume', '\$28.5B'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.neutralGray,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  void _toggleChartType() {
    // Switch between line and candlestick charts
  }
}