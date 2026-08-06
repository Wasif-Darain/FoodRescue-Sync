import 'package:flutter/material.dart';
import '../../widgets/layout/app_layout.dart';

class LanguageRegion extends StatelessWidget {
  const LanguageRegion({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF121212);
    final subColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
    final borderColor = isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2);

    return AppLayout(
      title: 'Language & Region',
      subtitle: 'Set your preferred language and region',
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
            _RegionTile(
              icon: Icons.language_outlined,
              title: 'Language',
              subtitle: 'English (US)',
              textColor: textColor,
              subColor: subColor,
            ),
            _RegionTile(
              icon: Icons.place_outlined,
              title: 'Region',
              subtitle: 'Bangladesh',
              textColor: textColor,
              subColor: subColor,
            ),
            _RegionTile(
              icon: Icons.schedule_outlined,
              title: 'Time Zone',
              subtitle: 'GMT+6 (Dhaka)',
              textColor: textColor,
              subColor: subColor,
            ),
            _RegionTile(
              icon: Icons.currency_exchange_outlined,
              title: 'Currency',
              subtitle: 'BDT (৳)',
              textColor: textColor,
              subColor: subColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _RegionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color textColor;
  final Color subColor;

  const _RegionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.textColor,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, size: 20, color: const Color(0xFF16A34A)),
      title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: subColor)),
      trailing: Icon(Icons.arrow_forward_ios, size: 12, color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFBFBFBF)),
      dense: true,
      onTap: () {},
    );
  }
}