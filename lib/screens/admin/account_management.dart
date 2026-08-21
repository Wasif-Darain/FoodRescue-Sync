import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/app_badge.dart';
import '../../models/models.dart';
import '../../providers/admin_provider.dart';

const _accountTypeLabel = {
  AccountType.restaurant: 'Restaurant',
  AccountType.caterer: 'Caterer',
  AccountType.store: 'Store',
  AccountType.ngo: 'NGO',
  AccountType.foodBank: 'Food Bank',
  AccountType.shelter: 'Shelter',
  AccountType.individual: 'Individual',
};

class AccountManagement extends StatefulWidget {
  const AccountManagement({super.key});

  @override
  State<AccountManagement> createState() => _AccountManagementState();
}

class _AccountManagementState extends State<AccountManagement> {
  AccountStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final admin = context.watch<AdminProvider>();
    return StreamBuilder<List<RegisteredAccount>>(
      stream: admin.accountsStream,
      builder: (context, snapshot) {
        final accounts = snapshot.data ?? [];
        final filtered = _filter == null ? accounts : accounts.where((a) => a.status == _filter).toList();

    return AppLayout(
      title: 'Accounts',
      subtitle: 'Approve, suspend, or remove registered accounts',
      currentRoute: '/admin/accounts',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(label: 'All (${accounts.length})', selected: _filter == null, onTap: () => setState(() => _filter = null)),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Pending (${accounts.where((a) => a.status == AccountStatus.pending).length})',
                  selected: _filter == AccountStatus.pending,
                  onTap: () => setState(() => _filter = AccountStatus.pending),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Approved (${accounts.where((a) => a.status == AccountStatus.approved).length})',
                  selected: _filter == AccountStatus.approved,
                  onTap: () => setState(() => _filter = AccountStatus.approved),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Suspended (${accounts.where((a) => a.status == AccountStatus.suspended).length})',
                  selected: _filter == AccountStatus.suspended,
                  onTap: () => setState(() => _filter = AccountStatus.suspended),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Text('No accounts in this filter.', style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)))),
            )
          else
            Column(
              children: filtered.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _AccountCard(account: a),
              )).toList(),
            ),
        ],
      ),
    );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? (isDark ? Colors.white : const Color(0xFF121212)) : (isDark ? const Color(0xFF2A2A2A) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? (isDark ? Colors.white : const Color(0xFF121212)) : (isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2))),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? (isDark ? const Color(0xFF121212) : Colors.white) : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF525252)))),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final RegisteredAccount account;
  const _AccountCard({required this.account});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (label, variant) = switch (account.status) {
      AccountStatus.pending => ('Pending', BadgeVariant.orange),
      AccountStatus.approved => ('Approved', BadgeVariant.green),
      AccountStatus.suspended => ('Suspended', BadgeVariant.red),
    };
    final admin = context.read<AdminProvider>();

    return Container(
      padding: const EdgeInsets.all(16),
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
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: account.mode == UserMode.donor ? (isDark ? const Color(0xFF0D2818) : const Color(0xFFDCFCE7)) : (isDark ? const Color(0xFF2A1A0A) : const Color(0xFFFFE3CC)),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    account.name.isNotEmpty ? account.name[0] : '?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: account.mode == UserMode.donor ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D)) : (isDark ? const Color(0xFFF97316) : const Color(0xFFC2410C)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(account.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF121212)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(account.email, style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              AppBadge(label: label, variant: variant),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _Tag(text: account.mode == UserMode.donor ? 'Donor' : 'Consumer'),
              _Tag(text: _accountTypeLabel[account.accountType] ?? ''),
              _Tag(text: 'Joined ${account.joinedAt.year}-${account.joinedAt.month.toString().padLeft(2, '0')}-${account.joinedAt.day.toString().padLeft(2, '0')}'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (account.status != AccountStatus.approved)
                Expanded(
                  child: _ActionButton(
                    label: 'Approve',
                    color: const Color(0xFF16A34A),
                    onTap: () => admin.setStatus(account.email, AccountStatus.approved),
                  ),
                ),
              if (account.status == AccountStatus.approved)
                Expanded(
                  child: _ActionButton(
                    label: 'Suspend',
                    color: const Color(0xFFD97706),
                    onTap: () => admin.setStatus(account.email, AccountStatus.suspended),
                  ),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  label: 'Remove',
                  color: const Color(0xFFEF4444),
                  outlined: true,
                  onTap: () => _confirmRemove(context, admin, account),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmRemove(BuildContext context, AdminProvider admin, RegisteredAccount account) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove account?'),
        content: Text('This will permanently remove "${account.name}" from the platform.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              admin.removeAccount(account.email);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white, elevation: 0),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag({required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(fontSize: 10, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF525252), fontWeight: FontWeight.w500)),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool outlined;
  final VoidCallback onTap;
  const _ActionButton({required this.label, required this.color, required this.onTap, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: outlined ? (isDark ? const Color(0xFF2A2A2A) : Colors.white) : color,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: outlined ? Border.all(color: color) : null,
          ),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: outlined ? color : Colors.white)),
        ),
      ),
    );
  }
}
