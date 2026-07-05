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
            decoration: BoxDecoration(color: const Color(0xFF141416), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF262626))),
            child: Column(children: [
              _RequestHeader(),
              ...mockRequests.map((r) => _HoverScale(child: _RequestRow(request: r))),
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
    final (label, color, bg) = switch (status) {
      RequestStatus.pending   => ('Pending',   const Color(0xFFD97706), const Color(0xFF2A2410)),
      RequestStatus.accepted  => ('Accepted',  const Color(0xFF16A34A), const Color(0xFF0D2818)),
      RequestStatus.completed => ('Completed', const Color(0xFF2563EB), const Color(0xFF11223A)),
      RequestStatus.rejected  => ('Rejected',  const Color(0xFFEF4444), const Color(0xFF2A1414)),
    };
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Column(children: [
        Text('$count', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8), fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

class _RequestHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    decoration: const BoxDecoration(color: Color(0xFF0A0A0A), borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
    child: const Row(children: [
      Expanded(flex: 3, child: Text('Item', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF)))),
      Expanded(flex: 2, child: Text('Donor', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF)))),
      Expanded(child: Text('Qty', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF)))),
      Expanded(flex: 2, child: Text('Date', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF)))),
      Expanded(child: Text('Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF)))),
    ]),
  );
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF262626)))),
      child: Row(children: [
        Expanded(flex: 3, child: Text(request.listingTitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), maxLines: 2, overflow: TextOverflow.ellipsis)),
        Expanded(flex: 2, child: Text(request.donorName, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)))),
        Expanded(child: Text('×${request.quantity}', style: const TextStyle(fontSize: 13))),
        Expanded(flex: 2, child: Text(
          '${request.createdAt.year}-${request.createdAt.month.toString().padLeft(2, '0')}-${request.createdAt.day.toString().padLeft(2, '0')}',
          style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
        )),
        Expanded(child: Align(alignment: Alignment.centerLeft, child: AppBadge(label: label, variant: variant))),
      ]),
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
