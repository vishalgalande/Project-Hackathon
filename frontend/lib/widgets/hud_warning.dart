import 'package:flutter/material.dart';
import '../app/theme.dart';

/// HUD Warning Overlay
/// Full-screen alert displayed when user enters danger zone
class HudWarning extends StatefulWidget {
  final String title;
  final String message;
  final VoidCallback? onDismiss;
  final Color color;
  
  const HudWarning({
    super.key,
    this.title = 'CRITICAL THREAT DETECTED',
    this.message = 'You have entered a high-risk zone',
    this.onDismiss,
    this.color = AppColors.neonCrimson,
  });
  
  @override
  State<HudWarning> createState() => _HudWarningState();
}

class _HudWarningState extends State<HudWarning>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _borderController;
  late AnimationController _textController;
  
  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..repeat(reverse: true);
    
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _borderController.dispose();
    _textController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _borderController, _textController]),
      builder: (context, child) {
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // Flashing border overlay
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: widget.color.withOpacity(
                          0.3 + (_borderController.value * 0.7),
                        ),
                        width: 4 + (_borderController.value * 4),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Vignette effect
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.transparent,
                          widget.color.withOpacity(0.1 * _pulseController.value),
                        ],
                        radius: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Warning content
              Center(
                child: Transform.scale(
                  scale: 0.9 + (_textController.value * 0.1),
                  child: Opacity(
                    opacity: _textController.value,
                    child: Container(
                      margin: const EdgeInsets.all(40),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.voidBlack.withOpacity(0.95),
                        border: Border.all(
                          color: widget.color,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.color.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Warning icon
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 64,
                            color: widget.color,
                          ),
                          const SizedBox(height: 24),
                          
                          // Title
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: widget.color,
                              letterSpacing: 4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          
                          // Message
                          Text(
                            widget.message,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          
                          // Dismiss button
                          if (widget.onDismiss != null)
                            GestureDetector(
                              onTap: widget.onDismiss,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                child: const Text(
                                  'ACKNOWLEDGE',
                                  style: TextStyle(
                                    fontFamily: 'JetBrains Mono',
                                    fontSize: 12,
                                    letterSpacing: 2,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          
                          // Status line
                          const SizedBox(height: 24),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: widget.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'THREAT LEVEL: MAXIMUM',
                                style: TextStyle(
                                  fontFamily: 'JetBrains Mono',
                                  fontSize: 10,
                                  color: widget.color,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Corner HUD elements
              _buildCornerHud(Alignment.topLeft),
              _buildCornerHud(Alignment.topRight),
              _buildCornerHud(Alignment.bottomLeft),
              _buildCornerHud(Alignment.bottomRight),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildCornerHud(Alignment alignment) {
    return Positioned(
      top: alignment.y < 0 ? 20 : null,
      bottom: alignment.y > 0 ? 20 : null,
      left: alignment.x < 0 ? 20 : null,
      right: alignment.x > 0 ? 20 : null,
      child: IgnorePointer(
        child: Text(
          alignment.y < 0
              ? (alignment.x < 0 ? '// ALERT_ACTIVE' : 'SYS_001 //')
              : (alignment.x < 0 ? '// ZONE_BREACH' : 'CRITICAL //'),
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 10,
            color: widget.color.withOpacity(0.5),
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
