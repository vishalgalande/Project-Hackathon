import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Glitch Effect Button
/// Cyberpunk-style CTA with text distortion on hover/tap
class GlitchButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final double width;
  final double height;

  const GlitchButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = const Color(0xFF00FFFF), // AppColors.cyberCyan
    this.width = 280,
    this.height = 60,
  });

  @override
  State<GlitchButton> createState() => _GlitchButtonState();
}

class _GlitchButtonState extends State<GlitchButton>
    with TickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _glitchController;
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _glitchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _glitchController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  void _triggerGlitch() {
    _glitchController.forward().then((_) {
      _glitchController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _triggerGlitch();
      },
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _triggerGlitch();
        },
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: Listenable.merge([_glitchController, _scanController]),
          builder: (context, child) {
            final glitchOffset = _glitchController.value * 4;
            final isGlitching = _glitchController.isAnimating;

            return Transform.scale(
              scale: _isPressed ? 0.98 : 1.0,
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: widget.color,
                    width: 2,
                  ),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: widget.color.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    // Background fill on hover
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: _isHovered
                            ? widget.color.withOpacity(0.1)
                            : Colors.transparent,
                      ),
                    ),

                    // Scan line
                    if (_isHovered)
                      Positioned(
                        top: _scanController.value * widget.height,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                widget.color.withOpacity(0.5),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Main text
                    Center(
                      child: Text(
                        widget.text,
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                          color: _isHovered ? widget.color : Colors.white,
                        ),
                      ),
                    ),

                    // Glitch layer 1 (Red offset)
                    if (isGlitching)
                      Positioned(
                        left: -glitchOffset,
                        top: glitchOffset / 2,
                        child: ClipRect(
                          child: Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: widget.width,
                              height: widget.height,
                              child: Center(
                                child: Text(
                                  widget.text,
                                  style: TextStyle(
                                    fontFamily: 'JetBrains Mono',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 3,
                                    color:
                                        AppColors.neonCrimson.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Glitch layer 2 (Cyan offset)
                    if (isGlitching)
                      Positioned(
                        left: glitchOffset,
                        top: -glitchOffset / 2,
                        child: ClipRect(
                          child: Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: widget.width,
                              height: widget.height,
                              child: Center(
                                child: Text(
                                  widget.text,
                                  style: TextStyle(
                                    fontFamily: 'JetBrains Mono',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 3,
                                    color: AppColors.cyberCyan.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Corner brackets
                    Positioned(
                      top: 4,
                      left: 4,
                      child: _CornerBracket(color: widget.color),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(math.pi),
                        child: _CornerBracket(color: widget.color),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      left: 4,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationX(math.pi),
                        child: _CornerBracket(color: widget.color),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationZ(math.pi),
                        child: _CornerBracket(color: widget.color),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CornerBracket extends StatelessWidget {
  final Color color;

  const _CornerBracket({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 12,
      height: 12,
      child: CustomPaint(
        painter: _BracketPainter(color: color),
      ),
    );
  }
}

class _BracketPainter extends CustomPainter {
  final Color color;

  _BracketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
