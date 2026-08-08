import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/app_badge.dart';
import '../../widgets/ui/countdown_timer.dart';
import '../../models/models.dart';
import '../../providers/donor_provider.dart';

// Map-style screen showing nearby surplus food listings as pins on a
// stylised Dhaka map, plus a sortable list alongside it.
//
// Converted from StatelessWidget -> StatefulWidget so we can track which
// marker/restaurant the user has tapped and show its details.
class SurplusRadar extends StatefulWidget {
  const SurplusRadar({super.key});

  @override
  State<SurplusRadar> createState() => _SurplusRadarState();
}

class _SurplusRadarState extends State<SurplusRadar> {
  // The listing currently selected on the map (null = nothing selected yet).
  // Tapping a marker sets this; tapping the info card's close button, or
  // tapping the same marker again, clears it.
  Listing? _selectedListing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final listings = context.watch<DonorProvider>().listings.where((l) => l.pickupEnd.isAfter(now)).toList();
    // Sort listings by distance so the closest surplus food appears first
    // in the side list (falls back to 99 km if distance is missing).
    final sorted = [...listings]..sort((a, b) => (a.distance ?? 99).compareTo(b.distance ?? 99));

    return AppLayout(
      title: 'Surplus Radar',
      subtitle: 'Discover surplus food near you',
      currentRoute: '/consumer/radar',
      child: LayoutBuilder(builder: (context, constraints) {
        // Stack the map above the list on narrow (mobile-width) screens,
        // otherwise show them side by side.
        final isNarrow = constraints.maxWidth < 700;

        // Only the first 5 nearest listings get a pin on the map, to avoid
        // clutter; the full list is still shown in the sidebar.
        final mapListings = sorted.take(5).toList();

        // Fixed pin positions on the map canvas. Each of the up to 5 map
        // listings gets placed at one of these spots (cycled via modulo).
        const positions = [Offset(110, 220), Offset(220, 310), Offset(170, 140), Offset(260, 200), Offset(90, 320)];

        final map = Container(
          height: 500,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1C3252), Color(0xFF24406B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              // Stylised background map (roads, blocks, "Dhaka" label).
              Positioned.fill(child: CustomPaint(painter: _DhakaMapPainter())),

              // "Live Radar" pill badge, top-left.
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

              // Marker representing the current user's own position.
              Positioned(
                top: 140,
                left: 120,
                child: _LocationMarker(label: 'You'),
              ),

              // One tappable marker per nearby listing.
              ...mapListings.asMap().entries.map((e) {
                final index = e.key;
                final listing = e.value;
                final position = positions[index % positions.length];
                final isDonation = listing.listingType == ListingType.donation;
                final isSelected = _selectedListing?.id == listing.id;

                return Positioned(
                  left: position.dx,
                  top: position.dy,
                  child: GestureDetector(
                    // Tapping a marker selects it (showing the info card below)
                    // and tapping the already-selected marker deselects it.
                    onTap: () => setState(() {
                      _selectedListing = isSelected ? null : listing;
                    }),
                    child: Column(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDonation ? const Color(0xFF16A34A) : const Color(0xFFEA580C),
                          borderRadius: BorderRadius.circular(6),
                          // Selected markers get a white ring so they stand
                          // out from the rest while their info card is shown.
                          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))],
                        ),
                        child: Text(isDonation ? 'FREE' : '৳${listing.price.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      Container(width: 2, height: 8, color: isDonation ? const Color(0xFF16A34A) : const Color(0xFFEA580C)),
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                    ]),
                  ),
                );
              }),

