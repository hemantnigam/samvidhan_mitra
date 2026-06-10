import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_provider.dart';
import '../utils/constants.dart';
import 'main_layout.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.paperWhite,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildLanguagePage(context),
                  _buildFeaturePage(
                    context,
                    "Know Your Rights",
                    "Understand the Constitution of India in simple words, grounded in the official text.",
                    Icons.gavel,
                  ),
                  _buildFeaturePage(
                    context,
                    "AI Powered Assistant",
                    "Ask Samvidhan Mitra anything about your rights and get instant, simplified answers.",
                    Icons.auto_awesome,
                  ),
                ],
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguagePage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.language, size: 64, color: AppConstants.accentWheat),
          const SizedBox(height: 32),
          Text(
            "Select Language",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontFamily: 'Newsreader'),
          ),
          const SizedBox(height: 12),
          const Text(
            "अपनी भाषा चुनकर शुरू करें",
            style: TextStyle(color: AppConstants.secondaryGray, fontSize: 18),
          ),
          const SizedBox(height: 48),
          _buildLangButton(context, "English", "Continue in English", "en_IN"),
          const SizedBox(height: 16),
          _buildLangButton(context, "हिंदी", "हिंदी में जारी रखें", "hi_IN"),
        ],
      ),
    );
  }

  Widget _buildLangButton(BuildContext context, String title, String sub, String locale) {
    return InkWell(
      onTap: () {
        // Update the provider's locale based on selection
        final chatProvider = context.read<ChatProvider>();
        if (chatProvider.speechLocale != locale) {
          chatProvider.toggleSpeechLocale();
        }
        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppConstants.secondaryGray.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(sub, style: const TextStyle(color: AppConstants.secondaryGray, fontSize: 12)),
              ],
            ),
            const Icon(Icons.chevron_right, color: AppConstants.secondaryGray),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturePage(BuildContext context, String title, String desc, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: AppConstants.primaryNavy),
          const SizedBox(height: 40),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontFamily: 'Newsreader'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            desc,
            style: const TextStyle(color: AppConstants.secondaryGray, fontSize: 16, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(3, (index) => _buildDot(index)),
          ),
          ElevatedButton(
            onPressed: () {
              if (_currentPage < 2) {
                _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
              } else {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainLayout()));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryNavy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: Text(_currentPage == 2 ? "Get Started" : "Next"),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? AppConstants.accentWheat : AppConstants.secondaryGray.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
