import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/app_badge.dart';
import '../../widgets/ui/rating_stars.dart';
import '../../models/donation_log.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/ui/block_button.dart';
import '../../widgets/ui/detail_sheet.dart';
import '../../l10n/l10n_ext.dart';

/// History of completed donations for the signed-in user.
///
/// The view depends on the active mode: donors see donations they gave,
/// consumers see donations they received. A row of summary cards (count,
/// total weight, number of distinct counterparties) sits above the list.
class DonationLogScreen extends StatelessWidget {
  const DonationLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    // Show the log according to the active mode: donors see the donations
    // they gave, consumers see the donations they received.
    final isDonor = context.watch<AuthProvider>().user?.mode == UserMode.donor;
    // Firestore field used to match the current user in each log document.
    final roleField = isDonor ? 'donorId' : 'recipientId';

    // Live stream of the user's logs (empty if signed out). Sorted newest
    // first on the client so no composite Firestore index is required.
    final stream = uid == null
        ? Stream<List<DonationLogModel>>.value([])
        : FirebaseFirestore.instance
            .collection('donation_logs')
            .where(roleField, isEqualTo: uid)
            .snapshots()
            .map((snap) => snap.docs
                .map((doc) => DonationLogModel.fromFirestore(doc))
                .toList()
              ..sort((a, b) => b.completedAt.compareTo(a.completedAt)));

    return StreamBuilder<List<DonationLogModel>>(
      stream: stream,
      builder: (context, snapshot) {
        final logs = snapshot.data ?? [];
        // Total weight across all logs, in kg.
        final total = logs.fold<double>(0, (acc, l) => acc + l.totalWeightKg);
        final t = context.l10n;

        return AppLayout(
          title: t.donationLogTitle,
          subtitle: isDonor ? t.donationLogSubtitle : 'Donations you have received',
          currentRoute: '/donor/donation-log',
          child: Column(
            children: [
              // ---- Summary cards (equal height) ----
              IntrinsicHeight(
                child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  // Number of logs.
                  Expanded(child: _SummaryCard(icon: Icons.receipt_long_outlined, color: const Color(0xFF16A34A), value: '${logs.length}', label: isDonor ? t.donationLogTotalDonations : 'Total Received')),
                  const SizedBox(width: 12),
                  // Total weight in kg (one decimal).
                  Expanded(child: _SummaryCard(icon: Icons.scale_outlined, color: const Color(0xFF2563EB), value: total.toStringAsFixed(1), label: t.donationLogWeightKg)),
                  const SizedBox(width: 12),
                  // Distinct counterparties: recipients for donors, donors for
                  // consumers (a Set removes duplicates).
                  Expanded(child: _SummaryCard(icon: Icons.people_outline, color: const Color(0xFFEA580C), value: '${logs.map((l) => isDonor ? l.recipientId : l.donorId).toSet().length}', label: isDonor ? t.donationLogRecipients : 'Donors')),
                ]),
              ),
              const SizedBox(height: 20),
              if (logs.isEmpty)
                // Empty state.
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 48, color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFBFBFBF)),
                      const SizedBox(height: 12),
                      Text(isDonor ? t.donationLogEmpty : 'No donations received yet', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF121212))),
                    ],
                  ),
                )
              else
                // List card. antiAlias clips row ripples to the rounded corners.
                Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14), offset: const Offset(0, 4), blurRadius: 0)],),
                  child: Column(
                    children: [
                      for (final log in logs) _LogRow(log: log),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Card showing one headline number with a label and a small tinted icon.
class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  const _SummaryCard({required this.icon, required this.color, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        // Hard-edged offset shadow (blurRadius 0): the app's card style.
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14), offset: const Offset(0, 4), blurRadius: 0)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Icon in a soft circle tinted with the card's accent color.
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(height: 10),
        Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF121212))),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
      ]),
    );
  }
}

/// One entry in the log. Tapping opens a detail sheet (with a block option for
/// the other party); the row itself shows weight, status, counterparty, date
/// and a rating widget.
class _LogRow extends StatelessWidget {
  final DonationLogModel log;
  const _LogRow({required this.log});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDonor = context.watch<AuthProvider>().user?.mode == UserMode.donor;
    final t = context.l10n;
    // Completion date as yyyy-MM-dd.
    final date = '${log.completedAt.year}-${log.completedAt.month.toString().padLeft(2, '0')}-${log.completedAt.day.toString().padLeft(2, '0')}';
    // The "other party": recipient for donors, donor for consumers.
    final otherId = isDonor ? log.recipientId : log.donorId;
    final otherName = isDonor ? log.recipientDisplayName : log.donorDisplayName;
    // e.g. "Rice (2.0 kg), Bread (1.5 kg)"
    final itemSummary = log.itemSummary.entries
        .map((e) => '${e.key} (${e.value.toStringAsFixed(1)} kg)')
        .join(', ');
    return InkWell(
      onTap: () => showListingDetailSheet(
        context,
        title: '${log.totalWeightKg.toStringAsFixed(1)} kg',
        subtitle: date,
        donorId: otherId,
        rows: [
          DetailRow(
            Icons.person_outline,
            isDonor ? 'Recipient' : 'Donor',
            isDonor ? log.recipientDisplayName : log.donorDisplayName,
          ),
          // Items row only when there is a summary to show.
          if (itemSummary.isNotEmpty)
            DetailRow(Icons.inventory_2_outlined, 'Items', itemSummary),
          DetailRow(
            Icons.check_circle_outline,
            'Status',
            t.donationLogCompleted,
          ),
        ],
        // Offer "block" for the other party, unless their id is unknown.
        menuActions: otherId.isEmpty
            ? const <SheetMenuItem>[]
            : <SheetMenuItem>[
                blockSheetMenuItem(
                  context,
                  targetUid: otherId,
                  targetLabel: otherName,
                ),
              ],
      ),
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      // Thin divider line above each row.
      decoration: BoxDecoration(border: Border(top: BorderSide(color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2)))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top line: weight + "Completed" badge.
          Row(
            children: [
              Expanded(
                child: Text('${log.totalWeightKg.toStringAsFixed(1)} kg', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF121212)), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              AppBadge(label: t.donationLogCompleted, variant: BadgeVariant.green),
            ],
          ),
          const SizedBox(height: 4),
          // Counterparty and date.
          Text(
            isDonor
                ? t.donationLogRecipient(log.recipientDisplayName, date)
                : 'Donor: ${log.donorDisplayName} · $date',
            style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // Lets the user rate the other party for this pickup.
          RatingStars(reviewLabel: t.donationLogRateThis, targetUid: otherId, pickupId: log.id),
        ],
      ),
      ),
    );
  }
}