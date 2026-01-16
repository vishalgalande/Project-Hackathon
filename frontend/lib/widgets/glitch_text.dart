import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class GlitchText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration interval;

  const GlitchText({
    super.key,
    required this.text,
    required this.style,
    this.interval = const Duration(seconds: 3),
  });

  @override
  State<GlitchText> createState() => _GlitchTextState();
}

class _GlitchTextState extends State<GlitchText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _glitchTimer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    _startGlitchLoop();
  }

  void _startGlitchLoop() {
    _glitchTimer = Timer.periodic(widget.interval, (timer) {
      if (!mounted) return;
      // Randomly decide to glitch
      if (_random.nextDouble() > 0.3) {
        _controller.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _glitchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // If not animating, return clean text
        if (!_controller.isAnimating) {
          return Text(widget.text, style: widget.style, textAlign: TextAlign.center);
        }

        // Glitch Phase
        final double dist = _random.nextDouble() * 5.0;
        final double redX = _random.nextDouble() * 4 - 2;
        final double blueX = _random.nextDouble() * 4 - 2;
        final double blueY = _random.nextDouble() * 4 - 2;

        return Stack(
          children: [
            // Red Channel Shift
            Transform.translate(
              offset: Offset(redX, 0),
              child: Text(
                widget.text,
                textAlign: TextAlign.center,
                style: widget.style.copyWith(color: Colors.red.withOpacity(0.8)),
              ),
            ),
            // Blue Channel Shift
            Transform.translate(
              offset: Offset(blueX, blueY),
              child: Text(
                widget.text,
                textAlign: TextAlign.center,
                style: widget.style.copyWith(color: Colors.blue.withOpacity(0.8)),
              ),
            ),
            // Main Text (White) with clip/cut effect
            // Simulating "Cut" by simple ClipRect logic is hard on Text, so we keep the base layer clean
            // but shake it slightly.
            Transform.translate(
              offset: Offset(_random.nextDouble() * 2 - 1, _random.nextDouble() * 2 - 1),
              child: Text(
                widget.text,
                textAlign: TextAlign.center,
                style: widget.style,
              ),
            ),
          ],
        );
      },
    );
  }
}
