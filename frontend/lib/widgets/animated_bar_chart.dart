import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Animated Bar Chart
/// Used in Intel page for zone statistics
class AnimatedBarChart extends StatefulWidget {
  final String label;
  final int value; // 0-100
  final Color color;
  final Duration delay;
  final bool showPercentage;
  final IconData? icon;

  const AnimatedBarChart({
    super.key,
    required this.label,
    required this.value,
    this.color = AppColors.primary,
    this.delay = Duration.zero,
    this.showPercentage = true,
    this.icon,
  });

  @override
  State<AnimatedBarChart> createState() => _AnimatedBarChartState();
}

class _AnimatedBarChartState extends State<AnimatedBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _animation = Tween<double>(
      begin: 0,
      end: widget.value / 100,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    // Start with delay
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        size: 16,
                        color: widget.color,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                if (widget.showPercentage)
                  Text(
                    '${(_animation.value * 100).toInt()}%',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 14,
                      color: widget.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Bar container
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Stack(
                children: [
                  // Filled portion
                  FractionallySizedBox(
                    widthFactor: _animation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.color.withOpacity(0.8),
                            widget.color,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: widget.color.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Scanline effect
                  if (_controller.isAnimating)
                    Positioned(
                      left: _animation.value *
                              MediaQuery.of(context).size.width *
                              0.7 -
                          20,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 20,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Stat Card for Intel Page
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 24,
            color: color,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
