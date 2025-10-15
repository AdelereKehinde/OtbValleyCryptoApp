import 'package:flutter/foundation.dart';
import 'package:cheeseball/services/api_service.dart';
import 'package:cheeseball/providers/auth_provider.dart';

class PortfolioProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthProvider _authProvider;

  PortfolioProvider(this._authProvider);

  List<dynamic> _portfolio = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get portfolio => _portfolio;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalValue {
    return _portfolio.fold(0, (sum, holding) {
      return sum + (getHoldingCurrentValue(holding) ?? 0);
    });
  }

  double get dailyChange {
    // Mock implementation - in real app, calculate from price changes
    return totalValue * 0.025; // 2.5% gain
  }

  double get dailyChangePercent {
    return 2.5; // Mock 2.5%
  }

  String? get _token => _authProvider.token;

  Future<void> loadPortfolio() async {
    if (_token == null) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.getUserPortfolio(_token!);
      _portfolio = data;
    } catch (e) {
      _error = 'Failed to load portfolio: $e';
      _portfolio = _getMockPortfolio(); // Fallback to mock data
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  double? getHoldingCurrentValue(dynamic holding) {
    // Mock current prices - in real app, fetch from API
    final mockPrices = {
      'bitcoin': 43250.50,
      'ethereum': 2580.75,
      'cardano': 0.52,
    };
    
    final coinId = holding['coin_id'];
    final amount = holding['amount'] ?? 0;
    final currentPrice = mockPrices[coinId] ?? 0;
    
    return amount * currentPrice;
  }

  double getHoldingProfitLoss(dynamic holding) {
    final currentValue = getHoldingCurrentValue(holding) ?? 0;
    final purchaseValue = (holding['amount'] ?? 0) * (holding['purchase_price'] ?? 0);
    return currentValue - purchaseValue;
  }

  List<dynamic> _getMockPortfolio() {
    return [
      {
        'id': 1,
        'coin_id': 'bitcoin',
        'coin_symbol': 'btc',
        'coin_name': 'Bitcoin',
        'amount': 0.5,
        'purchase_price': 40000.0,
        'purchase_currency': 'usd',
        'purchase_date': '2024-01-15',
      },
      {
        'id': 2,
        'coin_id': 'ethereum',
        'coin_symbol': 'eth',
        'coin_name': 'Ethereum',
        'amount': 2.0,
        'purchase_price': 2400.0,
        'purchase_currency': 'usd',
        'purchase_date': '2024-01-20',
      },
    ];
  }
}