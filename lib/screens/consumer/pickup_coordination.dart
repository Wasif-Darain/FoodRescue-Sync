import 'package:flutter/material.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/app_badge.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';

class PickupCoordination extends StatelessWidget {
  const PickupCoordination({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Pickups',
      subtitle: 'Coordinate and track your food pickups',
      currentRoute: '/consumer/pickups',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            for (final s in [PickupStatus.scheduled, PickupStatus.enRoute, PickupStatus.completed]) ...[
              if (s != PickupStatus.scheduled) const SizedBox(width: 12),
              Expanded(child: _PickupStat(
                status: s,
                count: mockPickups.where((p) => p.status == s).length,
              )),
            ],
          ]),
          const SizedBox(height: 20),
          const Text('Active Pickups', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF111827))),
          const SizedBox(height: 12),
          ...mockPickups.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _PickupCard(pickup: p),
          )),
        ],
      ),
    );
  }
}

class _PickupStat extends StatelessWidget {
  final PickupStatus status;
  final int count;
  const _PickupStat({required this.status, required this.count});

  @override
  Widget build(BuildContext context) {
    final (label, icon, color, bg) = switch (status) {
      PickupStatus.scheduled => ('Scheduled', Icons.schedule,         const Color(0xFF2563EB), const Color(0xFFEFF6FF)),
      PickupStatus.enRoute   => ('En Route',  Icons.directions_car,   const Color(0xFFEA580C), const Color(0xFFFFF7ED)),
      PickupStatus.completed => ('Completed', Icons.check_circle_outline, const Color(0xFF16A34A), const Color(0xFFF0FDF4)),
    };
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Row(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$count', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8))),
        ]),
      ]),
    );
  }
}

class _PickupCard extends StatelessWidget {
  final Pickup pickup;
  const _PickupCard({required this.pickup});

  @override
  Widget build(BuildContext context) {
    final (label, variant, statusColor) = switch (pickup.status) {
      PickupStatus.scheduled => ('Scheduled', BadgeVariant.blue,   const Color(0xFF2563EB)),
      PickupStatus.enRoute   => ('En Route',  BadgeVariant.orange, const Color(0xFFEA580C)),
      PickupStatus.completed => ('Completed', BadgeVariant.green,  const Color(0xFF16A34A)),
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(pickup.donorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF111827))),
          AppBadge(label: label, variant: variant),
        ]),
        const SizedBox(height: 12),
        _InfoRow(icon: Icons.location_on_outlined, label: pickup.address),
        const SizedBox(height: 6),
        _InfoRow(icon: Icons.access_time, label:
          '${pickup.scheduledTime.hour.toString().padLeft(2, '0')}:${pickup.scheduledTime.minute.toString().padLeft(2, '0')} — ${pickup.scheduledTime.day}/${pickup.scheduledTime.month}/${pickup.scheduledTime.year}'),
        const SizedBox(height: 10),
        Wrap(spacing: 6, children: pickup.items.map((item) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(16)),
          child: Text(item, style: const TextStyle(fontSize: 11, color: Color(0xFF374151))),
        )).toList()),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 14, color: const Color(0xFF9CA3AF)),
    const SizedBox(width: 6),
    Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)))),
  ]);
}
