import 'package:flutter/material.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart'; // ADD THIS IMPORT
import 'screens/forgot_password_screen.dart'; // ADD THIS IMPORT
import 'screens/verify_otp_screen.dart'; // ADD THIS IMPORT
import 'screens/reset_password_screen.dart'; // ADD THIS IMPORT
import 'screens/home_dashboard.dart'; // ADD THIS IMPORT

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CheeseBall',
      home: const OnboardingScreen(),
      debugShowCheckedModeBanner: false,
      // ADD THESE ROUTES:
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/verify_otp': (context) => const VerifyOtpScreen(),
        '/reset_password': (context) => const ResetPasswordScreen(),
        '/home': (context) => const HomeDashboard(),
      },
    );
  }
}