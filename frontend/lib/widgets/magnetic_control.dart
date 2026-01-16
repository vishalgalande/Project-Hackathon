import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class MagneticControl extends StatefulWidget {
  final Widget child;
  final double distance;
  final VoidCallback? onTap;

  const MagneticControl({
    super.key,
    required this.child,
    this.distance = 30.0, // Max distance the button moves
    this.onTap,
  });

  @override
  State<MagneticControl> createState() => _MagneticControlState();
}

class _MagneticControlState extends State<MagneticControl> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Alignment _alignment = Alignment.center;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHover(PointerEvent details) {
    if (context.size == null) return;
    
    final size = context.size!;
    final center = Offset(size.width / 2, size.height / 2);
    final delta = details.localPosition - center;
    
    // Calculate normalized alignment (-1 to 1)
    final x = (delta.dx / (size.width / 2)).clamp(-1.0, 1.0);
    final y = (delta.dy / (size.height / 2)).clamp(-1.0, 1.0);
    
    setState(() {
      _alignment = Alignment(x, y);
    });
  }

  void _onExit(PointerEvent details) {
    // Spring back to center
    _runSpringAnimation();
  }

  void _runSpringAnimation() {
    final simulation = SpringSimulation(
      const SpringDescription(mass: 1, stiffness: 500, damping: 15),
      _alignment.x, // Start value (using x as proxy for magnitude, but we need vector spring really)
      0.0, // End value
      0.0, // Velocity
    );
     // Simplified: Just animate alignment back to (0,0) using standard curve for now
     // true spring logic for 2D vectors is verbose in Flutter without a custom ticker
     setState(() {
       _alignment = Alignment.center;
     });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: _onHover,
      onExit: _onExit,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..translate(
              _alignment.x * widget.distance,
              _alignment.y * widget.distance,
            ),
          child: widget.child,
        ),
      ),
    );
  }
}
