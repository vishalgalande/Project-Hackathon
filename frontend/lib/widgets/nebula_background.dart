import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../core/shader_manager.dart';

class NebulaBackground extends StatefulWidget {
  const NebulaBackground({super.key});

  @override
  State<NebulaBackground> createState() => _NebulaBackgroundState();
}

class _NebulaBackgroundState extends State<NebulaBackground>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _time = 0.0;
  Offset _mousePos = Offset.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      if (!mounted) return;
      setState(() {
        _time = elapsed.inMilliseconds / 1000.0;
      });
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!ShaderManager().isReady) {
      return Container(color: const Color(0xFF050505)); // Fallback
    }

    return RepaintBoundary(
      child: MouseRegion(
        onHover: (event) {
          setState(() {
            _mousePos = event.localPosition;
          });
        },
        child: CustomPaint(
          painter: _NebulaPainter(
            shader: ShaderManager().nebulaProgram!.fragmentShader(),
            time: _time,
            mousePos: _mousePos,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _NebulaPainter extends CustomPainter {
  final FragmentShader shader;
  final double time;
  final Offset mousePos;

  _NebulaPainter({
    required this.shader,
    required this.time,
    required this.mousePos,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Uniforms: uSize (0, 1), uTime (2), uMouse (3, 4)
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, time);
    shader.setFloat(3, mousePos.dx);
    shader.setFloat(4, mousePos.dy);

    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _NebulaPainter oldDelegate) {
    return oldDelegate.time != time || oldDelegate.mousePos != mousePos;
  }
}
