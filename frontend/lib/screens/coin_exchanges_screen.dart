import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cheeseball/providers/crypto_provider.dart';
import 'package:cheeseball/theme/app_theme.dart'; 


class CoinExchangesScreen extends StatefulWidget {
  final String coinId;
  final String coinName;

  const CoinExchangesScreen({
    super.key,
    required this.coinId,
    required this.coinName,
  });

  @override
  _CoinExchangesScreenState createState() => _CoinExchangesScreenState();
}

class _CoinExchangesScreenState extends State<CoinExchangesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CryptoProvider>().fetchCoinTickers(widget.coinId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.coinName} Exchanges'),
      ),
      body: Consumer<CryptoProvider>(
        builder: (context, cryptoProvider, child) {
          final tickers = cryptoProvider.coinTickers;

          if (tickers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Exchange stats
              _buildExchangeStats(tickers),
              // Exchanges list
              Expanded(
                child: ListView.builder(
                  itemCount: tickers.length,
                  itemBuilder: (context, index) {
                    final ticker = tickers[index];
                    return _buildExchangeItem(ticker);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildExchangeStats(List<dynamic> tickers) {
    double totalVolume = 0;
    double highestPrice = 0;
    double lowestPrice = double.infinity;

    for (final ticker in tickers) {
      final volume = ticker['volume'] ?? 0;
      final price = ticker['last'] ?? 0;
      
      totalVolume += volume;
      if (price > highestPrice) highestPrice = price;
      if (price < lowestPrice) lowestPrice = price;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.05),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildExchangeStat('Total Volume', '\$${_formatNumber(totalVolume)}'),
          _buildExchangeStat('Highest Price', '\$${highestPrice.toStringAsFixed(2)}'),
          _buildExchangeStat('Lowest Price', '\$${lowestPrice.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _buildExchangeStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.neutralGray,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildExchangeItem(Map<String, dynamic> ticker) {
    final market = ticker['market'] ?? {};
    final base = ticker['base'] ?? '';
    final target = ticker['target'] ?? '';
    final last = ticker['last'] ?? 0;
    final volume = ticker['volume'] ?? 0;
    final trustScore = ticker['trust_score'] ?? 'gray';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppTheme.primaryBlue.withOpacity(0.1),
          ),
          child: market['logo'] != null 
              ? Image.network(market['logo']!)
              : Icon(Icons.currency_exchange, color: AppTheme.primaryBlue),
        ),
        title: Text(
          market['name'] ?? 'Unknown Exchange',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$base/$target'),
            Text(
              'Volume: \$${_formatNumber(volume)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '\$${last.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            _buildTrustScore(trustScore),
          ],
        ),
        onTap: () => _openExchange(market),
      ),
    );
  }

  Widget _buildTrustScore(String score) {
    Color color;
    switch (score) {
      case 'green':
        color = AppTheme.positiveGreen;
        break;
      case 'yellow':
        color = Colors.orange;
        break;
      case 'red':
        color = AppTheme.negativeRed;
        break;
      default:
        color = AppTheme.neutralGray;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        score.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
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

  void _openExchange(Map<String, dynamic> market) {
    final url = market['trade_url'];
    if (url != null) {
      // Implement URL launching
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening ${market['name']}...'),
          backgroundColor: AppTheme.primaryBlue,
        ),
      );
    }
  }
}