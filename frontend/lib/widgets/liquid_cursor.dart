import 'dart:collection';
import 'dart:ui';
import 'package:flutter/material.dart';

class LiquidCursor extends StatefulWidget {
  final Widget child;
  final Color color;

  const LiquidCursor({
    super.key,
    required this.child,
    this.color = const Color(0xFF00F0FF),
  });

  @override
  State<LiquidCursor> createState() => _LiquidCursorState();
}

class _LiquidCursorState extends State<LiquidCursor> {
  final List<Offset> _points = [];
  final int _maxPoints = 20;

  void _onHover(PointerEvent event) {
    setState(() {
      _points.add(event.localPosition);
      if (_points.length > _maxPoints) {
        _points.removeAt(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: _onHover,
      opaque: false,
      child: CustomPaint(
        foregroundPainter: _CursorTrailPainter(
          points: List.from(_points),
          color: widget.color,
        ),
        child: widget.child,
      ),
    );
  }
}

class _CursorTrailPainter extends CustomPainter {
  final List<Offset> points;
  final Color color;

  _CursorTrailPainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw glowing trail
    for (int i = 0; i < points.length - 1; i++) {
        // Opacity fades out for older points
        final double opacity = (i / points.length);
        final double width = (i / points.length) * 8.0; // Tapering
        
        paint.color = color.withOpacity(opacity * 0.6);
        paint.strokeWidth = width;
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0); // Glow
        
        canvas.drawLine(points[i], points[i+1], paint);
    }
    
    // Core bright line (no blur)
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    
    // Simple spline smoothing
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      path.quadraticBezierTo(
        p0.dx, p0.dy, 
        (p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2
      );
    }
    
    // paint.maskFilter = null;
    // paint.color = Colors.white.withOpacity(0.5);
    // paint.strokeWidth = 2.0;
    // canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CursorTrailPainter oldDelegate) => true;
}
