import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/initialization_page.dart';
import '../pages/command_center_page.dart';
import '../pages/intel_page.dart';
import '../features/landing_page.dart';
import '../features/emergency_contacts_page.dart';
import '../features/safety_dashboard_page.dart';
import '../features/about_dev_page.dart';

/// SAFE_PROTOCOL Router Configuration
/// Cinematic page transitions with custom animations

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Page 0: Landing Page (Root)
    GoRoute(
      path: '/',
      name: 'home',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const LandingPage(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),

    // Page 1: Initialization / Welcome
    GoRoute(
      path: '/welcome',
      name: 'welcome',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const InitializationPage(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    
    // Page 2: Command Center (Map)
    GoRoute(
      path: '/command-center',
      name: 'command_center',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const CommandCenterPage(),
        transitionDuration: const Duration(milliseconds: 800),
        reverseTransitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Cinematic zoom-in effect
          final scaleAnimation = Tween<double>(
            begin: 0.8,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutExpo,
          ));
          
          final fadeAnimation = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
          ));
          
          return FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: child,
            ),
          );
        },
      ),
    ),
    
    // Page 3: Intel (Zone Detail)
    GoRoute(
      path: '/intel/:zoneId',
      name: 'intel',
      pageBuilder: (context, state) {
        final zoneId = state.pathParameters['zoneId'] ?? '';
        return CustomTransitionPage(
          key: state.pageKey,
          child: IntelPage(zoneId: zoneId),
          transitionDuration: const Duration(milliseconds: 600),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Slide up with fade
            final slideAnimation = Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ));
            
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: slideAnimation,
                child: child,
              ),
            );
          },
        );
      },
    ),
    
    // Emergency Contacts
    GoRoute(
      path: '/emergency-contacts',
      name: 'emergency_contacts',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const EmergencyContactsPage(),
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            ),
          );
        },
      ),
    ),
    
    // Safety Dashboard
    GoRoute(
      path: '/safety-dashboard',
      name: 'safety_dashboard',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SafetyDashboardPage(),
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.95,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            ),
          );
        },
      ),
    ),
    
    // About Dev
    GoRoute(
      path: '/about',
      name: 'about',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const AboutDevPage(),
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    ),
  ],
);
