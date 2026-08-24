import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/user_badge.dart';
import '../../providers/auth_provider.dart';
import '../../models/models.dart';
import '../../l10n/l10n_ext.dart';
import '../../l10n/gen/app_localizations.dart';

Map<AccountType, String> _accountTypeLabel(AppLocalizations t) => {
  AccountType.restaurant: t.accountTypeRestaurant,
  AccountType.caterer: t.accountTypeCaterer,
  AccountType.store: t.accountTypeStore,
  AccountType.ngo: t.accountTypeNgo,
  AccountType.foodBank: t.accountTypeFoodBank,
  AccountType.shelter: t.accountTypeShelter,
  AccountType.individual: t.accountTypeIndividual,
};

class ProfileSettings extends StatelessWidget {
  const ProfileSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthProvider>().user!;
    final t = context.l10n;

    final quickLinks = [
      (Icons.person_outline, t.profileEditProfile, '/profile/edit'),
      (Icons.notifications_outlined, t.profileNotificationPreferences, '/profile/notifications'),
      (Icons.lock_outline, t.profilePrivacySecurity, '/profile/privacy-security'),
      (Icons.language_outlined, t.profileLanguageRegion, '/profile/language-region'),
      (Icons.help_outline, t.profileHelpSupport, '/profile/help-support'),
    ];

    return AppLayout(
      title: t.profileSettingsTitle,
      subtitle: t.profileSettingsSubtitle,
      currentRoute: '/profile',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 700;

          final profileColumn = SizedBox(
            width: isNarrow ? double.infinity : 280,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(16),
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
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0D2818) : const Color(0xFFDCFCE7),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            user.name[0],
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        user.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : const Color(0xFF121212),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0D2818) : const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _accountTypeLabel(t)[user.accountType] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF16A34A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (user.mode != UserMode.admin) ...[
                        const SizedBox(height: 10),
                        UserBadge(label: t.navMember, isLegend: false),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14),
                        offset: const Offset(0, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                          child: Text(
                            t.profileQuickLinks,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575),
                            ),
                          ),
                        ),
                        for (final item in quickLinks)
                          ListTile(
                            leading: Icon(
                              item.$1,
                              size: 18,
                              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575),
                            ),
                            title: Text(
                              item.$2,
                              style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF121212)),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFBFBFBF),
                            ),
                            dense: true,
                            onTap: () => context.go(item.$3),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [profileColumn],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              profileColumn,
            ],
          );
        },
      ),
    );
  }
}
