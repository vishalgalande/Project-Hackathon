import 'package:flutter/material.dart';
import 'dart:math';

// Draws random tech "data lines" moving across screen
class TechParticles extends StatefulWidget {
  const TechParticles({super.key});

  @override
  State<TechParticles> createState() => _TechParticlesState();
}

class _TechParticlesState extends State<TechParticles> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_TechLine> _lines = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))
      ..repeat();
    
    // Init lines
    for(int i=0; i<5; i++) {
      _lines.add(_generateLine());
    }
  }
  
  _TechLine _generateLine() {
      return _TechLine(
          y: _random.nextDouble(),
          width: 50 + _random.nextDouble() * 200,
          speed: 0.1 + _random.nextDouble() * 0.3,
          delay: _random.nextDouble(),
      );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _TechLinesPainter(
            lines: _lines, 
            progress: _controller.value, 
            random: _random
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _TechLine {
  double y; // 0-1
  double width;
  double speed;
  double delay;
  
  _TechLine({required this.y, required this.width, required this.speed, required this.delay});
}

class _TechLinesPainter extends CustomPainter {
  final List<_TechLine> lines;
  final double progress;
  final Random random;

  _TechLinesPainter({required this.lines, required this.progress, required this.random});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
       ..strokeCap = StrokeCap.square;

    for (var line in lines) {
        // Calculate X based on time * speed
        double currentX = ((progress + line.delay) * line.speed * size.width * 5) % (size.width + line.width + 500);
        currentX -= line.width; // Start off screen
        
        paint.color = const Color(0xFF00F0FF).withOpacity(0.1);
        paint.strokeWidth = 1.0;
        
        // Draw main line
        canvas.drawLine(
            Offset(currentX, line.y * size.height),
            Offset(currentX + line.width, line.y * size.height),
            paint
        );
        
        // Draw head
        paint.color = Colors.white.withOpacity(0.4);
        canvas.drawCircle(Offset(currentX + line.width, line.y * size.height), 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TechLinesPainter oldDelegate) => true;
}
