import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/app_button.dart';
import '../../widgets/ui/location_picker.dart';
import '../../providers/auth_provider.dart';
import '../../models/models.dart';
import '../../l10n/l10n_ext.dart';
import '../../l10n/gen/app_localizations.dart';

Map<AccountType, String> _accountTypeLabel(AppLocalizations t) => {
  AccountType.restaurant: t.accountTypeRestaurant,
  AccountType.caterer: t.accountTypeCaterer,
  AccountType.store: t.accountTypeStore,
  AccountType.ngo: t.accountTypeNgo,
  AccountType.foodBank: t.accountTypeFoodBank,
  AccountType.shelter: t.accountTypeShelter,
  AccountType.individual: t.accountTypeIndividual,
  AccountType.rider: t.accountTypeRider,
};

class _SettingSlider extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final String displayValue;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String sliderLabel;
  final ValueChanged<double> onChanged;
  const _SettingSlider({
    required this.icon,
    required this.label,
    required this.hint,
    required this.displayValue,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.sliderLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF121212),
                ),
              ),
            ),
            Text(
              displayValue,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF16A34A),
              ),
            ),
          ],
        ),
        Text(
          hint,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575),
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: sliderLabel,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  bool _saving = false;
  bool _changingPassword = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameCtrl = TextEditingController(text: auth.user!.name);
    _phoneCtrl = TextEditingController(text: auth.phone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    super.dispose();
  }

  void _message(String value, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(value), backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF16A34A)),
    );
  }

  Future<void> _save() async {
    final t = context.l10n;
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _message(t.editProfileNameRequired, isError: true);
      return;
    }
    setState(() => _saving = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.updateProfile(name: name, phone: _phoneCtrl.text.trim());
    if (!mounted) return;
    setState(() => _saving = false);
    _message(ok ? t.editProfileProfileUpdated : (auth.errorMessage ?? ''), isError: !ok);
  }

  Future<void> _changePassword() async {
    final t = context.l10n;
    final current = _currentPasswordCtrl.text;
    final next = _newPasswordCtrl.text;
    if (current.isEmpty || next.isEmpty) {
      _message(t.editProfileEnterCurrentAndNew, isError: true);
      return;
    }
    if (next.length < 8) {
      _message(t.editProfileWeakPassword, isError: true);
      return;
    }
    setState(() => _changingPassword = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.changePassword(currentPassword: current, newPassword: next);
    if (!mounted) return;
    setState(() => _changingPassword = false);
    if (ok) {
      _currentPasswordCtrl.clear();
      _newPasswordCtrl.clear();
      _message(t.editProfilePasswordChanged);
    } else {
      _message(auth.errorMessage ?? t.editProfileWrongCurrentPassword, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthProvider>().user!;
    final auth = context.watch<AuthProvider>();
    final t = context.l10n;

    return AppLayout(
      title: t.editProfileTitle,
      subtitle: t.editProfileSubtitle,
      currentRoute: '/profile',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.fromBorderSide(
            BorderSide(
              color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14),
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.editProfilePersonalInfo,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDark ? Colors.white : const Color(0xFFF5F5F5),
              ),
            ),
            const SizedBox(height: 18),
            _EditableFieldRow(
              children: [
                _EditableField(label: t.editProfileFullName, controller: _nameCtrl),
                _EditableField(label: t.editProfileEmailAddress, controller: TextEditingController(text: user.email), readOnly: true),
              ],
            ),
            const SizedBox(height: 14),
            _EditableFieldRow(
              children: [
                _EditableField(label: t.editProfilePhoneNumber, controller: _phoneCtrl, keyboardType: TextInputType.phone),
                _EditableField(
                  label: t.editProfileAccountType,
                  controller: TextEditingController(text: _accountTypeLabel(t)[user.accountType] ?? ''),
                  readOnly: true,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              t.editProfileLocation,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF525252),
              ),
            ),
            const SizedBox(height: 4),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () async {
                final picked = await pickLocation(context);
                if (picked == null || !context.mounted) return;
                context.read<AuthProvider>().updateOwnLocation(
                  lat: picked.lat,
                  lng: picked.lng,
                  address: picked.address,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(t.editProfileLocationUpdated),
                    backgroundColor: const Color(0xFF16A34A),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF3F3F46)
                        : const Color(0xFFE2E2E2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: isDark
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF757575),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        auth.address ?? t.editProfileNotSetTapToPick,
                        style: TextStyle(
                          fontSize: 13,
                          color: auth.address == null
                              ? const Color(0xFFBFBFBF)
                              : (isDark
                                    ? Colors.white
                                    : const Color(0xFF121212)),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.edit_outlined,
                      size: 15,
                      color: isDark
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF757575),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              t.editProfileRadarNotifications,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF525252),
              ),
            ),
            const SizedBox(height: 4),
            _SettingSlider(
              icon: Icons.radar_outlined,
              label: t.editProfileRadarLabel,
              hint: t.editProfileRadarHint,
              displayValue: '${auth.maxRadiusKm.toStringAsFixed(0)} km',
              value: auth.maxRadiusKm.clamp(1, 50).toDouble(),
              min: 1,
              max: 50,
              divisions: 49,
              sliderLabel: '${auth.maxRadiusKm.toStringAsFixed(0)} km',
              onChanged: (v) => auth.updateMaxRadiusKm(v),
            ),
            _SettingSlider(
              icon: Icons.schedule_outlined,
              label: t.editProfileUnattendedLabel,
              hint: t.editProfileUnattendedHint,
              displayValue: '${auth.unattendedAfterHours} h',
              value: auth.unattendedAfterHours.clamp(6, 72).toDouble(),
              min: 6,
              max: 72,
              divisions: 66,
              sliderLabel: '${auth.unattendedAfterHours} h',
              onChanged: (v) => auth.updateUnattendedAfterHours(v.round()),
            ),
            const SizedBox(height: 22),
            Divider(
              color: isDark ? const Color(0xFF3F3F46) : const Color(0xFF262626),
            ),
            const SizedBox(height: 18),
            Text(
              t.editProfileChangePassword,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDark ? Colors.white : const Color(0xFFF5F5F5),
              ),
            ),
            const SizedBox(height: 16),
            _EditableFieldRow(
              children: [
                _EditableField(
                  label: t.editProfileCurrentPassword,
                  controller: _currentPasswordCtrl,
                  obscure: true,
                  placeholder: '••••••••',
                ),
                _EditableField(
                  label: t.editProfileNewPassword,
                  controller: _newPasswordCtrl,
                  obscure: true,
                  placeholder: '••••••••',
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppButton(
              label: _changingPassword ? t.commonLoading : t.editProfileChangePassword,
              outlined: true,
              onPressed: _changingPassword ? null : _changePassword,
            ),
            const SizedBox(height: 22),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                AppButton(
                  label: _saving ? t.commonLoading : t.commonSaveChanges,
                  icon: const Icon(Icons.check, size: 16),
                  onPressed: _saving ? null : _save,
                ),
                AppButton(
                  label: t.commonCancel,
                  outlined: true,
                  onPressed: () {
                    _nameCtrl.text = auth.user!.name;
                    _phoneCtrl.text = auth.phone;
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EditableField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool readOnly;
  final bool obscure;
  final String? placeholder;
  final TextInputType? keyboardType;
  const _EditableField({
    required this.label,
    required this.controller,
    this.readOnly = false,
    this.obscure = false,
    this.placeholder,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF525252),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: readOnly,
          obscureText: obscure,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFFBFBFBF), fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: readOnly,
            fillColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF16A34A), width: 2),
            ),
          ),
          style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF121212)),
        ),
      ],
    );
  }
}

class _EditableFieldRow extends StatelessWidget {
  final List<Widget> children;
  const _EditableFieldRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 420) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index < children.length - 1) const SizedBox(height: 14),
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < children.length; index++) ...[
              Expanded(child: children[index]),
              if (index < children.length - 1) const SizedBox(width: 16),
            ],
          ],
        );
      },
    );
  }
}
