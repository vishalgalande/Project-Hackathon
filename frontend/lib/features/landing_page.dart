import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'auth/auth_dialogs.dart';
import 'chatbot/chat_button.dart';
import 'sos/sos_page.dart';

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
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // Animated gradient background
          const _GradientBackground(),
          // Main content
          CustomScrollView(
            slivers: [
              // Navigation bar
              SliverToBoxAdapter(child: _buildNavBar()),
              // Hero section
              SliverToBoxAdapter(child: _buildHeroSection()),
              // Features section
              SliverToBoxAdapter(child: _buildFeaturesSection()),
              // Footer
              SliverToBoxAdapter(child: _buildFooter()),
            ],
          ),
          // AI Chatbot floating button
          const ChatButton(),
        ],
      ),
    );
  }

  Widget _buildNavBar() {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;
    final isMobile = width < 600;

    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.bgDark.withOpacity(0.8),
        border: const Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text('🛡️', style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 12),
              if (!isMobile) // Optional: Hide title on very small screens if needed
                Text(
                  'SafeTravel',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
            ],
          ),
          const Spacer(),
          // Desktop Navigation
          if (isDesktop) ...[
            Row(
              children: [
                _NavLink(text: 'Home', isActive: true, onTap: () {}),
                const SizedBox(width: 40),
                _NavLink(
                  text: 'Safety Zones',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Safety Map feature - Navigate to web version'),
                      ),
                    );
                    context
                        .go('/geofencing', extra: {'triggerAnimation': true});
                  },
                ),
                const SizedBox(width: 40),
                _NavLink(
                  text: 'Transit Tracker',
                  onTap: () {
                    context.go('/tracker');
                  },
                ),
              ],
            ),
            const SizedBox(width: 40),
            _buildAuthSection(),
          ] else ...[
            // Mobile Menu Button
            IconButton(
              icon: const Icon(Icons.menu, color: AppColors.textPrimary),
              onPressed: () => _showMobileMenu(context),
            ),
          ],
        ],
      ),
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MobileMenuLink(
                text: 'Home',
                icon: Icons.home,
                isActive: true,
                onTap: () => Navigator.pop(context),
              ),
              _MobileMenuLink(
                text: 'Safety Map',
                icon: Icons.map,
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Navigate to Safety Map')),
                  );
                },
              ),
              _MobileMenuLink(
                text: 'Transit Tracker',
                icon: Icons.directions_bus,
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Navigate to Transit Tracker')),
                  );
                },
              ),
              const Divider(color: AppColors.border, height: 32),
              if (_user != null) ...[
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text(
                      (_user!.displayName ?? _user!.email ?? 'U')[0]
                          .toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    _user!.displayName ?? _user!.email ?? 'User',
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.logout,
                        color: AppColors.textSecondary),
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.pop(context);
                    },
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      showLoginDialog(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Log In'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      showSignupDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Sign Up'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildAuthSection() {
    if (_user != null) {
      // Logged in state
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  () {
                    final name = _user!.displayName;
                    final email = _user!.email;
                    String initial = 'U';
                    if (name != null && name.isNotEmpty) {
                      initial = name[0];
                    } else if (email != null && email.isNotEmpty) {
                      initial = email[0];
                    }
                    return initial.toUpperCase();
                  }(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _user!.displayName ?? _user!.email?.split('@')[0] ?? 'User',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text('Logout'),
            ),
          ],
        ),
      );
    }

    // Logged out state
    return Row(
      children: [
        TextButton(
          onPressed: () => showLoginDialog(context),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Log In'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => showSignupDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Sign Up'),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 32,
        vertical: MediaQuery.of(context).size.height * 0.15,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🚀', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Text(
                  'Built at Hackathon 2026',
                  style: TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Title
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Navigate India ',
                  style: GoogleFonts.inter(
                    fontSize: 56,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                WidgetSpan(
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                    ).createShader(bounds),
                    child: Text(
                      'Safely',
                      style: GoogleFonts.inter(
                        fontSize: 56,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Subtitle
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Text(
              'Real-time crowd-sourced safety zones and public transit tracking to help tourists explore with confidence.',
              style: GoogleFonts.inter(
                fontSize: 20,
                color: AppColors.textSecondary,
                height: 1.7,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          // CTA Buttons
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  context.go('/geofencing', extra: {'triggerAnimation': true});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Explore Safety Zones',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  context.go('/tracker');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  side: const BorderSide(color: AppColors.border, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Track Transit',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 96),
      child: Column(
        children: [
          // Section header
          Text(
            'Two Powerful Tools, One Platform',
            style: GoogleFonts.inter(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Everything you need for safe and smart travel in India',
            style: GoogleFonts.inter(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 64),
          // Features grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              return Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  _FeatureCard(
                    icon: '🗺️',
                    iconBgColor: AppColors.success.withOpacity(0.15),
                    title: 'Safety Zones (Geofencing)',
                    description:
                        "View real-time safety ratings for areas across Delhi. Community-powered zones show you where it's safe to go, where to be cautious, and areas to avoid.",
                    linkText: 'Open Map',
                    status: FeatureStatus.live,
                    width: isWide
                        ? (constraints.maxWidth - 24) / 2
                        : constraints.maxWidth,
                    onTap: () {
                      context
                          .go('/geofencing', extra: {'triggerAnimation': true});
                    },
                  ),
                  _FeatureCard(
                    icon: '🚌',
                    iconBgColor: AppColors.primary.withOpacity(0.15),
                    title: 'Transit Tracker',
                    description:
                        "Track public transportation in real-time. Find bus routes, train schedules, and live vehicle positions across India's major cities.",
                    linkText: 'Track Now',
                    status: FeatureStatus.live,
                    width: isWide
                        ? (constraints.maxWidth - 24) / 2
                        : constraints.maxWidth,
                    onTap: () {},
                  ),
                  _FeatureCard(
                    icon: '👍',
                    iconBgColor: AppColors.accent.withOpacity(0.15),
                    title: 'Community Voting',
                    description:
                        'Share your experience by voting on zone safety. Your feedback updates the map in real-time and helps fellow travelers stay safe.',
                    linkText: 'Start Voting',
                    status: FeatureStatus.beta,
                    width: isWide
                        ? (constraints.maxWidth - 24) / 2
                        : constraints.maxWidth,
                    onTap: () {},
                  ),
                  _FeatureCard(
                    icon: '🆘',
                    iconBgColor: AppColors.danger.withOpacity(0.15),
                    title: 'Emergency SOS',
                    description:
                        'One-tap emergency button with automatic location sharing to your trusted contacts and local authorities.',
                    linkText: 'Open SOS',
                    status: FeatureStatus.live,
                    width: isWide
                        ? (constraints.maxWidth - 24) / 2
                        : constraints.maxWidth,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SosPage()),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: Center(
        child: Text(
          'Built with 💜 by Team SafeTravel at Hackathon 2026',
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// Gradient background widget
class _GradientBackground extends StatelessWidget {
  const _GradientBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withOpacity(0.1),
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
}

// Navigation link widget
class _NavLink extends StatefulWidget {
  final String text;
  final bool isActive;
  final VoidCallback onTap;

  const _NavLink({
    required this.text,
    this.isActive = false,
    required this.onTap,
  });

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.text,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: widget.isActive || _isHovered
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            if (widget.isActive)
              Container(
                height: 2,
                width: 30,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MobileMenuLink extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  const _MobileMenuLink({
    required this.text,
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Text(
        text,
        style: TextStyle(
          color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}

// Feature status enum
enum FeatureStatus { live, beta, comingSoon }

// Feature card widget
class _FeatureCard extends StatefulWidget {
  final String icon;
  final Color iconBgColor;
  final String title;
  final String description;
  final String linkText;
  final FeatureStatus status;
  final double width;
  final VoidCallback? onTap;

  const _FeatureCard({
    required this.icon,
    required this.iconBgColor,
    required this.title,
    required this.description,
    required this.linkText,
    required this.status,
    required this.width,
    this.onTap,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.width,
        padding: const EdgeInsets.all(32),
        transform: Matrix4.translationValues(0, _isHovered ? -8 : 0, 0),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isHovered
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.border,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 50,
                    offset: const Offset(0, 25),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Top accent line (visible on hover)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isHovered ? 1 : 0,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            // Status badge
            Positioned(
              top: 0,
              right: 0,
              child: _buildStatusBadge(),
            ),
            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: widget.iconBgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child:
                        Text(widget.icon, style: const TextStyle(fontSize: 32)),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.title,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.description,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: widget.onTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.linkText,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: widget.onTap != null
                              ? AppColors.primaryLight
                              : AppColors.textSecondary.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: widget.onTap != null
                            ? AppColors.primaryLight
                            : AppColors.textSecondary.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    String text;
    Color bgColor;
    Color textColor;

    switch (widget.status) {
      case FeatureStatus.live:
        text = '🟢 Live';
        bgColor = AppColors.success.withOpacity(0.2);
        textColor = AppColors.success;
        break;
      case FeatureStatus.beta:
        text = 'Beta';
        bgColor = AppColors.warning.withOpacity(0.2);
        textColor = AppColors.warning;
        break;
      case FeatureStatus.comingSoon:
        text = 'Coming Soon';
        bgColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
