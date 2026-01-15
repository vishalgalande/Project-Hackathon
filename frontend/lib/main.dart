import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'features/landing_page.dart';
import 'features/auth/auth_dialogs.dart' hide AppColors;
import 'pages/command_center_page.dart';
import 'pages/intel_page.dart';
import 'app/router.dart'; // Import central router
import 'app/theme.dart'; // Import theme for AppColors

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (optional - app works without it but chatbot won't)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // .env file not found - chatbot will show error message
    debugPrint(
        'Warning: .env file not loaded. Chatbot requires GEMINI_API_KEY.');
  }

  if (kIsWeb) {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyCxzI9sx8tnH0kHmm41N-XeS8u9yM0L1EU",
          authDomain: "heacathon-f52de.firebaseapp.com",
          projectId: "heacathon-f52de",
          storageBucket: "heacathon-f52de.firebasestorage.app",
          messagingSenderId: "500721061913",
          appId: "1:500721061913:web:0db27fd412986bc4405a88",
          measurementId: "G-WJEWEWT9ZF",
        ),
      );
    }
  } else {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  }

  runApp(
    const ProviderScope(
      child: SafeTravelApp(),
    ),
  );
}

// Consolidated to lib/app/router.dart

class SafeTravelApp extends StatelessWidget {
  const SafeTravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SafeTravel India',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bgDark,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.bgCard,
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      routerConfig: appRouter,
    );
  }
}
