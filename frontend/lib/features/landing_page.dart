import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Animation Power

import 'auth/auth_dialogs.dart';
import 'chatbot/chat_button.dart';
import 'sos/sos_page.dart';
import 'transitions/warp_transition.dart';

// New High-Fidelity Widgets
import '../widgets/nebula_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/liquid_button.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  User? _user;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) setState(() => _user = user);
    });
    _user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    // Lando Aesthetic: Deep Void + Nebula Shader
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. GLSL Shader Background (Precached in main.dart)
          const NebulaBackground(),
          
          // 2. Main Scrollable Content
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildNavBar()),
              SliverToBoxAdapter(child: _buildHeroSection()),
              SliverToBoxAdapter(child: _buildFeaturesSection()),
              SliverFillRemaining(hasScrollBody: false, child: _buildFooter()),
            ],
          ),
          
          // 3. Floating AI Chatbot
          const ChatButton(),
        ],
      ),
    );
  }

  Widget _buildNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF050505).withOpacity(0.5), // Semi-transparent
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          Text(
            'SAFETRAVEL', // Uppercase for impact
            style: GoogleFonts.syncopate( // Wide, futuristic
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2.0,
            ),
          ).animate().fadeIn(duration: 600.ms),
          
          const Spacer(),
          
          if (_user == null)
            Row(
              children: [
                TextButton(
                  onPressed: () => showLoginDialog(context),
                  child: Text('LOG IN', style: GoogleFonts.inter(color: Colors.white70, letterSpacing: 1.0)),
                ),
                const SizedBox(width: 16),
                LiquidButton(text: 'SIGN UP', onTap: () => showSignupDialog(context)),
              ],
            )
          else
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.5)),
                  ),
                  child: Text(
                     _user!.email?.split('@')[0].toUpperCase() ?? 'PILOT',
                     style: GoogleFonts.spaceMono(color: const Color(0xFF8B5CF6), fontSize: 12),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.power_settings_new, color: Colors.white54),
                  onPressed: () => FirebaseAuth.instance.signOut(),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    final size = MediaQuery.of(context).size;
    
    return Container(
      height: size.height * 0.85,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Badge
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
             decoration: BoxDecoration(
               color: Colors.white.withOpacity(0.05),
               borderRadius: BorderRadius.circular(50),
               border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.3)),
             ),
             child: Text(
               'SYSTEM ONLINE • V2.4.0',
               style: GoogleFonts.spaceMono(color: const Color(0xFF00F0FF), fontSize: 10, letterSpacing: 2),
             ),
          ).animate().slideY(begin: -0.5, end: 0).fadeIn(),
          
          const SizedBox(height: 32),
          
          // HERO TEXT: "Navigate India Safely"
          // Staggered Slide + Fade + Shimmer
          Column(
             children: [
               Text(
                 'NAVIGATE INDIA',
                 textAlign: TextAlign.center,
                 style: GoogleFonts.syncopate(
                   fontSize: 56, // Large
                   fontWeight: FontWeight.w900,
                   color: Colors.white,
                   height: 1.0,
                   letterSpacing: -2.0,
                 ),
               ).animate()
                 .slideY(begin: 0.2, end: 0, duration: 800.ms, curve: Curves.easeOutCirc)
                 .fadeIn(duration: 800.ms)
                 .shimmer(delay: 1000.ms, duration: 1500.ms, color: Colors.white.withOpacity(0.5)),
                 
               Text(
                 'SAFELY',
                 textAlign: TextAlign.center,
                 style: GoogleFonts.syncopate(
                   fontSize: 56,
                   fontWeight: FontWeight.w900,
                   color: const Color(0xFF8B5CF6), // Neon Purple
                   height: 1.0,
                   letterSpacing: -2.0,
                   shadows: [
                     BoxShadow(color: const Color(0xFF8B5CF6).withOpacity(0.6), blurRadius: 40)
                   ],
                 ),
               ).animate()
                 .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 800.ms, curve: Curves.easeOutCirc)
                 .fadeIn(delay: 200.ms)
                 .shimmer(delay: 1200.ms, duration: 1500.ms, color: const Color(0xFF00F0FF)),
             ],
          ),
          
          const SizedBox(height: 32),
          
          // Subtitle
          Text(
            'Real-time crowd-sourced safety zones and AI-powered transit tracking.\nExplore the world with an invisible shield.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white60,
              height: 1.6,
            ),
          ).animate().fadeIn(delay: 600.ms),
          
          const SizedBox(height: 56),
          
          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LiquidButton(
                text: 'EXPLORE MAP',
                icon: Icons.map,
                onTap: () {
                    // Warp Speed Transition
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          WarpTransition(
                        onFinished: () {
                          // Pass extra trigger
                          context.go('/geofencing', extra: {'triggerAnimation': true});
                        },
                      ),
                      opaque: false,
                    ));
                },
              ).animate().scale(delay: 800.ms, duration: 400.ms, curve: Curves.easeOutBack),
              
              const SizedBox(width: 24),
              
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => context.go('/tracker'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('TRACK TRANSIT', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                ),
              ).animate().scale(delay: 900.ms, duration: 400.ms, curve: Curves.easeOutBack),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
      child: Column(
        children: [
          Text('PREMIUM UTILITY', style: GoogleFonts.spaceMono(color: Colors.white24, fontSize: 12, letterSpacing: 4)).animate().fadeIn(),
          const SizedBox(height: 16),
          Text('ADVANCED SYSTEMS', style: GoogleFonts.syncopate(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)).animate().fadeIn(),
          const SizedBox(height: 64),
          
          // Cards Grid
          Wrap(
            spacing: 32,
            runSpacing: 32,
            alignment: WrapAlignment.center,
            children: [
               _buildGlassFeature(
                 title: 'SAFETY ZONES',
                 desc: 'Live heatmaps of safe and danger zones across your city.',
                 icon: Icons.shield_moon,
                 color: const Color(0xFF00F0FF),
                 onTap: () => context.go('/geofencing'),
                 label: 'LIVE',
               ),
               _buildGlassFeature(
                 title: 'TRANSIT TRACKER',
                 desc: 'AI-predicted arrivals for buses and trains in real-time.',
                 icon: Icons.directions_transit_filled,
                 color: const Color(0xFF8B5CF6),
                 onTap: () => context.go('/tracker'),
                 label: 'BETA',
               ),
                 _buildGlassFeature(
                 title: 'EMERGENCY SOS',
                 desc: 'Instant beacon to authorities and trusted contacts.',
                 icon: Icons.emergency_share,
                 color: Colors.redAccent,
                 onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SosPage())),
                 label: 'ACTIVE',
               ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassFeature({
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String label,
  }) {
    // GlassCard wrapper from glass_card.dart
    return SizedBox(
      width: 350,
      height: 350,
      child: GlassCard(
        baseColor: color,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Icon(icon, color: color, size: 32),
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                   decoration: BoxDecoration(
                     color: color.withOpacity(0.1),
                     borderRadius: BorderRadius.circular(4),
                     border: Border.all(color: color.withOpacity(0.3)),
                   ),
                   child: Text(label, style: GoogleFonts.spaceMono(fontSize: 10, color: color)),
                 ),
               ],
             ),
             const Spacer(),
             Text(title, style: GoogleFonts.syncopate(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
             const SizedBox(height: 12),
             Text(desc, style: GoogleFonts.inter(fontSize: 14, color: Colors.white60, height: 1.5)),
             const SizedBox(height: 24),
             Row(
               children: [
                 Text('ACCESS TERMINAL', style: GoogleFonts.spaceMono(fontSize: 10, color: color)),
                 const SizedBox(width: 8),
                 Icon(Icons.arrow_forward_ios, color: color, size: 10),
               ],
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(40),
      alignment: Alignment.center,
      child: Text(
        'SAFETRAVEL SYSTEMS • 2026',
        style: GoogleFonts.spaceMono(color: Colors.white10, fontSize: 10, letterSpacing: 2),
      ),
    );
  }
}
