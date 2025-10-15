import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cheeseball/providers/crypto_provider.dart';
import 'package:cheeseball/widgets/coin_card.dart';
import 'package:cheeseball/theme/app_theme.dart'; 
import 'package:cheeseball/theme/colors.dart';


class MarketOverviewScreen extends StatefulWidget {
  const MarketOverviewScreen({super.key});

  @override
  _MarketOverviewScreenState createState() => _MarketOverviewScreenState();
}

class _MarketOverviewScreenState extends State<MarketOverviewScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = ['All', 'DeFi', 'Gaming', 'Layer 1', 'Meme', 'Stablecoins'];
  String _selectedCategory = 'All';
  String _sortBy = 'market_cap_desc';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMarketData();
  }

  void _loadMarketData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CryptoProvider>().fetchMarketData(
            category: _selectedCategory == 'All' ? null : _selectedCategory.toLowerCase(),
            order: _sortBy,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Markets'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Coins'),
            Tab(text: 'Categories'),
            Tab(text: 'Exchanges'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCoinsTab(),
          _buildCategoriesTab(),
          _buildExchangesTab(),
        ],
      ),
    );
  }

  Widget _buildCoinsTab() {
    return Consumer<CryptoProvider>(
      builder: (context, cryptoProvider, child) {
        return Column(
          children: [
            // Filters
            _buildFilters(),
            // Market List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await cryptoProvider.fetchMarketData(
                    category: _selectedCategory == 'All' ? null : _selectedCategory.toLowerCase(),
                    order: _sortBy,
                  );
                },
                child: ListView.builder(
                  itemCount: cryptoProvider.marketData.length,
                  itemBuilder: (context, index) {
                    final coin = cryptoProvider.marketData[index];
                    return CoinCard(coin: coin);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Category Dropdown
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                  _loadMarketData();
                });
              },
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Sort Dropdown
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _sortBy,
              items: const [
                DropdownMenuItem(value: 'market_cap_desc', child: Text('Market Cap')),
                DropdownMenuItem(value: 'volume_desc', child: Text('Volume')),
                DropdownMenuItem(value: 'id_asc', child: Text('Name A-Z')),
                DropdownMenuItem(value: 'price_change_percentage_24h_desc', child: Text('Top Gainers')),
                DropdownMenuItem(value: 'price_change_percentage_24h_asc', child: Text('Top Losers')),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _sortBy = newValue!;
                  _loadMarketData();
                });
              },
              decoration: const InputDecoration(
                labelText: 'Sort By',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return FutureBuilder<List<dynamic>>(
      future: context.read<CryptoProvider>().fetchCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final categories = snapshot.data ?? [];

        return ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.category, color: AppTheme.primaryBlue),
              ),
              title: Text(
                category['name'] ?? 'Unknown',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              subtitle: Text(
                'Top Gainers: ${category['top_3_coins']?.join(', ') ?? 'N/A'}',
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to category detail
              },
            );
          },
        );
      },
    );
  }

  Widget _buildExchangesTab() {
    return const Center(
      child: Text(
        'Exchanges data coming soon...',
        style: TextStyle(color: AppTheme.neutralGray),
      ),
    );
  }
}