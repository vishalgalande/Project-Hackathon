import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth/auth_dialogs.dart';
import 'chatbot/chat_button.dart';
import 'sos/sos_page.dart';
import 'transitions/warp_transition.dart';

// ADVANCED WIDGETS
import '../widgets/nebula_background.dart';
import '../widgets/tilt_card.dart'; // UPDATED from GlassCard
import '../widgets/liquid_button.dart';
import '../widgets/glitch_text.dart'; // NEW
import '../app/providers.dart'; // For preloading

class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage> {
  User? _user;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) setState(() => _user = user);
    });
    _user = FirebaseAuth.instance.currentUser;
  }

  /// Preload data for Geofencing page during warp animation
  void _preloadGeofencingData() {
    // Using .future forces the StreamProvider to start fetching
    // The data will be cached in Riverpod and available when CommandCenterPage opens
    ref.read(firebaseZonesProvider.future).then((_) {
      debugPrint('✅ Zones preloaded');
    }).catchError((_) {});

    // UserLocationProvider is a StateNotifier, just reading triggers its init
    ref.read(userLocationProvider);

    // Also trigger local zones fallback
    ref.read(zonesProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const NebulaBackground(),
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildNavBar()),
              SliverToBoxAdapter(child: _buildHeroSection()),
              SliverToBoxAdapter(child: _buildFeaturesSection()),
              SliverFillRemaining(hasScrollBody: false, child: _buildFooter()),
            ],
          ),
          const ChatButton(),
        ],
      ),
    );
  }

  Widget _buildNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF050505).withOpacity(0.5),
        border:
            Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          GlitchText(
            text: 'SAFETRAVEL',
            style: GoogleFonts.syncopate(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2.0,
            ),
            interval: const Duration(seconds: 5),
          ),
          const Spacer(),
          if (_user == null)
            Row(
              children: [
                TextButton(
                  onPressed: () => showLoginDialog(context),
                  child: Text('LOG IN',
                      style: GoogleFonts.inter(
                          color: Colors.white70, letterSpacing: 1.0)),
                ),
                const SizedBox(width: 16),
                LiquidButton(
                    text: 'SIGN UP', onTap: () => showSignupDialog(context)),
              ],
            )
          else
            IconButton(
              icon: const Icon(Icons.power_settings_new, color: Colors.white54),
              onPressed: () => FirebaseAuth.instance.signOut(),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(50),
              border:
                  Border.all(color: const Color(0xFF00F0FF).withOpacity(0.3)),
            ),
            child: Text(
              'SYSTEM ONLINE • V2.5.0',
              style: GoogleFonts.spaceMono(
                  color: const Color(0xFF00F0FF),
                  fontSize: 10,
                  letterSpacing: 2),
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 32),

          // MAIN GLITCH TITLE
          GlitchText(
            text: 'NAVIGATE INDIA',
            interval: const Duration(seconds: 4),
            style: GoogleFonts.syncopate(
              fontSize: 56,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.0,
              letterSpacing: -2.0,
            ),
          ),
          GlitchText(
            text: 'SAFELY',
            interval: const Duration(seconds: 3),
            style: GoogleFonts.syncopate(
              fontSize: 56,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF8B5CF6),
              height: 1.0,
              letterSpacing: -2.0,
              shadows: [
                BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.6),
                    blurRadius: 40)
              ],
            ),
          ),

          const SizedBox(height: 32),
          Text(
            'Real-time crowd-sourced safety zones and AI-powered transit tracking.\nExplore the world with an invisible shield.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 16, color: Colors.white60, height: 1.6),
          ).animate().fadeIn(delay: 600.ms),
          const SizedBox(height: 56),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LiquidButton(
                text: 'EXPLORE MAP',
                icon: Icons.map,
                onTap: () {
                  // Preload zone data while animation plays (using .future forces fetch)
                  _preloadGeofencingData();

                  Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (context, _, __) => WarpTransition(
                      onFinished: () {
                        context.go('/geofencing',
                            extra: {'triggerAnimation': true});
                      },
                    ),
                    opaque: false,
                  ));
                },
              ),
              const SizedBox(width: 24),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    // Preload transit data while animation plays
                    // (Transit page uses its own local state, but we can still trigger the animation)
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, _, __) => WarpTransition(
                        onFinished: () {
                          context.go('/tracker');
                        },
                      ),
                      opaque: false,
                    ));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('TRACK TRANSIT',
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1)),
                  ),
                ),
              ),
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
          Text('PREMIUM UTILITY',
                  style: GoogleFonts.spaceMono(
                      color: Colors.white24, fontSize: 12, letterSpacing: 4))
              .animate()
              .fadeIn(),
          const SizedBox(height: 16),
          Text('ADVANCED SYSTEMS',
                  style: GoogleFonts.syncopate(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold))
              .animate()
              .fadeIn(),
          const SizedBox(height: 64),
          Wrap(
            spacing: 32,
            runSpacing: 32,
            alignment: WrapAlignment.center,
            children: [
              _buildTiltFeature(
                title: 'SAFETY ZONES',
                desc:
                    'Live heatmaps of safe and danger zones across your city.',
                icon: Icons.shield_moon,
                color: const Color(0xFF00F0FF),
                onTap: () => context.go('/geofencing'),
                label: 'LIVE',
              ),
              _buildTiltFeature(
                title: 'TRANSIT TRACKER',
                desc:
                    'AI-predicted arrivals for buses and trains in real-time.',
                icon: Icons.directions_transit_filled,
                color: const Color(0xFF8B5CF6),
                onTap: () => context.go('/tracker'),
                label: 'BETA',
              ),
              _buildTiltFeature(
                title: 'EMERGENCY SOS',
                desc: 'Instant beacon to authorities and trusted contacts.',
                icon: Icons.emergency_share,
                color: Colors.redAccent,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SosPage())),
                label: 'ACTIVE',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTiltFeature({
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String label,
  }) {
    // USES TILT CARD NOW
    return SizedBox(
      width: 350,
      height: 350,
      child: TiltCard(
        baseColor: color,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: Colors.white, size: 32),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Text(label,
                      style: GoogleFonts.spaceMono(fontSize: 10, color: color)),
                ),
              ],
            ),
            const Spacer(),
            Text(title,
                style: GoogleFonts.syncopate(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 12),
            Text(desc,
                style: GoogleFonts.inter(
                    fontSize: 14, color: Colors.white60, height: 1.5)),
            const SizedBox(height: 24),
            Row(
              children: [
                Text('ACCESS TERMINAL',
                    style: GoogleFonts.spaceMono(fontSize: 10, color: color)),
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
        style: GoogleFonts.spaceMono(
            color: Colors.white10, fontSize: 10, letterSpacing: 2),
      ),
    );
  }
}
