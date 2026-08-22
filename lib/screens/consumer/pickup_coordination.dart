import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../providers/donor_provider.dart';
import '../../widgets/ui/app_badge.dart';
import '../../widgets/ui/rating_stars.dart';
import '../../widgets/ui/countdown_timer.dart';
import '../../widgets/ui/detail_sheet.dart';
import '../../models/pickup.dart';

class PickupCoordination extends StatelessWidget {
  const PickupCoordination({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    final stream = uid == null
        ? Stream<List<PickupModel>>.value([])
        : FirebaseFirestore.instance
            .collection('pickups')
            .where('consumerId', isEqualTo: uid)
            .snapshots()
            .map((snap) => snap.docs
                .map((doc) => PickupModel.fromFirestore(doc))
                .toList());

    return StreamBuilder<List<PickupModel>>(
      stream: stream,
      builder: (context, snapshot) {
        final pickups = snapshot.data ?? [];

        return AppLayout(
          title: 'Pickups',
          subtitle: 'Coordinate and track your food pickups',
          currentRoute: '/consumer/pickups',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IntrinsicHeight(
                child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  for (final s in [PickupStatusModel.scheduled, PickupStatusModel.enRoute, PickupStatusModel.completed]) ...[
                    if (s != PickupStatusModel.scheduled) const SizedBox(width: 12),
                    Expanded(child: _HoverScale(
                      child: _PickupStat(
                        status: s,
                        count: pickups.where((p) => p.status == s).length,
                      ),
                    )),
                  ],
                ]),
              ),
              const SizedBox(height: 20),
              Text('Active Pickups', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF121212))),
              const SizedBox(height: 12),
              if (pickups.isEmpty)
                Center(
                  child: Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.local_shipping_outlined, size: 48, color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFBFBFBF)),
                      const SizedBox(height: 12),
                      Text('No pickups scheduled', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF121212))),
                    ],
                  ),
                ),
                )
              else
                ...pickups.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _HoverScale(child: _PickupCard(pickup: p)),
                )),
            ],
          ),
        );
      },
    );
  }
}

class _PickupStat extends StatelessWidget {
  final PickupStatusModel status;
  final int count;
  const _PickupStat({required this.status, required this.count});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (label, icon, color) = switch (status) {
      PickupStatusModel.scheduled => ('Scheduled', Icons.schedule, const Color(0xFF2563EB)),
      PickupStatusModel.enRoute   => ('En Route',  Icons.directions_car, const Color(0xFFEA580C)),
      PickupStatusModel.completed => ('Completed', Icons.check_circle_outline, const Color(0xFF16A34A)),
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
  final PickupModel pickup;
  const _PickupCard({required this.pickup});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allListings = context.watch<DonorProvider>().allListings;
    final matched = (pickup.listingId == null || pickup.listingId!.isEmpty)
        ? null
        : allListings.where((l) => l.docId == pickup.listingId).firstOrNull;
    final senderName = pickup.donorName?.isNotEmpty == true ? pickup.donorName! : matched?.donorName ?? '';
    final itemTitle = pickup.listingTitle?.isNotEmpty == true ? pickup.listingTitle! : matched?.title ?? '';
    final (label, variant, statusColor) = switch (pickup.status) {
      PickupStatusModel.scheduled => ('Scheduled', BadgeVariant.blue,   const Color(0xFF2563EB)),
      PickupStatusModel.enRoute   => ('En Route',  BadgeVariant.orange, const Color(0xFFEA580C)),
      PickupStatusModel.completed => ('Completed', BadgeVariant.green,  const Color(0xFF16A34A)),
    };

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => showDetailSheet(
        context,
        title: 'Pickup #${pickup.id}',
        subtitle: 'Pickup details',
        rows: [
          DetailRow(Icons.local_shipping_outlined, 'Status', label),
          if (senderName.isNotEmpty) DetailRow(Icons.storefront_outlined, 'From', senderName),
          if (itemTitle.isNotEmpty) DetailRow(Icons.inventory_2_outlined, 'Item', itemTitle),
          if (pickup.scheduledTime != null)
            DetailRow(Icons.access_time, 'Scheduled', '${pickup.scheduledTime!.day}/${pickup.scheduledTime!.month}/${pickup.scheduledTime!.year} at ${pickup.scheduledTime!.hour.toString().padLeft(2, '0')}:${pickup.scheduledTime!.minute.toString().padLeft(2, '0')}'),
          if (pickup.completedAt != null)
            DetailRow(Icons.check_circle_outline, 'Completed', '${pickup.completedAt!.day}/${pickup.completedAt!.month}/${pickup.completedAt!.year}'),
          if (pickup.address != null) DetailRow(Icons.location_on_outlined, 'Address', pickup.address!),
        ],
      ),
      child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14), offset: const Offset(0, 4), blurRadius: 0)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
            child: Text(
              itemTitle.isNotEmpty ? itemTitle : 'Pickup #${pickup.id}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF121212)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          AppBadge(label: label, variant: variant),
        ]),
        if (senderName.isNotEmpty) ...[
          const SizedBox(height: 4),
          _InfoRow(icon: Icons.storefront_outlined, label: 'From $senderName'),
        ],
        const SizedBox(height: 12),
        _InfoRow(icon: Icons.location_on_outlined, label: pickup.address ?? 'No address'),
        if (pickup.scheduledTime != null) ...[
          const SizedBox(height: 6),
          _InfoRow(icon: Icons.access_time, label:
            '${pickup.scheduledTime!.hour.toString().padLeft(2, '0')}:${pickup.scheduledTime!.minute.toString().padLeft(2, '0')} — ${pickup.scheduledTime!.day}/${pickup.scheduledTime!.month}/${pickup.scheduledTime!.year}'),
        ],
        if (pickup.status == PickupStatusModel.scheduled || pickup.status == PickupStatusModel.enRoute) ...[
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: pickup.scheduledTime != null
                ? CountdownTimer(expiry: pickup.scheduledTime!, fontSize: 9, expiredLabel: 'Overdue')
                : const SizedBox.shrink(),
          ),
        ],
        if (pickup.status == PickupStatusModel.completed) ...[
          const SizedBox(height: 14),
          RatingStars(reviewLabel: 'Rate this pickup'),
        ],
      ]),
      ),
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