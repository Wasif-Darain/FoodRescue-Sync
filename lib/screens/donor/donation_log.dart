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
            Expanded(child: _SummaryCard(value: '${mockDonationLogs.length}', label: 'Total Donations', color: const Color(0xFF16A34A), bg: const Color(0xFFF0FDF4))),
            const SizedBox(width: 12),
            Expanded(child: _SummaryCard(value: '$total', label: 'Items Donated', color: const Color(0xFF2563EB), bg: const Color(0xFFEFF6FF))),
            const SizedBox(width: 12),
            Expanded(child: _SummaryCard(value: '${mockDonationLogs.map((l) => l.recipientOrg).toSet().length}', label: 'Organizations Helped', color: const Color(0xFFEA580C), bg: const Color(0xFFFFF7ED))),
          ]),
          const SizedBox(height: 20),
          // Log table
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF3F4F6))),
            child: Column(
              children: [
                _LogHeader(),
                ...mockDonationLogs.map((log) => _LogRow(log: log)),
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
  final Color color;
  final Color bg;
  const _SummaryCard({required this.value, required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.2))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8))),
    ]),
  );
}

class _LogHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    decoration: const BoxDecoration(color: Color(0xFFF9FAFB), borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
    child: const Row(children: [
      Expanded(flex: 2, child: Text('Item', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)))),
      Expanded(child: Text('Qty', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)))),
      Expanded(flex: 2, child: Text('Recipient', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)))),
      Expanded(flex: 2, child: Text('Date', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)))),
      Expanded(child: Text('Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)))),
    ]),
  );
}

class _LogRow extends StatelessWidget {
  final dynamic log;
  const _LogRow({required this.log});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFF3F4F6)))),
    child: Row(children: [
      Expanded(flex: 2, child: Text(log.itemName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
      Expanded(child: Text('×${log.quantity}', style: const TextStyle(fontSize: 13))),
      Expanded(flex: 2, child: Text(log.recipientOrg, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)))),
      Expanded(flex: 2, child: Text(
        '${log.loggedAt.year}-${log.loggedAt.month.toString().padLeft(2, '0')}-${log.loggedAt.day.toString().padLeft(2, '0')}',
        style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
      )),
      const Expanded(child: AppBadge(label: 'Completed', variant: BadgeVariant.green)),
    ]),
  );
}
