class AppConstants {
  static const String appName = 'CheeseBall';
  static const String appVersion = '1.0.0';
  static const String apiBaseUrl = 'http://localhost:8000';
  
  // Cache durations
  static const int marketDataCacheDuration = 60; // seconds
  static const int chartDataCacheDuration = 300; // seconds
  
  // Default values
  static const String defaultCurrency = 'USD';
  static const int defaultChartDays = 7;
}

class RouteNames {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String markets = '/markets';
  static const String portfolio = '/portfolio';
  static const String watchlist = '/watchlist';
  static const String coinDetail = '/coin-detail';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String admin = '/admin';
}