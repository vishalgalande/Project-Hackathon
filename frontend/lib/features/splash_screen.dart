import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../widgets/wireframe_globe.dart';
import '../widgets/nebula_background.dart';
import '../widgets/glitch_text.dart';
import 'auth/auth_dialogs.dart';
import '../core/shader_manager.dart';

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
    _initializeShaders();
    _startSplashSequence();
  }

  // Pre-load shaders without async blocking
  void _initializeShaders() {
    ShaderManager().initialize().then((_) {
      print("Shaders initialized");
    });
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
      backgroundColor: const Color(0xFF050505),
      body: Stack(
        children: [
          // 1. High-End Nebula Background
          const NebulaBackground(),
          
          // 2. Main Content
          FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
                  
                  // Wireframe Globe with Glow
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF00F0FF).withOpacity(0.2), blurRadius: 50, spreadRadius: 10),
                      ],
                    ),
                    child: const WireframeGlobe(
                      size: 220,
                      color: Color(0xFF00F0FF),
                      rotationDuration: Duration(seconds: 12),
                    ),
                  ),
                  
                  const SizedBox(height: 64),
                  
                  // Glitch Title
                  SlideTransition(
                    position: _textSlideAnimation,
                    child: FadeTransition(
                      opacity: _textFadeAnimation,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🛡️', style: TextStyle(fontSize: 42)),
                              const SizedBox(width: 16),
                              GlitchText(
                                text: 'SafeTravel',
                                style: GoogleFonts.syncopate(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -1.0,
                                ),
                                interval: const Duration(seconds: 2),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Navigate India Safely',
                            style: GoogleFonts.spaceMono(
                              fontSize: 14,
                              color: const Color(0xFF00F0FF),
                              letterSpacing: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  
                  // Cyberpunk Progress Section
                  _buildProgressSection(),
                  
                  const Spacer(),
                  
                  // Footer Version
                  Text(
                    'SYSTEM V3.0.0', 
                    style: GoogleFonts.spaceMono(
                      color: Colors.white10, 
                      fontSize: 10
                    )
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    // Replaced by NebulaBackground, keeping this empty or removing if unused.
    return const SizedBox.shrink();
  }

  Widget _buildProgressSection() {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF101010).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          // Status Text
          Align(
            alignment: Alignment.centerLeft,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                '> $_statusText',
                key: ValueKey<String>(_statusText),
                style: GoogleFonts.spaceMono(
                  fontSize: 12,
                  color: const Color(0xFF00F0FF),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Cyber Progress Bar
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  // Track
                  Container(
                    height: 4,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  // Fill
                  Container(
                    height: 4,
                    width: 250 * _progressAnimation.value,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00F0FF), Color(0xFF8B5CF6)],
                      ),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF00F0FF).withOpacity(0.8), blurRadius: 10, spreadRadius: 1),
                      ]
                    ),
                  ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 12),
          
          Align(
            alignment: Alignment.centerRight,
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return Text(
                  '${(_progressAnimation.value * 100).toInt()}%',
                  style: GoogleFonts.spaceMono(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
