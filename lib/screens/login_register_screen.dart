import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../widgets/ui/glass.dart';

const _brandGreen = Color(0xFF16A34A);

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  bool _isLogin = true;
  bool _showPassword = false;
  AccountType _accountType = AccountType.restaurant;

  // Signup is split across two pages: 1 = identity, 2 = contact & security.
  int _signupStep = 1;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _extraCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _extraCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final auth = context.read<AuthProvider>();
    if (_isLogin &&
        auth.isMockAdminCredential(_emailCtrl.text, _passCtrl.text)) {
      auth.loginAsAdmin();
      context.go('/admin');
      return;
    }
    auth.login(
      _emailCtrl.text,
      _passCtrl.text,
      _accountType,
      _nameCtrl.text.isEmpty ? 'User' : _nameCtrl.text,
    );
    context.go('/donor');
  }

  void _switchMode(bool toLogin) => setState(() {
    _isLogin = toLogin;
    _signupStep = 1;
  });

  Widget _buildLogin() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Welcome Back', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF121212))),
      const SizedBox(height: 4),
      const Text('Sign in to continue', style: TextStyle(fontSize: 13, color: Color(0xFF757575))),
      const SizedBox(height: 24),
      _Field(icon: Icons.email_outlined, label: 'Email', ctrl: _emailCtrl, placeholder: 'you@example.com', keyboardType: TextInputType.emailAddress),
      const SizedBox(height: 18),
      _PasswordField(ctrl: _passCtrl, show: _showPassword, onToggle: () => setState(() => _showPassword = !_showPassword)),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () => context.go('/forgot-password'),
          style: TextButton.styleFrom(foregroundColor: _brandGreen, padding: EdgeInsets.zero),
          child: const Text('Forgot password?', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
        ),
      ),
      const SizedBox(height: 22),
      _PrimaryButton(label: 'Log in', onPressed: _submit),
      const SizedBox(height: 16),
      const _OrDivider(),
      const SizedBox(height: 16),
      _SecondaryButton(label: 'Sign up', onPressed: () => _switchMode(false)),
    ],
  );

  Widget _buildSignupStep1() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Create Account', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF121212))),
      const SizedBox(height: 4),
      const Text('Step 1 of 2 · Tell us about you', style: TextStyle(fontSize: 13, color: Color(0xFF757575))),
      const SizedBox(height: 24),
      const Text('Account Type', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF757575), letterSpacing: 0.5)),
      const SizedBox(height: 10),
      _AccountTypeGrid(selected: _accountType, onChanged: (t) => setState(() => _accountType = t)),
      const SizedBox(height: 18),
      _Field(icon: Icons.badge_outlined, label: _nameLabel(_accountType), ctrl: _nameCtrl, placeholder: 'Enter name'),
      const SizedBox(height: 18),
      _Field(icon: Icons.email_outlined, label: 'Email', ctrl: _emailCtrl, placeholder: 'you@example.com', keyboardType: TextInputType.emailAddress),
      const SizedBox(height: 22),
      _PrimaryButton(label: 'Next', onPressed: () => setState(() => _signupStep = 2)),
      const SizedBox(height: 16),
      const _OrDivider(),
      const SizedBox(height: 16),
      _SecondaryButton(label: 'Log in', onPressed: () => _switchMode(true)),
    ],
  );

  Widget _buildSignupStep2() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextButton.icon(
        onPressed: () => setState(() => _signupStep = 1),
        style: TextButton.styleFrom(foregroundColor: const Color(0xFF757575), padding: EdgeInsets.zero),
        icon: const Icon(Icons.arrow_back, size: 16),
        label: const Text('Back'),
      ),
      const SizedBox(height: 8),
      const Text('Create Account', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF121212))),
      const SizedBox(height: 4),
      const Text('Step 2 of 2 · Contact & security', style: TextStyle(fontSize: 13, color: Color(0xFF757575))),
      const SizedBox(height: 24),
      _Field(icon: Icons.phone_outlined, label: 'Phone Number', ctrl: _phoneCtrl, placeholder: '+880 XXXX XXXXXX', keyboardType: TextInputType.phone),
      const SizedBox(height: 18),
      _Field(icon: Icons.location_on_outlined, label: 'Address', ctrl: _addressCtrl, placeholder: 'Business / organization address'),
      const SizedBox(height: 18),
      _PasswordField(ctrl: _passCtrl, show: _showPassword, onToggle: () => setState(() => _showPassword = !_showPassword)),
      const SizedBox(height: 22),
      _PrimaryButton(label: 'Create Account', onPressed: _submit),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topHeight = (screenHeight * 0.46).clamp(300.0, 440.0);

    const cardOverlap = 40.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---- Colored top section: photo + wave ----
            ClipPath(
              clipper: _BottomWaveClipper(),
              child: SizedBox(
                height: topHeight,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset('assets/images/login_background.png', fit: BoxFit.cover),
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.25), shape: BoxShape.circle),
                              child: IconButton(
                                onPressed: () => context.go('/'),
                                icon: const Icon(Icons.arrow_back, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ---- Glass form card, pulled up to overlap the photo's wave ----
            Transform.translate(
              offset: const Offset(0, -cardOverlap),
              child: GlassContainer(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: _isLogin
                        ? _buildLogin()
                        : (_signupStep == 1 ? _buildSignupStep1() : _buildSignupStep2()),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _nameLabel(AccountType t) => switch (t) {
    AccountType.restaurant => 'Restaurant Name',
    AccountType.caterer => 'Business Name',
    AccountType.store => 'Store Name',
    AccountType.ngo => 'Organization Name',
    AccountType.foodBank => 'Food Bank Name',
    AccountType.shelter => 'Shelter Name',
    AccountType.individual => 'Full Name',
  };
}

/// Gentle S-curve along the bottom edge, so the white form section flows
/// into the colored photo section above it instead of a hard straight cut.
class _BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()..lineTo(0, size.height - 36);
    path.quadraticBezierTo(size.width * 0.25, size.height, size.width * 0.5, size.height - 26);
    path.quadraticBezierTo(size.width * 0.75, size.height - 52, size.width, size.height - 16);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
    ),
  );
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _SecondaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF121212),
        side: const BorderSide(color: Color(0xFFE2E2E2)),
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
    ),
  );
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(child: Divider(color: Color(0xFFE2E2E2))),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Text('or', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12.5)),
      ),
      const Expanded(child: Divider(color: Color(0xFFE2E2E2))),
    ],
  );
}

