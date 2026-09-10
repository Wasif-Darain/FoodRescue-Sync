import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/app_badge.dart';
import '../../widgets/ui/verified_badge.dart';
import '../../models/models.dart';
import '../../providers/admin_provider.dart';
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
  AccountType.rider: t.accountTypeRider,
};

String _roleLabel(AppLocalizations t, UserMode mode) => switch (mode) {
  UserMode.donor => t.acctMgmtDonor,
  UserMode.rider => t.acctMgmtRider,
  UserMode.admin => t.navAdministrator,
  UserMode.consumer => t.acctMgmtConsumer,
};

class AccountManagement extends StatefulWidget {
  const AccountManagement({super.key});

  @override
  State<AccountManagement> createState() => _AccountManagementState();
}

class _AccountManagementState extends State<AccountManagement> {
  AccountStatus? _filter;
  bool _approvingAll = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final admin = context.watch<AdminProvider>();
    final t = context.l10n;
    return StreamBuilder<List<RegisteredAccount>>(
      stream: admin.accountsStream,
      builder: (context, snapshot) {
        final accounts = snapshot.data ?? [];
        final filtered = _filter == null ? accounts : accounts.where((a) => a.status == _filter).toList();
        final pendingCount = accounts.where((a) => a.status == AccountStatus.pending).length;

    return AppLayout(
      title: t.acctMgmtTitle,
      subtitle: t.acctMgmtSubtitle,
      currentRoute: '/admin/accounts',
      action: pendingCount > 0
          ? TextButton(
              onPressed: _approvingAll
                  ? null
                  : () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Approve All Accounts'),
                          content: Text('Approve all $pendingCount pending accounts?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Approve All')),
                          ],
                        ),
                      );
                      if (confirmed == true && mounted) {
                        setState(() => _approvingAll = true);
                        await admin.approveAllExisting();
                        if (mounted) setState(() => _approvingAll = false);
                      }
                    },
              child: _approvingAll
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text('Approve All ($pendingCount)', style: const TextStyle(color: Color(0xFF16A34A), fontSize: 13)),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(label: t.acctMgmtFilterAll(accounts.length), selected: _filter == null, onTap: () => setState(() => _filter = null)),
                const SizedBox(width: 8),
                _FilterChip(
                  label: t.acctMgmtFilterPending(accounts.where((a) => a.status == AccountStatus.pending).length),
                  selected: _filter == AccountStatus.pending,
                  onTap: () => setState(() => _filter = AccountStatus.pending),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: t.acctMgmtFilterApproved(accounts.where((a) => a.status == AccountStatus.approved).length),
                  selected: _filter == AccountStatus.approved,
                  onTap: () => setState(() => _filter = AccountStatus.approved),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: t.acctMgmtFilterSuspended(accounts.where((a) => a.status == AccountStatus.suspended).length),
                  selected: _filter == AccountStatus.suspended,
                  onTap: () => setState(() => _filter = AccountStatus.suspended),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: t.acctMgmtFilterExpired(accounts.where((a) => a.status == AccountStatus.expired).length),
                  selected: _filter == AccountStatus.expired,
                  onTap: () => setState(() => _filter = AccountStatus.expired),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Text(t.acctMgmtNoAccounts, style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)))),
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
    final t = context.l10n;
    final (label, variant) = switch (account.status) {
      AccountStatus.pending => (t.acctMgmtStatusPending, BadgeVariant.orange),
      AccountStatus.approved => (t.acctMgmtStatusApproved, BadgeVariant.green),
      AccountStatus.suspended => (t.acctMgmtStatusSuspended, BadgeVariant.red),
      AccountStatus.expired => (t.acctMgmtStatusExpired, BadgeVariant.gray),
    };
    final admin = context.read<AdminProvider>();

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.go('/admin/user/${account.uid}'),
      child: Container(
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
                    Row(
                      children: [
                        Flexible(child: Text(account.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF121212)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        if (account.isVerified) ...[
                          const SizedBox(width: 4),
                          VerifiedBadge(mode: account.mode, size: 14),
                        ],
                      ],
                    ),
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
              _Tag(text: _roleLabel(t, account.mode)),
              _Tag(text: _accountTypeLabel(t)[account.accountType] ?? ''),
              _Tag(text: t.acctMgmtJoinedTag('${account.joinedAt.year}-${account.joinedAt.month.toString().padLeft(2, '0')}-${account.joinedAt.day.toString().padLeft(2, '0')}')),
            ],
          ),
          if (account.status != AccountStatus.approved && !account.hasSubmittedDocuments) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.warning_amber_outlined, size: 14, color: Color(0xFFD97706)),
                const SizedBox(width: 6),
                Expanded(child: Text(t.acctMgmtNoDocuments, style: const TextStyle(fontSize: 11, color: Color(0xFFD97706)))),
              ],
            ),
          ],
          if (account.hasSubmittedDocuments) ...[
            const SizedBox(height: 8),
            _NidPreview(account: account),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (account.status == AccountStatus.expired)
                Expanded(
                  child: _ActionButton(
                    label: t.acctMgmtBringBackOnTrack,
                    color: const Color(0xFF16A34A),
                    onTap: () => admin.reactivateAccount(account.uid),
                  ),
                ),
              if (account.status == AccountStatus.pending || account.status == AccountStatus.suspended)
                Expanded(
                  child: _ActionButton(
                    label: t.acctMgmtApprove,
                    color: const Color(0xFF16A34A),
                    onTap: () => admin.approve(account.uid),
                  ),
                ),
              if (account.status == AccountStatus.approved)
                Expanded(
                  child: _ActionButton(
                    label: t.acctMgmtSuspend,
                    color: const Color(0xFFD97706),
                    onTap: () => admin.setStatus(account.uid, AccountStatus.suspended),
                  ),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  label: t.acctMgmtRemove,
                  color: const Color(0xFFEF4444),
                  outlined: true,
                  onTap: () => _confirmRemove(context, admin, account),
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  void _confirmRemove(BuildContext context, AdminProvider admin, RegisteredAccount account) {
    final t = context.l10n;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.acctMgmtRemoveTitle),
        content: Text(t.acctMgmtRemoveBody(account.name)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(t.commonCancel)),
          ElevatedButton(
            onPressed: () {
              admin.removeAccount(account.uid);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white, elevation: 0),
            child: Text(t.acctMgmtRemove),
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

class _NidPreview extends StatelessWidget {
  final RegisteredAccount account;
  const _NidPreview({required this.account});

  @override
  Widget build(BuildContext context) {
    final isIndividual = account.accountType == AccountType.individual || account.accountType == AccountType.rider;
    final urls = isIndividual
        ? [account.nidFrontUrl, account.nidBackUrl]
        : [account.verificationDocUrl];
    final labels = isIndividual ? ['NID Front', 'NID Back'] : ['Verification Doc'];

    return Row(
      children: List.generate(urls.length, (i) {
        final url = urls[i];
        if (url == null) return const SizedBox.shrink();
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < urls.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => _showFullImage(context, url, labels[i]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(labels[i], style: TextStyle(fontSize: 10, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(url, height: 80, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, _, _) => Container(height: 80, color: const Color(0xFFF5F5F5), child: const Icon(Icons.broken_image_outlined, color: Color(0xFFBFBFBF)))),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  void _showFullImage(BuildContext context, String url, String label) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(title: Text(label), leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx))),
            Image.network(url, fit: BoxFit.contain),
          ],
        ),
      ),
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
