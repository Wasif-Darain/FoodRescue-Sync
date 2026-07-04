import 'package:flutter/material.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/app_badge.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';

class SurplusRadar extends StatelessWidget {
  const SurplusRadar({super.key});

  @override
  Widget build(BuildContext context) {
    final sorted = [...mockListings]..sort((a, b) => (a.distance ?? 99).compareTo(b.distance ?? 99));

    return AppLayout(
      title: 'Surplus Radar',
      subtitle: 'Discover surplus food near you',
      currentRoute: '/consumer/radar',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              height: 500,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1C3252), Color(0xFF24406B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Positioned.fill(child: CustomPaint(painter: _DhakaMapPainter())),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(999)),
                      child: Row(children: const [
                        Icon(Icons.waves, size: 16, color: Color(0xFF1D4ED8)),
                        SizedBox(width: 6),
                        Text('Live Radar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8))),
                      ]),
                    ),
                  ),
                  Positioned(
                    top: 140,
                    left: 120,
                    child: _LocationMarker(label: 'You'),
                  ),
                  ...sorted.take(5).toList().asMap().entries.map((e) {
                    final positions = [const Offset(110, 220), const Offset(220, 310), const Offset(170, 140), const Offset(260, 200), const Offset(90, 320)];
                    final position = positions[e.key % positions.length];
                    final isDonation = e.value.listingType == ListingType.donation;
                    return Positioned(
                      left: position.dx,
                      top: position.dy,
                      child: GestureDetector(
                        onTap: () {},
                        child: Column(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDonation ? const Color(0xFF16A34A) : const Color(0xFFEA580C),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))],
                            ),
                            child: Text(isDonation ? 'FREE' : '৳${e.value.price.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          Container(width: 2, height: 8, color: isDonation ? const Color(0xFF16A34A) : const Color(0xFFEA580C)),
                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                        ]),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            width: 280,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(color: const Color(0xFF141416), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF2E2E32))),
                  child: const Row(children: [
                    Icon(Icons.sort, size: 16, color: Color(0xFF9CA3AF)),
                    SizedBox(width: 8),
                    Text('Nearest first', style: TextStyle(fontSize: 12, color: Color(0xFFB0B3B8))),
                  ]),
                ),
                const SizedBox(height: 12),
                ...sorted.map((l) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _HoverScale(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: const Color(0xFF141416), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF262626))),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Expanded(child: Text(l.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          AppBadge(label: l.listingType == ListingType.donation ? 'FREE' : '৳${l.price.toInt()}', variant: l.listingType == ListingType.donation ? BadgeVariant.green : BadgeVariant.orange),
                        ]),
                        const SizedBox(height: 6),
                        Text(l.donorName, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                        const SizedBox(height: 6),
                        Row(children: [
                          const Icon(Icons.location_on, size: 12, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 4),
                          Text('${l.distance} km away', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                        ]),
                      ]),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationMarker extends StatelessWidget {
  final String label;
  const _LocationMarker({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: const Color(0xFF1D4ED8), borderRadius: BorderRadius.circular(999)),
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
      ),
      const SizedBox(height: 4),
      Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFF1D4ED8), shape: BoxShape.circle)),
    ]);
  }
}

class _DhakaMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFE0F2FE);
    canvas.drawRect(Offset.zero & size, bg);

    final roadPaint = Paint()
      ..color = const Color(0xFF93C5FD)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(40, 80), Offset(size.width - 50, 80), roadPaint);
    canvas.drawLine(const Offset(80, 40), Offset(80, size.height - 60), roadPaint);
    canvas.drawLine(const Offset(150, 140), Offset(size.width - 70, 140), roadPaint);
    canvas.drawLine(const Offset(220, 70), Offset(220, size.height - 90), roadPaint);
    canvas.drawLine(const Offset(50, 260), Offset(size.width - 90, 260), roadPaint);

    final blockPaint = Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.45)..style = PaintingStyle.fill;
    final blocks = [Rect.fromLTWH(40, 100, 70, 70), Rect.fromLTWH(140, 180, 80, 70), Rect.fromLTWH(240, 100, 70, 80), Rect.fromLTWH(120, 300, 90, 60)];
    for (final block in blocks) {
      canvas.drawRect(block, blockPaint);
    }

    final textPainter = TextPainter(
      text: TextSpan(text: 'Dhaka', style: TextStyle(color: const Color(0xFF1E3A8A), fontSize: 26, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(24, 24));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