              // Info card for whichever restaurant/listing is currently
              // selected — this is what lets the user "find" the restaurant
              // after tapping its marker.
              if (_selectedListing != null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: _RestaurantInfoCard(
                    listing: _selectedListing!,
                    onClose: () => setState(() => _selectedListing = null),
                  ),
                ),
            ],
          ),
        );

        final list = SizedBox(
          width: isNarrow ? double.infinity : 280,
          child: Column(
            children: [
              // "Nearest first" sort indicator (informational only for now).
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(10), border: Border.all(color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2))),
                child: Row(children: [
                  Icon(Icons.sort, size: 16, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
                  const SizedBox(width: 8),
                  Text('Nearest first', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF525252))),
                ]),
              ),
              const SizedBox(height: 12),
              // One card per listing; tapping it also selects it on the map,
              // so the list and the radar stay in sync either direction.
              ...sorted.map((l) {
                final isSelected = _selectedListing?.id == l.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _HoverScale(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _selectedListing = isSelected ? null : l;
                      }),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(16),
                          // Highlight the card that matches the selected marker.
                          border: isSelected ? Border.all(color: const Color(0xFF1D4ED8), width: 2) : null,
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14), offset: const Offset(0, 4), blurRadius: 0)],
                        ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Expanded(child: Text(l.title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? Colors.white : const Color(0xFF121212)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            AppBadge(label: l.listingType == ListingType.donation ? 'FREE' : '৳${l.price.toInt()}', variant: l.listingType == ListingType.donation ? BadgeVariant.green : BadgeVariant.orange),
                          ]),
                          const SizedBox(height: 6),
                          Text(l.donorName, style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
                          const SizedBox(height: 6),
                          Row(children: [
                            const Icon(Icons.location_on, size: 12, color: Color(0xFF757575)),
                            const SizedBox(width: 4),
                            Text('${l.distance} km away', style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
                          ]),
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: CountdownTimer(expiry: l.pickupEnd, fontSize: 9),
                          ),
                        ]),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );

        // Narrow screens: map on top, list below. Wide screens: side by side.
        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [map, const SizedBox(height: 20), list],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: map),
            const SizedBox(width: 20),
            list,
          ],
        );
      }),
    );
  }
}

// Small floating card shown over the map when a marker is tapped, so the
// user can see which restaurant/listing the pin belongs to without leaving
// the radar screen.
class _RestaurantInfoCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback onClose;
  const _RestaurantInfoCard({required this.listing, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDonation = listing.listingType == ListingType.donation;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.25), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          // Icon avatar, color-coded the same way as the badges elsewhere.
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDonation ? (isDark ? const Color(0xFF0D2818) : const Color(0xFFDCFCE7)) : (isDark ? const Color(0xFF2A1A0A) : const Color(0xFFFFE3CC)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.storefront_outlined, color: isDonation ? const Color(0xFF16A34A) : const Color(0xFFEA580C)),
          ),
          const SizedBox(width: 12),
          // Restaurant/listing details: title, donor name, and distance.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(listing.title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? Colors.white : const Color(0xFF121212)), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(listing.donorName, style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
                const SizedBox(height: 2),
                Row(children: [
                  const Icon(Icons.location_on, size: 11, color: Color(0xFF757575)),
                  const SizedBox(width: 3),
                  Text('${listing.distance} km away', style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
                ]),
                const SizedBox(height: 4),
                CountdownTimer(expiry: listing.pickupEnd, fontSize: 9),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Price/Free badge for a quick glance without reading the whole card.
          AppBadge(label: isDonation ? 'FREE' : '৳${listing.price.toInt()}', variant: isDonation ? BadgeVariant.green : BadgeVariant.orange),
          // Close button to dismiss the info card.
          IconButton(
            icon: Icon(Icons.close, size: 18, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF9CA3AF)),
            onPressed: onClose,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

// Small marker used for the "You" (current user) pin on the map.
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

// Hand-drawn stylised map background: a light blue canvas with a few roads,
// building blocks, and a "Dhaka" label. Purely decorative — no real geodata.
class _DhakaMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Base background color.
    final bg = Paint()..color = const Color(0xFFE0F2FE);
    canvas.drawRect(Offset.zero & size, bg);

    // A handful of straight lines standing in for roads.
    final roadPaint = Paint()
      ..color = const Color(0xFF93C5FD)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(40, 80), Offset(size.width - 50, 80), roadPaint);
    canvas.drawLine(const Offset(80, 40), Offset(80, size.height - 60), roadPaint);
    canvas.drawLine(const Offset(150, 140), Offset(size.width - 70, 140), roadPaint);
    canvas.drawLine(const Offset(220, 70), Offset(220, size.height - 90), roadPaint);
    canvas.drawLine(const Offset(50, 260), Offset(size.width - 90, 260), roadPaint);

    // Semi-transparent rectangles standing in for city blocks/buildings.
    final blockPaint = Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.45)..style = PaintingStyle.fill;
    final blocks = [Rect.fromLTWH(40, 100, 70, 70), Rect.fromLTWH(140, 180, 80, 70), Rect.fromLTWH(240, 100, 70, 80), Rect.fromLTWH(120, 300, 90, 60)];
    for (final block in blocks) {
      canvas.drawRect(block, blockPaint);
    }

    // "Dhaka" label in the top-left corner of the map.
    final textPainter = TextPainter(
      text: TextSpan(text: 'Dhaka', style: TextStyle(color: const Color(0xFF1E3A8A), fontSize: 26, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(24, 24));
  }

  // Static painting, so there's never a need to repaint.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Wraps a child widget with a subtle scale-up animation on hover (desktop/web)
// or press (touch), giving list cards a bit of tactile feedback.
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