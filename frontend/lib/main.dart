import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'features/home_screen.dart';
import 'features/auth/login_screen.dart';

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
    // But we should also check to avoid errors on hot restart if platform implementation differs
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  }
  runApp(const TourismApp());
}

class TourismApp extends StatelessWidget {
  const TourismApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tourism Hackathon App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins', 
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1a2a6c)),
      ),
      initialRoute: '/login',
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
