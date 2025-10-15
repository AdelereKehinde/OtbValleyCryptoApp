import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cheeseball/theme/app_theme.dart';
import 'package:cheeseball/providers/theme_provider.dart';
import 'package:cheeseball/providers/auth_provider.dart';
import 'package:cheeseball/providers/crypto_provider.dart';
import 'package:cheeseball/providers/watchlist_provider.dart';
import 'package:cheeseball/providers/portfolio_provider.dart';
import 'package:cheeseball/screens/onboarding_screen.dart';
import 'package:cheeseball/providers/notifications_provider.dart';

class CheeseBallApp extends StatelessWidget {
  const CheeseBallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, CryptoProvider>(
          create: (context) => CryptoProvider(Provider.of<AuthProvider>(context, listen: false)),
          update: (context, authProvider, cryptoProvider) =>
              CryptoProvider(authProvider),
        ),
        ChangeNotifierProxyProvider<AuthProvider, WatchlistProvider>(
          create: (context) => WatchlistProvider(Provider.of<AuthProvider>(context, listen: false)),
          update: (context, authProvider, watchlistProvider) =>
              WatchlistProvider(authProvider),
        ),
        ChangeNotifierProxyProvider<AuthProvider, PortfolioProvider>(
          create: (context) => PortfolioProvider(Provider.of<AuthProvider>(context, listen: false)),
          update: (context, authProvider, portfolioProvider) =>
              PortfolioProvider(authProvider),
        ),
        ChangeNotifierProxyProvider<AuthProvider, NotificationsProvider>(
          create: (context) => NotificationsProvider(Provider.of<AuthProvider>(context, listen: false)),
          update: (context, authProvider, notificationsProvider) =>
              NotificationsProvider(authProvider),
        ),
      ],
      builder: (context, child) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        return MaterialApp(
          title: 'CheeseBall',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          debugShowCheckedModeBanner: false,
          home: const OnboardingScreen(),
        );
      },
    );
  }
}