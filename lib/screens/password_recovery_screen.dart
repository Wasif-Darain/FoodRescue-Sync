import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  var _step = 0;
  var _showPassword = false;
  var _showConfirmPassword = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _sendCode() {
    final email = _emailCtrl.text.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      _message('Enter a valid email address.');
      return;
    }
    final code = context.read<AuthProvider>().requestPasswordReset(email);
    setState(() => _step = 1);
    _message(
      kDebugMode
          ? 'Recovery code created. Demo code: $code'
          : 'A verification code was sent to $email.',
    );
  }

  void _verifyCode() {
    if (context.read<AuthProvider>().verifyPasswordResetOtp(_otpCtrl.text)) {
      setState(() => _step = 2);
    } else {
      _message(
        'That code is invalid or has expired. Request a new code and try again.',
      );
    }
  }

  void _resetPassword() {
    if (_passwordCtrl.text.length < 8) {
      _message('Use at least 8 characters for your password.');
    } else if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
      _message('The passwords do not match.');
    } else if (context.read<AuthProvider>().resetPassword(_passwordCtrl.text)) {
      _message('Password reset successfully. You can now sign in.');
      context.go('/login');
    }
  }

  void _message(String value) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(value)));

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF16A34A);
    final email =
        context.watch<AuthProvider>().resetEmail ?? _emailCtrl.text.trim();
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/login_background.png', fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.25),
                  Colors.black.withValues(alpha: 0.7),
                ],
                stops: const [0, 0.55],
              ),
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 8,
                  left: 8,
                  child: IconButton(
                    tooltip: 'Back to sign in',
                    onPressed: () => context.go('/login'),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.16),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.arrow_back),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            width: 64,
                            height: 64,
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Account recovery',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      _step == 2
                                          ? Icons.lock_reset
                                          : Icons.mark_email_read_outlined,
                                      color: green,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _step == 0
                                          ? 'Forgot your password?'
                                          : _step == 1
                                          ? 'Check your email'
                                          : 'Create a new password',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF171717),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _step == 0
                                          ? 'Enter your account email and we’ll send a six-digit verification code.'
                                          : _step == 1
                                          ? 'Enter the six-digit code sent to $email. It expires in 10 minutes.'
                                          : 'Choose a strong password with at least 8 characters.',
                                      style: const TextStyle(
                                        color: Color(0xFF525252),
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    if (_step == 0) ...[
                                      _input(
                                        controller: _emailCtrl,
                                        label: 'Email address',
                                        hint: 'you@example.com',
                                        keyboardType:
                                            TextInputType.emailAddress,
                                      ),
                                      const SizedBox(height: 20),
                                      _button(
                                        'Send verification code',
                                        _sendCode,
                                      ),
                                    ] else if (_step == 1) ...[
                                      _input(
                                        controller: _otpCtrl,
                                        label: 'Verification code',
                                        hint: '000000',
                                        keyboardType: TextInputType.number,
                                        maxLength: 6,
                                      ),
                                      const SizedBox(height: 20),
                                      _button('Verify code', _verifyCode),
                                      Center(
                                        child: TextButton(
                                          onPressed: _sendCode,
                                          style: TextButton.styleFrom(
                                            foregroundColor: green,
                                          ),
                                          child: const Text('Resend code'),
                                        ),
                                      ),
                                    ] else ...[
                                      _passwordInput(
                                        _passwordCtrl,
                                        'New password',
                                        _showPassword,
                                        () => setState(
                                          () => _showPassword = !_showPassword,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      _passwordInput(
                                        _confirmPasswordCtrl,
                                        'Confirm new password',
                                        _showConfirmPassword,
                                        () => setState(
                                          () => _showConfirmPassword =
                                              !_showConfirmPassword,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      _button('Reset password', _resetPassword),
                                    ],
                                    const SizedBox(height: 12),
                                    Center(
                                      child: TextButton(
                                        onPressed: () => context.go('/login'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: green,
                                        ),
                                        child: const Text('Back to sign in'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _button(String label, VoidCallback onPressed) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    ),
  );

  Widget _input({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int? maxLength,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D2D2D),
        ),
      ),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        decoration: _fieldDecoration(hint),
      ),
    ],
  );

  Widget _passwordInput(
    TextEditingController controller,
    String label,
    bool show,
    VoidCallback toggle,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D2D2D),
        ),
      ),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        obscureText: !show,
        decoration: _fieldDecoration('Enter ${label.toLowerCase()}').copyWith(
          suffixIcon: IconButton(
            onPressed: toggle,
            icon: Icon(
              show ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: const Color(0xFF525252),
            ),
          ),
        ),
      ),
    ],
  );

  InputDecoration _fieldDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
    counterText: '',
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.75),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF16A34A), width: 2),
    ),
  );
}
