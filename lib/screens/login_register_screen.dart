import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../widgets/ui/glass.dart';
import '../utils/password_validator.dart';
import '../l10n/l10n_ext.dart';
import '../l10n/gen/app_localizations.dart';

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

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    if (_isLogin) {
      await auth.signIn(_emailCtrl.text, _passCtrl.text);
      if (!mounted) return;
      if (auth.errorMessage != null) {
        _showAuthError(auth.errorMessage!);
        return;
      }
      if (auth.user != null) {
        context.go(auth.user!.mode == UserMode.admin ? '/admin' : '/donor');
      }
      return;
    }
    // Validate password strength before creating the account.
    final passwordResult = PasswordValidationResult.validate(_passCtrl.text);
    if (!passwordResult.isValid) {
      _showAuthError(context.l10n.authPasswordNotStrong(kMinPasswordLength));
      return;
    }
    await auth.signUp(
      name: _nameCtrl.text.isEmpty ? 'User' : _nameCtrl.text,
      email: _emailCtrl.text,
      password: _passCtrl.text,
      phone: _phoneCtrl.text,
      address: _addressCtrl.text,
      accountType: _accountType,
    );
    if (!mounted) return;
    if (auth.errorMessage != null) {
      _showAuthError(auth.errorMessage!);
      return;
    }
    if (auth.user != null) {
      context.go(auth.user!.mode == UserMode.admin ? '/admin' : '/donor');
    }
  }

  void _showAuthError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _switchMode(bool toLogin) => setState(() {
    _isLogin = toLogin;
    _signupStep = 1;
  });

  Widget _buildLogin() {
    final t = context.l10n;
    return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(t.authWelcomeBack, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF121212))),
      const SizedBox(height: 4),
      Text(t.authSignInToContinue, style: const TextStyle(fontSize: 13, color: Color(0xFF757575))),
      const SizedBox(height: 24),
      _Field(icon: Icons.email_outlined, label: t.authEmail, ctrl: _emailCtrl, placeholder: 'you@example.com', keyboardType: TextInputType.emailAddress),
      const SizedBox(height: 18),
      _PasswordField(ctrl: _passCtrl, show: _showPassword, onToggle: () => setState(() => _showPassword = !_showPassword)),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () => context.go('/forgot-password'),
          style: TextButton.styleFrom(foregroundColor: _brandGreen, padding: EdgeInsets.zero),
          child: Text(t.authForgotPassword, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
        ),
      ),
      const SizedBox(height: 22),
      _PrimaryButton(label: t.authLogIn, onPressed: _submit),
      const SizedBox(height: 16),
      const _OrDivider(),
      const SizedBox(height: 16),
      _SecondaryButton(label: t.authSignUp, onPressed: () => _switchMode(false)),
    ],
    );
  }

  Widget _buildSignupStep1() {
    final t = context.l10n;
    return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(t.authCreateAccount, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF121212))),
      const SizedBox(height: 4),
      Text(t.authStep1Title, style: const TextStyle(fontSize: 13, color: Color(0xFF757575))),
      const SizedBox(height: 24),
      Text(t.authAccountType, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF757575), letterSpacing: 0.5)),
      const SizedBox(height: 10),
      _AccountTypeGrid(selected: _accountType, onChanged: (v) => setState(() => _accountType = v)),
      const SizedBox(height: 18),
      _Field(icon: Icons.badge_outlined, label: _nameLabel(t, _accountType), ctrl: _nameCtrl, placeholder: t.authEnterName),
      const SizedBox(height: 18),
      _Field(icon: Icons.email_outlined, label: t.authEmail, ctrl: _emailCtrl, placeholder: 'you@example.com', keyboardType: TextInputType.emailAddress),
      const SizedBox(height: 22),
      _PrimaryButton(label: t.authNext, onPressed: () => setState(() => _signupStep = 2)),
      const SizedBox(height: 16),
      const _OrDivider(),
      const SizedBox(height: 16),
      _SecondaryButton(label: t.authLogIn, onPressed: () => _switchMode(true)),
    ],
    );
  }

  Widget _buildSignupStep2() {
    final t = context.l10n;
    return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextButton.icon(
        onPressed: () => setState(() => _signupStep = 1),
        style: TextButton.styleFrom(foregroundColor: const Color(0xFF757575), padding: EdgeInsets.zero),
        icon: const Icon(Icons.arrow_back, size: 16),
        label: Text(t.authBack),
      ),
      const SizedBox(height: 8),
      Text(t.authCreateAccount, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF121212))),
      const SizedBox(height: 4),
      Text(t.authStep2Title, style: const TextStyle(fontSize: 13, color: Color(0xFF757575))),
      const SizedBox(height: 24),
      _Field(
        icon: Icons.phone_outlined,
        label: t.authPhoneNumber,
        ctrl: _phoneCtrl,
        placeholder: '+880 1XXX-XXXXXX',
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
          _BdPhoneFormatter(),
        ],
      ),
      const SizedBox(height: 18),
      _Field(icon: Icons.location_on_outlined, label: t.authAddress, ctrl: _addressCtrl, placeholder: t.authAddressHint),
      const SizedBox(height: 18),
      _PasswordField(ctrl: _passCtrl, show: _showPassword, onToggle: () => setState(() => _showPassword = !_showPassword), showValidation: true),
      const SizedBox(height: 22),
      _PrimaryButton(label: t.authCreateAccount, onPressed: _submit),
    ],
    );
  }

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

  String _nameLabel(AppLocalizations t, AccountType type) => switch (type) {
    AccountType.restaurant => t.accountTypeNameRestaurant,
    AccountType.caterer => t.accountTypeNameCaterer,
    AccountType.store => t.accountTypeNameStore,
    AccountType.ngo => t.accountTypeNameNgo,
    AccountType.foodBank => t.accountTypeNameFoodBank,
    AccountType.shelter => t.accountTypeNameShelter,
    AccountType.individual => t.accountTypeNameIndividual,
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
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(context.l10n.authOr, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12.5)),
      ),
      const Expanded(child: Divider(color: Color(0xFFE2E2E2))),
    ],
  );
}

