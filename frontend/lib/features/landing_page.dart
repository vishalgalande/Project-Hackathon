import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// AUTH
import 'auth/cyber_auth_dialogs.dart';

// WIDGETS
import '../widgets/nebula_background.dart';
import '../widgets/tilt_card.dart';
import '../widgets/liquid_button.dart';
import '../widgets/glitch_text.dart';
import '../widgets/magnetic_control.dart';
import '../widgets/scramble_text.dart';

import 'chatbot/chat_button.dart';
import 'sos/sos_page.dart';
import 'transitions/warp_transition.dart';

import '../app/providers.dart';

class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage> {
  User? _user;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) setState(() => _user = user);
    });
    _user = FirebaseAuth.instance.currentUser;
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (mounted) setState(() => _scrollOffset = _scrollController.offset);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Preload data for Geofencing page during warp animation
  void _preloadGeofencingData() {
    ref.read(firebaseZonesProvider.future).then((_) {
      debugPrint('✅ Zones preloaded');
    }).catchError((_) {});
    ref.read(userLocationProvider);
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
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(child: _buildNavBar()),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: Offset(0, _scrollOffset * 0.5),
                  child: Opacity(
                    opacity: (1 - (_scrollOffset / 500)).clamp(0.0, 1.0),
                    child: _buildHeroSection(),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
                letterSpacing: 2.0),
            interval: const Duration(seconds: 4),
          ),
          const Spacer(),
          if (_user == null)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00F0FF).withOpacity(0.1),
                border:
                    Border.all(color: const Color(0xFF00F0FF).withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00F0FF).withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.power_settings_new,
                    color: Color(0xFF00F0FF)),
                tooltip: 'LOGIN',
                onPressed: () => showCyberLogin(context),
              ),
            )
          else
            Row(
              children: [
                Text(
                  _user!.displayName?.toUpperCase() ?? 'PILOT',
                  style: GoogleFonts.spaceMono(
                      color: const Color(0xFF00F0FF), fontSize: 12),
                ),
                const SizedBox(width: 16),
                MagneticControl(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: Colors.redAccent.withOpacity(0.3)),
                      color: Colors.redAccent.withOpacity(0.1),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.power_settings_new,
                          color: Colors.redAccent),
                      tooltip: 'Disconnect',
                      onPressed: () => FirebaseAuth.instance.signOut(),
                    ),
                  ),
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
      height: size.height * 0.8,
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle, size: 8, color: Color(0xFF00F0FF))
                    .animate(onPlay: (c) => c.repeat())
                    .fadeIn(duration: 500.ms)
                    .fadeOut(delay: 500.ms),
                const SizedBox(width: 8),
                Text('SYSTEM ONLINE • V3.0.0',
                    style: GoogleFonts.spaceMono(
                        color: const Color(0xFF00F0FF),
                        fontSize: 10,
                        letterSpacing: 2)),
              ],
            ),
          ),
          const SizedBox(height: 48),
          Transform.translate(
            offset: Offset(0, -_scrollOffset * 0.2),
            child: SizedBox(
              height: 60,
              child: ScrambleText(
                text: 'NAVIGATE INDIA',
                duration: const Duration(milliseconds: 1500),
                style: GoogleFonts.syncopate(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.0,
                    letterSpacing: -2.0),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(0, _scrollOffset * 0.1),
            child: SizedBox(
              height: 60,
              child: ScrambleText(
                text: 'SAFELY',
                duration: const Duration(milliseconds: 2000),
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
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Real-time crowd-sourced safety zones.\nExplore the world with an invisible shield.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 16, color: Colors.white60, height: 1.6),
          ).animate().fadeIn(delay: 1500.ms),
          const SizedBox(height: 64),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MagneticControl(
                distance: 20,
                child: LiquidButton(
                  text: 'EXPLORE MAP',
                  icon: Icons.map,
                  onTap: () {
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
              ).animate().scale(delay: 1800.ms, curve: Curves.easeOutBack),
              const SizedBox(width: 32),
              MagneticControl(
                distance: 20,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (context, _, __) => WarpTransition(
                          onFinished: () => context.go('/tracker'),
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
              ).animate().scale(delay: 2000.ms, curve: Curves.easeOutBack),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 50),
      child: Column(
        children: [
          Text('PREMIUM UTILITY',
              style: GoogleFonts.spaceMono(
                  color: Colors.white24, fontSize: 12, letterSpacing: 4)),
          const SizedBox(height: 16),
          Text('ADVANCED SYSTEMS',
              style: GoogleFonts.syncopate(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 64),
          Wrap(
            spacing: 32,
            runSpacing: 32,
            alignment: WrapAlignment.center,
            children: [
              _buildTiltFeature(
                title: 'SAFETY ZONES',
                desc: 'Live heatmaps of safe and danger zones.',
                icon: Icons.shield_moon,
                color: const Color(0xFF00F0FF),
                onTap: () => context.go('/geofencing'),
                label: 'LIVE',
              ),
              _buildTiltFeature(
                title: 'TRANSIT TRACKER',
                desc: 'AI-predicted arrivals for buses/trains.',
                icon: Icons.directions_transit_filled,
                color: const Color(0xFF8B5CF6),
                onTap: () => context.go('/tracker'),
                label: 'BETA',
              ),
              _buildTiltFeature(
                title: 'EMERGENCY SOS',
                desc: 'Instant beacon to authorities.',
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
    return SizedBox(
      width: 350,
      height: 350,
      child: MagneticControl(
        distance: 15,
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
                        style:
                            GoogleFonts.spaceMono(fontSize: 10, color: color)),
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
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Text('SAFETRAVEL SYSTEMS • 2026',
              style: GoogleFonts.spaceMono(
                  color: Colors.white10, fontSize: 10, letterSpacing: 2)),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.go('/about'),
            child: Text('ABOUT US',
                style: GoogleFonts.inter(
                    color: Colors.blueGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
