import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cheeseball/providers/portfolio_provider.dart';
import 'package:cheeseball/widgets/portfolio_chart.dart';
import 'package:cheeseball/theme/colors.dart';


class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  _PortfolioScreenState createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PortfolioProvider>().loadPortfolio();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addHolding,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showPortfolioOptions,
          ),
        ],
      ),
      body: Consumer<PortfolioProvider>(
        builder: (context, portfolioProvider, child) {
          final portfolio = portfolioProvider.portfolio;
          final totalValue = portfolioProvider.totalValue;
          final dailyChange = portfolioProvider.dailyChange;
          final dailyChangePercent = portfolioProvider.dailyChangePercent;

          return Column(
            children: [
              // Portfolio Summary
              _buildPortfolioSummary(totalValue, dailyChange, dailyChangePercent),
              // Portfolio Chart
              const Expanded(
                flex: 2,
                child: PortfolioChart(),
              ),
              // Holdings List
              Expanded(
                flex: 3,
                child: _buildHoldingsList(portfolio, portfolioProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPortfolioSummary(double totalValue, double dailyChange, double dailyChangePercent) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue.withOpacity(0.8),
            AppTheme.secondaryBlue.withOpacity(0.9),
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            'Total Portfolio Value',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${totalValue.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                dailyChange >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                color: dailyChange >= 0 ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '\$${dailyChange.abs().toStringAsFixed(2)} (${dailyChangePercent.toStringAsFixed(2)}%)',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: dailyChange >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(width: 8),
              Text(
                'Today',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingsList(List<dynamic> portfolio, PortfolioProvider portfolioProvider) {
    if (portfolio.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wallet,
              size: 64,
              color: AppTheme.neutralGray.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No holdings yet',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.neutralGray,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first cryptocurrency holding',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.neutralGray,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _addHolding,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
              ),
              child: const Text('Add Holding'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: portfolio.length,
      itemBuilder: (context, index) {
        final holding = portfolio[index];
        final currentValue = portfolioProvider.getHoldingCurrentValue(holding);
        final profitLoss = portfolioProvider.getHoldingProfitLoss(holding);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
              child: Text(
                holding.symbol.substring(0, 2).toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
            title: Text(
              holding.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${holding.amount} ${holding.symbol.toUpperCase()}'),
                Text(
                  'Buy: \$${holding.purchasePrice.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '\$${currentValue.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  '${profitLoss >= 0 ? '+' : ''}\$${profitLoss.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: profitLoss >= 0 ? AppTheme.positiveGreen : AppTheme.negativeRed,
                      ),
                ),
              ],
            ),
            onTap: () => _editHolding(holding),
          ),
        );
      },
    );
  }

  void _addHolding() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddHoldingScreen(),
    );
  }

  void _editHolding(dynamic holding) {
    // Implement edit holding
  }

  void _showPortfolioOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.file_download),
                title: const Text('Export Portfolio'),
                onTap: () {
                  Navigator.pop(context);
                  _exportPortfolio();
                },
              ),
              ListTile(
                leading: const Icon(Icons.analytics),
                title: const Text('Portfolio Analytics'),
                onTap: () {
                  Navigator.pop(context);
                  _showAnalytics();
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Transaction History'),
                onTap: () {
                  Navigator.pop(context);
                  _showTransactionHistory();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _exportPortfolio() {
    // Implement portfolio export
  }

  void _showAnalytics() {
    // Implement analytics screen
  }

  void _showTransactionHistory() {
    // Implement transaction history
  }
}

class AddHoldingScreen extends StatefulWidget {
  const AddHoldingScreen({super.key});

  @override
  _AddHoldingScreenState createState() => _AddHoldingScreenState();
}

class _AddHoldingScreenState extends State<AddHoldingScreen> {
  // Implementation for adding holdings
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}