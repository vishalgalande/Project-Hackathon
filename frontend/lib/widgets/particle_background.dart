import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ParticleBackground extends StatefulWidget {
  const ParticleBackground({super.key});

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // Initialize particles
    for (int i = 0; i < 100; i++) {
      _particles.add(Particle(random: _random));
    }

    _ticker = createTicker((elapsed) {
      setState(() {
        for (var particle in _particles) {
          particle.update();
        }
      });
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF050505), // Deep Void Black
      child: CustomPaint(
        painter: ParticlePainter(particles: _particles),
        size: Size.infinite,
      ),
    );
  }
}

class Particle {
  double x = 0;
  double y = 0;
  double speed = 0;
  double theta = 0;
  double radius = 0;
  Color color = Colors.white;

  Particle({required Random random}) {
    reset(random);
    // Scramble initial layout
    x = random.nextDouble();
    y = random.nextDouble();
  }

  void reset(Random random) {
    x = random.nextDouble();
    y = random.nextDouble();
    speed = random.nextDouble() * 0.002 + 0.001;
    theta = random.nextDouble() * 2 * pi;
    radius = random.nextDouble() * 2 + 1;
    
    // Cyberpunk Palette
    final colors = [
      const Color(0xFF8B5CF6).withOpacity(0.6), // Neon Purple
      const Color(0xFF00F0FF).withOpacity(0.6), // Cyber Blue
      const Color(0xFFFFFFFF).withOpacity(0.3), // White
    ];
    color = colors[random.nextInt(colors.length)];
  }

  void update() {
    x += cos(theta) * speed;
    y += sin(theta) * speed;

    if (x < 0 || x > 1 || y < 0 || y > 1) {
      // Wrap around or bounce? Wrap looks more "flow"
      if (x < 0) x = 1;
      if (x > 1) x = 0;
      if (y < 0) y = 1;
      if (y > 1) y = 0;
    }
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()..color = particle.color;
      final dx = particle.x * size.width;
      final dy = particle.y * size.height;
      
      canvas.drawCircle(Offset(dx, dy), particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}
