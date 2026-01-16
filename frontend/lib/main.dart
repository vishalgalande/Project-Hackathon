import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'features/landing_page.dart';
import 'features/splash_screen.dart';
import 'features/auth/auth_dialogs.dart';
import 'pages/command_center_page.dart';
import 'pages/intel_page.dart';
import 'pages/admin_page.dart';
import 'features/transit_tracker_screen.dart';
import 'core/shader_manager.dart';
import 'features/about/about_page.dart';
import 'features/cinematic_intro_screen.dart';

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

  // Precache Shaders
  // ShaderManager().initialize() is now handled in SplashScreen/LandingPage lazily

  runApp(
    const ProviderScope(
      child: SafeTravelApp(),
    ),
  );
}

// GoRouter configuration
final GoRouter _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const LandingPage(),
    ),
    GoRoute(
      path: '/geofencing',
      name: 'geofencing',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final triggerAnimation = extra?['triggerAnimation'] as bool? ?? false;
        return CommandCenterPage(triggerIntroAnimation: triggerAnimation);
      },
    ),
    GoRoute(
      path: '/intel/:zoneId',
      name: 'intel',
      builder: (context, state) {
        final zoneId = state.pathParameters['zoneId'] ?? '';
        return IntelPage(zoneId: zoneId);
      },
    ),
    GoRoute(
      path: '/intro',
      name: 'intro',
      builder: (context, state) => const CinematicIntroScreen(),
    ),
    GoRoute(
      path: '/tracker',
      name: 'tracker',
      builder: (context, state) => const TransitTrackerScreen(),
    ),
    GoRoute(
      path: '/admin',
      name: 'admin',
      builder: (context, state) => const AdminPage(),
    ),
    GoRoute(
      path: '/about',
      name: 'about',
      builder: (context, state) => const AboutPage(),
    ),
  ],
);

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
      routerConfig: _router,
    );
  }
}
