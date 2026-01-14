import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../auth/auth_dialogs.dart' show AppColors;
import 'chat_overlay.dart';

/// Floating chat button widget that appears in the corner of the screen.
/// Tap to open the AI chatbot overlay.
class ChatButton extends StatefulWidget {
  const ChatButton({super.key});

  @override
  State<ChatButton> createState() => _ChatButtonState();
}

class _ChatButtonState extends State<ChatButton> {
  bool _isChatOpen = false;

  void _toggleChat() {
    setState(() {
      _isChatOpen = !_isChatOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Chat overlay (shown when open)
        if (_isChatOpen) ChatOverlay(onClose: _toggleChat),

        // Floating action button
        Positioned(
          bottom: 20,
          right: 20,
          child: GestureDetector(
            onTap: _toggleChat,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.accent,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 16,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  _isChatOpen ? Icons.close_rounded : Icons.chat_rounded,
                  key: ValueKey(_isChatOpen),
                  color: Colors.white,
                  size: 28,
                ),
              ),
            )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.05, 1.05),
                  duration: 1500.ms,
                  curve: Curves.easeInOut,
                ),
          ),
        ),
      ],
    );
  }
}
