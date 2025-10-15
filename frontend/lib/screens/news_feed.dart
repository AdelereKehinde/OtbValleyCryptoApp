import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cheeseball/theme/colors.dart';


class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  _NewsFeedScreenState createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  final List<String> _categories = ['All', 'Bitcoin', 'Ethereum', 'DeFi', 'NFT', 'Regulation'];
  String _selectedCategory = 'All';
  bool _isLoading = true;

  final List<Map<String, dynamic>> _newsItems = [
    {
      'title': 'Bitcoin Surges Past $45,000 as Institutional Adoption Grows',
      'summary': 'Major financial institutions continue to add Bitcoin to their balance sheets, driving prices to new yearly highs.',
      'source': 'CryptoNews',
      'time': '2 hours ago',
      'image': 'https://via.placeholder.com/100',
      'url': 'https://example.com/news/1',
      'category': 'Bitcoin',
    },
    {
      'title': 'Ethereum 2.0 Upgrade Nears Completion, Staking Reaches All-Time High',
      'summary': 'The long-awaited Ethereum upgrade promises improved scalability and reduced energy consumption.',
      'source': 'Blockchain Daily',
      'time': '5 hours ago',
      'image': 'https://via.placeholder.com/100',
      'url': 'https://example.com/news/2',
      'category': 'Ethereum',
    },
    {
      'title': 'DeFi Total Value Locked Crosses $100 Billion Milestone',
      'summary': 'Decentralized finance protocols continue to attract massive capital inflows despite market volatility.',
      'source': 'DeFi Pulse',
      'time': '1 day ago',
      'image': 'https://via.placeholder.com/100',
      'url': 'https://example.com/news/3',
      'category': 'DeFi',
    },
    {
      'title': 'NFT Market Sees Record-Breaking Sales in Digital Art Collection',
      'summary': 'A collection of digital artworks sold for over $20 million, signaling strong demand for NFT assets.',
      'source': 'NFT Insider',
      'time': '2 days ago',
      'image': 'https://via.placeholder.com/100',
      'url': 'https://example.com/news/4',
      'category': 'NFT',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  void _loadNews() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto News'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _searchNews,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _filterNews,
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter
          _buildCategoryFilter(),
          // News list
          Expanded(
            child: _isLoading
                ? _buildLoadingIndicator()
                : _buildNewsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: FilterChip(
              label: Text(_categories[index]),
              selected: _selectedCategory == _categories[index],
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = _categories[index];
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 14,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 100,
                        height: 12,
                        color: Colors.grey.shade300,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNewsList() {
    final filteredNews = _selectedCategory == 'All'
        ? _newsItems
        : _newsItems.where((item) => item['category'] == _selectedCategory).toList();

    if (filteredNews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article,
              size: 64,
              color: AppColors.neutralGray.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No news found',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppColors.neutralGray,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try changing your filters',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.neutralGray,
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshNews,
      child: ListView.builder(
        itemCount: filteredNews.length,
        itemBuilder: (context, index) {
          final newsItem = filteredNews[index];
          return _buildNewsItem(newsItem);
        },
      ),
    );
  }

  Widget _buildNewsItem(Map<String, dynamic> newsItem) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _openNewsArticle(newsItem['url']),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // News image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  image: DecorationImage(
                    image: NetworkImage(newsItem['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // News content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      newsItem['title'],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      newsItem['summary'],
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          newsItem['source'],
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.neutralGray,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          newsItem['time'],
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.neutralGray,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshNews() async {
    setState(() {
      _isLoading = true;
    });
    await _loadNews();
  }

  void _searchNews() {
    showSearch(
      context: context,
      delegate: NewsSearchDelegate(),
    );
  }

  void _filterNews() {
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
                  'Filter News',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ..._categories.map((category) {
                return ListTile(
                  title: Text(category),
                  trailing: _selectedCategory == category
                      ? const Icon(Icons.check, color: AppColors.primaryBlue)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _openNewsArticle(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open news article'),
          backgroundColor: AppColors.negativeRed,
        ),
      );
    }
  }
}

class NewsSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return const Center(
      child: Text('Search results would appear here'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(
      child: Text('Search for crypto news...'),
    );
  }
}