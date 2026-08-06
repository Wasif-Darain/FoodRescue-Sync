import 'package:flutter/material.dart';
import '../../widgets/layout/app_layout.dart';

class PrivacySecurity extends StatelessWidget {
  const PrivacySecurity({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF121212);
    final subColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
    final borderColor = isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2);

    return AppLayout(
      title: 'Privacy & Security',
      subtitle: 'Manage your account security settings',
      currentRoute: '/profile',
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.fromBorderSide(BorderSide(color: borderColor)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14), offset: const Offset(0, 4), blurRadius: 0)],
        ),
        child: Column(
          children: [
            _SecurityTile(
              icon: Icons.visibility_outlined,
              title: 'Profile Visibility',
              subtitle: 'Make your profile visible to other users',
              value: true,
              textColor: textColor,
              subColor: subColor,
            ),
            _SecurityTile(
              icon: Icons.shield_outlined,
              title: 'Login Alerts',
              subtitle: 'Get notified about new device logins',
              value: true,
              textColor: textColor,
              subColor: subColor,
            ),
            _SecurityTile(
              icon: Icons.data_usage_outlined,
              title: 'Data Sharing',
              subtitle: 'Allow anonymous usage data collection',
              value: false,
              textColor: textColor,
              subColor: subColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _SecurityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final Color textColor;
  final Color subColor;

  const _SecurityTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.textColor,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, size: 20, color: const Color(0xFF16A34A)),
      title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: subColor)),
      value: value,
      activeTrackColor: const Color(0xFF16A34A),
      onChanged: (_) {},
    );
  }
}