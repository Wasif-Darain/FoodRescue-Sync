import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/app_button.dart';
import '../../widgets/ui/user_badge.dart';
import '../../l10n/l10n_ext.dart';

const _supportEmail = 'support@foodrescuesync.app';

Future<void> _showContentDialog(BuildContext context, String title, String content) {
  return showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(child: Text(content, style: const TextStyle(height: 1.5))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(dialogContext.l10n.commonClose)),
      ],
    ),
  );
}

Future<void> _showMessageDialog(BuildContext context, String title, String type) async {
  final controller = TextEditingController();
  final t = context.l10n;
  final message = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        maxLines: 4,
        decoration: InputDecoration(hintText: t.helpMessageHint, border: const OutlineInputBorder()),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(t.commonCancel)),
        ElevatedButton(
          onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
          child: Text(t.helpSend),
        ),
      ],
    ),
  );
  if (message == null) return;
  if (!context.mounted) return;
  if (message.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.helpMessageEmpty)));
    return;
  }
  final user = FirebaseAuth.instance.currentUser;
  await FirebaseFirestore.instance.collection('support_messages').add({
    'uid': user?.uid,
    'email': user?.email,
    'type': type,
    'message': message,
    'createdAt': Timestamp.now(),
  });
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(t.helpMessageSent), backgroundColor: const Color(0xFF16A34A)),
  );
}

Future<void> _getInTouch(BuildContext context) async {
  final t = context.l10n;
  final uri = Uri(scheme: 'mailto', path: _supportEmail, query: 'subject=FoodRescue Sync Support');
  final launched = await launchUrl(uri);
  if (!context.mounted || launched) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.helpNoEmailApp)));
}

class HelpSupport extends StatelessWidget {
  const HelpSupport({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF121212);
    final subColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
    final borderColor = isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2);
    final t = context.l10n;

    return AppLayout(
      title: t.helpTitle,
      subtitle: t.helpSubtitle,
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
                  title: t.helpFaq,
                  subtitle: t.helpFaqSub,
                  textColor: textColor,
                  subColor: subColor,
                  onTap: () => _showContentDialog(context, t.helpFaq, t.helpFaqContent),
                ),
                _HelpTile(
                  icon: Icons.chat_outlined,
                  title: t.helpContactSupport,
                  subtitle: t.helpContactSupportSub,
                  textColor: textColor,
                  subColor: subColor,
                  onTap: () => _showMessageDialog(context, t.helpContactSupport, 'contact'),
                ),
                _HelpTile(
                  icon: Icons.report_problem_outlined,
                  title: t.helpReportIssue,
                  subtitle: t.helpReportIssueSub,
                  textColor: textColor,
                  subColor: subColor,
                  onTap: () => _showMessageDialog(context, t.helpReportIssue, 'report'),
                ),
                _HelpTile(
                  icon: Icons.description_outlined,
                  title: t.helpTerms,
                  subtitle: t.helpTermsSub,
                  textColor: textColor,
                  subColor: subColor,
                  onTap: () => _showContentDialog(context, t.helpTerms, t.helpTermsContent),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: AppButton(
                    label: t.helpGetInTouch,
                    icon: const Icon(Icons.mail_outline, size: 16),
                    fullWidth: true,
                    onPressed: () => _getInTouch(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(t.helpRankingSystem, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 4),
          Text(t.helpRankingSystemSub, style: TextStyle(fontSize: 12, color: subColor)),
          const SizedBox(height: 14),
          _TierSection(
            title: t.helpDonorTiers,
            icon: Icons.volunteer_activism_outlined,
            color: const Color(0xFF16A34A),
            tiers: [
              ('Novice', t.levelNovice, t.tierDonorNoviceDesc),
              ('Contributor', t.tierContributor, t.tierDonorContributorDesc),
              ('Provider', t.tierProvider, t.tierDonorProviderDesc),
              ('Patron', t.tierPatron, t.tierDonorPatronDesc),
              ('Master', t.tierMaster, t.tierDonorMasterDesc),
              ('Legend', t.tierLegend, t.tierDonorLegendDesc),
            ],
            isDark: isDark,
            cardColor: cardColor,
            borderColor: borderColor,
            textColor: textColor,
            subColor: subColor,
          ),
          const SizedBox(height: 14),
          _TierSection(
            title: t.helpConsumerTiers,
            icon: Icons.restaurant_outlined,
            color: const Color(0xFFEA580C),
            tiers: [
              ('Novice', t.levelNovice, t.tierConsumerNoviceDesc),
              ('Scout', t.tierScout, t.tierConsumerScoutDesc),
              ('Saver', t.tierSaver, t.tierConsumerSaverDesc),
              ('Rescuer', t.tierRescuer, t.tierConsumerRescuerDesc),
              ('Master', t.tierMaster, t.tierConsumerMasterDesc),
              ('Legend', t.tierLegend, t.tierConsumerLegendDesc),
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
  final List<(String, String, String)> tiers;
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
          for (final (colorKey, label, desc) in tiers)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserBadge(label: label, colorKey: colorKey, isLegend: colorKey == 'Legend', fontSize: 9),
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
  final VoidCallback onTap;

  const _HelpTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.textColor,
    required this.subColor,
    required this.onTap,
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
      onTap: onTap,
    );
  }
}
