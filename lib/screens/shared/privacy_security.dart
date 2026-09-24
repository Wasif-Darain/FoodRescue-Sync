import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/block_button.dart';
import '../../providers/auth_provider.dart';
import '../../providers/block_provider.dart';
import '../../l10n/l10n_ext.dart';

/// Privacy & security settings screen.
///
/// Contains three privacy toggles (profile visibility, login alerts, data
/// sharing) followed by a "Blocked accounts" section listing every user the
/// current user has blocked, each with a button to manage the block.
class PrivacySecurity extends StatelessWidget {
  const PrivacySecurity({super.key});

  @override
  Widget build(BuildContext context) {
    // Theme-dependent colors reused throughout the screen.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF121212);
    final subColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575);
    final cardColor = isDark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFFFFFFF);
    final borderColor = isDark
        ? const Color(0xFF3F3F46)
        : const Color(0xFFE2E2E2);
    // watch() so the toggles rebuild when a setting changes.
    final auth = context.watch<AuthProvider>();
    final t = context.l10n;

    return AppLayout(
      title: t.privacyTitle,
      subtitle: t.privacySubtitle,
      currentRoute: '/profile',
      // Single rounded card holding all settings rows.
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.fromBorderSide(BorderSide(color: borderColor)),
          // Hard-edged offset shadow (blurRadius 0) for the app's card style.
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14),
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            // Whether the user's profile is visible to others.
            _SecurityTile(
              icon: Icons.visibility_outlined,
              title: t.privacyVisibility,
              subtitle: t.privacyVisibilitySub,
              value: auth.privacyVisible,
              onChanged: auth.updatePrivacyVisible,
              textColor: textColor,
              subColor: subColor,
            ),
            // Whether to alert the user about new sign-ins.
            _SecurityTile(
              icon: Icons.shield_outlined,
              title: t.privacyLoginAlerts,
              subtitle: t.privacyLoginAlertsSub,
              value: auth.privacyLoginAlerts,
              onChanged: auth.updatePrivacyLoginAlerts,
              textColor: textColor,
              subColor: subColor,
            ),
            // Whether usage data may be shared.
            _SecurityTile(
              icon: Icons.data_usage_outlined,
              title: t.privacyDataSharing,
              subtitle: t.privacyDataSharingSub,
              value: auth.privacyDataSharing,
              onChanged: auth.updatePrivacyDataSharing,
              textColor: textColor,
              subColor: subColor,
            ),
            const Divider(height: 1),
            // ---- Blocked accounts section header ----
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.block_outlined,
                    size: 20,
                    color: Color(0xFFDC2626),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      t.blockBlockedAccounts,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Builder gives this section its own BuildContext so watching
            // BlockProvider only rebuilds this list, not the whole screen.
            Builder(
              builder: (context) {
                final blockedUids = context
                    .watch<BlockProvider>()
                    .blockedUids
                    .toList();
                // Empty state: nobody blocked yet.
                if (blockedUids.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      t.blockBlockedEmpty,
                      style: TextStyle(fontSize: 12, color: subColor),
                    ),
                  );
                }
                return Column(
                  children: [
                    // One row per blocked user. Only UIDs are stored locally,
                    // so each row streams that user's profile document to
                    // display their name and email.
                    for (final uid in blockedUids)
                      StreamBuilder<Map<String, dynamic>?>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .snapshots()
                            .map((doc) => doc.data()),
                        builder: (context, snap) {
                          // Fall back to the raw UID while loading or if the
                          // profile has no name.
                          final name = snap.data?['name'] as String? ?? uid;
                          return ListTile(
                            leading: const Icon(
                              Icons.person_off_outlined,
                              size: 20,
                              color: Color(0xFFDC2626),
                            ),
                            title: Text(
                              name,
                              style: TextStyle(fontSize: 13, color: textColor),
                            ),
                            subtitle: Text(
                              snap.data?['email'] as String? ?? '',
                              style: TextStyle(fontSize: 11, color: subColor),
                            ),
                            // Button to unblock (or re-block) this user.
                            trailing: BlockButton(
                              targetUid: uid,
                              targetLabel: name,
                            ),
                          );
                        },
                      ),
                    // Bottom spacing inside the card.
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// A single labelled on/off switch row used for the privacy settings.
///
/// Colors are passed in from the parent so tiles match the current theme
/// without each one re-reading it.
class _SecurityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color textColor;
  final Color subColor;

  const _SecurityTile({
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
      // Leading icon in the brand green.
      secondary: Icon(icon, size: 20, color: const Color(0xFF16A34A)),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: subColor)),
      value: value,
      // Green track when the switch is on.
      activeTrackColor: const Color(0xFF16A34A),
      onChanged: onChanged,
    );
  }
}