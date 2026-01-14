import 'package:flutter/material.dart';
// IMPORT YOUR FEATURES HERE
import 'features/home_screen.dart';
import 'features/geofencing_screen.dart';

void main() {
  runApp(const TourismApp());
}

class TourismApp extends StatelessWidget {
  const TourismApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tourism Geofencing App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
      ),
      // DEFINING ROUTES
      // This allows different people to work on different pages
      // without breaking the main app.
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/geofencing': (context) => const GeofencingScreen(),
        // Add new features here:
        // '/tours': (context) => const TourListScreen(),
        // '/login': (context) => const LoginScreen(),
      },
    );
  }
}
