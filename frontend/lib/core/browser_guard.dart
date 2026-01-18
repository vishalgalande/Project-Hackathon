import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:universal_html/html.dart' as html;

class BrowserGuard extends StatefulWidget {
  final Widget child;
  const BrowserGuard({super.key, required this.child});

  @override
  State<BrowserGuard> createState() => _BrowserGuardState();
}

class _BrowserGuardState extends State<BrowserGuard> {
  bool _isCompatible = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkBrowser();
  }

  void _checkBrowser() {
    if (!kIsWeb) {
      if (mounted) {
        setState(() {
          _isCompatible = true;
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final userAgent = html.window.navigator.userAgent.toLowerCase();

      // Check for Chromium-based browsers (Chrome, Edge, Brave, Opera usually have 'chrome')
      // Firefox does not have 'chrome'. Safari does not have 'chrome' (usually).
      final isChrome = userAgent.contains('chrome') ||
          userAgent.contains('crios'); // crios is chrome on ios

      if (mounted) {
        setState(() {
          _isCompatible = isChrome;
          _isLoading = false;
        });
      }
    } catch (e) {
      // If check fails, let them pass
      if (mounted) {
        setState(() {
          _isCompatible = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
          color: Colors.black); // Simple black screen while checking
    }

    if (!_isCompatible) {
      return _buildIncompatibleScreen();
    }

    return widget.child;
  }

  Widget _buildIncompatibleScreen() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF050505),
        body: Stack(
          children: [
            // Background Elements could go here (nebula etc), keeping it simple but styled
            Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                constraints: const BoxConstraints(maxWidth: 500),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        size: 64, color: Colors.redAccent),
                    const SizedBox(height: 24),
                    Text(
                      'UNSUPPORTED TERMINAL DETECTED',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.syncopate(
                        color: Colors.redAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'This system is optimized for Chromium engines (Google Chrome, Edge, Brave).',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceMono(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Please switch to CHROME for full visual fidelity and performance.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceMono(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.5,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 32),
                    // Option to proceed anyway (optional, maybe hidden or small button)
                    TextButton(
                      onPressed: () {
                        setState(() => _isCompatible = true);
                      },
                      child: Text(
                        '[ OVERRIDE PROTOCOL ]',
                        style: GoogleFonts.spaceMono(
                          color: Colors.white24,
                          fontSize: 12,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
