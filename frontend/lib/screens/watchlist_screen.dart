import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cheeseball/providers/watchlist_provider.dart';
import 'package:cheeseball/widgets/coin_card.dart';
import 'package:cheeseball/theme/colors.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  _WatchlistScreenState createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WatchlistProvider>().loadWatchlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addToWatchlist,
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),
        ],
      ),
      body: Consumer<WatchlistProvider>(
        builder: (context, watchlistProvider, child) {
          final watchlist = watchlistProvider.watchlist;

          if (watchlist.isEmpty) {
            return _buildEmptyWatchlist();
          }

          return RefreshIndicator(
            onRefresh: () async {
              await watchlistProvider.refreshWatchlistPrices();
            },
            child: ListView.builder(
              itemCount: watchlist.length,
              itemBuilder: (context, index) {
                final coin = watchlist[index];
                return Dismissible(
                  key: Key(coin['id'] ?? ''),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    watchlistProvider.removeFromWatchlist(coin['id']);
                  },
                  child: CoinCard(coin: coin),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyWatchlist() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_outline,
            size: 80,
            color: AppTheme.neutralGray.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No coins in watchlist',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppTheme.neutralGray,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Add coins to track their prices',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.neutralGray,
                ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _addToWatchlist,
            icon: const Icon(Icons.add),
            label: const Text('Add Coins'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  void _addToWatchlist() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddToWatchlistScreen(),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Sort Watchlist',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.trending_up),
                title: const Text('Price Change (24h)'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<WatchlistProvider>().sortByPriceChange();
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('Market Cap'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<WatchlistProvider>().sortByMarketCap();
                },
              ),
              ListTile(
                leading: const Icon(Icons.abc),
                title: const Text('Alphabetical'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<WatchlistProvider>().sortAlphabetically();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class AddToWatchlistScreen extends StatefulWidget {
  const AddToWatchlistScreen({super.key});

  @override
  _AddToWatchlistScreenState createState() => _AddToWatchlistScreenState();
}

class _AddToWatchlistScreenState extends State<AddToWatchlistScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Add to Watchlist',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search coins...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: _performSearch,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final coin = _searchResults[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                          child: Text(
                            coin['symbol']?.toString().substring(0, 2).toUpperCase() ?? '??',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                        title: Text(coin['name'] ?? 'Unknown'),
                        subtitle: Text(coin['symbol']?.toString().toUpperCase() ?? ''),
                        trailing: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => _addCoinToWatchlist(coin),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    // In real app, call your search API
    setState(() {
      _searchResults = [
        {'id': 'bitcoin', 'name': 'Bitcoin', 'symbol': 'btc'},
        {'id': 'ethereum', 'name': 'Ethereum', 'symbol': 'eth'},
        {'id': 'cardano', 'name': 'Cardano', 'symbol': 'ada'},
      ].where((coin) => 
        coin['name']!.toLowerCase().contains(query.toLowerCase()) ||
        coin['symbol']!.toLowerCase().contains(query.toLowerCase())
      ).toList();
      _isSearching = false;
    });
  }

  void _addCoinToWatchlist(Map<String, dynamic> coin) {
    context.read<WatchlistProvider>().addToWatchlist(
      coin['id'],
      coin['symbol'],
      coin['name'],
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${coin['name']} added to watchlist'),
        backgroundColor: AppTheme.positiveGreen,
      ),
    );
  }
}