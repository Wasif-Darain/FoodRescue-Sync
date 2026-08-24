import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../models/models.dart';
import '../../widgets/ui/app_badge.dart';
import '../../widgets/ui/rating_stars.dart';
import '../../widgets/ui/detail_sheet.dart';
import '../../models/request.dart';
import '../../providers/consumer_provider.dart';
import '../../providers/donor_provider.dart';
import '../../l10n/l10n_ext.dart';

class RequestStatusTracker extends StatelessWidget {
  const RequestStatusTracker({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final consumer = context.watch<ConsumerProvider>();

    return StreamBuilder<List<RequestModel>>(
      stream: consumer.myRequestsStream,
      builder: (context, snapshot) {
        final requests = snapshot.data ?? [];
        final t = context.l10n;

        return AppLayout(
          title: t.reqTrackerTitle,
          subtitle: t.reqTrackerSubtitle,
          currentRoute: '/consumer/requests',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DirectOffersSection(),
              const SizedBox(height: 20),
              IntrinsicHeight(
                child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  for (final s in [RequestStatusModel.pending, RequestStatusModel.accepted, RequestStatusModel.completed, RequestStatusModel.rejected]) ...[
                    if (s != RequestStatusModel.pending) const SizedBox(width: 12),
                    Expanded(child: _HoverScale(
                      child: _StatusSummary(
                        status: s,
                        count: requests.where((r) => r.status == s).length,
                      ),
                    )),
                  ],
                ]),
              ),
              const SizedBox(height: 20),
              if (requests.isEmpty)
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
                      Icon(Icons.assignment_outlined, size: 48, color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFBFBFBF)),
                      const SizedBox(height: 12),
                      Text(t.reqTrackerEmpty, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF121212))),
                      const SizedBox(height: 4),
                      Text(t.reqTrackerEmptyHint, style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
                    ],
                  ),
                ),
                )
              else
                Container(
                  decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14), offset: const Offset(0, 4), blurRadius: 0)],),
                  child: Column(children: [
                    for (final r in requests) _HoverScale(child: _RequestRow(request: r)),
                  ]),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DirectOffersSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final consumer = context.watch<ConsumerProvider>();
    return StreamBuilder<List<ScheduledDonation>>(
      stream: consumer.myDirectDonationsStream,
      builder: (context, snapshot) {
        final offers = (snapshot.data ?? [])
            .where((d) => d.status == DonationScheduleStatus.scheduled)
            .toList();
        if (offers.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Direct Donation Offers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF121212))),
            const SizedBox(height: 12),
            ...offers.map((d) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF16A34A), width: 1.5),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14), offset: const Offset(0, 4), blurRadius: 0)],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text('${d.itemName} · Qty ${d.quantity}', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF121212)))),
                    AppBadge(label: 'Offer', variant: BadgeVariant.green),
                  ]),
                  const SizedBox(height: 4),
                  Text('From ${d.donorName} · ${d.category}', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
                  if (d.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(d.description, style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.access_time, size: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
                    const SizedBox(width: 4),
                    Text('${d.scheduledTime.day}/${d.scheduledTime.month}/${d.scheduledTime.year} at ${d.scheduledTime.hour.toString().padLeft(2, '0')}:${d.scheduledTime.minute.toString().padLeft(2, '0')}', style: TextStyle(fontSize: 11.5, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
                  ]),
                  if (d.location.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(Icons.location_on_outlined, size: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
                      const SizedBox(width: 4),
                      Expanded(child: Text(d.location, style: TextStyle(fontSize: 11.5, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)), overflow: TextOverflow.ellipsis)),
                    ]),
                  ],
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => context.read<ConsumerProvider>().respondDirectDonation(d.docId!, true),
                        icon: const Icon(Icons.check, size: 15),
                        label: const Text('Accept', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white, elevation: 0),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => context.read<ConsumerProvider>().respondDirectDonation(d.docId!, false),
                        icon: const Icon(Icons.close, size: 15),
                        label: const Text('Reject', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, foregroundColor: const Color(0xFFDC2626), elevation: 0, side: const BorderSide(color: Color(0xFFDC2626))),
                      ),
                    ),
                  ]),
                ]),
              ),
            )),
          ],
        );
      },
    );
  }
}

