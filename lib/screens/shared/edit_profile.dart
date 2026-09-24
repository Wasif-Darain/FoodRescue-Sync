import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/app_button.dart';
import '../../widgets/ui/location_picker.dart';
import '../../providers/auth_provider.dart';
import '../../models/models.dart';
import '../../l10n/l10n_ext.dart';
import '../../l10n/gen/app_localizations.dart';

// Helper map to get localized account type labels from AccountType enum
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

// Widget for a labeled slider setting with an icon, hint, current value display and slider control
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
        // Row showing icon, label, and current selected value
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
        // Hint text explaining the setting
        Text(
          hint,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575),
          ),
        ),
        // Slider to update the setting value
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

// Main screen widget for editing user profile information
class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late final TextEditingController _nameCtrl; // controller for name input
  late final TextEditingController _phoneCtrl; // controller for phone input
  final _currentPasswordCtrl = TextEditingController(); // current password input controller
  final _newPasswordCtrl = TextEditingController(); // new password input controller

  bool _saving = false; // flag to indicate if profile is being saved
  bool _changingPassword = false; // flag to indicate if password change is in progress

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    // Initialize controllers with existing user data
    _nameCtrl = TextEditingController(text: auth.user!.name);
    _phoneCtrl = TextEditingController(text: auth.phone);
  }

  @override
  void dispose() {
    // Dispose controllers to free resources
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    super.dispose();
  }

  // Utility to show a message snack bar, optionally with error styling
  void _message(String value, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(value), backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF16A34A)),
    );
  }

  // Save updated profile information
  Future<void> _save() async {
    final t = context.l10n;
    final name = _nameCtrl.text.trim();

    // Validate that name is not empty
    if (name.isEmpty) {
      _message(t.editProfileNameRequired, isError: true);
      return;
    }

    setState(() => _saving = true); // show loading state

    final auth = context.read<AuthProvider>();

    // Attempt to update profile with new name and phone number
    final ok = await auth.updateProfile(name: name, phone: _phoneCtrl.text.trim());

    if (!mounted) return;

    setState(() => _saving = false); // hide loading state

    // Show success or error message
    _message(ok ? t.editProfileProfileUpdated : (auth.errorMessage ?? ''), isError: !ok);
  }

  // Change password flow with validations
  Future<void> _changePassword() async {
    final t = context.l10n;
    final current = _currentPasswordCtrl.text;
    final next = _newPasswordCtrl.text;

    // Validate that both current and new passwords are entered
    if (current.isEmpty || next.isEmpty) {
      _message(t.editProfileEnterCurrentAndNew, isError: true);
      return;
    }

    // Check new password strength (minimum length 8)
    if (next.length < 8) {
      _message(t.editProfileWeakPassword, isError: true);
      return;
    }

    setState(() => _changingPassword = true); // show loading on change password button

    final auth = context.read<AuthProvider>();

    // Attempt to change password
    final ok = await auth.changePassword(currentPassword: current, newPassword: next);

    if (!mounted) return;

    setState(() => _changingPassword = false); // hide loading

    if (ok) {
      // Clear fields on success
      _currentPasswordCtrl.clear();
      _newPasswordCtrl.clear();
      _message(t.editProfilePasswordChanged);
    } else {
      // Show error if current password wrong or other failure
      _message(auth.errorMessage ?? t.editProfileWrongCurrentPassword, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Get current user from AuthProvider
    final user = context.watch<AuthProvider>().user!;
    final auth = context.watch<AuthProvider>();
    final t = context.l10n;

    return AppLayout(
      title: t.editProfileTitle,
      subtitle: t.editProfileSubtitle,
      currentRoute: '/profile', // current navigation route
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
        // Main content column for profile editing form
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title for personal info inputs
            Text(
              t.editProfilePersonalInfo,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDark ? Colors.white : const Color(0xFFF5F5F5),
              ),
            ),
            const SizedBox(height: 18),

            // Editable fields for name and email (email read-only)
            _EditableFieldRow(
              children: [
                _EditableField(label: t.editProfileFullName, controller: _nameCtrl),
                _EditableField(label: t.editProfileEmailAddress, controller: TextEditingController(text: user.email), readOnly: true),
              ],
            ),

            const SizedBox(height: 14),

            // Editable fields for phone and account type (account type read-only)
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

            // Section label and picker for location
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

            // Tap area to pick location, update location, and show current address or placeholder
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
                // Row showing location icon, address text, and edit icon
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

            // Section title for radar notification settings
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

            // Slider for max radius in kilometers notifications
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

            // Slider for unattended hours threshold setting
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

            // Divider to separate sections
            Divider(
              color: isDark ? const Color(0xFF3F3F46) : const Color(0xFF262626),
            ),

            const SizedBox(height: 18),

            // Section title for changing password
            Text(
              t.editProfileChangePassword,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDark ? Colors.white : const Color(0xFFF5F5F5),
              ),
            ),

            const SizedBox(height: 16),

            // Row of editable fields: current password and new password
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

            // Button to trigger password change, disabled when in progress
            AppButton(
              label: _changingPassword ? t.commonLoading : t.editProfileChangePassword,
              outlined: true,
              onPressed: _changingPassword ? null : _changePassword,
            ),

            const SizedBox(height: 22),

            // Buttons for saving profile changes or cancelling edits
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
                    // Reset fields to original values if cancelled
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

// A reusable widget representing a labeled editable input field with optional readOnly or obscured text
class _EditableField extends StatelessWidget {
  final String label; // Label above the input field
  final TextEditingController controller; // Controller managing the text
  final bool readOnly; // Whether input is read-only
  final bool obscure; // Whether to hide input text (for passwords)
  final String? placeholder; // Placeholder hint text
  final TextInputType? keyboardType; // Keyboard type (e.g. phone, email)

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
        // Label text
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF525252),
          ),
        ),
        const SizedBox(height: 6),

        // The actual text input field
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

// Widget to arrange a list of child widgets either in a row or column,
// switching layout responsively based on available width
class _EditableFieldRow extends StatelessWidget {
  final List<Widget> children;

  const _EditableFieldRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If narrow, stack children vertically with spacing
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
        // If wider, arrange children horizontally with spacing
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
