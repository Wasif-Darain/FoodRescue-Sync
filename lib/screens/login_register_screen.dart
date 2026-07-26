import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../widgets/ui/glass.dart';

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  bool _isLogin = true;
  bool _showPassword = false;
  AccountType _accountType = AccountType.restaurant;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _extraCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose();
    _phoneCtrl.dispose(); _addressCtrl.dispose(); _extraCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<AuthProvider>().login(
      _emailCtrl.text, _passCtrl.text, _accountType,
      _nameCtrl.text.isEmpty ? 'User' : _nameCtrl.text,
    );
    context.go('/donor');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1488459716781-31db52582fe9?auto=format&fit=crop&w=900&q=80',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFFF5F5F5)),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withValues(alpha: 0.25), Colors.black.withValues(alpha: 0.7)],
                stops: const [0.0, 0.55],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    children: [
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go('/'),
                      child: Image.asset('assets/images/logo.png', width: 64, height: 64),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(_isLogin ? 'Welcome back!' : 'Create your account',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(_isLogin ? 'Sign in to continue' : 'Join FoodRescue Sync today',
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.85))),
                  const SizedBox(height: 20),
                  // Form card (glass)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(32),
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(8),
                      ),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), offset: const Offset(0, 8), blurRadius: 24)],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(32),
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(8),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                        child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!_isLogin) ...[
                          const Text('Account Type', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF757575), letterSpacing: 0.5)),
                          const SizedBox(height: 10),
                          _AccountTypeGrid(selected: _accountType, onChanged: (t) => setState(() => _accountType = t)),
                          const SizedBox(height: 16),
                          _Field(label: _nameLabel(_accountType), ctrl: _nameCtrl, placeholder: 'Enter name'),
                          const SizedBox(height: 12),
                        ],
                        _Field(label: 'Email', ctrl: _emailCtrl, placeholder: 'you@example.com', keyboardType: TextInputType.emailAddress),
                        if (!_isLogin) ...[
                          const SizedBox(height: 12),
                          _Field(label: 'Phone Number', ctrl: _phoneCtrl, placeholder: '+880 XXXX XXXXXX', keyboardType: TextInputType.phone),
                          const SizedBox(height: 12),
                          _Field(label: 'Address', ctrl: _addressCtrl, placeholder: 'Business / organization address'),
                        ],
                        const SizedBox(height: 12),
                        _PasswordField(ctrl: _passCtrl, show: _showPassword, onToggle: () => setState(() => _showPassword = !_showPassword)),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF121212),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          child: Text(_isLogin ? 'Sign In' : 'Create Account', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          ),
                        ),
                      ],
                    ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_isLogin ? "Don't have an account? " : 'Already have an account? ', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
                      GestureDetector(
                        onTap: () => setState(() { _isLogin = !_isLogin; }),
                        child: Text(_isLogin ? 'Sign up' : 'Sign in', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13, decoration: TextDecoration.underline)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      context.read<AuthProvider>().loginAsAdmin();
                      context.go('/admin');
                    },
                    child: Text('Continue as Admin', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12, decoration: TextDecoration.underline)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
        ],
      ),
    );
  }

  String _nameLabel(AccountType t) => switch (t) {
    AccountType.restaurant => 'Restaurant Name',
    AccountType.caterer    => 'Business Name',
    AccountType.store      => 'Store Name',
    AccountType.ngo        => 'Organization Name',
    AccountType.foodBank   => 'Food Bank Name',
    AccountType.shelter    => 'Shelter Name',
    AccountType.individual => 'Full Name',
  };
}

class _AccountTypeGrid extends StatelessWidget {
  final AccountType selected;
  final ValueChanged<AccountType> onChanged;
  const _AccountTypeGrid({required this.selected, required this.onChanged});

  static const _types = [
    (AccountType.restaurant, 'Restaurant', Icons.restaurant),
    (AccountType.caterer,    'Caterer',    Icons.soup_kitchen),
    (AccountType.store,      'Store',      Icons.store),
    (AccountType.ngo,        'NGO',        Icons.business),
    (AccountType.foodBank,   'Food Bank',  Icons.favorite_outline),
    (AccountType.shelter,    'Shelter',    Icons.home_outlined),
    (AccountType.individual, 'Individual', Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: _types.map((t) {
        final isSelected = selected == t.$1;
                return GestureDetector(
          onTap: () => onChanged(t.$1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFDCFCE7) : const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isSelected ? const Color(0xFF16A34A) : const Color(0xFFE2E2E2), width: isSelected ? 2 : 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(t.$3, size: 14, color: isSelected ? const Color(0xFF16A34A) : const Color(0xFF757575)),
                const SizedBox(width: 4),
                Text(t.$2, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? const Color(0xFF16A34A) : const Color(0xFF525252))),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final String placeholder;
  final TextInputType? keyboardType;
  const _Field({required this.label, required this.ctrl, required this.placeholder, this.keyboardType});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF525252))),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: const TextStyle(color: Color(0xFFBFBFBF), fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E2E2))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E2E2))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF16A34A), width: 2)),
        ),
        style: const TextStyle(fontSize: 13),
      ),
    ],
  );
}

class _PasswordField extends StatelessWidget {
  final TextEditingController ctrl;
  final bool show;
  final VoidCallback onToggle;
  const _PasswordField({required this.ctrl, required this.show, required this.onToggle});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF525252))),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        obscureText: !show,
        decoration: InputDecoration(
          hintText: 'Enter your password',
          hintStyle: const TextStyle(color: Color(0xFFBFBFBF), fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E2E2))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E2E2))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF16A34A), width: 2)),
          suffixIcon: IconButton(icon: Icon(show ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: const Color(0xFF757575)), onPressed: onToggle),
        ),
        style: const TextStyle(fontSize: 13),
      ),
    ],
  );
}