class _StatusSummary extends StatelessWidget {
  final RequestStatusModel status;
  final int count;
  const _StatusSummary({required this.status, required this.count});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = context.l10n;
    final label = switch (status) {
      RequestStatusModel.pending   => t.reqStatusPending,
      RequestStatusModel.accepted  => t.reqStatusAccepted,
      RequestStatusModel.completed => t.reqStatusCompleted,
      RequestStatusModel.rejected  => t.reqStatusRejected,
    };
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14), offset: const Offset(0, 4), blurRadius: 0)],
      ),
      child: Column(children: [
        Text('$count', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF121212))),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575), fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

class _RequestRow extends StatelessWidget {
  final RequestModel request;
  const _RequestRow({required this.request});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kindLabel = request.isBulk ? 'Bulk Request' : 'Request';
    final allListings = context.watch<DonorProvider>().allListings;
    final matched = request.listingId.isEmpty
        ? null
        : allListings.where((l) => l.docId == request.listingId).firstOrNull;
    final donorInfo = matched == null ? '' : 'From ${matched.donorName} · ${matched.title}';
    final t = context.l10n;
    final (label, variant) = switch (request.status) {
      RequestStatusModel.pending   => (t.reqStatusPending,   BadgeVariant.orange),
      RequestStatusModel.accepted  => (t.reqStatusAccepted,  BadgeVariant.green),
      RequestStatusModel.completed => (t.reqStatusCompleted, BadgeVariant.blue),
      RequestStatusModel.rejected  => (t.reqStatusRejected,  BadgeVariant.red),
    };
    final date = '${request.createdAt.year}-${request.createdAt.month.toString().padLeft(2, '0')}-${request.createdAt.day.toString().padLeft(2, '0')}';
    return InkWell(
      onTap: () => showDetailSheet(
        context,
        title: '$kindLabel #${request.id}',
        subtitle: t.reqDetails,
        rows: [
          DetailRow(Icons.local_shipping_outlined, t.reqDetailStatus, label),
          DetailRow(Icons.inventory_2_outlined, t.reqDetailQuantity, '${request.requestedQuantity} ${request.unit}'),
          DetailRow(Icons.calendar_today_outlined, t.reqDetailCreated, date),
          if (request.updatedAt != null)
            DetailRow(Icons.update_outlined, t.reqDetailLastUpdated, '${request.updatedAt!.day}/${request.updatedAt!.month}/${request.updatedAt!.year}'),
        ],
      ),
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2)))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('$kindLabel #${request.id}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF121212)), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              AppBadge(label: label, variant: variant),
            ],
          ),
          if (donorInfo.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.storefront_outlined, size: 12, color: const Color(0xFF16A34A)),
              const SizedBox(width: 4),
              Expanded(child: Text(donorInfo, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF525252)), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
          ],
          const SizedBox(height: 4),
          Text(t.reqQtyDate('${request.requestedQuantity}', request.unit, date), style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)), maxLines: 1, overflow: TextOverflow.ellipsis),
          if (request.status == RequestStatusModel.pending) ...[
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.read<ConsumerProvider>().respondToRequest(request.id, true),
                  icon: const Icon(Icons.check, size: 15),
                  label: const Text('Accept', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white, elevation: 0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.read<ConsumerProvider>().respondToRequest(request.id, false),
                  icon: const Icon(Icons.close, size: 15),
                  label: const Text('Reject', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, foregroundColor: const Color(0xFFDC2626), elevation: 0, side: const BorderSide(color: Color(0xFFDC2626))),
                ),
              ),
            ]),
          ],
          if (request.status == RequestStatusModel.completed) ...[
            const SizedBox(height: 12),
            RatingStars(reviewLabel: t.reqRateThis),
          ],
        ],
      ),
      ),
    );
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