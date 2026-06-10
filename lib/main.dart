import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/database_service.dart';
import 'services/chat_provider.dart';
import 'utils/constants.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (Platform.isAndroid) {
    try {
      await FlutterDisplayMode.setHighRefreshRate();
    } catch (_) {}
  }
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Hive
  await DatabaseService.init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ChatProvider(apiKey: AppConstants.aiApiKey),
        ),
      ],
      child: const SamvidhanMitraApp(),
    ),
  );
}

class SamvidhanMitraApp extends StatelessWidget {
  const SamvidhanMitraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppConstants.paperWhite,
        primaryColor: AppConstants.primaryNavy,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstants.primaryNavy,
          primary: AppConstants.primaryNavy,
          secondary: AppConstants.accentWheat,
          surface: AppConstants.paperWhite,
        ),
        textTheme: GoogleFonts.instrumentSansTextTheme(
          Theme.of(context).textTheme,
        ).copyWith(
          displayLarge: GoogleFonts.newsreader(
            textStyle: Theme.of(context).textTheme.displayLarge,
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryNavy,
          ),
          headlineMedium: GoogleFonts.newsreader(
            textStyle: Theme.of(context).textTheme.headlineMedium,
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryNavy,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
