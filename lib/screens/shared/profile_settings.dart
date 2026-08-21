import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/user_badge.dart';
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

class ProfileSettings extends StatelessWidget {
  const ProfileSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthProvider>().user!;

    final quickLinks = [
      (Icons.person_outline, 'Edit Profile', '/profile/edit'),
      (Icons.notifications_outlined, 'Notification Preferences', '/profile/notifications'),
      (Icons.lock_outline, 'Privacy & Security', '/profile/privacy-security'),
      (Icons.language_outlined, 'Language & Region', '/profile/language-region'),
      (Icons.help_outline, 'Help & Support', '/profile/help-support'),
    ];

    return AppLayout(
      title: 'Profile & Settings',
      subtitle: 'Manage your account information',
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
                          _accountTypeLabel[user.accountType] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF16A34A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (user.mode != UserMode.admin) ...[
                        const SizedBox(height: 10),
                        const UserBadge(label: 'Member', isLegend: false),
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
                            'Quick Links',
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

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatChip({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Icon(icon, size: 16, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF121212))),
        const SizedBox(height: 1),
        Text(label, style: TextStyle(fontSize: 9, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
      ],
    );
  }
}
