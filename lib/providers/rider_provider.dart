import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/pickup.dart';
import '../services/push_notification_sender.dart';

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
  /// Pickups a rider cancelled after accepting (`priorityBoostedAt` set) are
  /// sorted first, ahead of never-claimed pickups.
  Stream<List<PickupModel>> get availablePickupsStream => _firestore
      .collection('pickups')
      .where('status', isEqualTo: PickupStatusModel.scheduled.name)
      .snapshots()
      .map(
        (snap) =>
            snap.docs
                .map((d) => PickupModel.fromFirestore(d))
                .where((p) => p.volunteerDriverId == null)
                .toList()
              ..sort((a, b) {
                final aBoost = a.priorityBoostedAt;
                final bBoost = b.priorityBoostedAt;
                if (aBoost != null && bBoost != null) return bBoost.compareTo(aBoost);
                if (aBoost != null) return -1;
                if (bBoost != null) return 1;
                return 0;
              }),
      );

  /// Pickups this rider has claimed or accepted, regardless of status.
  /// Excludes directly-assigned pickups the rider hasn't accepted yet —
  /// those live in [pendingAssignmentsStream] until acted on.
  Stream<List<PickupModel>> get myDeliveriesStream {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(const []);
    return _firestore
        .collection('pickups')
        .where('volunteerDriverId', isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.docs.map((d) => PickupModel.fromFirestore(d)).where((p) => !p.assignmentPending).toList());
  }

  /// Pickups a consumer directly assigned to this rider that are still
  /// awaiting the rider's accept/decline. Filters `assignmentPending`
  /// client-side (rather than as a second `where` clause) to avoid requiring
  /// a Firestore composite index, matching [availablePickupsStream]'s
  /// approach to the same problem.
  Stream<List<PickupModel>> get pendingAssignmentsStream {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(const []);
    return _firestore
        .collection('pickups')
        .where('volunteerDriverId', isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.docs.map((d) => PickupModel.fromFirestore(d)).where((p) => p.assignmentPending).toList());
  }

  /// Accepts a directly-assigned pickup — it moves from Assignment Requests
  /// into the rider's active deliveries.
  Future<void> acceptAssignment(String pickupId) async {
    await _firestore.collection('pickups').doc(pickupId).update({'assignmentPending': false});
  }

  /// Declines a directly-assigned pickup, returning it to the open pool for
  /// any rider to self-claim.
  Future<void> declineAssignment(String pickupId) async {
    final ref = _firestore.collection('pickups').doc(pickupId);
    final snap = await ref.get();
    final consumerId = snap.data()?['consumerId'] as String?;
    await ref.update({'volunteerDriverId': FieldValue.delete(), 'assignmentPending': false});
    if (consumerId != null && consumerId.isNotEmpty) {
      const declinedMessage = 'The rider declined your assignment — it was posted back to the open pool.';
      final notifRef = await _firestore.collection('notifications').add({
        'recipientUid': consumerId,
        'payloadType': 'pickup',
        'message': declinedMessage,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      unawaited(sendPushNotification(recipientUid: consumerId, message: declinedMessage, payloadType: 'pickup', notificationId: notifRef.id));
    }
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

  /// Cancels a pickup this rider already claimed/accepted (still `scheduled`
  /// or `enRoute`), requiring a [reason] so the consumer knows why. The
  /// pickup goes back to the open pool — `volunteerDriverId` cleared, status
  /// reset to `scheduled` — and is stamped with `priorityBoostedAt` so it
  /// jumps to the top of [availablePickupsStream] for other riders.
  Future<String?> cancelAcceptedPickup(String pickupId, String reason) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return 'Not signed in.';
    if (reason.trim().isEmpty) return 'Please provide a reason.';
    final ref = _firestore.collection('pickups').doc(pickupId);
    try {
      String? consumerId;
      await _firestore.runTransaction((tx) async {
        final snap = await tx.get(ref);
        if (!snap.exists) throw StateError('Pickup not found.');
        final data = snap.data() as Map<String, dynamic>;
        if (data['volunteerDriverId'] != uid) {
          throw StateError('Not your pickup.');
        }
        final status = data['status'] as String?;
        if (status != PickupStatusModel.scheduled.name && status != PickupStatusModel.enRoute.name) {
          throw StateError('This pickup can no longer be cancelled.');
        }
        consumerId = data['consumerId'] as String?;
        tx.update(ref, {
          'volunteerDriverId': FieldValue.delete(),
          'assignmentPending': false,
          'status': PickupStatusModel.scheduled.name,
          'cancellationReason': reason.trim(),
          'priorityBoostedAt': FieldValue.serverTimestamp(),
        });
      });
      stopTracking(pickupId);
      if (consumerId != null && consumerId!.isNotEmpty) {
        final cancelMessage = 'The rider cancelled your pickup (reason: ${reason.trim()}). It has been reposted for other riders.';
        final notifRef = await _firestore.collection('notifications').add({
          'recipientUid': consumerId,
          'payloadType': 'pickup',
          'message': cancelMessage,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
        unawaited(sendPushNotification(recipientUid: consumerId!, message: cancelMessage, payloadType: 'pickup', notificationId: notifRef.id));
      }
      return null;
    } catch (_) {
      return 'Could not cancel this pickup. Please try again.';
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
