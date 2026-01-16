import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class CinematicIntroScreen extends StatefulWidget {
  const CinematicIntroScreen({super.key});

  @override
  State<CinematicIntroScreen> createState() => _CinematicIntroScreenState();
}

class _CinematicIntroScreenState extends State<CinematicIntroScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Animation Phases
  late Animation<double> _warpSpeed;
  late Animation<double> _earthScale;
  late Animation<double> _earthRotation;
  late Animation<double> _indiaZoom;
  late Animation<double> _fadeOpacity;

  // Starfield Data
  final List<Star> _stars = List.generate(100, (index) => Star());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // Extended to 5s for the "2 spins"
    );

    // Phase 1: Stars Accelerate (0-20%)
    _warpSpeed = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.2, curve: Curves.easeIn),
      ),
    );

    // Phase 2: Earth Pops Up (10-30%)
    _earthScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.3, curve: Curves.elasticOut),
      ),
    );

    // Phase 3: Rotation (1 Full Spin + Land on Delhi)
    // Map Center (0,0) is usually Greenwich.
    // Image Alignment: 0 is Center. -1 is Left Edge (-180). 1 is Right Edge (+180).
    // Delhi is 77°E.
    // To center Delhi, we must shift the map LEFT.
    // 77 / 180 = 0.427.
    // So Target Alignment = -0.427.
    // We want 1 full rotation before landing.
    // 1 Rotation = 360 deg = Alignment delta of 2.0.
    // Start Alignment = -0.427 + 2.0 = 1.573.
    _earthRotation = Tween<double>(begin: 1.573, end: -0.427).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeInOutCubic),
      ),
    );

    // Phase 4: Zoom into India (80-100%)
    _indiaZoom = Tween<double>(begin: 1.0, end: 25.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeInExpo),
      ),
    );

    // Phase 5: Fade Out text
    _fadeOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.9, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    _controller.addListener(() {
      setState(() {
        for (var star in _stars) {
          star.update(_controller.value);
        }
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        context.go('/tracker');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // High-res Blue Marble textur
    const String earthMapUrl =
        "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Aurora_as_seen_by_IMAGE_satellite_in_UV_%28Blue_Marble_wrapped%29.jpg/1024px-Aurora_as_seen_by_IMAGE_satellite_in_UV_%28Blue_Marble_wrapped%29.jpg";

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Starfield
          CustomPaint(
            painter: StarFieldPainter(_stars, _warpSpeed.value),
            size: Size.infinite,
          ),

          // 2. The Realistic Earth Simulation
          Center(
            child: ScaleTransition(
              scale: _earthScale,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _indiaZoom.value,
                    child: Container(
                      width: 350,
                      height: 350,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            // Atmosphere Glow (Outer)
                            BoxShadow(
                                color: Color(0xFF0077FF),
                                blurRadius: 60,
                                spreadRadius: 2),
                          ]),
                      child: ClipOval(
                        child: Stack(
                          children: [
                            // A. Deep Ocean Base (Fallback)
                            Container(color: const Color(0xFF001133)),

                            // B. The Map Texture (Rotating)
                            Positioned.fill(
                              child: FractionallySizedBox(
                                widthFactor:
                                    4.0, // Make image wider to allowing sliding
                                heightFactor: 1.2,
                                child: Image.network(
                                  earthMapUrl,
                                  fit: BoxFit.cover,
                                  alignment:
                                      Alignment(_earthRotation.value, 0.0),
                                  loadingBuilder: (ctx, child, progress) {
                                    if (progress == null) return child;
                                    // While loading, show a generated globe gradient
                                    return Container(
                                      decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                              colors: [
                                            Color(0xFF004488),
                                            Color(0xFF002244)
                                          ],
                                              begin: Alignment.bottomLeft,
                                              end: Alignment.topRight)),
                                    );
                                  },
                                  errorBuilder: (ctx, err, stack) => Container(
                                    decoration: const BoxDecoration(
                                        gradient: RadialGradient(colors: [
                                      Colors.greenAccent,
                                      Colors.blue
                                    ], stops: [
                                      0.2,
                                      1.0
                                    ])),
                                  ),
                                ),
                              ),
                            ),

                            // C. Sphere Shading (Inner Shadow for 3D effect)
                            Container(
                              decoration: const BoxDecoration(
                                gradient: RadialGradient(
                                  center: Alignment(
                                      -0.3, -0.3), // Light Source Top-Left
                                  radius: 1.3,
                                  colors: [
                                    Colors.transparent,
                                    Color(0x44000000), // Light Shadow
                                    Color(0xFF000000), // Hard Shadow Edge
                                  ],
                                  stops: [0.4, 0.8, 1.0],
                                ),
                              ),
                            ),

                            // D. Specular Highlight (Reflection)
                            Positioned(
                              left: 80,
                              top: 80,
                              child: Container(
                                width: 60,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(50),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.white.withOpacity(0.3),
                                          blurRadius: 30,
                                          spreadRadius: 10)
                                    ]),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 3. Cinematic Text
          IgnorePointer(
            child: AnimatedOpacity(
              opacity: _fadeOpacity.value,
              duration: Duration.zero,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(height: 150),
                    Text(
                      "TARGETING: NEW DELHI",
                      style: GoogleFonts.orbitron(
                          color: Colors.cyanAccent,
                          fontSize: 16,
                          letterSpacing: 4,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "COORDINATES: 28.61° N, 77.20° E",
                      style: GoogleFonts.shareTechMono(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// --- Space & Physics ---

class Star {
  double x = 0;
  double y = 0;
  double z = 0;

  Star() {
    reset();
  }

  void reset() {
    // Random position full screen
    x = (Random().nextDouble() - 0.5) * 3000;
    y = (Random().nextDouble() - 0.5) * 3000;
    z = Random().nextDouble() * 2000; // Deep depth
  }

  void update(double t) {
    // Slower, majestic movement
    z -= 10;

    if (z <= 1) {
      z = 2000;
      x = (Random().nextDouble() - 0.5) * 3000;
      y = (Random().nextDouble() - 0.5) * 3000;
    }
  }
}

class StarFieldPainter extends CustomPainter {
  final List<Star> stars;
  final double intensity;

  StarFieldPainter(this.stars, this.intensity);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..strokeCap = StrokeCap.round;

    canvas.translate(center.dx, center.dy);

    for (var star in stars) {
      // Perspective projection
      double sx = star.x / star.z * 500;
      double sy = star.y / star.z * 500;

      // Previous pos for trail
      double prevZ = star.z + (20 + intensity * 50);
      double px = star.x / prevZ * 500;
      double py = star.y / prevZ * 500;

      // Opacity based on depth
      double opacity = (1000 - star.z) / 1000;
      paint.color = Colors.white.withOpacity(opacity.clamp(0.0, 1.0));
      paint.strokeWidth = (1 - star.z / 1000) * 3;

      if (intensity > 0.1) {
        // Streaks
        canvas.drawLine(Offset(px, py), Offset(sx, sy), paint);
      } else {
        // Dots
        canvas.drawCircle(Offset(sx, sy), paint.strokeWidth, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
