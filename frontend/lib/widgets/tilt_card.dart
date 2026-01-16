import 'package:flutter/material.dart';
import 'dart:math' as math;

class TiltCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color baseColor;
  final double sensitivity;

  const TiltCard({
    super.key,
    required this.child,
    this.onTap,
    this.baseColor = const Color(0xFF8B5CF6),
    this.sensitivity = 15.0, // Higher is less sensitive (inverse logic in matrix)
  });

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard> with SingleTickerProviderStateMixin {
  Offset _mousePos = Offset.zero;
  bool _isHovering = false;
  late AnimationController _resetController;
  late Animation<Offset> _resetAnimation;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _onHover(PointerEvent details) {
    final size = context.size ?? Size.zero;
    final center = Offset(size.width / 2, size.height / 2);
    // Calculate offset from center (-1.0 to 1.0)
    final offset = Offset(
      (details.localPosition.dx - center.dx) / center.dx,
      (details.localPosition.dy - center.dy) / center.dy,
    );
    
    setState(() {
      _mousePos = offset;
      _isHovering = true;
    });
  }

  void _onExit(PointerEvent details) {
    setState(() => _isHovering = false);
    
    // Animate back to center
    _resetAnimation = Tween<Offset>(
      begin: _mousePos,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _resetController, curve: Curves.easeOutBack));
    
    _resetController.forward(from: 0).then((_) {
      if (!_isHovering) setState(() => _mousePos = Offset.zero);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Current tilt angles
    final rotateX = _isHovering ? -_mousePos.dy * (math.pi / widget.sensitivity) : 0.0;
    final rotateY = _isHovering ? _mousePos.dx * (math.pi / widget.sensitivity) : 0.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: _onExit,
      onHover: _onHover,
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 200),
          tween: Tween(begin: 0, end: _isHovering ? 1.0 : 0.0),
          builder: (context, hoverValue, child) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // Perspective
                ..rotateX(_isHovering ? rotateX : 0) // Immediate update for responsiveness
                ..rotateY(_isHovering ? rotateY : 0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: widget.baseColor.withOpacity(0.2 * hoverValue),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      // Base Card Content
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A0A0A),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.all(32),
                        child: widget.child,
                      ),
                      
                      // Dynamic Glare Effect
                      // Moves opposite to mouse (if mouse is top-left, glare is bottom-right)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment(
                                -_mousePos.dx * 1.5,
                                -_mousePos.dy * 1.5,
                              ),
                              radius: 1.2,
                              colors: [
                                Colors.white.withOpacity(0.1 * hoverValue),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.5],
                            ),
                          ),
                        ),
                      ),
                      
                      // Border Gradient
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: widget.baseColor.withOpacity(0.3 * hoverValue),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
