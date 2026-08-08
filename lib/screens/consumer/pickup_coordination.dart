import 'package:flutter/material.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/app_badge.dart';
import '../../widgets/ui/rating_stars.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';

class PickupCoordination extends StatelessWidget {
  const PickupCoordination({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppLayout(
      title: 'Pickups',
      subtitle: 'Coordinate and track your food pickups',
      currentRoute: '/consumer/pickups',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (final s in [PickupStatus.scheduled, PickupStatus.enRoute, PickupStatus.completed]) ...[
              if (s != PickupStatus.scheduled) const SizedBox(width: 12),
              Expanded(child: _HoverScale(
                child: _PickupStat(
                  status: s,
                  count: mockPickups.where((p) => p.status == s).length,
                ),
              )),
            ],
          ]),
          ),
          const SizedBox(height: 20),
          Text('Active Pickups', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF121212))),
          const SizedBox(height: 12),
          ...mockPickups.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _HoverScale(child: _PickupCard(pickup: p)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (label, icon, color) = switch (status) {
      PickupStatus.scheduled => ('Scheduled', Icons.schedule, const Color(0xFF2563EB)),
      PickupStatus.enRoute   => ('En Route',  Icons.directions_car, const Color(0xFFEA580C)),
      PickupStatus.completed => ('Completed', Icons.check_circle_outline, const Color(0xFF16A34A)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14), offset: const Offset(0, 4), blurRadius: 0)],
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF121212))),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label, style: TextStyle(fontSize: 10, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

class _PickupCard extends StatelessWidget {
  final Pickup pickup;
  const _PickupCard({required this.pickup});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (label, variant, statusColor) = switch (pickup.status) {
      PickupStatus.scheduled => ('Scheduled', BadgeVariant.blue,   const Color(0xFF2563EB)),
      PickupStatus.enRoute   => ('En Route',  BadgeVariant.orange, const Color(0xFFEA580C)),
      PickupStatus.completed => ('Completed', BadgeVariant.green,  const Color(0xFF16A34A)),
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14), offset: const Offset(0, 4), blurRadius: 0)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(pickup.donorName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF121212))),
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
          decoration: BoxDecoration(color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE2E2E2), borderRadius: BorderRadius.circular(16)),
          child: Text(item, style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF525252))),
        )).toList()),
        if (pickup.status == PickupStatus.completed) ...[
          const SizedBox(height: 14),
          RatingStars(reviewLabel: 'Rate ${pickup.donorName}'),
        ],
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(children: [
      Icon(icon, size: 14, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
      const SizedBox(width: 6),
      Expanded(child: Text(label, style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)))),
    ]);
  }
}

class _HoverScale extends StatefulWidget {
  final Widget child;
  const _HoverScale({required this.child});

  @override
  State<_HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<_HoverScale> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          scale: (_hovered || _pressed) ? 1.02 : 1.0,
          child: widget.child,
        ),
      ),
    );
  }
}
