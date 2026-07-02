import 'package:flutter/material.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/app_badge.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';

class ExpiryTracker extends StatelessWidget {
  const ExpiryTracker({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final expired = mockInventory.where((i) => i.expiryDate.isBefore(now)).toList();
    final today = mockInventory.where((i) {
      final d = i.expiryDate.difference(now);
      return d.inSeconds > 0 && d.inHours < 24;
    }).toList();
    final thisWeek = mockInventory.where((i) {
      final d = i.expiryDate.difference(now);
      return d.inHours >= 24 && d.inDays <= 7;
    }).toList();
    final safe = mockInventory.where((i) => i.expiryDate.difference(now).inDays > 7).toList();

    return AppLayout(
      title: 'Expiry Tracker',
      subtitle: 'Monitor your inventory expiration dates',
      currentRoute: '/donor/expiry',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: _ExpiryStatCard(count: expired.length, label: 'Expired', color: const Color(0xFFEF4444), bg: const Color(0xFFFEF2F2))),
            const SizedBox(width: 12),
            Expanded(child: _ExpiryStatCard(count: today.length, label: 'Expires Today', color: const Color(0xFFEA580C), bg: const Color(0xFFFFF7ED))),
            const SizedBox(width: 12),
            Expanded(child: _ExpiryStatCard(count: thisWeek.length, label: 'This Week', color: const Color(0xFFD97706), bg: const Color(0xFFFEFCE8))),
            const SizedBox(width: 12),
            Expanded(child: _ExpiryStatCard(count: safe.length, label: 'Safe', color: const Color(0xFF16A34A), bg: const Color(0xFFF0FDF4))),
          ]),
          const SizedBox(height: 24),
          if (expired.isNotEmpty) _ExpirySection(title: 'Expired', items: expired, variant: BadgeVariant.red),
          if (today.isNotEmpty) _ExpirySection(title: 'Expires Today', items: today, variant: BadgeVariant.orange),
          if (thisWeek.isNotEmpty) _ExpirySection(title: 'Expires This Week', items: thisWeek, variant: BadgeVariant.gray),
          if (safe.isNotEmpty) _ExpirySection(title: 'Safe Items', items: safe, variant: BadgeVariant.green),
        ],
      ),
    );
  }
}

class _ExpiryStatCard extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final Color bg;
  const _ExpiryStatCard({required this.count, required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.2))),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$count', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8), fontWeight: FontWeight.w500)),
      ],
    ),
  );
}

class _ExpirySection extends StatelessWidget {
  final String title;
  final List<InventoryItem> items;
  final BadgeVariant variant;
  const _ExpirySection({required this.title, required this.items, required this.variant});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF374151))),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF3F4F6))),
        child: Column(
          children: items.map((item) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFF3F4F6)))),
            child: Row(
              children: [
                const Icon(Icons.inventory_2_outlined, size: 16, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                    Text('${item.category} · Qty: ${item.quantity}', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                  ],
                )),
                Text(
                  '${item.expiryDate.year}-${item.expiryDate.month.toString().padLeft(2, '0')}-${item.expiryDate.day.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
                const SizedBox(width: 12),
                AppBadge(label: item.isSurplus ? 'Surplus' : 'Normal', variant: variant),
              ],
            ),
          )).toList(),
        ),
      ),
      const SizedBox(height: 20),
    ],
  );
}
