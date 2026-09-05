import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/pickup.dart';

/// Backs the Rider dashboard: a pool of unclaimed pickups any rider can
/// self-claim, plus the current rider's own active/completed deliveries.
/// Also owns the live-location broadcast for pickups this rider has marked
/// "en route" — donors and consumers watch the same `pickups/{id}` document
/// to see the rider move on a map.
class RiderProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Map<String, StreamSubscription<Position>> _locationSubs = {};
  bool _permissionDenied = false;
  bool get permissionDenied => _permissionDenied;

  /// Scheduled pickups nobody has claimed yet. Filtered client-side for
  /// `volunteerDriverId == null` rather than in the query — pickups created
  /// before this feature existed never wrote that field at all, and
  /// Firestore's `isEqualTo: null` only matches docs where the field is
  /// present and null, not where it's missing.
  Stream<List<PickupModel>> get availablePickupsStream => _firestore
      .collection('pickups')
      .where('status', isEqualTo: PickupStatusModel.scheduled.name)
      .snapshots()
      .map(
        (snap) => snap.docs
            .map((d) => PickupModel.fromFirestore(d))
            .where((p) => p.volunteerDriverId == null)
            .toList(),
      );

  /// Pickups this rider has claimed, regardless of status.
  Stream<List<PickupModel>> get myDeliveriesStream {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(const []);
    return _firestore
        .collection('pickups')
        .where('volunteerDriverId', isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.docs.map((d) => PickupModel.fromFirestore(d)).toList());
  }

  /// Atomically claims [pickupId] for the current rider, failing if another
  /// rider claimed it first. Returns an error message, or null on success.
  Future<String?> claimPickup(String pickupId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return 'Not signed in.';
    final ref = _firestore.collection('pickups').doc(pickupId);
    try {
      await _firestore.runTransaction((tx) async {
        final snap = await tx.get(ref);
        if (!snap.exists) {
          throw StateError('This pickup no longer exists.');
        }
        final data = snap.data() as Map<String, dynamic>;
        if (data['volunteerDriverId'] != null) {
          throw StateError('Already claimed by another rider.');
        }
        tx.update(ref, {'volunteerDriverId': uid});
      });
      return null;
    } catch (_) {
      return 'Could not claim this pickup — it may have just been taken.';
    }
  }

  Future<void> markEnRoute(String pickupId) async {
    await _firestore.collection('pickups').doc(pickupId).update({'status': PickupStatusModel.enRoute.name});
    await startTracking(pickupId);
  }

  /// Rider has collected the order from the donor — the map should now
  /// route them to the delivery destination instead of the pickup point.
  /// Location broadcast keeps running unchanged.
  Future<void> markPickedUp(String pickupId) async {
    await _firestore.collection('pickups').doc(pickupId).update({'status': PickupStatusModel.pickedUp.name});
  }

  /// Rider has handed the order off to the consumer — the rider's own leg is
  /// done here. The consumer takes over from this point: they still need to
  /// distribute it to the community and mark that complete before the
  /// pickup is fully `completed`.
  Future<void> markCompleted(String pickupId) async {
    stopTracking(pickupId);
    await _firestore.collection('pickups').doc(pickupId).update({
      'status': PickupStatusModel.delivered.name,
    });
  }

  /// Makes sure every one of the rider's currently-`enRoute` deliveries has
  /// an active location broadcast, and stops any broadcast for a pickup
  /// that's no longer `enRoute` (completed/cancelled) or no longer theirs.
  /// Called from the dashboard on every `myDeliveriesStream` update so
  /// tracking resumes correctly after an app restart mid-delivery.
  void ensureTracking(List<PickupModel> myDeliveries) {
    final stillActive = myDeliveries
        .where((p) => p.status == PickupStatusModel.enRoute || p.status == PickupStatusModel.pickedUp)
        .map((p) => p.id)
        .toSet();
    for (final id in _locationSubs.keys.toList()) {
      if (!stillActive.contains(id)) stopTracking(id);
    }
    for (final id in stillActive) {
      if (!_locationSubs.containsKey(id)) startTracking(id);
    }
  }

  /// Begins streaming this device's GPS position into
  /// `pickups/{pickupId}.riderLat/riderLng` so anyone watching that document
  /// sees the rider move live. No-ops if already tracking, or if location
  /// permission isn't available.
  Future<void> startTracking(String pickupId) async {
    if (_locationSubs.containsKey(pickupId)) return;
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _permissionDenied = true;
        notifyListeners();
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        _permissionDenied = true;
        notifyListeners();
        return;
      }
      _permissionDenied = false;
      final ref = _firestore.collection('pickups').doc(pickupId);
      _locationSubs[pickupId] = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 15),
      ).listen((pos) {
        ref.update({
          'riderLat': pos.latitude,
          'riderLng': pos.longitude,
          'riderLocationUpdatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (_) {
      _permissionDenied = true;
      notifyListeners();
    }
  }

  void stopTracking(String pickupId) {
    _locationSubs.remove(pickupId)?.cancel();
  }

  @override
  void dispose() {
    for (final sub in _locationSubs.values) {
      sub.cancel();
    }
    _locationSubs.clear();
    super.dispose();
  }
}
