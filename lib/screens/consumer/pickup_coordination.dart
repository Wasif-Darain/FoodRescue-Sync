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
import '../../providers/consumer_provider.dart';
import '../../widgets/ui/block_button.dart';
import '../../widgets/ui/live_tracking_map.dart';
import '../../l10n/l10n_ext.dart';

/// Bottom sheet listing every registered rider so a consumer can directly
/// assign one to [pickupId] instead of leaving it for self-claim.
void _showAssignRiderSheet(BuildContext rootContext, String pickupId) {
  final t = rootContext.l10n;
  final consumer = rootContext.read<ConsumerProvider>();
  showModalBottomSheet(
    context: rootContext,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (sheetContext) {
      final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
      return Container(
        constraints: const BoxConstraints(maxHeight: 480),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Text(t.pickupChooseRider, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF121212)))),
                IconButton(
                  icon: Icon(Icons.close, size: 18, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
                  onPressed: () => Navigator.pop(sheetContext),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ]),
              const SizedBox(height: 8),
              Flexible(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'rider').snapshots(),
                  builder: (context, snap) {
                    final riders = snap.data?.docs ?? [];
                    if (riders.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(t.pickupNoRidersAvailable, style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: riders.length,
                      itemBuilder: (context, i) {
                        final doc = riders[i];
                        final name = doc.data()['name'] as String? ?? '';
                        return ListTile(
                          leading: const Icon(Icons.moped_outlined, color: Color(0xFF2563EB)),
                          title: Text(name, style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF121212))),
                          onTap: () async {
                            final error = await consumer.assignRider(pickupId, doc.id);
                            if (!sheetContext.mounted) return;
                            Navigator.pop(sheetContext);
                            if (!rootContext.mounted) return;
                            ScaffoldMessenger.of(rootContext).showSnackBar(SnackBar(
                              content: Text(error ?? t.pickupAssignedSnack),
                              backgroundColor: error == null ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                            ));
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

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
        final t = context.l10n;

        return AppLayout(
          title: t.pickupTitle,
          subtitle: t.pickupSubtitle,
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
              Text(t.pickupActivePickups, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF121212))),
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
                      Text(t.pickupNoneScheduled, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF121212))),
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
    final t = context.l10n;
    final (label, icon, color) = switch (status) {
      PickupStatusModel.scheduled => (t.pickupStatusScheduled, Icons.schedule, const Color(0xFF2563EB)),
      PickupStatusModel.enRoute   => (t.pickupStatusEnRoute,  Icons.directions_car, const Color(0xFFEA580C)),
      PickupStatusModel.completed => (t.pickupStatusCompleted, Icons.check_circle_outline, const Color(0xFF16A34A)),
      PickupStatusModel.cancelled => (t.pickupStatusCancelled, Icons.cancel_outlined, const Color(0xFFDC2626)),
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
    final t = context.l10n;
    final (label, variant, statusColor) = switch (pickup.status) {
      PickupStatusModel.scheduled => (t.pickupStatusScheduled, BadgeVariant.blue,   const Color(0xFF2563EB)),
      PickupStatusModel.enRoute   => (t.pickupStatusEnRoute,  BadgeVariant.orange, const Color(0xFFEA580C)),
      PickupStatusModel.completed => (t.pickupStatusCompleted, BadgeVariant.green,  const Color(0xFF16A34A)),
      PickupStatusModel.cancelled => (t.pickupStatusCancelled, BadgeVariant.red, const Color(0xFFDC2626)),
    };

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => showDetailSheet(
        context,
        title: t.pickupHashId(pickup.id),
        subtitle: t.pickupDetails,
        rows: [
          DetailRow(Icons.local_shipping_outlined, t.pickupDetailStatus, label),
          if (senderName.isNotEmpty) DetailRow(Icons.storefront_outlined, t.pickupDetailFrom, senderName),
          if (itemTitle.isNotEmpty) DetailRow(Icons.inventory_2_outlined, t.pickupDetailItem, itemTitle),
          if (pickup.scheduledTime != null)
            DetailRow(Icons.access_time, t.pickupDetailScheduled, '${pickup.scheduledTime!.day}/${pickup.scheduledTime!.month}/${pickup.scheduledTime!.year} at ${pickup.scheduledTime!.hour.toString().padLeft(2, '0')}:${pickup.scheduledTime!.minute.toString().padLeft(2, '0')}'),
          if (pickup.completedAt != null)
            DetailRow(Icons.check_circle_outline, t.pickupDetailCompleted, '${pickup.completedAt!.day}/${pickup.completedAt!.month}/${pickup.completedAt!.year}'),
          if (pickup.address != null) DetailRow(Icons.location_on_outlined, t.pickupDetailAddress, pickup.address!),
        ],
        menuActions: matched == null
            ? const <SheetMenuItem>[]
            : <SheetMenuItem>[
                blockSheetMenuItem(
                  context,
                  targetUid: matched.donorUid,
                  targetLabel: matched.donorName,
                ),
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
              itemTitle.isNotEmpty ? itemTitle : t.pickupHashId(pickup.id),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF121212)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          AppBadge(label: label, variant: variant),
        ]),
        if (senderName.isNotEmpty) ...[
          const SizedBox(height: 4),
          _InfoRow(icon: Icons.storefront_outlined, label: t.pickupFromSender(senderName)),
        ],
        const SizedBox(height: 12),
        _InfoRow(icon: Icons.location_on_outlined, label: pickup.address ?? t.pickupNoAddress),
        if (pickup.scheduledTime != null) ...[
          const SizedBox(height: 6),
          _InfoRow(icon: Icons.access_time, label:
            '${pickup.scheduledTime!.hour.toString().padLeft(2, '0')}:${pickup.scheduledTime!.minute.toString().padLeft(2, '0')} — ${pickup.scheduledTime!.day}/${pickup.scheduledTime!.month}/${pickup.scheduledTime!.year}'),
        ],
        if (pickup.status == PickupStatusModel.scheduled) ...[
          const SizedBox(height: 12),
          if (pickup.volunteerDriverId == null || pickup.volunteerDriverId!.isEmpty)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showAssignRiderSheet(context, pickup.id),
                icon: const Icon(Icons.person_add_alt_outlined, size: 16),
                label: Text(t.pickupAssignRider),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                  side: const BorderSide(color: Color(0xFF2563EB)),
                ),
              ),
            )
          else
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('users').doc(pickup.volunteerDriverId).snapshots(),
              builder: (context, riderSnap) {
                final riderName = riderSnap.data?.data()?['name'] as String? ?? '…';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(icon: Icons.moped_outlined, label: t.pickupAssignedTo(riderName)),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showAssignRiderSheet(context, pickup.id),
                          style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF2563EB), side: const BorderSide(color: Color(0xFF2563EB))),
                          child: Text(t.pickupReassignRider, style: const TextStyle(fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            await context.read<ConsumerProvider>().unassignRider(pickup.id);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.pickupUnassignedSnack)));
                          },
                          style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFDC2626), side: const BorderSide(color: Color(0xFFDC2626))),
                          child: Text(t.pickupUnassign, style: const TextStyle(fontSize: 12)),
                        ),
                      ),
                    ]),
                  ],
                );
              },
            ),
        ],
        if (pickup.volunteerDriverId != null &&
            pickup.volunteerDriverId!.isNotEmpty &&
            (pickup.status == PickupStatusModel.scheduled || pickup.status == PickupStatusModel.enRoute)) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => showLiveTrackingMap(context, pickup.id),
              icon: const Icon(Icons.map_outlined, size: 16),
              label: Text(t.trackButton),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
                side: const BorderSide(color: Color(0xFF2563EB)),
              ),
            ),
          ),
        ],
        if (pickup.status == PickupStatusModel.scheduled || pickup.status == PickupStatusModel.enRoute) ...[
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final consumer = context.read<ConsumerProvider>();
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: Text(t.pickupCancelClaim),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: Text(t.commonClose),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: Text(t.pickupCancelClaim),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await consumer.cancelClaim(pickup.id);
                }
              },
              icon: const Icon(Icons.cancel_outlined, size: 18),
              label: Text(t.pickupCancelClaim),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                side: const BorderSide(color: Color(0xFFDC2626)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: pickup.scheduledTime != null
                ? CountdownTimer(expiry: pickup.scheduledTime!, fontSize: 9, expiredLabel: t.pickupOverdue)
                : const SizedBox.shrink(),
          ),
        ],
        if (pickup.status == PickupStatusModel.completed) ...[
          const SizedBox(height: 14),
          RatingStars(reviewLabel: t.pickupRateThis),
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