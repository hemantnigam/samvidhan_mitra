import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'main_layout.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainLayout()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.paperWhite,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_balance,
              size: 80,
              color: AppConstants.primaryNavy,
            ),
            const SizedBox(height: 24),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppConstants.primaryNavy,
                fontFamily: 'Newsreader',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Constitution for Everyone',
              style: TextStyle(
                fontSize: 14,
                color: AppConstants.secondaryGray,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
