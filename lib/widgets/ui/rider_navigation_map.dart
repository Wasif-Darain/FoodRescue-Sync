import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../models/pickup.dart';
import '../../providers/consumer_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/rider_provider.dart';
import '../../l10n/l10n_ext.dart';
import '../../l10n/gen/app_localizations.dart';

/// Turn-by-turn driving mode for whoever is doing the trip: rotates the map
/// to their heading, shows the next maneuver with distance and a spoken
/// instruction, and re-fetches the route from OSRM as they move so it always
/// reflects the actual next turn from wherever they currently are — which
/// doubles as automatic rerouting if they miss a turn. Donors and consumers
/// keep watching the same passive [showLiveTrackingMap] overview; only the
/// person actually driving the trip needs active guidance.
///
/// [selfPickup] is true when a consumer is collecting their own claim
/// instead of a rider delivering it: navigation to the pickup point works
/// identically, but there's no fixed delivery address afterwards — once
/// picked up, the screen drops the route and just shows their live position
/// while they distribute it, ending in "Mark Distribution Complete" instead
/// of "Mark Delivered".
Future<void> showRiderNavigation(BuildContext context, String pickupId, {bool selfPickup = false}) {
  return Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => _RiderNavigationPage(pickupId: pickupId, selfPickup: selfPickup), fullscreenDialog: true),
  );
}

class _NavStep {
  final String type;
  final String? modifier;
  final String road;
  final LatLng location;
  final double distanceMeters;
  _NavStep({required this.type, required this.modifier, required this.road, required this.location, required this.distanceMeters});
}

class _RiderNavigationPage extends StatefulWidget {
  final String pickupId;
  final bool selfPickup;
  const _RiderNavigationPage({required this.pickupId, this.selfPickup = false});

  @override
  State<_RiderNavigationPage> createState() => _RiderNavigationPageState();
}

class _RiderNavigationPageState extends State<_RiderNavigationPage> {
  final _mapController = MapController();
  final _tts = FlutterTts();
  StreamSubscription<Position>? _positionSub;
  Position? _position;

  List<LatLng> _routePoints = [];
  List<_NavStep> _steps = [];
  double _remainingDistanceMeters = 0;
  double _remainingDurationSeconds = 0;
  bool _fetchingRoute = false;
  LatLng? _lastFetchedOrigin;
  LatLng? _lastFetchedTarget;

  bool _autoFollow = true;
  bool _muted = false;
  double _lastHeading = 0;
  String? _lastStepKey;
  bool _announcedNear = false;

  @override
  void initState() {
    super.initState();
    _configureTts();
    _listenPosition();
  }

  Future<void> _configureTts() async {
    await _tts.setSpeechRate(0.48);
    await _tts.awaitSpeakCompletion(true);
    if (!mounted) return;
    final languageCode = context.read<LocaleProvider>().locale.languageCode;
    final target = languageCode == 'bn' ? 'bn-BD' : 'en-US';
    try {
      final available = await _tts.isLanguageAvailable(target);
      await _tts.setLanguage(available == true ? target : 'en-US');
    } catch (_) {
      // Falls back to whatever the device's default TTS voice already is.
    }
  }

