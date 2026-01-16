import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color baseColor;

  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.baseColor = const Color(0xFF8B5CF6),
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> with SingleTickerProviderStateMixin {
  Offset _mousePos = Offset.zero;
  bool _isHovering = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      onHover: (event) {
        setState(() {
          _mousePos = event.localPosition;
        });
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutBack,
          child: CustomPaint(
            painter: _GradientFollowerBorderPainter(
              mousePos: _mousePos,
              hovering: _isHovering,
              color: widget.baseColor,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  padding: const EdgeInsets.all(32),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientFollowerBorderPainter extends CustomPainter {
  final Offset mousePos;
  final bool hovering;
  final Color color;

  _GradientFollowerBorderPainter({
    required this.mousePos,
    required this.hovering,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(24));

    // Base subtle border
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white.withOpacity(0.1);
    canvas.drawRRect(rrect, basePaint);

    if (!hovering) return;

    // Follower Gradient
    // We create a radial gradient centered at mouse that reveals the border color
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..shader = RadialGradient(
        colors: [color, Colors.transparent],
        stops: const [0.0, 0.5],
        center: Alignment(
          (mousePos.dx / size.width) * 2 - 1,
          (mousePos.dy / size.height) * 2 - 1,
        ),
        radius: 0.6,
      ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientFollowerBorderPainter oldDelegate) {
    return oldDelegate.mousePos != mousePos || oldDelegate.hovering != hovering;
  }
}
