import 'package:flutter/material.dart';
// IMPORT YOUR FEATURES HERE
import 'features/home_screen.dart';
import 'features/login_screen.dart';

void main() {
  runApp(const TourismApp());
}

class TourismApp extends StatelessWidget {
  const TourismApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tourism Hackathon App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // DEFINING ROUTES
      // This allows different people to work on different pages
      // without breaking the main app.
      initialRoute: '/login',
      routes: {
        '/': (context) => const HomeScreen(),
        // Add new features here:
        // '/tours': (context) => const TourListScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
