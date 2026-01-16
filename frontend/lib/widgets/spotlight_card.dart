import 'package:flutter/material.dart';
import 'dart:ui';

class SpotlightCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color spotlightColor;

  const SpotlightCard({
    super.key,
    required this.child,
    this.onTap,
    this.spotlightColor = const Color(0xFF8B5CF6),
  });

  @override
  State<SpotlightCard> createState() => _SpotlightCardState();
}

class _SpotlightCardState extends State<SpotlightCard> {
  Offset _mousePos = Offset.zero;
  bool _isHovering = false;

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
        onTap: widget.onTap,
        child: CustomPaint(
          painter: _SpotlightBorderPainter(
            mousePos: _mousePos,
            color: widget.spotlightColor,
            opacity: _isHovering ? 1.0 : 0.0,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Stack( // Use Stack to ensure BackdropFilter is distinct
                children: [
                  // Blur Layer
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: widget.child,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpotlightBorderPainter extends CustomPainter {
  final Offset mousePos;
  final Color color;
  final double opacity;

  _SpotlightBorderPainter({
    required this.mousePos,
    required this.color,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity == 0) return;

    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16));

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..shader = RadialGradient(
        colors: [color.withOpacity(1.0), Colors.transparent],
        stops: const [0.0, 0.6],
        center: Alignment(
          (mousePos.dx / size.width) * 2 - 1,
          (mousePos.dy / size.height) * 2 - 1,
        ),
        radius: 0.8,
      ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _SpotlightBorderPainter oldDelegate) {
    return oldDelegate.mousePos != mousePos || oldDelegate.opacity != opacity;
  }
}
