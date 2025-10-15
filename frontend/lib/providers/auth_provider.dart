import 'package:flutter/material.dart';
import 'package:cheeseball/services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  String? _token;
  Map<String, dynamic>? _currentUser;
  bool _isLoading = false;
  String? _error;

  String? get token => _token;
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _token != null;

  Future<bool> login(String username, String password) async {
    setLoading(true);
    _error = null;
    
    try {
      final response = await _apiService.login(username, password);
      _token = response['access_token'];
      _currentUser = response['user'];
      notifyListeners();
      setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String username, String email, String password, String preferredCurrency) async {
    setLoading(true);
    _error = null;
    
    try {
      final response = await _apiService.register(username, email, password, preferredCurrency);
      // Auto-login after registration
      return await login(username, password);
    } catch (e) {
      _error = e.toString();
      setLoading(false);
      notifyListeners();
      return false;
    }
  }

  void signOut() {
    _token = null;
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}