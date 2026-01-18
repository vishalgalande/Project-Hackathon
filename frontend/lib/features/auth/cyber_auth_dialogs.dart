import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

// REUSING OUR CYBER WIDGETS
import '../../widgets/liquid_button.dart';
import '../../widgets/glitch_text.dart';
import '../../widgets/tilt_card.dart';

Future<bool> showCyberLogin(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        barrierColor: Colors.black.withOpacity(0.9), // Darker barrier
        barrierDismissible: true,
        builder: (context) => const _CyberAuthDialog(isLogin: true),
      ) ??
      false;
}

Future<bool> showCyberSignup(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        barrierColor: Colors.black.withOpacity(0.9),
        barrierDismissible: true,
        builder: (context) => const _CyberAuthDialog(isLogin: false),
      ) ??
      false;
}

class _CyberAuthDialog extends StatefulWidget {
  final bool isLogin;
  const _CyberAuthDialog({required this.isLogin});

  @override
  State<_CyberAuthDialog> createState() => _CyberAuthDialogState();
}

class _CyberAuthDialogState extends State<_CyberAuthDialog>
    with SingleTickerProviderStateMixin {
  late bool _isLogin;
  final _emailCtrl = TextEditingController(text: "abc@gmail.com");
  final _passCtrl = TextEditingController(text: "123456");
  final _nameCtrl = TextEditingController(); // For signup

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.isLogin;
  }

  Future<void> _submit() async {
    print("CyberAuth: Submit Pressed");
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      if (_isLogin) {
        print("CyberAuth: Attempting Login...");
        // LOGIN LOGIC
        try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text.trim(),
          );
        } catch (loginError) {
          // Catch Firefox-specific TypeError and show user-friendly message
          final errorString = loginError.toString();
          if (errorString.contains('minified') ||
              errorString.contains('TypeError')) {
            throw Exception(
                'Login failed on this browser. Please try Chrome or check your credentials.');
          }
          rethrow;
        }
      } else {
        // SIGNUP LOGIC WITH FIRESTORE
        UserCredential cred;
        try {
          cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text.trim(),
          );
        } catch (signupError) {
          final errorString = signupError.toString();
          if (errorString.contains('minified') ||
              errorString.contains('TypeError')) {
            throw Exception(
                'Signup failed on this browser. Please try Chrome.');
          }
          rethrow;
        }

        final user = cred.user;
        if (user != null) {
          // Update Profile
          await user.updateDisplayName(_nameCtrl.text.trim());

          // SAVE TO FIRESTORE
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'uid': user.uid,
            'email': user.email,
            'displayName': _nameCtrl.text.trim(),
            'role': 'user',
            'createdAt': FieldValue.serverTimestamp(),
            'lastLogin': FieldValue.serverTimestamp(),
          });
        }
      }

      if (mounted) Navigator.pop(context, true); // Success
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF050505).withOpacity(0.9),
            border: Border.all(
                color: _isLogin
                    ? const Color(0xFF00F0FF)
                    : const Color(0xFF8B5CF6)),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: (_isLogin
                        ? const Color(0xFF00F0FF)
                        : const Color(0xFF8B5CF6))
                    .withOpacity(0.3),
                blurRadius: 20,
              )
            ],
          ),
          padding: const EdgeInsets.all(32),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                GlitchText(
                  text: _isLogin ? 'SECURE LOGIN' : 'NEW ACCOUNT',
                  style: GoogleFonts.syncopate(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2),
                  interval: const Duration(seconds: 2),
                ),

                const SizedBox(height: 32),

                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      border: Border.all(color: Colors.red.withOpacity(0.5)),
                    ),
                    child: Text(_error!,
                        style: GoogleFonts.spaceMono(
                            color: Colors.redAccent, fontSize: 12)),
                  ),
                  const SizedBox(height: 16),
                ],

                if (!_isLogin) ...[
                  _buildCyberField('CODENAME', _nameCtrl, Icons.badge),
                  const SizedBox(height: 16),
                ],

                _buildCyberField(
                    'NET LINK (EMAIL)', _emailCtrl, Icons.alternate_email),
                const SizedBox(height: 16),
                _buildCyberField(
                  'ACCESS KEY (PASS)',
                  _passCtrl,
                  Icons.key,
                  isPassword: true,
                  isVisible: _isPasswordVisible,
                  onToggleVisibility: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),

                const SizedBox(height: 32),

                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white))
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isLogin
                                ? const Color(0xFF00F0FF)
                                : const Color(0xFF8B5CF6),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                            elevation: 10,
                            shadowColor: _isLogin
                                ? const Color(0xFF00F0FF)
                                : const Color(0xFF8B5CF6),
                          ),
                          icon: Icon(_isLogin ? Icons.login : Icons.person_add),
                          label: Text(
                            _isLogin ? 'LOGIN' : 'SIGN UP',
                            style: GoogleFonts.syncopate(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          onPressed: _submit,
                        ),
                      ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: _toggleMode,
                  child: Text(
                    _isLogin ? 'REQUEST NEW IDENTITY >>' : '<< RETURN TO LOGIN',
                    style: GoogleFonts.spaceMono(
                        color: Colors.white54, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCyberField(
      String label, TextEditingController ctrl, IconData icon,
      {bool isPassword = false,
      bool isVisible = false,
      VoidCallback? onToggleVisibility}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.spaceMono(
                color: const Color(0xFF00F0FF), fontSize: 10)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            border: Border.all(color: Colors.white24),
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextField(
            controller: ctrl,
            obscureText: isPassword && !isVisible,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.white54, size: 18),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                          isVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.white54,
                          size: 18),
                      onPressed: onToggleVisibility,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
