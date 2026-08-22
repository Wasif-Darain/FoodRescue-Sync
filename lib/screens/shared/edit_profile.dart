import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/app_button.dart';
import '../../widgets/ui/form_field.dart';
import '../../widgets/ui/location_picker.dart';
import '../../providers/auth_provider.dart';
import '../../models/models.dart';

const _accountTypeLabel = {
  AccountType.restaurant: 'Restaurant',
  AccountType.caterer: 'Caterer',
  AccountType.store: 'Store',
  AccountType.ngo: 'NGO',
  AccountType.foodBank: 'Food Bank',
  AccountType.shelter: 'Shelter',
  AccountType.individual: 'Individual',
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
            Icon(icon, size: 16, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF121212))),
            ),
            Text(displayValue, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
          ],
        ),
        Text(hint, style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
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

class EditProfile extends StatelessWidget {
  const EditProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthProvider>().user!;
    final auth = context.watch<AuthProvider>();

    return AppLayout(
      title: 'Edit Profile',
      subtitle: 'Update your personal information',
      currentRoute: '/profile',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.fromBorderSide(BorderSide(color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2))),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14), offset: const Offset(0, 4), blurRadius: 0)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDark ? Colors.white : const Color(0xFFF5F5F5),
              ),
            ),
            const SizedBox(height: 18),
            AppFormFieldRow(
              children: [
                AppFormField(label: 'Full Name', value: user.name),
                AppFormField(label: 'Email Address', value: user.email),
              ],
            ),
            const SizedBox(height: 14),
            AppFormFieldRow(
              children: [
                AppFormField(label: 'Phone Number', value: '+880 1234 567890'),
                AppFormField(
                  label: 'Account Type',
                  value: _accountTypeLabel[user.accountType] ?? '',
                  readOnly: true,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text('Location', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF525252))),
            const SizedBox(height: 4),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () async {
                final picked = await pickLocation(context);
                if (picked == null || !context.mounted) return;
                context.read<AuthProvider>().updateOwnLocation(lat: picked.lat, lng: picked.lng, address: picked.address);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Location updated!'),
                  backgroundColor: Color(0xFF16A34A),
                ));
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2)),
                ),
                  child: Row(children: [
                  Icon(Icons.location_on_outlined, size: 16, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      auth.address ?? 'Not set — tap to pick on map',
                      style: TextStyle(fontSize: 13, color: auth.address == null ? const Color(0xFFBFBFBF) : (isDark ? Colors.white : const Color(0xFF121212))),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.edit_outlined, size: 15, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
                ]),
              ),
            ),
            const SizedBox(height: 18),
            Text('Radar & Notifications', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF525252))),
            const SizedBox(height: 4),
            _SettingSlider(
              icon: Icons.radar_outlined,
              label: 'Surplus Radar Radius',
              hint: 'Listings within this radius appear on the Radar map and trigger nearby notifications.',
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
              label: 'Unattended Listing Alert',
              hint: 'Listings outside your radius that remain unclaimed for longer than this will still notify you.',
              displayValue: '${auth.unattendedAfterHours} h',
              value: auth.unattendedAfterHours.clamp(6, 72).toDouble(),
              min: 6,
              max: 72,
              divisions: 66,
              sliderLabel: '${auth.unattendedAfterHours} h',
              onChanged: (v) => auth.updateUnattendedAfterHours(v.round()),
            ),
            const SizedBox(height: 22),
            Divider(color: isDark ? const Color(0xFF3F3F46) : const Color(0xFF262626)),
            const SizedBox(height: 18),
            Text(
              'Change Password',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDark ? Colors.white : const Color(0xFFF5F5F5),
              ),
            ),
            const SizedBox(height: 16),
            AppFormFieldRow(
              children: const [
                AppFormField(
                  label: 'Current Password',
                  value: '',
                  obscure: true,
                  placeholder: '••••••••',
                ),
                AppFormField(
                  label: 'New Password',
                  value: '',
                  obscure: true,
                  placeholder: '••••••••',
                ),
              ],
            ),
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
                      const SnackBar(
                        content: Text('Profile updated!'),
                        backgroundColor: Color(0xFF16A34A),
                      ),
                    );
                  },
                ),
                AppButton(label: 'Cancel', outlined: true, onPressed: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}