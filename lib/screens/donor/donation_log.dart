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

class DonationLogScreen extends StatelessWidget {
  const DonationLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    // Show the log according to the active mode: donors see the donations
    // they gave, consumers see the donations they received.
    final isDonor = context.watch<AuthProvider>().user?.mode == UserMode.donor;
    final roleField = isDonor ? 'donorId' : 'recipientId';

    final stream = uid == null
        ? Stream<List<DonationLogModel>>.value([])
        : FirebaseFirestore.instance
            .collection('donation_logs')
            .where(roleField, isEqualTo: uid)
            .orderBy('completedAt', descending: true)
            .snapshots()
            .map((snap) => snap.docs
                .map((doc) => DonationLogModel.fromFirestore(doc))
                .toList());

    return StreamBuilder<List<DonationLogModel>>(
      stream: stream,
      builder: (context, snapshot) {
        final logs = snapshot.data ?? [];
        final total = logs.fold<double>(0, (sum, l) => sum + l.totalWeightKg);

        return AppLayout(
          title: 'Donation Log',
          subtitle: isDonor ? 'Your complete donation history' : 'Donations you have received',
          currentRoute: '/donor/donation-log',
          child: Column(
            children: [
              Row(children: [
                Expanded(child: _SummaryCard(value: '${logs.length}', label: isDonor ? 'Total Donations' : 'Total Received')),
                const SizedBox(width: 12),
                Expanded(child: _SummaryCard(value: total.toStringAsFixed(1), label: 'Weight (kg)')),
                const SizedBox(width: 12),
                Expanded(child: _SummaryCard(value: '${logs.map((l) => isDonor ? l.recipientId : l.donorId).toSet().length}', label: isDonor ? 'Recipients' : 'Donors')),
              ]),
              const SizedBox(height: 20),
              if (logs.isEmpty)
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
                      Text(isDonor ? 'No donations logged yet' : 'No donations received yet', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF121212))),
                    ],
                  ),
                )
              else
                Container(
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

class _SummaryCard extends StatelessWidget {
  final String value;
  final String label;
  const _SummaryCard({required this.value, required this.label});

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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF121212))),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
      ]),
    );
  }
}

class _LogRow extends StatelessWidget {
  final DonationLogModel log;
  const _LogRow({required this.log});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDonor = context.watch<AuthProvider>().user?.mode == UserMode.donor;
    final date = '${log.completedAt.year}-${log.completedAt.month.toString().padLeft(2, '0')}-${log.completedAt.day.toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2)))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('${log.totalWeightKg.toStringAsFixed(1)} kg', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF121212)), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              AppBadge(label: 'Completed', variant: BadgeVariant.green),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isDonor
                ? 'Recipient: ${log.recipientId} · $date'
                : 'Donor: ${log.donorId} · $date',
            style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          RatingStars(reviewLabel: 'Rate this donation'),
        ],
      ),
    );
  }
}