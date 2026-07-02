import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFFF0FDF4), Colors.white, Color(0xFFFFF7ED)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: [
                  // Logo
                  GestureDetector(
                    onTap: () => context.go('/'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: const Color(0xFF16A34A), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.eco, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('FoodRescue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF111827))),
                            Text('Sync', style: TextStyle(color: Color(0xFF16A34A), fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(_isLogin ? 'Welcome back!' : 'Create your account',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                  const SizedBox(height: 4),
                  Text(_isLogin ? 'Sign in to continue' : 'Join FoodRescue Sync today',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                  const SizedBox(height: 24),
                  // Form card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF3F4F6)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!_isLogin) ...[
                          const Text('Account Type', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF), letterSpacing: 0.5)),
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
                              backgroundColor: const Color(0xFF16A34A),
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
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_isLogin ? "Don't have an account? " : 'Already have an account? ', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
                      GestureDetector(
                        onTap: () => setState(() { _isLogin = !_isLogin; }),
                        child: Text(_isLogin ? 'Sign up' : 'Sign in', style: const TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
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
              color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isSelected ? const Color(0xFF16A34A) : const Color(0xFFE5E7EB), width: isSelected ? 2 : 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(t.$3, size: 14, color: isSelected ? const Color(0xFF16A34A) : const Color(0xFF6B7280)),
                const SizedBox(width: 4),
                Text(t.$2, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? const Color(0xFF16A34A) : const Color(0xFF374151))),
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
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
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
      const Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        obscureText: !show,
        decoration: InputDecoration(
          hintText: 'Enter your password',
          hintStyle: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF16A34A), width: 2)),
          suffixIcon: IconButton(icon: Icon(show ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: const Color(0xFF9CA3AF)), onPressed: onToggle),
        ),
        style: const TextStyle(fontSize: 13),
      ),
    ],
  );
}
