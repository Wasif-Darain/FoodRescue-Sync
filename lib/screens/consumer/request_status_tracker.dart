import 'package:flutter/material.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/app_badge.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';

class RequestStatusTracker extends StatelessWidget {
  const RequestStatusTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'My Requests',
      subtitle: 'Track the status of your food requests',
      currentRoute: '/consumer/requests',
      child: Column(
        children: [
          Row(children: [
            for (final s in [RequestStatus.pending, RequestStatus.accepted, RequestStatus.completed, RequestStatus.rejected]) ...[
              if (s != RequestStatus.pending) const SizedBox(width: 12),
              Expanded(child: _HoverScale(
                child: _StatusSummary(
                  status: s,
                  count: mockRequests.where((r) => r.status == s).length,
                ),
              )),
            ],
          ]),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.14), offset: const Offset(0, 4), blurRadius: 0)],),
            child: Column(children: [
              for (final r in mockRequests) _HoverScale(child: _RequestRow(request: r)),
            ]),
          ),
        ],
      ),
    );
  }
}

class _StatusSummary extends StatelessWidget {
  final RequestStatus status;
  final int count;
  const _StatusSummary({required this.status, required this.count});

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      RequestStatus.pending   => 'Pending',
      RequestStatus.accepted  => 'Accepted',
      RequestStatus.completed => 'Completed',
      RequestStatus.rejected  => 'Rejected',
    };
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.14), offset: const Offset(0, 4), blurRadius: 0)],
      ),
      child: Column(children: [
        Text('$count', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF121212))),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF757575), fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

class _RequestRow extends StatelessWidget {
  final FoodRequest request;
  const _RequestRow({required this.request});

  @override
  Widget build(BuildContext context) {
    final (label, variant) = switch (request.status) {
      RequestStatus.pending   => ('Pending',   BadgeVariant.orange),
      RequestStatus.accepted  => ('Accepted',  BadgeVariant.green),
      RequestStatus.completed => ('Completed', BadgeVariant.blue),
      RequestStatus.rejected  => ('Rejected',  BadgeVariant.red),
    };
    final date = '${request.createdAt.year}-${request.createdAt.month.toString().padLeft(2, '0')}-${request.createdAt.day.toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFE2E2E2)))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(request.listingTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF121212)), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              AppBadge(label: label, variant: variant),
            ],
          ),
          const SizedBox(height: 4),
          Text('${request.donorName} · ×${request.quantity} · $date', style: const TextStyle(fontSize: 12, color: Color(0xFF757575)), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
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
