import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/pickup.dart';

/// Backs the Rider dashboard: a pool of unclaimed pickups any rider can
/// self-claim, plus the current rider's own active/completed deliveries.
class RiderProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  Future<void> markEnRoute(String pickupId) => _firestore
      .collection('pickups')
      .doc(pickupId)
      .update({'status': PickupStatusModel.enRoute.name});

  Future<void> markCompleted(String pickupId) => _firestore
      .collection('pickups')
      .doc(pickupId)
      .update({
        'status': PickupStatusModel.completed.name,
        'completedAt': FieldValue.serverTimestamp(),
      });
}
