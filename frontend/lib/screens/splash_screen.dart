import 'package:flutter/material.dart';
import 'package:cheeseball/screens/onboarding_screen.dart';
import 'package:cheeseball/theme/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToOnboarding();
  }


  _navigateToOnboarding() async {
  print('🔄 SplashScreen: Starting navigation...');
  
  // Wait for 2 seconds
  await Future.delayed(const Duration(seconds: 2));
  print('🔄 SplashScreen: 2 seconds passed, navigating...');
  
  // Navigate to OnboardingScreen
  if (mounted) {
    print('🔄 SplashScreen: Context is mounted, pushing replacement...');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
    );
    print('✅ SplashScreen: Navigation completed!');
  } else {
    print('❌ SplashScreen: Context not mounted!');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.currency_bitcoin,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              'CheeseBall',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'Crypto Tracker',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}