import 'package:flutter/material.dart';
import 'package:cheeseball/theme/colors.dart';

class MarketStatsCard extends StatelessWidget {
  final Map<String, dynamic>? globalData;

  const MarketStatsCard({super.key, required this.globalData});

  @override
  Widget build(BuildContext context) {
    final marketData = globalData?['data'] ?? {};
    final totalMarketCap = marketData['total_market_cap']?['usd'] ?? 0;
    final totalVolume = marketData['total_volume']?['usd'] ?? 0;
    final marketCapChange = marketData['market_cap_change_percentage_24h_usd'] ?? 0;
    final btcDominance = marketData['market_cap_percentage']?['btc'] ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Market Overview',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                Icon(
                  marketCapChange >= 0 ? Icons.trending_up : Icons.trending_down,
                  color: marketCapChange >= 0 ? AppColors.positiveGreen : AppColors.negativeRed,
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildStatItem(
                  'Total Market Cap',
                  '\$${_formatNumber(totalMarketCap)}',
                  Icons.auto_graph,
                ),
                _buildStatItem(
                  '24h Volume',
                  '\$${_formatNumber(totalVolume)}',
                  Icons.bar_chart,
                ),
                _buildStatItem(
                  '24h Change',
                  '${marketCapChange.toStringAsFixed(2)}%',
                  marketCapChange >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  color: marketCapChange >= 0 ? AppColors.positiveGreen : AppColors.negativeRed,
                ),
                _buildStatItem(
                  'BTC Dominance',
                  '${btcDominance.toStringAsFixed(1)}%',
                  Icons.currency_bitcoin,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color ?? AppColors.primaryBlue,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double number) {
    if (number >= 1000000000000) {
      return '${(number / 1000000000000).toStringAsFixed(2)}T';
    } else if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(2)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(2)}M';
    }
    return number.toStringAsFixed(2);
  }
}