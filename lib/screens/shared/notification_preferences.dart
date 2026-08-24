import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../providers/auth_provider.dart';
import '../../l10n/l10n_ext.dart';

class NotificationPreferences extends StatelessWidget {
  const NotificationPreferences({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF121212);
    final subColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
    final borderColor = isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2);
    final auth = context.watch<AuthProvider>();
    final t = context.l10n;

    return AppLayout(
      title: t.notifPrefsTitle,
      subtitle: t.notifPrefsSubtitle,
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
              title: t.notifPrefsNewListings,
              subtitle: t.notifPrefsNewListingsSub,
              value: auth.notifNewListings,
              onChanged: auth.updateNotifNewListings,
              textColor: textColor,
              subColor: subColor,
            ),
            _PreferenceTile(
              icon: Icons.assignment_outlined,
              title: t.notifPrefsRequests,
              subtitle: t.notifPrefsRequestsSub,
              value: auth.notifRequests,
              onChanged: auth.updateNotifRequests,
              textColor: textColor,
              subColor: subColor,
            ),
            _PreferenceTile(
              icon: Icons.local_shipping_outlined,
              title: t.notifPrefsPickups,
              subtitle: t.notifPrefsPickupsSub,
              value: auth.notifPickups,
              onChanged: auth.updateNotifPickups,
              textColor: textColor,
              subColor: subColor,
            ),
            _PreferenceTile(
              icon: Icons.campaign_outlined,
              title: t.notifPrefsPromotions,
              subtitle: t.notifPrefsPromotionsSub,
              value: auth.notifPromotions,
              onChanged: auth.updateNotifPromotions,
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
  final ValueChanged<bool> onChanged;
  final Color textColor;
  final Color subColor;

  const _PreferenceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
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
      onChanged: onChanged,
    );
  }
}
