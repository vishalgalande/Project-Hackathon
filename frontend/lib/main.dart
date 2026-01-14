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
    );
  }
}
