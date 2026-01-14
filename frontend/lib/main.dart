import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/router.dart';
import 'app/theme.dart';

/// SAFE_PROTOCOL
/// Smart Tourist Safety System
/// 
/// A cyberpunk-themed Flutter Web app for tourist safety
/// with real-time GPS tracking and danger zone alerts.

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    const ProviderScope(
      child: SafeProtocolApp(),
    ),
  );
}

class SafeProtocolApp extends StatelessWidget {
  const SafeProtocolApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SAFE_PROTOCOL',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/landing_page.dart';
import 'features/auth/auth_dialogs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    // For Android/iOS, we expect google-services.json / GoogleService-Info.plist
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  }
  runApp(const SafeTravelApp());
}

class SafeTravelApp extends StatelessWidget {
  const SafeTravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: const LandingPage(),
    );
  }
}
