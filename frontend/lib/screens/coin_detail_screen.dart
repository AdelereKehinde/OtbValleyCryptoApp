import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cheeseball/providers/crypto_provider.dart';
import 'package:cheeseball/widgets/price_chart.dart';
import 'package:cheeseball/theme/app_theme.dart'; 
import 'package:cheeseball/theme/colors.dart';


class CoinDetailScreen extends StatefulWidget {
  final String coinId;
  final String coinName;

  const CoinDetailScreen({
    super.key,
    required this.coinId,
    required this.coinName,
  });

  @override
  _CoinDetailScreenState createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends State<CoinDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CryptoProvider>().fetchCoinDetail(widget.coinId);
      context.read<CryptoProvider>().fetchCoinChart(widget.coinId, days: 7);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.coinName),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareCoin,
          ),
          IconButton(
            icon: const Icon(Icons.star_border),
            onPressed: _addToWatchlist,
          ),
        ],
      ),
      body: Consumer<CryptoProvider>(
        builder: (context, cryptoProvider, child) {
          final coinDetail = cryptoProvider.coinDetail;
          final chartData = cryptoProvider.chartData;

          if (coinDetail == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price Section
                _buildPriceSection(coinDetail),
                const SizedBox(height: 24),
                
                // Chart Section
                PriceChart(
                  chartData: chartData,
                  coinId: widget.coinId,
                ),
                const SizedBox(height: 24),
                
                // Market Stats
                _buildMarketStats(coinDetail),
                const SizedBox(height: 24),
                
                // About Section
                _buildAboutSection(coinDetail),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPriceSection(Map<String, dynamic> coinDetail) {
    final marketData = coinDetail['market_data'];
    final currentPrice = marketData?['current_price']?['usd'] ?? 0.0;
    final priceChange24h = marketData?['price_change_24h'] ?? 0.0;
    final priceChangePercentage24h = marketData?['price_change_percentage_24h'] ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '\$${currentPrice.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              priceChange24h >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
              color: priceChange24h >= 0 ? AppTheme.positiveGreen : AppTheme.negativeRed,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              '\$${priceChange24h.abs().toStringAsFixed(2)} (${priceChangePercentage24h.toStringAsFixed(2)}%)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: priceChange24h >= 0 ? AppTheme.positiveGreen : AppTheme.negativeRed,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMarketStats(Map<String, dynamic> coinDetail) {
    final marketData = coinDetail['market_data'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Market Stats',
          style: Theme.of(context).textTheme.displayMedium,
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
            _buildStatCard(
              'Market Cap',
              '\$${_formatNumber(marketData?['market_cap']?['usd'] ?? 0)}',
            ),
            _buildStatCard(
              '24h Volume',
              '\$${_formatNumber(marketData?['total_volume']?['usd'] ?? 0)}',
            ),
            _buildStatCard(
              'Circulating Supply',
              _formatNumber(marketData?['circulating_supply'] ?? 0),
            ),
            _buildStatCard(
              'Total Supply',
              _formatNumber(marketData?['total_supply'] ?? 0),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAboutSection(Map<String, dynamic> coinDetail) {
    final description = coinDetail['description']?['en'] ?? 'No description available.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 16),
        Text(
          description.length > 300 ? '${description.substring(0, 300)}...' : description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.neutralGray,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(dynamic number) {
    if (number is num) {
      if (number >= 1000000000) {
        return '${(number / 1000000000).toStringAsFixed(2)}B';
      } else if (number >= 1000000) {
        return '${(number / 1000000).toStringAsFixed(2)}M';
      } else if (number >= 1000) {
        return '${(number / 1000).toStringAsFixed(2)}K';
      }
      return number.toStringAsFixed(2);
    }
    return '0';
  }

  void _shareCoin() {
    // Implement share functionality
  }

  void _addToWatchlist() {
    // Implement add to watchlist functionality
  }
}