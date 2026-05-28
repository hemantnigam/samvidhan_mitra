import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/database_service.dart';
import 'services/chat_provider.dart';
import 'utils/constants.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Hive
  await DatabaseService.init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ChatProvider(apiKey: AppConstants.geminiApiKey),
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
        primaryColor: AppConstants.primaryBlue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstants.primaryBlue,
          primary: AppConstants.primaryBlue,
        ),
        textTheme: GoogleFonts.muktaTextTheme(Theme.of(context).textTheme).copyWith(
          // English fonts will fallback to default if not explicitly set, 
          // but Mukta is great for both.
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
