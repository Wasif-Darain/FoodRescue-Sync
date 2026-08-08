import 'package:flutter/material.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/app_button.dart';
import '../../widgets/ui/user_badge.dart';

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
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
          const SizedBox(height: 20),
          Text('Ranking System', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 4),
          Text('Earn badges by donating food or rescuing meals. Higher tiers unlock more trust and visibility.', style: TextStyle(fontSize: 12, color: subColor)),
          const SizedBox(height: 14),
          _TierSection(
            title: 'Donor Tiers',
            icon: Icons.volunteer_activism_outlined,
            color: const Color(0xFF16A34A),
            tiers: [
              ('Novice', 'Default starting rank upon registration.'),
              ('Contributor', '5+ listings created OR 25+ kg saved (≥80% fulfillment).'),
              ('Provider', '20+ listings OR 100+ kg saved (≥85% fulfillment, ≥3.8★, 3+ reviews).'),
              ('Patron', '50+ listings OR 300+ kg saved (≥90% fulfillment, ≥4.2★, 5+ reviews).'),
              ('Master', '120+ listings OR 750+ kg saved (≥95% fulfillment, ≥4.5★, 10+ reviews).'),
              ('Legend', '250+ listings OR 1,500+ kg saved (top 2% regional, ≥4.7★).'),
            ],
            isDark: isDark,
            cardColor: cardColor,
            borderColor: borderColor,
            textColor: textColor,
            subColor: subColor,
          ),
          const SizedBox(height: 14),
          _TierSection(
            title: 'Consumer Tiers',
            icon: Icons.restaurant_outlined,
            color: const Color(0xFFEA580C),
            tiers: [
              ('Novice', 'Default starting rank (0–2 meals rescued).'),
              ('Scout', '3–9 meals rescued/purchased.'),
              ('Saver', '10–24 meals rescued (≥85% on-time pickup, ≥3.8★, 3+ reviews).'),
              ('Rescuer', '25–49 meals rescued (≥90% on-time pickup, ≥4.2★, 5+ reviews).'),
              ('Master', '50–99 meals rescued (≥95% on-time pickup, ≥4.5★, 10+ reviews).'),
              ('Legend', '100+ meals rescued (≥98% on-time pickup, ≥4.7★).'),
            ],
            isDark: isDark,
            cardColor: cardColor,
            borderColor: borderColor,
            textColor: textColor,
            subColor: subColor,
          ),
        ],
      ),
    );
  }
}

class _TierSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<(String, String)> tiers;
  final bool isDark;
  final Color cardColor;
  final Color borderColor;
  final Color textColor;
  final Color subColor;

  const _TierSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.tiers,
    required this.isDark,
    required this.cardColor,
    required this.borderColor,
    required this.textColor,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.fromBorderSide(BorderSide(color: borderColor)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14), offset: const Offset(0, 4), blurRadius: 0)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
            ],
          ),
          const SizedBox(height: 12),
          for (final (label, desc) in tiers)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserBadge(label: label, isLegend: label == 'Legend', fontSize: 9),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(desc, style: TextStyle(fontSize: 11.5, color: subColor)),
                  ),
                ],
              ),
            ),
        ],
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