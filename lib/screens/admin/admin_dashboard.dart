import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/stat_card.dart';
import '../../widgets/ui/responsive_grid.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../providers/admin_provider.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accounts = context.watch<AdminProvider>().accounts;
    final pending = accounts.where((a) => a.status == AccountStatus.pending).length;
    final totalDonated = mockDonationLogs.fold<int>(0, (s, l) => s + l.quantity);
    final totalConsumed = mockRequests
        .where((r) => r.status == RequestStatus.completed)
        .fold<int>(0, (s, r) => s + r.quantity);

    return AppLayout(
      title: 'Admin Overview',
      subtitle: 'Platform-wide donations, consumption & accounts',
      currentRoute: '/admin',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveGrid(
            children: [
              StatCard(
                label: 'Items Donated',
                value: totalDonated,
                icon: const Icon(Icons.volunteer_activism_outlined),
                color: 'green',
                subtitle: '${mockDonationLogs.length} donations logged',
              ),
              StatCard(
                label: 'Items Consumed',
                value: totalConsumed,
                icon: const Icon(Icons.restaurant_outlined),
                color: 'blue',
                subtitle: 'From completed requests',
              ),
              StatCard(
                label: 'Registered Accounts',
                value: accounts.length,
                icon: const Icon(Icons.groups_outlined),
                color: 'red',
              ),
              StatCard(
                label: 'Pending Approvals',
                value: pending,
                icon: const Icon(Icons.pending_actions_outlined),
                color: 'orange',
                subtitle: pending > 0 ? 'Needs review' : 'All caught up',
              ),
            ],
          ),
          const SizedBox(height: 20),
          _ManageAccountsCard(pending: pending),
          const SizedBox(height: 20),
          _SectionCard(
            title: 'Recent Donations',
            icon: Icons.receipt_long_outlined,
            child: Column(
              children: mockDonationLogs
                  .take(5)
                  .map((log) => _ActivityRow(
                        title: '${log.itemName} ×${log.quantity}',
                        subtitle: '${log.recipientOrg} · ${_formatDate(log.loggedAt)}',
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 20),
          _SectionCard(
            title: 'Recent Requests',
            icon: Icons.assignment_outlined,
            child: Column(
              children: mockRequests
                  .take(5)
                  .map((r) => _ActivityRow(
                        title: r.listingTitle,
                        subtitle: '${r.donorName} · ×${r.quantity} · ${_formatDate(r.createdAt)}',
                        trailing: r.status.name,
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
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
                width: 44, height: 44,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.12), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.manage_accounts_outlined, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Manage Accounts', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(
                      pending > 0 ? '$pending account${pending == 1 ? '' : 's'} waiting for approval' : 'Review, approve, or remove accounts',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SectionCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14), offset: const Offset(0, 4), blurRadius: 0)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: isDark ? Colors.white : const Color(0xFF121212)),
              const SizedBox(width: 6),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF121212))),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? trailing;
  const _ActivityRow({required this.title, required this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: isDark ? Colors.white : const Color(0xFF121212)), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(subtitle, style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            Text(trailing!, style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575), fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    );
  }
}
