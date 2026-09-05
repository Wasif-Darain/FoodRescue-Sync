import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/app_badge.dart';
import '../../widgets/ui/countdown_timer.dart';
import '../../models/pickup.dart';
import '../../providers/auth_provider.dart';
import '../../providers/rider_provider.dart';
import '../../l10n/l10n_ext.dart';
import '../../widgets/ui/live_tracking_map.dart';
import '../../widgets/ui/rider_navigation_map.dart';

class RiderDashboard extends StatelessWidget {
  const RiderDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthProvider>().user!;
    final rider = context.watch<RiderProvider>();
    final t = context.l10n;

    return AppLayout(
      title: t.riderDashTitle,
      subtitle: t.riderDashSubtitle,
      currentRoute: '/rider',
      child: StreamBuilder<List<PickupModel>>(
        stream: rider.availablePickupsStream,
        builder: (context, availableSnap) {
          final available = availableSnap.data ?? [];
          return StreamBuilder<List<PickupModel>>(
            stream: rider.pendingAssignmentsStream,
            builder: (context, pendingSnap) {
              final pending = pendingSnap.data ?? [];
              return StreamBuilder<List<PickupModel>>(
            stream: rider.myDeliveriesStream,
            builder: (context, mineSnap) {
              final mine = mineSnap.data ?? [];
              // Once the rider hands off, their leg is done — `delivered`/
              // `distributing`/`completed` are all "finished" from a rider's
              // point of view, even though the consumer still has work left.
              final active = mine
                  .where((p) => p.status == PickupStatusModel.scheduled || p.status == PickupStatusModel.enRoute || p.status == PickupStatusModel.pickedUp)
                  .toList();
              final completed = mine
                  .where((p) => p.status == PickupStatusModel.delivered || p.status == PickupStatusModel.distributing || p.status == PickupStatusModel.completed)
                  .toList();
              rider.ensureTracking(mine);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14), offset: const Offset(0, 4), blurRadius: 0)],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.riderDashGreeting(user.name.split(' ').first), style: TextStyle(color: isDark ? Colors.white : const Color(0xFF121212), fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text(t.riderDashTagline, style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575), fontSize: 13)),
                            ],
                          ),
                        ),
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(14)),
                          child: const Icon(Icons.moped_outlined, color: Color(0xFF2563EB), size: 26),
                        ),
                      ],
                    ),
                  ),
                  if (rider.permissionDenied) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF3F2A0A) : const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEA580C)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.location_off_outlined, size: 18, color: Color(0xFFEA580C)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            t.riderLocationPermissionDenied,
                            style: TextStyle(fontSize: 11.5, color: isDark ? const Color(0xFFFDBA74) : const Color(0xFF9A3412)),
                          ),
                        ),
                      ]),
                    ),
                  ],
                  const SizedBox(height: 20),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _RiderStat(count: available.length, label: t.riderStatAvailable, color: const Color(0xFF2563EB))),
                        const SizedBox(width: 12),
                        Expanded(child: _RiderStat(count: active.length, label: t.riderStatActive, color: const Color(0xFFEA580C))),
                        const SizedBox(width: 12),
                        Expanded(child: _RiderStat(count: completed.length, label: t.riderStatCompleted, color: const Color(0xFF16A34A))),
                      ],
                    ),
                  ),
                  if (pending.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(t.riderAssignmentRequests, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF121212))),
                    const SizedBox(height: 12),
                    ...pending.map((p) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _AssignmentRequestCard(pickup: p),
                        )),
                  ],
                  const SizedBox(height: 24),
                  Text(t.riderAvailablePickups, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF121212))),
                  const SizedBox(height: 12),
                  if (available.isEmpty)
                    _EmptyNote(text: t.riderNoAvailable, isDark: isDark)
                  else
                    ...available.map((p) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _AvailablePickupCard(pickup: p),
                        )),
                  const SizedBox(height: 24),
                  Text(t.riderMyDeliveries, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF121212))),
                  const SizedBox(height: 12),
                  if (active.isEmpty)
                    _EmptyNote(text: t.riderNoDeliveries, isDark: isDark)
                  else
                    ...active.map((p) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _MyDeliveryCard(pickup: p),
                        )),
                ],
              );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _RiderStat extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  const _RiderStat({required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14), offset: const Offset(0, 4), blurRadius: 0)],
      ),
      child: Column(children: [
        Text('$count', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575), fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

class _EmptyNote extends StatelessWidget {
  final String text;
  final bool isDark;
  const _EmptyNote({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2)),
      ),
      child: Text(text, style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
    );
  }
}

