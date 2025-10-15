import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8000'; // Your FastAPI backend

  // Authentication
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Login failed: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
    String preferredCurrency,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
        'preferred_currency': preferredCurrency,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Registration failed: ${response.statusCode}');
    }
  }

  // CoinGecko API Proxies
  Future<List<dynamic>> getCoinsList(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/coins/list'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load coins list');
    }
  }

  Future<List<dynamic>> getMarketData({
    required String token,
    String vsCurrency = 'usd',
    String? category,
    String order = 'market_cap_desc',
    int perPage = 100,
  }) async {
    final params = {
      'vs_currency': vsCurrency,
      'order': order,
      'per_page': perPage.toString(),
    };
    
    if (category != null) {
      params['category'] = category;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/coins/markets').replace(queryParameters: params),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load market data');
    }
  }

  Future<Map<String, dynamic>> getCoinDetail(String token, String coinId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/coins/$coinId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load coin detail');
    }
  }

  // User-specific endpoints
  Future<List<dynamic>> getUserWatchlist(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/watchlist'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load watchlist');
    }
  }

  Future<Map<String, dynamic>> addToWatchlist(
    String token,
    String coinId,
    String coinSymbol,
    String coinName,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/watchlist'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'coin_id': coinId,
        'coin_symbol': coinSymbol,
        'coin_name': coinName,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add to watchlist');
    }
  }

  // Admin endpoints
  Future<Map<String, dynamic>> getAdminStatistics(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/statistics'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load admin statistics');
    }
  }

  Future<List<dynamic>> getAllUsers(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/users'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> deactivateUser(int userId, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/users/$userId/deactivate'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to deactivate user');
    }
  }

  Future<void> activateUser(int userId, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/users/$userId/activate'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to activate user');
    }
  }

  Future<List<dynamic>> getUserPortfolio(String token) async {
  final response = await http.get(
    Uri.parse('$baseUrl/user/portfolio'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load portfolio');
  }
}


Future<List<dynamic>> getUserAlerts(String token) async {
  final response = await http.get(
    Uri.parse('$baseUrl/user/alerts'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load alerts');
  }
}

Future<Map<String, dynamic>> createPriceAlert(
  String token,
  String coinId,
  double targetPrice,
  bool isAbove,
  String currency,
) async {
  final response = await http.post(
    Uri.parse('$baseUrl/user/alerts'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'coin_id': coinId,
      'target_price': targetPrice,
      'is_above': isAbove,
      'currency': currency,
    }),
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to create price alert');
  }
}
}