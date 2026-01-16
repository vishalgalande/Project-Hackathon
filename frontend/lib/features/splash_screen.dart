import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../widgets/wireframe_globe.dart';
import 'auth/auth_dialogs.dart';

/// Splash Screen for SafeTravel App
/// Uses the existing WireframeGlobe widget and matches the app's dark theme
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _progressController;
  late AnimationController _textController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

  String _statusText = 'Initializing...';
  final List<String> _statusMessages = [
    'Initializing...',
    'Loading Safety Data...',
    'Connecting to Network...',
    'Preparing Map...',
    'Almost Ready...',
  ];
  int _currentMessageIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    // Fade in animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Progress bar animation
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    );

    // Text animation
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    // Listen to progress for status text changes
    _progressController.addListener(_updateStatusText);
  }

  void _updateStatusText() {
    final progress = _progressController.value;
    int newIndex = (progress * (_statusMessages.length - 1)).floor();
    newIndex = newIndex.clamp(0, _statusMessages.length - 1);
    
    if (newIndex != _currentMessageIndex) {
      setState(() {
        _currentMessageIndex = newIndex;
        _statusText = _statusMessages[newIndex];
      });
    }
  }

  void _startSplashSequence() async {
    // Start fade in
    _fadeController.forward();
    _textController.forward();

    // Small delay then start progress
    await Future.delayed(const Duration(milliseconds: 400));
    _progressController.forward();

    // Wait for progress to complete
    await Future.delayed(const Duration(milliseconds: 3200));

    if (!mounted) return;

    // Navigate to landing page using GoRouter
    context.go('/');
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _progressController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // Gradient background
          _buildBackground(),
          // Main content
          FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  // Wireframe Globe
                  const WireframeGlobe(
                    size: 200,
                    color: AppColors.primary,
                    rotationDuration: Duration(seconds: 8),
                  ),
                  const SizedBox(height: 48),
                  // App Title
                  SlideTransition(
                    position: _textSlideAnimation,
                    child: FadeTransition(
                      opacity: _textFadeAnimation,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🛡️', style: TextStyle(fontSize: 32)),
                              const SizedBox(width: 12),
                              Text(
                                'SafeTravel',
                                style: GoogleFonts.inter(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Navigate India Safely',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Progress section
                  _buildProgressSection(),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
      ),
      child: Stack(
        children: [
          // Top-left gradient glow
          Positioned(
            top: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Bottom-right gradient glow
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          // Status text
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _statusText,
              key: ValueKey<String>(_statusText),
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                color: AppColors.primary,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Progress bar
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Container(
                height: 3,
                width: 200,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 200 * _progressAnimation.value,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                      ),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          // Percentage
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Text(
                '${(_progressAnimation.value * 100).toInt()}%',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
