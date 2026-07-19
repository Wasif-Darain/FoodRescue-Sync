import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/app_button.dart';
import '../../providers/auth_provider.dart';
import '../../models/models.dart';

const _accountTypeLabel = {
  AccountType.restaurant: 'Restaurant',
  AccountType.caterer:    'Caterer',
  AccountType.store:      'Store',
  AccountType.ngo:        'NGO',
  AccountType.foodBank:   'Food Bank',
  AccountType.shelter:    'Shelter',
  AccountType.individual: 'Individual',
};

const _kWideBreakpoint = 720.0;
const _kFieldRowBreakpoint = 420.0;

class ProfileSettings extends StatelessWidget {
  const ProfileSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final isWide = MediaQuery.of(context).size.width >= _kWideBreakpoint;

    final quickLinks = [
      (Icons.notifications_outlined, 'Notification Preferences'),
      (Icons.lock_outline, 'Privacy & Security'),
      (Icons.language_outlined, 'Language & Region'),
      (Icons.help_outline, 'Help & Support'),
    ];

    const cardDecoration = BoxDecoration(
      color: Color(0xFF141416),
      borderRadius: BorderRadius.all(Radius.circular(16)),
      border: Border.fromBorderSide(BorderSide(color: Color(0xFF262626))),
    );

