import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../../models/pickup.dart';
import '../../l10n/l10n_ext.dart';

/// Opens a full-screen live map for [pickupId]: pickup point, delivery
/// destination, and the rider's current position (once they've started),
/// with a road-following route between the rider and their next stop.
/// Used from the Rider Dashboard, the consumer's Pickup Coordination screen,
/// and the donor's Active Pickups section — everyone watches the same
/// `pickups/{pickupId}` document, so all three see the rider move live.
Future<void> showLiveTrackingMap(BuildContext context, String pickupId) {
  return Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => _LiveTrackingPage(pickupId: pickupId)),
  );
}

class _LiveTrackingPage extends StatefulWidget {
  final String pickupId;
  const _LiveTrackingPage({required this.pickupId});

  @override
  State<_LiveTrackingPage> createState() => _LiveTrackingPageState();
}

class _LiveTrackingPageState extends State<_LiveTrackingPage> {
  final _mapController = MapController();
  List<LatLng>? _routePoints;
  Timer? _routeTimer;
  LatLng? _lastRoutedFrom;
  LatLng? _lastRoutedTo;
  bool _autoFollow = true;

  @override
  void dispose() {
    _routeTimer?.cancel();
    super.dispose();
  }

  Future<void> _maybeFetchRoute(LatLng from, LatLng to) async {
    // Skip re-fetching if the rider hasn't moved meaningfully — keeps this
    // well within OSRM's free public demo server's usage policy.
    if (_lastRoutedFrom != null &&
        _lastRoutedTo == to &&
        const Distance().as(LengthUnit.Meter, _lastRoutedFrom!, from) < 40) {
      return;
    }
    _lastRoutedFrom = from;
    _lastRoutedTo = to;
    try {
      final uri = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${from.longitude},${from.latitude};${to.longitude},${to.latitude}'
        '?overview=full&geometries=geojson',
      );
      final response = await http.get(uri);
      if (!mounted || response.statusCode != 200) return;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final routes = data['routes'] as List?;
      if (routes == null || routes.isEmpty) return;
      final coords = ((routes.first as Map<String, dynamic>)['geometry']['coordinates'] as List)
          .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
          .toList();
      setState(() => _routePoints = coords);
    } catch (_) {
      // No network / OSRM unreachable — the pin positions alone are still
      // useful, so fail silently rather than interrupting live tracking.
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(t.trackingTitle)),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('pickups').doc(widget.pickupId).snapshots(),
        builder: (context, pickupSnap) {
          if (!pickupSnap.hasData || !pickupSnap.data!.exists) {
            return Center(child: Text(t.trackingNotFound));
          }
          final pickup = PickupModel.fromFirestore(pickupSnap.data!);
          final pickupPoint = LatLng(pickup.latitude, pickup.longitude);
          final riderPoint = (pickup.riderLat != null && pickup.riderLng != null)
              ? LatLng(pickup.riderLat!, pickup.riderLng!)
              : null;

          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: pickup.consumerId == null
                ? const Stream.empty()
                : FirebaseFirestore.instance.collection('users').doc(pickup.consumerId).snapshots(),
            builder: (context, consumerSnap) {
              final consumerData = consumerSnap.data?.data();
              final consumerLat = (consumerData?['latitude'] as num?)?.toDouble();
              final consumerLng = (consumerData?['longitude'] as num?)?.toDouble();
              final destPoint = (consumerLat != null && consumerLng != null) ? LatLng(consumerLat, consumerLng) : null;
              final consumerName = consumerData?['name'] as String? ?? '';

              // The pickup pin reads as "done" from the moment it's collected
              // onward, well past the pickedUp status itself.
              final pastPickup = pickup.status == PickupStatusModel.pickedUp ||
                  pickup.status == PickupStatusModel.delivered ||
                  pickup.status == PickupStatusModel.distributing ||
                  pickup.status == PickupStatusModel.completed;
              // Routing only makes sense while actively traveling toward a
              // fixed next stop: the donor's pickup point, then (for a
              // rider delivery) the consumer's address. Once delivered, the
              // consumer is off distributing to the community with no fixed
              // destination — same as a self-pickup always was — so there's
              // nothing left to draw a route to.
              final targetPoint = switch (pickup.status) {
                PickupStatusModel.scheduled || PickupStatusModel.enRoute => pickupPoint,
                PickupStatusModel.pickedUp => pickup.isSelfPickup ? null : destPoint,
                _ => null,
              };

              if (riderPoint != null && targetPoint != null) {
                _maybeFetchRoute(riderPoint, targetPoint);
              } else if (targetPoint == null && _routePoints != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => _routePoints = null);
                });
              }
              if (riderPoint != null && _autoFollow) {
                final target = riderPoint;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _mapController.move(target, _mapController.camera.zoom);
                });
              }

              final center = riderPoint ?? pickupPoint;

              return Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: center,
                            initialZoom: 14,
                            onPositionChanged: (pos, hasGesture) {
                              if (hasGesture) setState(() => _autoFollow = false);
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.foodrescue.sync',
                            ),
                            RichAttributionWidget(attributions: [TextSourceAttribution('OpenStreetMap contributors')]),
                            if (_routePoints != null)
                              PolylineLayer(polylines: [
                                Polyline(points: _routePoints!, strokeWidth: 4, color: const Color(0xFF2563EB)),
                              ]),
                            MarkerLayer(markers: [
                              Marker(
                                point: pickupPoint,
                                width: 70,
                                height: 46,
                                child: _PinLabel(
                                  icon: pastPickup ? Icons.check_circle : Icons.storefront,
                                  color: pastPickup ? const Color(0xFF9CA3AF) : const Color(0xFF16A34A),
                                  label: t.trackingPickupPin,
                                ),
                              ),
                              if (destPoint != null)
                                Marker(point: destPoint, width: 70, height: 46, child: _PinLabel(icon: Icons.flag, color: const Color(0xFFDC2626), label: t.trackingDeliveryPin)),
                              if (riderPoint != null)
                                Marker(point: riderPoint, width: 46, height: 46, child: const _RiderPin()),
                            ]),
                          ],
                        ),
                        if (!_autoFollow && riderPoint != null)
                          Positioned(
                            right: 16,
                            bottom: 16,
                            child: FloatingActionButton.small(
                              heroTag: 'recenter',
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF2563EB),
                              onPressed: () {
                                setState(() => _autoFollow = true);
                                _mapController.move(riderPoint, _mapController.camera.zoom);
                              },
                              child: const Icon(Icons.my_location),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, -2))],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pickup.listingTitle?.isNotEmpty == true ? pickup.listingTitle! : t.trackingTitle,
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF121212)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            riderPoint == null
                                ? (pickup.status == PickupStatusModel.delivered
                                    ? t.trackingWaitingForDistribution
                                    : (pickup.isSelfPickup ? t.trackingWaitingForSelf : t.trackingWaitingForRider))
                                : switch (pickup.status) {
                                    PickupStatusModel.delivered => t.trackingWaitingForDistribution,
                                    PickupStatusModel.distributing => t.navDistributing,
                                    PickupStatusModel.enRoute =>
                                      pickup.isSelfPickup ? t.trackingHeadingToPickupSelf : t.trackingHeadingToPickup,
                                    PickupStatusModel.pickedUp => pickup.isSelfPickup
                                        ? t.trackingEnRouteSelf
                                        : (consumerName.isNotEmpty ? t.trackingEnRouteTo(consumerName) : t.trackingEnRoute),
                                    _ => pickup.isSelfPickup ? t.trackingEnRouteSelf : t.trackingEnRoute,
                                  },
                            style: TextStyle(fontSize: 12.5, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
                          ),
                          if (pickup.riderLocationUpdatedAt != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              t.trackingLastUpdated(_relativeTime(pickup.riderLocationUpdatedAt!)),
                              style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return context.l10n.trackingSecondsAgo(diff.inSeconds);
    return context.l10n.trackingMinutesAgo(diff.inMinutes);
  }
}

class _PinLabel extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  const _PinLabel({required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))]),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ]),
      ),
      Container(width: 2, height: 6, color: color),
      Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
    ]);
  }
}

class _RiderPin extends StatelessWidget {
  const _RiderPin();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: const Icon(Icons.moped, color: Colors.white, size: 20),
    );
  }
}
