import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/database_service.dart';
import 'services/chat_provider.dart';
import 'utils/constants.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await DatabaseService.init();
  
  // Note: In a production app, use an environment variable for the API Key
  const String apiKey = 'YOUR_GEMINI_API_KEY';

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider(apiKey: apiKey)),
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
