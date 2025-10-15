import 'package:flutter/foundation.dart';
import 'package:cheeseball/services/api_service.dart';
import 'package:cheeseball/providers/auth_provider.dart';

class WatchlistProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthProvider _authProvider;

  WatchlistProvider(this._authProvider);

  List<dynamic> _watchlist = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get watchlist => _watchlist;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get _token => _authProvider.token;

  Future<void> loadWatchlist() async {
    if (_token == null) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.getUserWatchlist(_token!);
      _watchlist = data;
    } catch (e) {
      _error = 'Failed to load watchlist: $e';
      _watchlist = []; // Fallback to empty list
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToWatchlist(String coinId, String coinSymbol, String coinName) async {
    if (_token == null) return;
    
    try {
      await _apiService.addToWatchlist(_token!, coinId, coinSymbol, coinName);
      await loadWatchlist(); // Reload the watchlist
    } catch (e) {
      _error = 'Failed to add to watchlist: $e';
      notifyListeners();
    }
  }

  Future<void> removeFromWatchlist(String coinId) async {
    if (_token == null) return;
    
    try {
      // This would call your backend DELETE endpoint
      // For now, just remove locally
      _watchlist.removeWhere((item) => item['coin_id'] == coinId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to remove from watchlist: $e';
      notifyListeners();
    }
  }

  Future<void> refreshWatchlistPrices() async {
    // This would refresh prices for all coins in watchlist
    notifyListeners();
  }

  void sortByPriceChange() {
    _watchlist.sort((a, b) {
      final changeA = a['price_change_percentage_24h'] ?? 0;
      final changeB = b['price_change_percentage_24h'] ?? 0;
      return changeB.compareTo(changeA);
    });
    notifyListeners();
  }

  void sortByMarketCap() {
    _watchlist.sort((a, b) {
      final capA = a['market_cap'] ?? 0;
      final capB = b['market_cap'] ?? 0;
      return capB.compareTo(capA);
    });
    notifyListeners();
  }

  void sortAlphabetically() {
    _watchlist.sort((a, b) {
      final nameA = a['name']?.toString().toLowerCase() ?? '';
      final nameB = b['name']?.toString().toLowerCase() ?? '';
      return nameA.compareTo(nameB);
    });
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}