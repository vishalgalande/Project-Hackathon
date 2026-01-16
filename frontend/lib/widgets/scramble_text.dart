import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class ScrambleText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;
  final Duration interval; // Speed of character switch

  const ScrambleText({
    super.key,
    required this.text,
    required this.style,
    this.duration = const Duration(milliseconds: 2000),
    this.interval = const Duration(milliseconds: 50),
  });

  @override
  State<ScrambleText> createState() => _ScrambleTextState();
}

class _ScrambleTextState extends State<ScrambleText> {
  String _displayText = '';
  late Timer _timer;
  final Random _random = Random();
  int _counter = 0;
  final String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()';

  @override
  void initState() {
    super.initState();
    _startScramble();
  }

  void _startScramble() {
    _timer = Timer.periodic(widget.interval, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        final double progress = timer.tick * widget.interval.inMilliseconds / widget.duration.inMilliseconds;
        
        if (progress >= 1.0) {
          _displayText = widget.text;
          timer.cancel();
        } else {
          // Reveal characters based on progress
          final int revealCount = (widget.text.length * progress).floor();
          _displayText = '';
          for (int i = 0; i < widget.text.length; i++) {
            if (i < revealCount) {
              _displayText += widget.text[i];
            } else if (widget.text[i] == ' ') {
              _displayText += ' ';
            } else {
              _displayText += _chars[_random.nextInt(_chars.length)];
            }
          }
        }
      });
    });
  }

  @override
  void dispose() {
    if (_timer.isActive) _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayText,
      style: widget.style,
      textAlign: TextAlign.center,
      maxLines: 1, // Ensure layout stability
    );
  }
}
