import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cheeseball/providers/crypto_provider.dart';
import 'package:cheeseball/theme/colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  List<dynamic> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _searchFocusNode.requestFocus();
  }

  void _loadRecentSearches() {
    // Load recent searches from local storage
    _recentSearches = []; // Placeholder
  }

  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await context.read<CryptoProvider>().searchCoins(query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: const InputDecoration(
            hintText: 'Search coins, tokens...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          onChanged: _performSearch,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _performSearch('');
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchController.text.isNotEmpty && _searchResults.isEmpty) {
      return const Center(
        child: Text('No results found'),
      );
    }

    if (_searchController.text.isNotEmpty) {
      return _buildSearchResults();
    }

    return _buildRecentSearches();
  }

  Widget _buildSearchResults() {
    return ListView.builder(
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
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _navigateToCoinDetail(coin);
          },
        );
      },
    );
  }

  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Recent Searches',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (_recentSearches.isEmpty)
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Search for cryptocurrencies',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: _recentSearches.length,
              itemBuilder: (context, index) {
                final coin = _recentSearches[index];
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(coin['name']),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => _removeRecentSearch(coin),
                  ),
                  onTap: () => _navigateToCoinDetail(coin),
                );
              },
            ),
          ),
        // Trending section
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Trending',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _buildTrendingSection(),
      ],
    );
  }

  Widget _buildTrendingSection() {
    return FutureBuilder<List<dynamic>>(
      future: context.read<CryptoProvider>().fetchTrending(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final trending = snapshot.data ?? [];

        return SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: trending.length,
            itemBuilder: (context, index) {
              final coin = trending[index]['item'];
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 12, left: index == 0 ? 16 : 0),
                child: Card(
                  child: InkWell(
                    onTap: () => _navigateToCoinDetail(coin),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                            child: Text(
                              coin['symbol']?.toString().substring(0, 2).toUpperCase() ?? '??',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            coin['name'] ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            coin['symbol']?.toString().toUpperCase() ?? '',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _navigateToCoinDetail(Map<String, dynamic> coin) {
    // Add to recent searches
    _addToRecentSearches(coin);
    
    Navigator.pushNamed(
      context,
      '/coin-detail',
      arguments: {
        'coinId': coin['id'],
        'coinName': coin['name'],
      },
    );
  }

  void _addToRecentSearches(Map<String, dynamic> coin) {
    // Implement recent searches storage
  }

  void _removeRecentSearch(Map<String, dynamic> coin) {
    // Implement remove from recent searches
  }
}