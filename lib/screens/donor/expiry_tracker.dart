import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/responsive_grid.dart';
import '../../models/models.dart';
import '../../providers/donor_provider.dart';

class ExpiryTracker extends StatelessWidget {
  const ExpiryTracker({super.key});

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<DonorProvider>().inventory;
    final now = DateTime.now();
    final expired = inventory.where((i) => i.expiryDate.isBefore(now)).toList();
    final today = inventory.where((i) {
      final d = i.expiryDate.difference(now);
      return d.inSeconds > 0 && d.inHours < 24;
    }).toList();
    final thisWeek = inventory.where((i) {
      final d = i.expiryDate.difference(now);
      return d.inHours >= 24 && d.inDays <= 7;
    }).toList();
    final safe = inventory.where((i) => i.expiryDate.difference(now).inDays > 7).toList();

    return AppLayout(
      title: 'Expiry Tracker',
      subtitle: 'Monitor your inventory expiration dates',
      currentRoute: '/donor/expiry',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveGrid(
            spacing: 12,
            children: [
              _ExpiryStatCard(count: expired.length, label: 'Expired', color: const Color(0xFFEF4444)),
              _ExpiryStatCard(count: today.length, label: 'Expires Today', color: const Color(0xFFEA580C)),
              _ExpiryStatCard(count: thisWeek.length, label: 'This Week', color: const Color(0xFFD97706)),
              _ExpiryStatCard(count: safe.length, label: 'Safe', color: const Color(0xFF16A34A)),
            ],
          ),
          const SizedBox(height: 24),
          if (expired.isNotEmpty) _ExpirySection(title: 'Expired', items: expired),
          if (today.isNotEmpty) _ExpirySection(title: 'Expires Today', items: today),
          if (thisWeek.isNotEmpty) _ExpirySection(title: 'Expires This Week', items: thisWeek),
          if (safe.isNotEmpty) _ExpirySection(title: 'Safe Items', items: safe),
        ],
      ),
    );
  }
}

class _ExpiryStatCard extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  const _ExpiryStatCard({required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFFFFFFFF),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.14), offset: const Offset(0, 4), blurRadius: 0)],
    ),
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
  const _ExpirySection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF525252))),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.14), offset: const Offset(0, 4), blurRadius: 0)],),
        child: Column(
          children: items.map((item) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFE2E2E2)))),
            child: Row(
              children: [
                const Icon(Icons.inventory_2_outlined, size: 16, color: Color(0xFF757575)),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                    Text('${item.category} · Qty: ${item.quantity}', style: const TextStyle(fontSize: 11, color: Color(0xFF757575))),
                  ],
                )),
                Text(
                  '${item.expiryDate.year}-${item.expiryDate.month.toString().padLeft(2, '0')}-${item.expiryDate.day.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
                ),
              ],
            ),
          )).toList(),
        ),
      ),
      const SizedBox(height: 20),
    ],
  );
}