String _formatScheduled(DateTime? d) {
  if (d == null) return '';
  return '${d.day}/${d.month}/${d.year} · ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _AvailablePickupCard extends StatelessWidget {
  final PickupModel pickup;
  const _AvailablePickupCard({required this.pickup});

  Future<void> _claim(BuildContext context) async {
    final t = context.l10n;
    final error = await context.read<RiderProvider>().claimPickup(pickup.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error ?? t.riderClaimedMsg),
      backgroundColor: error == null ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = context.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2563EB), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14), offset: const Offset(0, 4), blurRadius: 0)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pickup.listingTitle?.isNotEmpty == true ? pickup.listingTitle! : t.riderPickupFrom(pickup.donorName ?? ''),
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF121212)),
          ),
          if (pickup.donorName != null && pickup.donorName!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(t.riderPickupFrom(pickup.donorName!), style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
          ],
          const SizedBox(height: 6),
          Row(children: [
            Icon(Icons.location_on_outlined, size: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
            const SizedBox(width: 4),
            Expanded(child: Text(pickup.address?.isNotEmpty == true ? pickup.address! : t.riderNoAddress, style: TextStyle(fontSize: 11.5, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)), overflow: TextOverflow.ellipsis)),
          ]),
          if (pickup.scheduledTime != null) ...[
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.access_time, size: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
              const SizedBox(width: 4),
              Text(_formatScheduled(pickup.scheduledTime), style: TextStyle(fontSize: 11.5, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
            ]),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _claim(context),
              icon: const Icon(Icons.check, size: 15),
              label: Text(t.riderClaim, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, elevation: 0),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentRequestCard extends StatelessWidget {
  final PickupModel pickup;
  const _AssignmentRequestCard({required this.pickup});

  Future<void> _respond(BuildContext context, bool accept) async {
    final t = context.l10n;
    final rider = context.read<RiderProvider>();
    if (accept) {
      await rider.acceptAssignment(pickup.id);
    } else {
      await rider.declineAssignment(pickup.id);
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(accept ? t.riderAssignmentAcceptedMsg : t.riderAssignmentDeclinedMsg),
      backgroundColor: accept ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = context.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEA580C), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14), offset: const Offset(0, 4), blurRadius: 0)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pickup.listingTitle?.isNotEmpty == true ? pickup.listingTitle! : t.riderPickupFrom(pickup.donorName ?? ''),
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF121212)),
          ),
          const SizedBox(height: 4),
          Text(t.riderAssignedDirectly, style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
          const SizedBox(height: 6),
          Row(children: [
            Icon(Icons.location_on_outlined, size: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
            const SizedBox(width: 4),
            Expanded(child: Text(pickup.address?.isNotEmpty == true ? pickup.address! : t.riderNoAddress, style: TextStyle(fontSize: 11.5, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)), overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _respond(context, false),
                style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFDC2626), side: const BorderSide(color: Color(0xFFDC2626))),
                child: Text(t.riderDecline, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _respond(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white, elevation: 0),
                child: Text(t.reqAccept, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

class _MyDeliveryCard extends StatelessWidget {
  final PickupModel pickup;
  const _MyDeliveryCard({required this.pickup});

  Future<void> _advance(BuildContext context) async {
    if (pickup.status == PickupStatusModel.scheduled) {
      await context.read<RiderProvider>().markEnRoute(pickup.id);
    }
    if (!context.mounted) return;
    await showRiderNavigation(context, pickup.id);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = context.l10n;
    final (statusLabel, variant) = switch (pickup.status) {
      PickupStatusModel.enRoute => (t.pickupStatusEnRoute, BadgeVariant.orange),
      PickupStatusModel.pickedUp => (t.pickupStatusPickedUp, BadgeVariant.purple),
      PickupStatusModel.completed => (t.pickupStatusCompleted, BadgeVariant.green),
      _ => (t.riderStatusClaimed, BadgeVariant.blue),
    };
    final actionLabel = pickup.status == PickupStatusModel.scheduled ? t.riderStartDelivery : t.riderResumeNavigation;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14), offset: const Offset(0, 4), blurRadius: 0)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
              child: Text(
                pickup.listingTitle?.isNotEmpty == true ? pickup.listingTitle! : t.riderPickupFrom(pickup.donorName ?? ''),
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF121212)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            AppBadge(label: statusLabel, variant: variant),
          ]),
          if (pickup.consumerId != null && pickup.consumerId!.isNotEmpty) ...[
            const SizedBox(height: 4),
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('users').doc(pickup.consumerId).snapshots(),
              builder: (context, snap) {
                final name = snap.data?.data()?['name'] as String? ?? '…';
                return Text(t.riderDeliverTo(name), style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)));
              },
            ),
          ],
          const SizedBox(height: 6),
          Row(children: [
            Icon(Icons.location_on_outlined, size: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
            const SizedBox(width: 4),
            Expanded(child: Text(pickup.address?.isNotEmpty == true ? pickup.address! : t.riderNoAddress, style: TextStyle(fontSize: 11.5, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)), overflow: TextOverflow.ellipsis)),
          ]),
          if (pickup.scheduledTime != null) ...[
            const SizedBox(height: 6),
            Align(alignment: Alignment.centerLeft, child: CountdownTimer(expiry: pickup.scheduledTime!, fontSize: 9)),
          ],
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _advance(context),
                icon: Icon(pickup.status == PickupStatusModel.scheduled ? Icons.directions_car_outlined : Icons.navigation_outlined, size: 15),
                label: Text(actionLabel, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white, elevation: 0),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => showLiveTrackingMap(context, pickup.id),
              style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF2563EB), side: const BorderSide(color: Color(0xFF2563EB))),
              child: const Icon(Icons.map_outlined, size: 18),
            ),
          ]),
        ],
      ),
    );
  }
}