class _AccountTypeGrid extends StatelessWidget {
  final AccountType selected;
  final ValueChanged<AccountType> onChanged;
  const _AccountTypeGrid({required this.selected, required this.onChanged});

  static List<(AccountType, String, IconData)> _types(AppLocalizations t) => [
    (AccountType.restaurant, t.accountTypeRestaurant, Icons.restaurant),
    (AccountType.caterer, t.accountTypeCaterer, Icons.soup_kitchen),
    (AccountType.store, t.accountTypeStore, Icons.store),
    (AccountType.ngo, t.accountTypeNgo, Icons.business),
    (AccountType.foodBank, t.accountTypeFoodBank, Icons.favorite_outline),
    (AccountType.shelter, t.accountTypeShelter, Icons.home_outlined),
    (AccountType.individual, t.accountTypeIndividual, Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _types(context.l10n).map((t) {
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

class _BdPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('880')) digits = digits.substring(3);
    if (digits.startsWith('0')) digits = digits.substring(1);
    if (digits.length > 10) digits = digits.substring(0, 10);
    final buffer = StringBuffer('+880');
    for (var i = 0; i < digits.length; i++) {
      if (i == 4) buffer.write('-');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _Field extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController ctrl;
  final String placeholder;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  const _Field({
    required this.icon,
    required this.label,
    required this.ctrl,
    required this.placeholder,
    this.keyboardType,
    this.inputFormatters,
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
        inputFormatters: inputFormatters,
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

class _PasswordField extends StatefulWidget {
  final TextEditingController ctrl;
  final bool show;
  final VoidCallback onToggle;
  final bool showValidation;

  const _PasswordField({
    required this.ctrl,
    required this.show,
    required this.onToggle,
    this.showValidation = false,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  PasswordValidationResult _result = PasswordValidationResult.validate('');

  @override
  void initState() {
    super.initState();
    widget.ctrl.addListener(_onChanged);
    _onChanged();
  }

  void _onChanged() {
    final result = PasswordValidationResult.validate(widget.ctrl.text);
    if (result.score != _result.score || result.strength != _result.strength) {
      setState(() => _result = result);
    }
  }

  @override
  void dispose() {
    widget.ctrl.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final showFeedback = widget.showValidation && widget.ctrl.text.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.authPassword, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF757575))),
        const SizedBox(height: 4),
        TextField(
          controller: widget.ctrl,
          obscureText: !widget.show,
          decoration: InputDecoration(
            hintText: t.authEnterYourPassword,
            hintStyle: const TextStyle(color: Color(0xFFBFBFBF), fontSize: 13.5),
            prefixIcon: const Icon(Icons.lock_outline, size: 19, color: Color(0xFF9CA3AF)),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE2E2E2))),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE2E2E2))),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: _brandGreen, width: 2)),
            suffixIcon: IconButton(
              icon: Icon(widget.show ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: const Color(0xFF9CA3AF)),
              onPressed: widget.onToggle,
            ),
          ),
          style: const TextStyle(fontSize: 14, color: Color(0xFF121212)),
        ),
        if (showFeedback) ...[
          const SizedBox(height: 14),
          _PasswordStrengthBar(result: _result),
          const SizedBox(height: 10),
          _PasswordCriteriaList(result: _result),
        ],
      ],
    );
  }
}

class _PasswordStrengthBar extends StatelessWidget {
  final PasswordValidationResult result;
  const _PasswordStrengthBar({required this.result});

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final progress = result.score / kPasswordCriteria.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              t.authPasswordStrength(passwordStrengthLabel(t, result.strength)),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: result.strength.color,
              ),
            ),
            Text(
              '${result.score}/${kPasswordCriteria.length}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 6,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFE5E7EB),
              color: result.strength.color,
            ),
          ),
        ),
      ],
    );
  }
}

class _PasswordCriteriaList extends StatelessWidget {
  final PasswordValidationResult result;
  const _PasswordCriteriaList({required this.result});

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: kPasswordCriteria.map((criterion) {
        final isMet = !result.unmet.contains(criterion);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Icon(
                isMet ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 16,
                color: isMet ? const Color(0xFF16A34A) : const Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 6),
              Text(
                passwordCriterionLabel(t, criterion.id),
                style: TextStyle(
                  fontSize: 12,
                  color: isMet ? const Color(0xFF16A34A) : const Color(0xFF757575),
                  fontWeight: isMet ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
