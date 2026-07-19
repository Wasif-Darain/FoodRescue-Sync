import 'package:flutter/material.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/app_badge.dart';
import '../../data/mock_data.dart';

class DonationLogScreen extends StatelessWidget {
  const DonationLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final total = mockDonationLogs.fold(0, (sum, l) => sum + l.quantity);

    return AppLayout(
      title: 'Donation Log',
      subtitle: 'Your complete donation history',
      currentRoute: '/donor/donation-log',
      child: Column(
        children: [
          // Summary cards
          Row(children: [
            Expanded(child: _SummaryCard(value: '${mockDonationLogs.length}', label: 'Total Donations')),
            const SizedBox(width: 12),
            Expanded(child: _SummaryCard(value: '$total', label: 'Items Donated')),
            const SizedBox(width: 12),
            Expanded(child: _SummaryCard(value: '${mockDonationLogs.map((l) => l.recipientOrg).toSet().length}', label: 'Organizations Helped')),
          ]),
          const SizedBox(height: 20),
          // Log list
          Container(
            decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.14), offset: const Offset(0, 4), blurRadius: 0)],),
            child: Column(
              children: [
                for (final log in mockDonationLogs) _LogRow(log: log),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String value;
  final String label;
  const _SummaryCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFFFFFFFF),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.14), offset: const Offset(0, 4), blurRadius: 0)],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF121212))),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
    ]),
  );
}

class _LogRow extends StatelessWidget {
  final dynamic log;
  const _LogRow({required this.log});

  @override
  Widget build(BuildContext context) {
    final date = '${log.loggedAt.year}-${log.loggedAt.month.toString().padLeft(2, '0')}-${log.loggedAt.day.toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFE2E2E2)))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('${log.itemName} ×${log.quantity}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF121212)), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              const AppBadge(label: 'Completed', variant: BadgeVariant.green),
            ],
          ),
          const SizedBox(height: 4),
          Text('${log.recipientOrg} · $date', style: const TextStyle(fontSize: 12, color: Color(0xFF757575)), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