class _AccountTypeGrid extends StatelessWidget {
  final AccountType selected;
  final ValueChanged<AccountType> onChanged;
  const _AccountTypeGrid({required this.selected, required this.onChanged});

  static const _types = [
    (AccountType.restaurant, 'Restaurant', Icons.restaurant),
    (AccountType.caterer, 'Caterer', Icons.soup_kitchen),
    (AccountType.store, 'Store', Icons.store),
    (AccountType.ngo, 'NGO', Icons.business),
    (AccountType.foodBank, 'Food Bank', Icons.favorite_outline),
    (AccountType.shelter, 'Shelter', Icons.home_outlined),
    (AccountType.individual, 'Individual', Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _types.map((t) {
        final isSelected = selected == t.$1;
        return GestureDetector(
          onTap: () => onChanged(t.$1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFDCFCE7) : const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? _brandGreen : const Color(0xFFE2E2E2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(t.$3, size: 14, color: isSelected ? _brandGreen : const Color(0xFF757575)),
                const SizedBox(width: 4),
                Text(
                  t.$2,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? _brandGreen : const Color(0xFF525252)),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _Field extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController ctrl;
  final String placeholder;
  final TextInputType? keyboardType;
  const _Field({
    required this.icon,
    required this.label,
    required this.ctrl,
    required this.placeholder,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF757575))),
      const SizedBox(height: 4),
      TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: const TextStyle(color: Color(0xFFBFBFBF), fontSize: 13.5),
          prefixIcon: Icon(icon, size: 19, color: const Color(0xFF9CA3AF)),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE2E2E2))),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE2E2E2))),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: _brandGreen, width: 2)),
        ),
        style: const TextStyle(fontSize: 14, color: Color(0xFF121212)),
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
      const Text('Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF757575))),
      const SizedBox(height: 4),
      TextField(
        controller: ctrl,
        obscureText: !show,
        decoration: InputDecoration(
          hintText: 'Enter your password',
          hintStyle: const TextStyle(color: Color(0xFFBFBFBF), fontSize: 13.5),
          prefixIcon: const Icon(Icons.lock_outline, size: 19, color: Color(0xFF9CA3AF)),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE2E2E2))),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE2E2E2))),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: _brandGreen, width: 2)),
          suffixIcon: IconButton(
            icon: Icon(show ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: const Color(0xFF9CA3AF)),
            onPressed: onToggle,
          ),
        ),
        style: const TextStyle(fontSize: 14, color: Color(0xFF121212)),
      ),
    ],
  );
}