    final profileCard = Container(
      padding: const EdgeInsets.all(24),
      decoration: cardDecoration,
      child: Column(children: [
        Container(
          width: 76,
          height: 76,
          decoration: const BoxDecoration(color: Color(0xFF14301F), shape: BoxShape.circle),
          child: Center(
            child: Text(
              user.name[0],
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFFF5F5F5)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(color: const Color(0xFF0D2818), borderRadius: BorderRadius.circular(20)),
          child: Text(
            _accountTypeLabel[user.accountType] ?? '',
            style: const TextStyle(fontSize: 12, color: Color(0xFF16A34A), fontWeight: FontWeight.w600),
          ),
        ),
      ]),
    );

    final quickLinksCard = Container(
      margin: const EdgeInsets.only(top: 14),
      decoration: cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              'Quick Links',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF)),
            ),
          ),
          for (final item in quickLinks) ListTile(
            leading: Icon(item.$1, size: 18, color: const Color(0xFF9CA3AF)),
            title: Text(item.$2, style: const TextStyle(fontSize: 13, color: Color(0xFFF5F5F5))),
            trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF3F3F46)),
            dense: true,
            onTap: () {},
          ),
        ],
      ),
    );

    final editForm = Container(
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Personal Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFFF5F5F5))),
        const SizedBox(height: 18),
        _FieldRow(children: [
          _Field(label: 'Full Name', value: user.name),
          _Field(label: 'Email Address', value: user.email),
        ]),
        const SizedBox(height: 14),
        _FieldRow(children: [
          const _Field(label: 'Phone Number', value: '+880 1234 567890'),
          _Field(label: 'Account Type', value: _accountTypeLabel[user.accountType] ?? '', readOnly: true),
        ]),
        const SizedBox(height: 14),
        const _Field(label: 'Address', value: 'Dhaka, Bangladesh'),
        const SizedBox(height: 22),
        const Divider(color: Color(0xFF262626)),
        const SizedBox(height: 18),
        const Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFFF5F5F5))),
        const SizedBox(height: 16),
        _FieldRow(children: const [
          _Field(label: 'Current Password', value: '', obscure: true, placeholder: '••••••••'),
          _Field(label: 'New Password', value: '', obscure: true, placeholder: '••••••••'),
        ]),
        const SizedBox(height: 22),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            AppButton(
              label: 'Save Changes',
              icon: const Icon(Icons.check, size: 16),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated!'), backgroundColor: Color(0xFF16A34A)),
                );
              },
            ),
            AppButton(label: 'Cancel', outlined: true, onPressed: () {}),
          ],
        ),
      ]),
    );

    final body = isWide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 300,
                child: Column(children: [profileCard, quickLinksCard]),
              ),
              const SizedBox(width: 20),
              Expanded(child: editForm),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [profileCard, quickLinksCard, const SizedBox(height: 14), editForm],
          );

    return AppLayout(
      title: 'Profile & Settings',
      subtitle: 'Manage your account information',
      currentRoute: '/profile',
      child: LayoutBuilder(builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 700;

        final profileColumn = SizedBox(
          width: isNarrow ? double.infinity : 280,
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.14), offset: const Offset(0, 4), blurRadius: 0)],),
              child: Column(children: [
                Container(
                  width: 72, height: 72,
                  decoration: const BoxDecoration(color: Color(0xFFDCFCE7), shape: BoxShape.circle),
                  child: Center(child: Text(user.name[0], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF15803D)))),
                ),
                const SizedBox(height: 14),
                Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF121212))),
                const SizedBox(height: 4),
                Text(user.email, style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(20)),
                  child: Text(_accountTypeLabel[user.accountType] ?? '', style: const TextStyle(fontSize: 12, color: Color(0xFF16A34A), fontWeight: FontWeight.w600)),
                ),
              ]),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.14), offset: const Offset(0, 4), blurRadius: 0)],),
              child: Material(
                color: Colors.transparent,
                child: Column(children: [
                  for (final item in [
                    (Icons.notifications_outlined, 'Notification Preferences'),
                    (Icons.lock_outline, 'Privacy & Security'),
                    (Icons.language_outlined, 'Language & Region'),
                    (Icons.help_outline, 'Help & Support'),
                  ]) ListTile(
                    leading: Icon(item.$1, size: 18, color: const Color(0xFF757575)),
                    title: Text(item.$2, style: const TextStyle(fontSize: 13)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFFBFBFBF)),
                    dense: true,
                    onTap: () {},
                  ),
                ]),
              ),
            ),
          ]),
        );

        final editForm = Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.14), offset: const Offset(0, 4), blurRadius: 0)],),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Personal Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF121212))),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: _Field(label: 'Full Name', value: user.name)),
              const SizedBox(width: 16),
              Expanded(child: _Field(label: 'Email Address', value: user.email)),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              const Expanded(child: _Field(label: 'Phone Number', value: '+880 1234 567890')),
              const SizedBox(width: 16),
              Expanded(child: _Field(label: 'Account Type', value: _accountTypeLabel[user.accountType] ?? '', readOnly: true)),
            ]),
            const SizedBox(height: 16),
            const _Field(label: 'Address', value: 'Dhaka, Bangladesh'),
            const SizedBox(height: 24),
            const Divider(color: Color(0xFFE2E2E2)),
            const SizedBox(height: 20),
            const Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF121212))),
            const SizedBox(height: 16),
            const Row(children: [
              Expanded(child: _Field(label: 'Current Password', value: '', obscure: true, placeholder: '••••••••')),
              SizedBox(width: 16),
              Expanded(child: _Field(label: 'New Password', value: '', obscure: true, placeholder: '••••••••')),
            ]),
            const SizedBox(height: 24),
            Row(children: [
              AppButton(label: 'Save Changes', icon: const Icon(Icons.check, size: 16), onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated!'), backgroundColor: Color(0xFF16A34A)));
              }),
              const SizedBox(width: 12),
              AppButton(label: 'Cancel', outlined: true, onPressed: () {}),
            ]),
          ]),
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [profileColumn, const SizedBox(height: 20), editForm],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            profileColumn,
            const SizedBox(width: 20),
            Expanded(child: editForm),
          ],
        );
      }),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;
  final bool readOnly;
  final bool obscure;
  final String? placeholder;
  const _Field({required this.label, required this.value, this.readOnly = false, this.obscure = false, this.placeholder});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF525252))),
      const SizedBox(height: 6),
      TextField(
        controller: TextEditingController(text: value),
        readOnly: readOnly,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: const TextStyle(color: Color(0xFFBFBFBF), fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          filled: readOnly,
          fillColor: const Color(0xFFF0F0F0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E2E2))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E2E2))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF16A34A), width: 2)),
        ),
        style: const TextStyle(fontSize: 13),
      ),
    ],
  );
}