import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../models/models.dart';
import '../../providers/admin_provider.dart';
import '../../l10n/l10n_ext.dart';

class _PlatformStats {
  final int totalDonations;
  final double totalKgSaved;
  final int completedPickups;
  final int cancelledPickups;
  final int scheduledPickups;
  final int inProgressPickups;
  const _PlatformStats({
    this.totalDonations = 0,
    this.totalKgSaved = 0,
    this.completedPickups = 0,
    this.cancelledPickups = 0,
    this.scheduledPickups = 0,
    this.inProgressPickups = 0,
  });

  int get totalPickups => completedPickups + cancelledPickups + scheduledPickups + inProgressPickups;
}

/// Platform-wide donation/distribution analytics for the admin — everything
/// the per-user stats on [AdminUserDetail] can't show in aggregate.
class AdminStatistics extends StatefulWidget {
  const AdminStatistics({super.key});

  @override
  State<AdminStatistics> createState() => _AdminStatisticsState();
}

class _AdminStatisticsState extends State<AdminStatistics> {
  _PlatformStats? _stats;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final firestore = FirebaseFirestore.instance;
    final logs = await firestore.collection('donation_logs').get();
    final pickups = await firestore.collection('pickups').get();
    final kg = logs.docs.fold<double>(0, (total, d) => total + ((d.data()['totalWeight'] as num?)?.toDouble() ?? 0));
    var completed = 0, cancelled = 0, scheduled = 0, inProgress = 0;
    for (final doc in pickups.docs) {
      switch (doc.data()['status'] as String?) {
        case 'completed':
          completed++;
        case 'cancelled':
          cancelled++;
        case 'scheduled':
          scheduled++;
        default:
          inProgress++;
      }
    }
    if (!mounted) return;
    setState(() => _stats = _PlatformStats(
      totalDonations: logs.docs.length,
      totalKgSaved: kg,
      completedPickups: completed,
      cancelledPickups: cancelled,
      scheduledPickups: scheduled,
      inProgressPickups: inProgress,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = context.l10n;
    final admin = context.watch<AdminProvider>();
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2);
    final subColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575);
    final textColor = isDark ? Colors.white : const Color(0xFF121212);
    final stats = _stats;

    return AppLayout(
      title: t.adminStatsTitle,
      subtitle: t.adminStatsSubtitle,
      currentRoute: '/admin/statistics',
      child: stats == null
          ? const Padding(padding: EdgeInsets.symmetric(vertical: 60), child: Center(child: CircularProgressIndicator()))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Section(
                  title: t.adminStatsDonations,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  children: [
                    _StatTile(t.adminStatDonations, '${stats.totalDonations}', textColor, subColor),
                    _StatTile(t.adminStatKgSaved, stats.totalKgSaved.toStringAsFixed(1), textColor, subColor),
                  ],
                ),
                const SizedBox(height: 16),
                _Section(
                  title: t.adminStatsDeliveries,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  children: [
                    _StatTile(t.adminStatCompleted, '${stats.completedPickups}', textColor, subColor),
                    _StatTile(t.adminStatCancelled, '${stats.cancelledPickups}', textColor, subColor),
                    _StatTile(t.adminStatScheduled, '${stats.scheduledPickups}', textColor, subColor),
                    _StatTile(t.adminStatInProgress, '${stats.inProgressPickups}', textColor, subColor),
                  ],
                ),
                if (stats.totalPickups > 0) ...[
                  const SizedBox(height: 16),
                  _Section(
                    title: t.adminStatsSuccessRate,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: stats.completedPickups / stats.totalPickups,
                          minHeight: 10,
                          backgroundColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
                          color: const Color(0xFF16A34A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.adminStatsSuccessRateValue((stats.completedPickups / stats.totalPickups * 100).toStringAsFixed(1)),
                        style: TextStyle(fontSize: 12, color: subColor),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                StreamBuilder<List<RegisteredAccount>>(
                  stream: admin.accountsStream,
                  builder: (context, snap) {
                    final accounts = snap.data ?? [];
                    final donors = accounts.where((a) => a.mode == UserMode.donor).length;
                    final consumers = accounts.where((a) => a.mode == UserMode.consumer).length;
                    final riders = accounts.where((a) => a.mode == UserMode.rider).length;
                    final verified = accounts.where((a) => a.isVerified).length;
                    return _Section(
                      title: t.adminStatsUsers,
                      cardColor: cardColor,
                      borderColor: borderColor,
                      children: [
                        _StatTile(t.acctMgmtDonor, '$donors', textColor, subColor),
                        _StatTile(t.acctMgmtConsumer, '$consumers', textColor, subColor),
                        _StatTile(t.acctMgmtRider, '$riders', textColor, subColor),
                        _StatTile(t.adminStatVerified, '$verified', textColor, subColor),
                      ],
                    );
                  },
                ),
              ],
            ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Color cardColor;
  final Color borderColor;
  final List<Widget> children;
  const _Section({required this.title, required this.cardColor, required this.borderColor, required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF121212))),
          const SizedBox(height: 12),
          if (children.length > 1 && children.every((c) => c is _StatTile))
            Wrap(spacing: 24, runSpacing: 12, children: children)
          else
            ...children,
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color textColor;
  final Color subColor;
  const _StatTile(this.label, this.value, this.textColor, this.subColor);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
      Text(label, style: TextStyle(fontSize: 11, color: subColor)),
    ],
  );
}
