import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class WarpTransition extends StatefulWidget {
  final VoidCallback onFinished;

  const WarpTransition({super.key, required this.onFinished});

  @override
  State<WarpTransition> createState() => _WarpTransitionState();
}

class _WarpTransitionState extends State<WarpTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<WarpObject> _objects = [];
  final int _objectCount = 80; // Fewer objects since text is heavier

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Initialize objects
    for (int i = 0; i < _objectCount; i++) {
      _objects.add(WarpObject());
    }

    _controller.addListener(() {
      if (_controller.value > 0.8 && !_hasFinished) {
          _hasFinished = true;
          // Small delay to let flash fill screen
          Future.delayed(const Duration(milliseconds: 200), widget.onFinished);
      }
    });

    _controller.forward();
  }

  bool _hasFinished = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: WarpPainter(
              objects: _objects,
              progress: _controller.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class WarpObject {
  double x = Random().nextDouble() * 2 - 1; // -1 to 1
  double y = Random().nextDouble() * 2 - 1; // -1 to 1
  double z = Random().nextDouble() + 0.1; // 0.1 to 1.1 (depth)
  String text = _randomText();
  Color color = _randomColor();

  static String _randomText() {
    final words = [
      'SAFETY', 'INDIA', 'TRAVEL', 'SAFE', 'SECURE', 
      'ZONE', 'PROTECT', 'GUIDE', 'SMART', 'AI', 'FUTURE'
    ];
    return words[Random().nextInt(words.length)];
  }

  static Color _randomColor() {
    final colors = [
      const Color(0xFF6366f1), // Indigo
      const Color(0xFFa855f7), // Purple
      const Color(0xFF06b6d4), // Cyan
      Colors.white,
    ];
    return colors[Random().nextInt(colors.length)];
  }
}

class WarpPainter extends CustomPainter {
  final List<WarpObject> objects;
  final double progress;

  WarpPainter({required this.objects, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..strokeCap = StrokeCap.round;

    // Background fade/flash
    if (progress > 0.9) {
      final flashOpacity = (progress - 0.9) * 10;
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = Colors.white.withOpacity(flashOpacity),
      );
    }

    // Speed factor increases exponentially
    final speed = pow(progress, 3) * 0.2;

    for (var obj in objects) {
      // Move object closer (decrease z)
      obj.z -= speed;

      // Reset if behind camera
      if (obj.z <= 0) {
        obj.z = 1.0;
        obj.x = Random().nextDouble() * 2 - 1;
        obj.y = Random().nextDouble() * 2 - 1;
        obj.text = WarpObject._randomText(); // New word
      }

      // Perspective projection
      final depth = obj.z;
      final px = obj.x / depth;
      final py = obj.y / depth;

      final screenX = center.dx + px * size.width * 0.5;
      final screenY = center.dy + py * size.height * 0.5;

      // Calculate trail (previous position/outer position) - "Streaking Lines"
      // Much longer tail for "Striking" effect
      final prevPx = obj.x / (depth + speed * 4); // Longer motion blur
      final prevPy = obj.y / (depth + speed * 4);
      final prevScreenX = center.dx + prevPx * size.width * 0.5;
      final prevScreenY = center.dy + prevPy * size.height * 0.5;

      // Don't draw if out of bounds (optimization)
      if (screenX < -100 || screenX > size.width + 100 || 
          screenY < -100 || screenY > size.height + 100) {
        continue;
      }

      // Size grows as it gets closer
      final scale = (1 - depth) * 2 + 0.5; 
      final fontSize = 8.0 * scale * (1 + progress); // Reduced base size from 12.0 to 8.0

      // Opacity fades in - Reduced max opacity
      final opacity = ((1 - depth) * 0.6).clamp(0.0, 0.6); // Max opacity 0.6
      
      // 1. Draw the "Striking Line" Trail
      paint.color = obj.color.withOpacity(opacity * 0.5);
      paint.strokeWidth = scale * 2;
      
      if (progress > 0.1) {
        canvas.drawLine(
          Offset(prevScreenX, prevScreenY),
          Offset(screenX, screenY),
          paint,
        );
      }

      // 2. Draw Text at the tip
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: obj.text,
          style: TextStyle(
            color: obj.color.withOpacity(opacity), // Uses reduced opacity
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: 'Courier', 
            letterSpacing: 1.5,
            shadows: [
                Shadow(
                    blurRadius: 5 * scale, // Reduced blur
                    color: obj.color.withOpacity(opacity * 0.5),
                ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      
      // Rotate text to match the streak angle (optional, but "Striking" implies direction)
      // Calculating angle from center to point
      final angle = atan2(screenY - center.dy, screenX - center.dx);
      
      canvas.save();
      canvas.translate(screenX, screenY);
      canvas.rotate(angle); // Text points outwards along the line
      
      textPainter.paint(canvas, Offset(10 * scale, -textPainter.height / 2)); // Offset slightly from line tip
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
