import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Wireframe Globe Widget
/// A 3D-style rotating wireframe sphere using CustomPainter
import 'package:flutter_animate/flutter_animate.dart';

class WireframeGlobe extends StatefulWidget {
  final double size;
  final Color color;
  final Duration rotationDuration;
  
  const WireframeGlobe({
    super.key,
    this.size = 300,
    this.color = AppColors.cyberCyan,
    this.rotationDuration = const Duration(seconds: 20),
  });
  
  @override
  State<WireframeGlobe> createState() => _WireframeGlobeState();
}

class _WireframeGlobeState extends State<WireframeGlobe>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.rotationDuration,
    )..repeat();
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
          size: Size(widget.size, widget.size),
          painter: _GlobePainter(
            rotation: _controller.value * 2 * math.pi,
            color: widget.color,
          ),
        );
      },
    )
    .animate(onPlay: (controller) => controller.repeat(reverse: true))
    .scaleXY(
      begin: 0.95, 
      end: 1.05, 
      duration: 2000.ms, 
      curve: Curves.easeInOutSine // "Breathing" effect
    )
    .animate() // Separate chain for entrance
    .scale(
      duration: 1200.ms, 
      curve: Curves.elasticOut // GSAP-style Elastic Entrance
    )
    .shimmer(
      delay: 1000.ms,
      duration: 2000.ms,
      color: Colors.white.withOpacity(0.5)
    );
  }
}

class _GlobePainter extends CustomPainter {
  final double rotation;
  final Color color;
  
  _GlobePainter({
    required this.rotation,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    
    // Main wireframe paint
    final wirePaint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    // Glow paint
    final glowPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    
    // Draw outer glow circle
    canvas.drawCircle(center, radius, glowPaint);
    canvas.drawCircle(center, radius, wirePaint);
    
    // Draw latitude lines (horizontal)
    for (int i = 1; i < 6; i++) {
      final latRadius = radius * math.sin(i * math.pi / 6);
      final yOffset = radius * math.cos(i * math.pi / 6);
      
      // Create ellipse for latitude lines
      final rect = Rect.fromCenter(
        center: Offset(center.dx, center.dy - yOffset),
        width: latRadius * 2,
        height: latRadius * 0.3, // Flatten for 3D perspective
      );
      
      final latPaint = Paint()
        ..color = color.withOpacity(0.3 + (i * 0.05))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;
      
      canvas.drawOval(rect, latPaint);
      
      // Draw on opposite side too
      final rectBottom = Rect.fromCenter(
        center: Offset(center.dx, center.dy + yOffset),
        width: latRadius * 2,
        height: latRadius * 0.3,
      );
      canvas.drawOval(rectBottom, latPaint);
    }
    
    // Draw longitude lines (vertical arcs)
    for (int i = 0; i < 12; i++) {
      final angle = rotation + (i * math.pi / 6);
      final visible = math.cos(angle);
      
      if (visible > -0.3) {
        final opacity = (visible + 0.3) / 1.3 * 0.6;
        final longPaint = Paint()
          ..color = color.withOpacity(opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8;
        
        // Create arc path for longitude
        final path = Path();
        for (int j = 0; j <= 36; j++) {
          final theta = j * math.pi / 36;
          final x = center.dx + math.sin(angle) * radius * math.sin(theta);
          final y = center.dy - radius * math.cos(theta);
          
          if (j == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        canvas.drawPath(path, longPaint);
      }
    }
    
    // Draw center point (North Pole marker)
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx, center.dy - radius), 3, dotPaint);
    canvas.drawCircle(Offset(center.dx, center.dy + radius), 3, dotPaint);
    
    // Draw rotating accent ring
    final ringAngle = rotation * 1.5;
    final ringPaint = Paint()
      ..color = AppColors.neonCrimson.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    final ringPath = Path();
    for (int i = 0; i <= 36; i++) {
      final theta = i * math.pi / 18;
      final x = center.dx + math.cos(ringAngle) * radius * 0.9 * math.cos(theta);
      final y = center.dy + math.sin(ringAngle) * radius * 0.3 + 
                radius * 0.9 * math.sin(theta) * math.sin(ringAngle + math.pi / 2);
      
      if (i == 0) {
        ringPath.moveTo(x, y);
      } else {
        ringPath.lineTo(x, y);
      }
    }
    // Partial ring
    canvas.drawPath(ringPath, ringPaint);
    
    // Draw radar scan line
    final scanAngle = rotation * 3;
    final scanPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(0.8),
          color.withOpacity(0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    final scanPath = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(
        center.dx + radius * math.cos(scanAngle),
        center.dy + radius * math.sin(scanAngle),
      )
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        scanAngle,
        0.3,
        false,
      )
      ..close();
    
    canvas.drawPath(scanPath, scanPaint);
  }
  
  @override
  bool shouldRepaint(_GlobePainter oldDelegate) {
    return oldDelegate.rotation != rotation;
  }
}
