import 'package:flutter/material.dart';
import 'package:cheeseball/theme/colors.dart';

class CoinCard extends StatelessWidget {
  final Map<String, dynamic> coin;

  const CoinCard({super.key, required this.coin});

  @override
  Widget build(BuildContext context) {
    final currentPrice = coin['current_price'] ?? 0.0;
    final priceChange24h = coin['price_change_percentage_24h'] ?? 0.0;
    final marketCap = coin['market_cap'] ?? 0;
    final imageUrl = coin['image'] ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: imageUrl.isNotEmpty
            ? Image.network(imageUrl, width: 40, height: 40)
            : Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.currency_bitcoin,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
              ),
        title: Text(
          coin['name'] ?? 'Unknown',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        subtitle: Text(
          'MC: \$${_formatNumber(marketCap)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '\$${currentPrice.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  priceChange24h >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 14,
                  color: priceChange24h >= 0 ? AppColors.positiveGreen : AppColors.negativeRed,
                ),
                const SizedBox(width: 2),
                Text(
                  '${priceChange24h.toStringAsFixed(2)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: priceChange24h >= 0 ? AppColors.positiveGreen : AppColors.negativeRed,
                      ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          // Navigate to coin detail
          Navigator.pushNamed(
            context,
            '/coin-detail',
            arguments: {
              'coinId': coin['id'],
              'coinName': coin['name'],
            },
          );
        },
      ),
    );
  }

  String _formatNumber(double number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(2)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(2)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(2)}K';
    }
    return number.toStringAsFixed(2);
  }
}