import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/app_badge.dart';
import '../../widgets/ui/countdown_timer.dart';
import '../../widgets/ui/location_picker.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/donor_provider.dart';

// Map-style screen showing nearby surplus food listings as pins on a real
// OpenStreetMap map (via flutter_map), plus a sortable list alongside it.
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

  // Real, road-following route from the consumer to the selected listing
  // (fetched from OSRM's free public routing API — no key required).
  List<LatLng>? _routePoints;
  double? _routeDistanceKm;
  double? _routeDurationMin;
  bool _routeLoading = false;
  int _routeToken = 0;

  void _selectListing(Listing? listing, LatLng from) {
    setState(() {
      _selectedListing = listing;
      _routePoints = null;
      _routeDistanceKm = null;
      _routeDurationMin = null;
    });
    if (listing != null) {
      _fetchRoute(from, LatLng(listing.latitude, listing.longitude));
    }
  }

  Future<void> _fetchRoute(LatLng from, LatLng to) async {
    final token = ++_routeToken;
    setState(() => _routeLoading = true);
    try {
      final uri = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${from.longitude},${from.latitude};${to.longitude},${to.latitude}'
        '?overview=full&geometries=geojson',
      );
      final response = await http.get(uri);
      if (!mounted || token != _routeToken) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final routes = data['routes'] as List?;
        if (routes != null && routes.isNotEmpty) {
          final route = routes.first as Map<String, dynamic>;
          final coords = (route['geometry']['coordinates'] as List)
              .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
              .toList();
          setState(() {
            _routePoints = coords;
            _routeDistanceKm = (route['distance'] as num) / 1000;
            _routeDurationMin = (route['duration'] as num) / 60;
          });
        }
      }
    } catch (_) {
      // No network / OSRM unreachable — silently fall back to markers-only
      // with the straight-line distance already shown via distanceFor().
    } finally {
      if (mounted && token == _routeToken) setState(() => _routeLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final listings = context.watch<DonorProvider>().allListings.where((l) => l.pickupEnd.isAfter(now)).toList();

    // Resolve the current consumer's own account so the "You" marker and
    // live distances are based on a real position when one has been set
    // (Profile > Edit Profile > Location), falling back to the old Dhaka
    // reference point otherwise.
    final user = context.watch<AuthProvider>().user!;
    final maxRadiusKm = context.watch<AuthProvider>().maxRadiusKm;
    final youLat = context.watch<AuthProvider>().latitude ?? 23.81;
    final youLng = context.watch<AuthProvider>().longitude ?? 90.41;
    final youPoint = LatLng(youLat, youLng);

    double distanceFor(Listing l) =>
        haversineKm(youLat, youLng, l.latitude, l.longitude);

    // Only listings inside the user's configured radar radius appear on
    // the map and in the side list.
    final sorted = listings.where((l) => distanceFor(l) <= maxRadiusKm).toList()
      ..sort((a, b) => distanceFor(a).compareTo(distanceFor(b)));

    return AppLayout(
      title: 'Surplus Radar',
      subtitle: 'Discover surplus food near you',
      currentRoute: '/consumer/radar',
      child: LayoutBuilder(builder: (context, constraints) {
        // Stack the map above the list on narrow (mobile-width) screens,
        // otherwise show them side by side.
        final isNarrow = constraints.maxWidth < 700;

        final map = Container(
          height: 500,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          child: Stack(
            children: [
              Positioned.fill(
                child: FlutterMap(
                  options: MapOptions(initialCenter: youPoint, initialZoom: 13),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.foodrescue.sync',
                    ),
                    RichAttributionWidget(
                      attributions: [TextSourceAttribution('OpenStreetMap contributors')],
                    ),
                    CircleLayer(circles: [
                      CircleMarker(
                        point: youPoint,
                        radius: maxRadiusKm * 1000,
                        useRadiusInMeter: true,
                        color: const Color(0xFF1D4ED8).withValues(alpha: 0.08),
                        borderColor: const Color(0xFF1D4ED8).withValues(alpha: 0.35),
                        borderStrokeWidth: 1.5,
                      ),
                    ]),
                    if (_routePoints != null)
                      PolylineLayer(polylines: [
                        Polyline(points: _routePoints!, strokeWidth: 4, color: const Color(0xFF1D4ED8)),
                      ]),
                    MarkerLayer(markers: [
                      Marker(point: youPoint, width: 60, height: 46, child: const _LocationMarker(label: 'You')),
                      ...sorted.map((listing) {
                        final isDonation = listing.listingType == ListingType.donation;
                        final isSelected = _selectedListing?.docId == listing.docId;
                        return Marker(
                          point: LatLng(listing.latitude, listing.longitude),
                          width: 72,
                          height: 46,
                          child: GestureDetector(
                            // Tapping a marker selects it (showing the info card
                            // below, plus a routed line from "You") and tapping
                            // the already-selected marker deselects it.
                            onTap: () => _selectListing(isSelected ? null : listing, youPoint),
                            child: Column(mainAxisSize: MainAxisSize.min, children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDonation ? const Color(0xFF16A34A) : const Color(0xFFEA580C),
                                  borderRadius: BorderRadius.circular(6),
                                  // Selected markers get a white ring so they
                                  // stand out from the rest while their info
                                  // card is shown.
                                  border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))],
                                ),
                                child: Text(isDonation ? 'FREE' : '৳${listing.price.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                              Container(width: 2, height: 6, color: isDonation ? const Color(0xFF16A34A) : const Color(0xFFEA580C)),
                              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                            ]),
                          ),
                        );
                      }),
                    ]),
                  ],
                ),
              ),

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
                    distanceKm: distanceFor(_selectedListing!),
                    routeDistanceKm: _routeDistanceKm,
                    routeDurationMin: _routeDurationMin,
                    routeLoading: _routeLoading,
                    onClose: () => _selectListing(null, youPoint),
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
                final isSelected = _selectedListing?.docId == l.docId;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _HoverScale(
                    child: GestureDetector(
                      onTap: () => _selectListing(isSelected ? null : l, youPoint),
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
                            Text('${distanceFor(l).toStringAsFixed(1)} km away', style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
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
  final double distanceKm;
  final double? routeDistanceKm;
  final double? routeDurationMin;
  final bool routeLoading;
  final VoidCallback onClose;
  const _RestaurantInfoCard({
    required this.listing,
    required this.distanceKm,
    this.routeDistanceKm,
    this.routeDurationMin,
    this.routeLoading = false,
    required this.onClose,
  });

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
                  Icon(routeDurationMin != null ? Icons.directions : Icons.location_on, size: 11, color: const Color(0xFF757575)),
                  const SizedBox(width: 3),
                  Text(
                    routeLoading
                        ? 'Finding route...'
                        : routeDurationMin != null
                            ? '${routeDistanceKm!.toStringAsFixed(1)} km · ${routeDurationMin!.round()} min drive'
                            : '${distanceKm.toStringAsFixed(1)} km away',
                    style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
                  ),
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
    return Column(mainAxisSize: MainAxisSize.min, children: [
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
