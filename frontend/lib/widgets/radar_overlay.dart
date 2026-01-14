import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../models/zone.dart';

/// Radar Overlay Widget for Map
/// Pulsing radar effect for zone visualization
class RadarOverlay extends StatefulWidget {
  final Zone zone;
  final double size;

  const RadarOverlay({
    super.key,
    required this.zone,
    this.size = 200,
  });

  @override
  State<RadarOverlay> createState() => _RadarOverlayState();
}

class _RadarOverlayState extends State<RadarOverlay>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _sweepController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: widget.zone.pulseSpeed,
    )..repeat(reverse: true);

    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _sweepController.dispose();
    super.dispose();
  }

  Color get _zoneColor {
    switch (widget.zone.type.toLowerCase()) {
      case 'danger':
        return AppColors.neonCrimson;
      case 'caution':
        return AppColors.cautionZone;
      case 'safe':
        return AppColors.cyberCyan;
      default:
        return AppColors.cyberCyan;
    }
  }

  double get _baseOpacity {
    switch (widget.zone.type.toLowerCase()) {
      case 'danger':
        return 0.4;
      case 'caution':
        return 0.25;
      case 'safe':
        return 0.15;
      default:
        return 0.2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _sweepController]),
      builder: (context, child) {
        final pulseValue = _pulseController.value;
        final sweepValue = _sweepController.value;

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulsing ring
              Container(
                width: widget.size * (0.9 + pulseValue * 0.1),
                height: widget.size * (0.9 + pulseValue * 0.1),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        _zoneColor.withOpacity(_baseOpacity + pulseValue * 0.2),
                    width: 2,
                  ),
                ),
              ),

              // Middle ring
              Container(
                width: widget.size * 0.7,
                height: widget.size * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _zoneColor.withOpacity(_baseOpacity),
                    width: 1,
                  ),
                ),
              ),

              // Inner ring
              Container(
                width: widget.size * 0.4,
                height: widget.size * 0.4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _zoneColor.withOpacity(_baseOpacity * 0.7),
                    width: 1,
                  ),
                ),
              ),

              // Fill gradient
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _zoneColor.withOpacity(_baseOpacity * pulseValue),
                      _zoneColor.withOpacity(_baseOpacity * 0.3),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),

              // Sweep line (for danger zones)
              if (widget.zone.type.toLowerCase() == 'danger')
                Transform.rotate(
                  angle: sweepValue * 2 * math.pi,
                  child: CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: _SweepPainter(color: _zoneColor),
                  ),
                ),

              // Center dot
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _zoneColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _zoneColor.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SweepPainter extends CustomPainter {
  final Color color;

  _SweepPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          color.withOpacity(0.5),
          Colors.transparent,
        ],
        stops: const [0.0, 0.25],
        startAngle: 0,
        endAngle: math.pi / 2,
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius * 0.95, sweepPaint);

    // Draw sweep line
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
        center, Offset(center.dx + radius * 0.95, center.dy), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