  void _listenPosition() {
    try {
      _positionSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5),
      ).listen((pos) {
        if (mounted) setState(() => _position = pos);
      });
    } catch (_) {
      // Permission was already confirmed on the dashboard before this screen
      // opens; if the stream still fails, the "waiting for GPS" state just
      // persists rather than crashing the navigation screen.
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _tts.stop();
    super.dispose();
  }

  Future<void> _fetchRoute(LatLng origin, LatLng target) async {
    if (_fetchingRoute) return;
    setState(() => _fetchingRoute = true);
    try {
      final uri = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${origin.longitude},${origin.latitude};${target.longitude},${target.latitude}'
        '?overview=full&geometries=geojson&steps=true',
      );
      final response = await http.get(uri);
      if (!mounted || response.statusCode != 200) return;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final routes = data['routes'] as List?;
      if (routes == null || routes.isEmpty) return;
      final route = routes.first as Map<String, dynamic>;
      final coords = ((route['geometry'] as Map<String, dynamic>)['coordinates'] as List)
          .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
          .toList();
      final steps = <_NavStep>[];
      for (final leg in (route['legs'] as List)) {
        for (final s in ((leg as Map<String, dynamic>)['steps'] as List)) {
          final step = s as Map<String, dynamic>;
          final maneuver = step['maneuver'] as Map<String, dynamic>;
          final loc = maneuver['location'] as List;
          steps.add(_NavStep(
            type: maneuver['type'] as String? ?? 'continue',
            modifier: maneuver['modifier'] as String?,
            road: step['name'] as String? ?? '',
            location: LatLng((loc[1] as num).toDouble(), (loc[0] as num).toDouble()),
            distanceMeters: (step['distance'] as num?)?.toDouble() ?? 0,
          ));
        }
      }
      if (!mounted) return;
      setState(() {
        _routePoints = coords;
        _steps = steps;
        _remainingDistanceMeters = (route['distance'] as num?)?.toDouble() ?? 0;
        _remainingDurationSeconds = (route['duration'] as num?)?.toDouble() ?? 0;
      });
    } catch (_) {
      // Offline / OSRM unreachable — keep the last known route rather than
      // interrupting navigation.
    } finally {
      if (mounted) setState(() => _fetchingRoute = false);
    }
  }

  /// Re-fetches the route whenever the destination changes (pickup ->
  /// delivery once the order is collected) or the rider has moved far enough
  /// that the old route no longer starts where they actually are — which is
  /// also what makes a missed turn "just work": the next fetch simply starts
  /// from wherever the rider ended up.
  void _maybeUpdateRoute(LatLng origin, LatLng target) {
    final targetIsNew = _lastFetchedTarget == null;
    final targetMoved = !targetIsNew && const Distance().as(LengthUnit.Meter, _lastFetchedTarget!, target) > 30;
    final originMoved = _lastFetchedOrigin != null && const Distance().as(LengthUnit.Meter, _lastFetchedOrigin!, origin) > 35;
    if (targetIsNew || targetMoved || originMoved) {
      _lastFetchedOrigin = origin;
      _lastFetchedTarget = target;
      _fetchRoute(origin, target);
    }
  }

  _NavStep? get _currentStep {
    if (_steps.isEmpty) return null;
    if (_steps.first.distanceMeters < 5 && _steps.length > 1) return _steps[1];
    return _steps.first;
  }

  void _maybeSpeak(_NavStep step, AppLocalizations t) {
    if (_muted) return;
    final key = '${step.type}_${step.modifier}_${step.road}';
    if (key != _lastStepKey) {
      _lastStepKey = key;
      _announcedNear = false;
      _speak('${t.navInDistance(_formatDistance(step.distanceMeters, t))}, ${_instructionText(step, t)}');
    } else if (!_announcedNear && step.type != 'arrive' && step.distanceMeters < 30) {
      _announcedNear = true;
      _speak(_instructionText(step, t));
    }
  }

  Future<void> _speak(String text) async {
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  void _updateCamera(LatLng point) {
    if (!_autoFollow) return;
    final speed = _position?.speed ?? 0;
    final heading = speed > 1 ? (_position?.heading ?? _lastHeading) : _lastHeading;
    _lastHeading = heading;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _mapController.moveAndRotate(point, _mapController.camera.zoom, -heading);
    });
  }

  String _formatDistance(double meters, AppLocalizations t) {
    if (meters >= 1000) return t.navDistanceKm((meters / 1000).toStringAsFixed(1));
    return t.navDistanceMeters(meters.round());
  }

  String _instructionText(_NavStep step, AppLocalizations t) {
    final road = step.road.isNotEmpty ? step.road : t.navUnnamedRoad;
    switch (step.type) {
      case 'arrive':
        return t.navArrive;
      case 'depart':
        return t.navDepart(road);
      case 'roundabout':
      case 'rotary':
        return t.navRoundabout(road);
      case 'merge':
        return t.navMerge(road);
      default:
        return switch (step.modifier) {
          'left' => t.navTurnLeft(road),
          'right' => t.navTurnRight(road),
          'slight left' => t.navTurnSlightLeft(road),
          'slight right' => t.navTurnSlightRight(road),
          'sharp left' => t.navTurnSharpLeft(road),
          'sharp right' => t.navTurnSharpRight(road),
          'uturn' => t.navUTurn,
          _ => t.navContinueStraight(road),
        };
    }
  }

  IconData _instructionIcon(_NavStep step) {
    if (step.type == 'arrive') return Icons.flag;
    if (step.type == 'roundabout' || step.type == 'rotary') return Icons.roundabout_left;
    return switch (step.modifier) {
      'left' => Icons.turn_left,
      'right' => Icons.turn_right,
      'slight left' => Icons.turn_slight_left,
      'slight right' => Icons.turn_slight_right,
      'sharp left' => Icons.turn_sharp_left,
      'sharp right' => Icons.turn_sharp_right,
      'uturn' => Icons.u_turn_left,
      _ => Icons.straight,
    };
  }

  String _formatEta(double seconds) {
    final eta = DateTime.now().add(Duration(seconds: seconds.round()));
    return '${eta.hour.toString().padLeft(2, '0')}:${eta.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = context.l10n;

    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('pickups').doc(widget.pickupId).snapshots(),
        builder: (context, pickupSnap) {
          if (!pickupSnap.hasData || !pickupSnap.data!.exists) {
            return Center(child: Text(t.trackingNotFound, style: const TextStyle(color: Colors.white)));
          }
          final pickup = PickupModel.fromFirestore(pickupSnap.data!);
          final pickupPoint = LatLng(pickup.latitude, pickup.longitude);

          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: pickup.consumerId == null
                ? const Stream.empty()
                : FirebaseFirestore.instance.collection('users').doc(pickup.consumerId).snapshots(),
            builder: (context, consumerSnap) {
              final consumerData = consumerSnap.data?.data();
              final consumerLat = (consumerData?['latitude'] as num?)?.toDouble();
              final consumerLng = (consumerData?['longitude'] as num?)?.toDouble();
              // A self-pickup consumer has no fixed delivery address — after
              // they pick up, they're off distributing to the community with
              // no destination to route to.
              final destPoint = widget.selfPickup
                  ? null
                  : (consumerLat != null && consumerLng != null ? LatLng(consumerLat, consumerLng) : null);

              final pickedUp = pickup.status == PickupStatusModel.pickedUp || pickup.status == PickupStatusModel.completed;
              final target = pickedUp ? destPoint : pickupPoint;
              final riderPoint = _position == null ? null : LatLng(_position!.latitude, _position!.longitude);

              if (riderPoint != null && target != null) {
                _maybeUpdateRoute(riderPoint, target);
                _updateCamera(riderPoint);
              }

              final step = target != null ? _currentStep : null;
              if (step != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _maybeSpeak(step, t);
                });
              }

              if (riderPoint == null) {
                return Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text(t.navWaitingForGps, style: const TextStyle(color: Colors.white)),
                  ]),
                );
              }

              return Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: riderPoint,
                      initialZoom: 17.5,
                      interactionOptions: const InteractionOptions(flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom),
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
                      if (_routePoints.isNotEmpty)
                        PolylineLayer(polylines: [Polyline(points: _routePoints, strokeWidth: 6, color: const Color(0xFF2563EB))]),
                      MarkerLayer(markers: [
                        Marker(
                          point: pickupPoint,
                          width: 60,
                          height: 40,
                          child: _MiniPin(icon: pickedUp ? Icons.check_circle : Icons.storefront, color: pickedUp ? const Color(0xFF9CA3AF) : const Color(0xFF16A34A)),
                        ),
                        if (destPoint != null) Marker(point: destPoint, width: 60, height: 40, child: const _MiniPin(icon: Icons.flag, color: Color(0xFFDC2626))),
                        Marker(point: riderPoint, width: 44, height: 44, child: const _HeadingChevron()),
                      ]),
                    ],
                  ),
                  if (step != null)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        bottom: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.fromLTRB(12, 12, 56, 0),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 4))]),
                              child: Row(children: [
                                Icon(_instructionIcon(step), color: Colors.white, size: 34),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (step.type != 'arrive')
                                        Text(_formatDistance(step.distanceMeters, t), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                      Text(
                                        _instructionText(step, t),
                                        style: TextStyle(color: Colors.white.withValues(alpha: 0.95), fontSize: step.type == 'arrive' ? 18 : 13, fontWeight: step.type == 'arrive' ? FontWeight.bold : FontWeight.normal),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ]),
                            ),
                            if (_fetchingRoute)
                              Container(
                                margin: const EdgeInsets.fromLTRB(24, 8, 68, 0),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(20)),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                                  const SizedBox(width: 8),
                                  Text(t.navRecalculating, style: const TextStyle(color: Colors.white, fontSize: 11.5)),
                                ]),
                              ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: _RoundIconButton(
                          icon: _muted ? Icons.volume_off : Icons.volume_up,
                          onTap: () => setState(() => _muted = !_muted),
                        ),
                      ),
                    ),
                  ),
                  if (!_autoFollow)
                    Positioned(
                      right: 16,
                      bottom: 156,
                      child: FloatingActionButton.small(
                        heroTag: 'nav-recenter',
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2563EB),
                        onPressed: () => setState(() => _autoFollow = true),
                        child: const Icon(Icons.navigation),
                      ),
                    ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SafeArea(
                      top: false,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                        decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, -2))]),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.selfPickup ? t.navToPickup : (pickedUp ? t.navToDelivery : t.navToPickup),
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF121212)),
                                ),
                                if (target != null && _remainingDurationSeconds > 0)
                                  Text(
                                    '${t.navMinLeft((_remainingDurationSeconds / 60).ceil())} · ${_formatDistance(_remainingDistanceMeters, t)} · ${t.navArriveEta(_formatEta(_remainingDurationSeconds))}',
                                    style: TextStyle(fontSize: 11.5, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFDC2626), side: const BorderSide(color: Color(0xFFDC2626)), padding: const EdgeInsets.symmetric(vertical: 14)),
                                  child: Text(t.navExit),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (widget.selfPickup) {
                                      // No destination to route to once the consumer has the
                                      // food in hand — the distribution leg itself is started
                                      // and completed from the Pickup Coordination screen.
                                      final consumer = context.read<ConsumerProvider>();
                                      await consumer.markSelfPickedUp(widget.pickupId);
                                      if (context.mounted) Navigator.of(context).pop();
                                    } else {
                                      final rider = context.read<RiderProvider>();
                                      if (pickup.status == PickupStatusModel.enRoute) {
                                        await rider.markPickedUp(widget.pickupId);
                                      } else if (pickup.status == PickupStatusModel.pickedUp) {
                                        await rider.markCompleted(widget.pickupId);
                                        if (context.mounted) Navigator.of(context).pop();
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14)),
                                  child: Text(
                                    widget.selfPickup
                                        ? t.riderMarkPickedUp
                                        : (pickup.status == PickupStatusModel.pickedUp ? t.riderMarkDelivered : t.riderMarkPickedUp),
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ]),
                          ],
                        ),
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
}

class _MiniPin extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _MiniPin({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2), boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2))]),
      padding: const EdgeInsets.all(6),
      child: Icon(icon, color: Colors.white, size: 16),
    );
  }
}

class _HeadingChevron extends StatelessWidget {
  const _HeadingChevron();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF2563EB), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 2))]),
      child: const Icon(Icons.navigation, color: Colors.white, size: 22),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(10), child: Icon(icon, color: const Color(0xFF2563EB), size: 20)),
      ),
    );
  }
}
