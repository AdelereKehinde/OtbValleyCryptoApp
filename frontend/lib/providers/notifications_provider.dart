import 'package:flutter/foundation.dart';
import 'package:cheeseball/services/api_service.dart';
import 'package:cheeseball/providers/auth_provider.dart';

class NotificationsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthProvider _authProvider;

  NotificationsProvider(this._authProvider);

  List<dynamic> _notifications = [];
  List<dynamic> _priceAlerts = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get notifications => _notifications;
  List<dynamic> get priceAlerts => _priceAlerts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get _token => _authProvider.token;

  Future<void> loadNotifications() async {
    if (_token == null) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load user alerts
      final alerts = await _apiService.getUserAlerts(_token!);
      _priceAlerts = alerts;
      
      // Generate notifications from alerts
      _generateNotifications();
    } catch (e) {
      _error = 'Failed to load notifications: $e';
      _notifications = _getMockNotifications();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _generateNotifications() {
    _notifications = [
      {
        'id': 1,
        'type': 'price_alert',
        'title': 'Price Alert Triggered',
        'message': 'Bitcoin reached your target price of \$45,000',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'read': false,
      },
      {
        'id': 2,
        'type': 'news',
        'title': 'Market Update',
        'message': 'Ethereum 2.0 upgrade completed successfully',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'read': true,
      },
      {
        'id': 3,
        'type': 'portfolio',
        'title': 'Portfolio Update',
        'message': 'Your portfolio gained 5.2% today',
        'timestamp': DateTime.now().subtract(const Duration(days: 2)),
        'read': true,
      },
    ];
  }

  Future<void> createPriceAlert(
    String coinId,
    double targetPrice,
    bool isAbove,
    String currency,
  ) async {
    if (_token == null) return;
    
    try {
      await _apiService.createPriceAlert(_token!, coinId, targetPrice, isAbove, currency);
      await loadNotifications(); // Reload to include new alert
    } catch (e) {
      _error = 'Failed to create price alert: $e';
      notifyListeners();
    }
  }

  Future<void> markAsRead(int notificationId) async {
    final notification = _notifications.firstWhere(
      (n) => n['id'] == notificationId,
      orElse: () => null,
    );
    
    if (notification != null) {
      notification['read'] = true;
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    for (final notification in _notifications) {
      notification['read'] = true;
    }
    notifyListeners();
  }

  Future<void> deleteNotification(int notificationId) async {
    _notifications.removeWhere((n) => n['id'] == notificationId);
    notifyListeners();
  }

  List<dynamic> _getMockNotifications() {
    return [
      {
        'id': 1,
        'type': 'price_alert',
        'title': 'Price Alert Triggered',
        'message': 'Bitcoin reached your target price of \$45,000',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'read': false,
      },
      {
        'id': 2,
        'type': 'news',
        'title': 'Market Update',
        'message': 'Ethereum 2.0 upgrade completed successfully',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'read': true,
      },
    ];
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}