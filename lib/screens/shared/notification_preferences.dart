import 'package:flutter/material.dart';
import '../../widgets/layout/app_layout.dart';

class NotificationPreferences extends StatelessWidget {
  const NotificationPreferences({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF121212);
    final subColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
    final borderColor = isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2);

    return AppLayout(
      title: 'Notification Preferences',
      subtitle: 'Choose what you want to be notified about',
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
            _PreferenceTile(
              icon: Icons.storefront_outlined,
              title: 'New Listings',
              subtitle: 'Get notified when new food listings are posted',
              value: true,
              textColor: textColor,
              subColor: subColor,
            ),
            _PreferenceTile(
              icon: Icons.assignment_outlined,
              title: 'Requests',
              subtitle: 'Get notified about new donation requests',
              value: true,
              textColor: textColor,
              subColor: subColor,
            ),
            _PreferenceTile(
              icon: Icons.local_shipping_outlined,
              title: 'Pickups',
              subtitle: 'Get notified about pickup coordination updates',
              value: false,
              textColor: textColor,
              subColor: subColor,
            ),
            _PreferenceTile(
              icon: Icons.campaign_outlined,
              title: 'Promotions',
              subtitle: 'Get notified about campaigns and promotions',
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

class _PreferenceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final Color textColor;
  final Color subColor;

  const _PreferenceTile({
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