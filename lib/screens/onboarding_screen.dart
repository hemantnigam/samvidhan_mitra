import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_provider.dart';
import '../utils/constants.dart';
import 'chat_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.language,
                size: 80,
                color: AppConstants.primaryBlue,
              ),
              const SizedBox(height: 32),
              const Text(
                'Choose your language to start\nअपनी भाषा चुनकर शुरू करें',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryBlue,
                ),
              ),
              const SizedBox(height: 48),
              _LanguageButton(
                title: 'ENGLISH',
                subtitle: 'Continue in English',
                onPressed: () {
                  context.read<ChatProvider>().setLanguage('en_IN');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
              _LanguageButton(
                title: 'हिंदी',
                subtitle: 'हिंदी में जारी रखें',
                onPressed: () {
                  context.read<ChatProvider>().setLanguage('hi_IN');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  const _LanguageButton({
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppConstants.primaryBlue,
        padding: const EdgeInsets.symmetric(vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppConstants.primaryBlue, width: 2),
        ),
        elevation: 4,
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
