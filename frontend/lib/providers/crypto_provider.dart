import 'package:flutter/foundation.dart';
import 'package:cheeseball/services/api_service.dart';
import 'package:cheeseball/providers/auth_provider.dart';

class CryptoProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthProvider _authProvider;

  CryptoProvider(this._authProvider);

  List<dynamic> _marketData = [];
  Map<String, dynamic>? _globalData;
  Map<String, dynamic>? _coinDetail;
  Map<String, dynamic>? _chartData;
  List<dynamic> _trendingCoins = [];
  List<dynamic> _coinTickers = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get marketData => _marketData;
  Map<String, dynamic>? get globalData => _globalData;
  Map<String, dynamic>? get coinDetail => _coinDetail;
  Map<String, dynamic>? get chartData => _chartData;
  List<dynamic> get trendingCoins => _trendingCoins;
  List<dynamic> get coinTickers => _coinTickers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get _token => _authProvider.token;

  Future<void> fetchGlobalData() async {
    if (_token == null) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // This would call your backend /global endpoint
      // For now, using mock data
      await Future.delayed(const Duration(seconds: 1));
      _globalData = {
        'data': {
          'total_market_cap': {'usd': 1720000000000},
          'total_volume': {'usd': 85000000000},
          'market_cap_percentage': {'btc': 48.2, 'eth': 17.5},
          'market_cap_change_percentage_24h_usd': 2.5,
        }
      };
    } catch (e) {
      _error = 'Failed to load global data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMarketData({
    String vsCurrency = 'usd',
    String? ids,
    String? category,
    String order = 'market_cap_desc',
    int perPage = 100,
    int page = 1,
  }) async {
    if (_token == null) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.getMarketData(
        token: _token!,
        vsCurrency: vsCurrency,
        category: category,
        order: order,
        perPage: perPage,
      );
      _marketData = data;
    } catch (e) {
      _error = 'Failed to load market data: $e';
      // Fallback to mock data
      _marketData = _getMockMarketData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCoinDetail(String coinId) async {
    if (_token == null) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.getCoinDetail(_token!, coinId);
      _coinDetail = data;
    } catch (e) {
      _error = 'Failed to load coin details: $e';
      // Fallback to mock data
      _coinDetail = _getMockCoinDetail(coinId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> fetchCoinChart(String coinId, {int days = 7, String vsCurrency = 'usd'}) async {
    if (_token == null) return {};
    
    try {
      // This would call your backend chart endpoint
      await Future.delayed(const Duration(seconds: 1));
      return _getMockChartData();
    } catch (e) {
      return {};
    }
  }

  Future<List<dynamic>> searchCoins(String query) async {
    if (_token == null) return [];
    
    try {
      final coinsList = await _apiService.getCoinsList(_token!);
      return coinsList.where((coin) {
        final name = coin['name']?.toString().toLowerCase() ?? '';
        final symbol = coin['symbol']?.toString().toLowerCase() ?? '';
        final searchLower = query.toLowerCase();
        return name.contains(searchLower) || symbol.contains(searchLower);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> fetchTrending() async {
    if (_token == null) return [];
    
    try {
      // This would call your backend trending endpoint
      await Future.delayed(const Duration(seconds: 1));
      return _getMockTrendingData();
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> fetchCategories() async {
    if (_token == null) return [];
    
    try {
      // This would call your backend categories endpoint
      await Future.delayed(const Duration(seconds: 1));
      return _getMockCategories();
    } catch (e) {
      return [];
    }
  }

  Future<void> fetchCoinTickers(String coinId) async {
    if (_token == null) return;
    
    try {
      // This would call your backend tickers endpoint
      await Future.delayed(const Duration(seconds: 1));
      _coinTickers = _getMockTickers();
      notifyListeners();
    } catch (e) {
      _coinTickers = [];
      notifyListeners();
    }
  }

  // Mock data methods (replace with actual API calls)
  List<dynamic> _getMockMarketData() {
    return [
      {
        'id': 'bitcoin',
        'symbol': 'btc',
        'name': 'Bitcoin',
        'current_price': 43250.50,
        'price_change_percentage_24h': 2.5,
        'market_cap': 845000000000,
        'market_cap_rank': 1,
        'total_volume': 28500000000,
        'image': 'https://assets.coingecko.com/coins/images/1/small/bitcoin.png',
      },
      {
        'id': 'ethereum',
        'symbol': 'eth',
        'name': 'Ethereum',
        'current_price': 2580.75,
        'price_change_percentage_24h': 1.8,
        'market_cap': 310000000000,
        'market_cap_rank': 2,
        'total_volume': 15200000000,
        'image': 'https://assets.coingecko.com/coins/images/279/small/ethereum.png',
      },
    ];
  }

  Map<String, dynamic> _getMockCoinDetail(String coinId) {
    return {
      'id': coinId,
      'name': coinId == 'bitcoin' ? 'Bitcoin' : 'Ethereum',
      'symbol': coinId == 'bitcoin' ? 'btc' : 'eth',
      'description': {'en': 'Description for $coinId'},
      'market_data': {
        'current_price': {'usd': coinId == 'bitcoin' ? 43250.50 : 2580.75},
        'price_change_24h': coinId == 'bitcoin' ? 1050.25 : 45.80,
        'price_change_percentage_24h': coinId == 'bitcoin' ? 2.5 : 1.8,
        'market_cap': {'usd': coinId == 'bitcoin' ? 845000000000 : 310000000000},
        'total_volume': {'usd': coinId == 'bitcoin' ? 28500000000 : 15200000000},
        'circulating_supply': coinId == 'bitcoin' ? 19500000 : 120000000},
      'links': {
        'homepage': ['https://bitcoin.org/'],
        'twitter_screen_name': 'bitcoin',
      }
    };
  }

  Map<String, dynamic> _getMockChartData() {
    return {
      'prices': [
        [1638316800000, 43250.50],
        [1638403200000, 43500.25],
        [1638489600000, 42800.75],
        [1638576000000, 43100.30],
        [1638662400000, 43350.60],
        [1638748800000, 43000.20],
        [1638835200000, 43250.50],
      ]
    };
  }

  List<dynamic> _getMockTrendingData() {
    return [
      {
        'item': {
          'id': 'bitcoin',
          'name': 'Bitcoin',
          'symbol': 'btc',
          'price_btc': 1.0,
        }
      },
      {
        'item': {
          'id': 'ethereum',
          'name': 'Ethereum',
          'symbol': 'eth',
          'price_btc': 0.06,
        }
      },
    ];
  }

  List<dynamic> _getMockCategories() {
    return [
      {'id': 'decentralized-finance-defi', 'name': 'DeFi'},
      {'id': 'gaming', 'name': 'Gaming'},
      {'id': 'meme-token', 'name': 'Meme'},
    ];
  }

  List<dynamic> _getMockTickers() {
    return [
      {
        'market': {'name': 'Binance', 'logo': 'https://example.com/binance.png'},
        'base': 'BTC',
        'target': 'USDT',
        'last': 43250.50,
        'volume': 1250000000,
        'trust_score': 'green',
      },
      {
        'market': {'name': 'Coinbase', 'logo': 'https://example.com/coinbase.png'},
        'base': 'BTC',
        'target': 'USD',
        'last': 43248.75,
        'volume': 850000000,
        'trust_score': 'green',
      },
    ];
  }
}