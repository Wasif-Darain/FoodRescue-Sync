import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/stat_card.dart';
import '../../widgets/ui/responsive_grid.dart';
import '../../models/models.dart';
import '../../providers/admin_provider.dart';
import '../../l10n/l10n_ext.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final t = context.l10n;
    return StreamBuilder<List<RegisteredAccount>>(
      stream: admin.accountsStream,
      builder: (context, snapshot) {
        final accounts = snapshot.data ?? [];
        final pending = accounts
            .where((a) => a.status == AccountStatus.pending)
            .length;

        return AppLayout(
          title: t.adminOverviewTitle,
          subtitle: t.adminOverviewSubtitle,
          currentRoute: '/admin',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResponsiveGrid(
                children: [
                  StatCard(
                    label: t.adminRegisteredAccounts,
                    value: accounts.length,
                    icon: const Icon(Icons.groups_outlined),
                    color: 'red',
                  ),
                  StatCard(
                    label: t.adminPendingApprovals,
                    value: pending,
                    icon: const Icon(Icons.pending_actions_outlined),
                    color: 'orange',
                    subtitle: pending > 0 ? t.adminNeedsReview : t.adminAllCaughtUp,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _ManageAccountsCard(pending: pending),
            ],
          ),
        );
      },
    );
  }
}

class _ManageAccountsCard extends StatelessWidget {
  final int pending;
  const _ManageAccountsCard({required this.pending});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF121212),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.go('/admin/accounts'),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.manage_accounts_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.adminManageAccounts,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pending > 0
                          ? context.l10n.adminAccountsWaiting(pending)
                          : context.l10n.adminReviewApproveRemove,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
