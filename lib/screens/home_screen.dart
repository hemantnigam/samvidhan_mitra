import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import '../services/chat_provider.dart';
import '../services/constitution_service.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onTabChange;
  const HomeScreen({super.key, this.onTabChange});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ConstitutionService _constitutionService = ConstitutionService();
  Map<String, dynamic>? _dailyArticle;
  bool _isLoadingDaily = true;

  @override
  void initState() {
    super.initState();
    _loadDailyArticle();
  }

  Future<void> _loadDailyArticle() async {
    await _constitutionService.load();
    if (mounted) {
      setState(() {
        _dailyArticle = _constitutionService.getDailyArticle();
        _isLoadingDaily = false;
      });
    }
  }

  void _searchInAI(BuildContext context, String topic) {
    if (topic.trim().isEmpty) return;
    context.read<ChatProvider>().sendMessage(topic);
    
    if (widget.onTabChange != null) {
      widget.onTabChange!(1); // Switch to Chat tab
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.paperWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 100.0), // Added 100px bottom padding to clear the nav bar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16), // Added space from status bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Jai Hind,",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontFamily: 'Newsreader',
                    ),
                  ),
                  const Text(
                    "Citizen of India",
                    style: TextStyle(
                      color: AppConstants.secondaryGray,
                      fontSize: 16,
                      fontFamily: 'Instrument Sans',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // New Floating Search Input
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppConstants.secondaryGray.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    const Icon(Icons.search, color: AppConstants.secondaryGray),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Ask anything about your rights...",
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: AppConstants.secondaryGray.withValues(alpha: 0.5),
                            fontSize: 14,
                          ),
                        ),
                        style: const TextStyle(fontFamily: 'Instrument Sans', fontSize: 14),
                        onSubmitted: (val) {
                          _searchInAI(context, val);
                          _searchController.clear();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        _searchInAI(context, _searchController.text);
                        _searchController.clear();
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppConstants.primaryNavy,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_upward, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _buildDailyArticle(context),
              const SizedBox(height: 32),
              Text(
                "Quick Prompts",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontFamily: 'Newsreader',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildPromptChips(context),
              const SizedBox(height: 32),
              _buildCategoryGrid(context),
              const SizedBox(height: 48),
              
              // Source & Disclaimer Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppConstants.secondaryGray.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Source of Information",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppConstants.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Constitutional data is sourced from the official website of the Legislative Department, Ministry of Law and Justice, Government of India.",
                      style: TextStyle(fontSize: 11, color: AppConstants.secondaryGray),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _launchURL("https://legislative.gov.in/constitution-of-india/"),
                      child: const Text(
                        "Visit Official Source (legislative.gov.in)",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 11,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const Divider(height: 24),
                    const Text(
                      "Disclaimer",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppConstants.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Samvidhan Mitra is an independent educational tool. It is NOT affiliated with, authorized by, or endorsed by any government entity.",
                      style: TextStyle(fontSize: 11, color: AppConstants.secondaryGray),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await url_launcher.canLaunchUrl(uri)) {
      await url_launcher.launchUrl(uri);
    }
  }

  Widget _buildDailyArticle(BuildContext context) {
    if (_isLoadingDaily) {
      return Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppConstants.primaryNavy,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator(color: AppConstants.accentWheat)),
      );
    }

    final title = _dailyArticle?['id'] ?? "Daily Article";
    final text = _dailyArticle?['text'] ?? "Loading amazing constitutional facts...";
    
    // Clean text a bit for the preview
    final cleanedText = text.length > 150 ? "${text.substring(0, 150)}..." : text;

    return GestureDetector(
      onTap: () => _searchInAI(context, "Tell me about $title"),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppConstants.primaryNavy,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppConstants.accentWheat,
                fontFamily: 'Newsreader',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              cleanedText,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9), 
                height: 1.5,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppConstants.accentWheat, size: 14),
                const SizedBox(width: 8),
                Text(
                  "Tap to learn more",
                  style: TextStyle(
                    color: AppConstants.accentWheat.withValues(alpha: 0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptChips(BuildContext context) {
    final prompts = [
      "Explain Article 21 simply",
      "What are my rights if arrested?",
      "How to file an RTI?",
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: prompts.map((prompt) => ActionChip(
        label: Text(prompt),
        onPressed: () => _searchInAI(context, prompt), // Added onClick functionality
        backgroundColor: Colors.white,
        labelStyle: const TextStyle(color: AppConstants.primaryNavy, fontSize: 13),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999),
          side: BorderSide(color: AppConstants.secondaryGray.withValues(alpha: 0.15)),
        ),
      )).toList(),
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    final categories = [
      {"icon": Icons.gavel, "label": "Rights"},
      {"icon": Icons.assignment, "label": "Duties"}, // Changed from Learn
      {"icon": Icons.emergency, "label": "SOS"},
      {"icon": Icons.menu_book, "label": "Laws"},
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final label = categories[index]["label"] as String;
        return InkWell(
          onTap: () {
            if (label == "SOS") {
              if (widget.onTabChange != null) {
                widget.onTabChange!(2); // Switch to SOS tab
              }
            } else if (label == "Duties") {
              _searchInAI(context, "Tell me about my Fundamental Duties as an Indian citizen");
            } else {
              _searchInAI(context, "Tell me about my $label");
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppConstants.secondaryGray.withValues(alpha: 0.1)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  categories[index]["icon"] as IconData, 
                  color: categories[index]["label"] == "SOS" ? AppConstants.emergencyRed : AppConstants.primaryNavy,
                ),
                const SizedBox(height: 8),
                Text(
                  categories[index]["label"] as String, 
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppConstants.primaryNavy),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
