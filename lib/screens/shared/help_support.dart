import 'package:flutter/material.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/app_button.dart';

class HelpSupport extends StatelessWidget {
  const HelpSupport({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF121212);
    final subColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
    final borderColor = isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2);

    return AppLayout(
      title: 'Help & Support',
      subtitle: 'Get help with using FoodRescue Sync',
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
            _HelpTile(
              icon: Icons.help_outline,
              title: 'FAQ',
              subtitle: 'Find answers to common questions',
              textColor: textColor,
              subColor: subColor,
            ),
            _HelpTile(
              icon: Icons.chat_outlined,
              title: 'Contact Support',
              subtitle: 'Reach out to our support team',
              textColor: textColor,
              subColor: subColor,
            ),
            _HelpTile(
              icon: Icons.report_problem_outlined,
              title: 'Report an Issue',
              subtitle: 'Report a bug or technical problem',
              textColor: textColor,
              subColor: subColor,
            ),
            _HelpTile(
              icon: Icons.description_outlined,
              title: 'Terms & Conditions',
              subtitle: 'Read our terms of service',
              textColor: textColor,
              subColor: subColor,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: AppButton(
                label: 'Get in Touch',
                icon: const Icon(Icons.mail_outline, size: 16),
                fullWidth: true,
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color textColor;
  final Color subColor;

  const _HelpTile({
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