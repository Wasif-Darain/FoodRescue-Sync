import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/listing.dart';
import '../models/pickup.dart';
import '../models/request.dart';

class ConsumerProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _listingSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userDocSub;

  double _maxRadiusKm = 10;
  int _unattendedAfterHours = 24;
  double? _latitude;
  double? _longitude;
  final Set<String> _notifiedListingIds = {};

  ConsumerProvider() {
    _authSub = _auth.authStateChanges().listen(_onAuthChanged);
  }

  void _onAuthChanged(User? user) {
    _listingSub?.cancel();
    _listingSub = null;
    _userDocSub?.cancel();
    _userDocSub = null;
    _latitude = null;
    _longitude = null;
    _maxRadiusKm = 10;
    _unattendedAfterHours = 24;
    _notifiedListingIds.clear();
    if (user == null) return;
    final userRef = _firestore.collection('users').doc(user.uid);
    _userDocSub = userRef.snapshots().listen((doc) {
      final data = doc.data();
      if (data == null) return;
      _latitude = (data['latitude'] as num?)?.toDouble();
      _longitude = (data['longitude'] as num?)?.toDouble();
      _maxRadiusKm = (data['maxRadiusKm'] as num?)?.toDouble() ?? 10;
      _unattendedAfterHours = (data['unattendedAfterHours'] as num?)?.toInt() ?? 24;
      final notified = data['notifiedListingIds'];
      if (notified is List) {
        _notifiedListingIds.addAll(notified.cast<String>());
      }
      _startListingWatch(user.uid);
    });
  }

  void _startListingWatch(String uid) {
    _listingSub ??= _firestore
        .collection('listings')
        .where('status', isEqualTo: ListingStatusModel.active.name)
        .snapshots()
        .listen((snapshot) {
      final now = DateTime.now();
      for (final doc in snapshot.docs) {
        final listing = ListingModel.fromFirestore(doc);
        if (_notifiedListingIds.contains(listing.id)) continue;
        if (listing.donorId == uid) continue;
        if (listing.claimDeadline != null && listing.claimDeadline!.isBefore(now)) {
          continue;
        }
        final ageHours = now.difference(listing.createdAt).inHours;
        final distanceKm = (_latitude != null && _longitude != null)
            ? _haversineKm(_latitude!, _longitude!, listing.latitude, listing.longitude)
            : null;

        String? message;
        if (distanceKm != null && distanceKm <= _maxRadiusKm) {
          message =
              'New listing "${listing.title}" is available ${distanceKm.toStringAsFixed(1)} km away from you.';
        } else if (ageHours >= _unattendedAfterHours) {
          message =
              'Listing "${listing.title}" has been unattended for over $_unattendedAfterHours hours and is still available.';
        }
        if (message != null) {
          _notifyListing(uid, listing.id, message);
        }
      }
    });
  }

  Future<void> _notifyListing(String uid, String listingId, String message) async {
    _notifiedListingIds.add(listingId);
    try {
      await _firestore.collection('notifications').add({
        'recipientUid': uid,
        'payloadType': 'listing',
        'listingId': listingId,
        'message': message,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await _firestore.collection('users').doc(uid).update({
        'notifiedListingIds': FieldValue.arrayUnion([listingId]),
      });
    } catch (_) {
      _notifiedListingIds.remove(listingId);
    }
  }

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) * cos(_degToRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _degToRad(double deg) => deg * pi / 180;

  Stream<List<ListingModel>> get availableListingsStream {
    return _firestore
        .collection('listings')
        .where('status', isEqualTo: ListingStatusModel.active.name)
        .where('quantity', isGreaterThan: 0)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ListingModel.fromFirestore(doc))
            .where((l) => l.claimDeadline == null || l.claimDeadline!.isAfter(DateTime.now()))
            .toList());
  }

  Stream<List<RequestModel>> get myRequestsStream {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);
    return _firestore
        .collection('requests')
        .where('consumerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RequestModel.fromFirestore(doc))
            .toList());
  }

  Future<bool> claimListing(
    String listingId,
    int claimQuantity, {
    DateTime? scheduledTime,
    String? deliveryAddress,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;
    try {
      late final double lat;
      late final double lng;
      var claimed = false;
      await _firestore.runTransaction((transaction) async {
        final listingRef = _firestore.collection('listings').doc(listingId);
        final snapshot = await transaction.get(listingRef);
        if (!snapshot.exists) return;
        final data = snapshot.data() as Map<String, dynamic>;
        final currentStatus = data['status'] as String? ?? ListingStatusModel.active.name;
        if (currentStatus != ListingStatusModel.active.name) return;
        final currentQty = (data['quantity'] as num?)?.toDouble() ?? 0;
        if (currentQty < claimQuantity) return;
        claimed = true;
        final remaining = currentQty - claimQuantity;
        lat = (data['latitude'] as num?)?.toDouble() ?? 0;
        lng = (data['longitude'] as num?)?.toDouble() ?? 0;
        transaction.update(listingRef, {
          'quantity': remaining,
          'claimedBy': uid,
          'status': remaining <= 0
              ? ListingStatusModel.claimed.name
              : ListingStatusModel.active.name,
        });
      });
      if (!claimed) return false;
      await _firestore.collection('pickups').add({
        'consumerId': uid,
        'requestId': listingId,
        'quantity': claimQuantity,
        'status': PickupStatusModel.scheduled.name,
        'scheduledTime': scheduledTime == null ? null : Timestamp.fromDate(scheduledTime),
        'latitude': lat,
        'longitude': lng,
        'address': deliveryAddress,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> cancelClaim(String pickupId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;
    try {
      String? donorId;
      String? listingTitle;
      await _firestore.runTransaction((transaction) async {
        final pickupRef = _firestore.collection('pickups').doc(pickupId);
        final pickupSnap = await transaction.get(pickupRef);
        if (!pickupSnap.exists) return;
        final pickupData = pickupSnap.data() as Map<String, dynamic>;
        if (pickupData['consumerId'] != uid) return;
        final status = pickupData['status'] as String?;
        if (status != PickupStatusModel.scheduled.name &&
            status != PickupStatusModel.enRoute.name) {
          return;
        }
        final listingId = pickupData['requestId'] as String? ?? '';
        final restoredQty = (pickupData['quantity'] as num?)?.toDouble() ?? 0;
        final listingRef = _firestore.collection('listings').doc(listingId);
        final listingSnap = await transaction.get(listingRef);
        transaction.update(pickupRef, {
          'status': PickupStatusModel.cancelled.name,
          'cancelledAt': FieldValue.serverTimestamp(),
        });
        if (!listingSnap.exists) return;
        final listingData = listingSnap.data() as Map<String, dynamic>;
        donorId = listingData['donorId'] as String?;
        listingTitle = listingData['title'] as String? ?? 'a listing';
        final currentQty = (listingData['quantity'] as num?)?.toDouble() ?? 0;
        transaction.update(listingRef, {
          'quantity': currentQty + restoredQty,
          'status': ListingStatusModel.active.name,
          'claimedBy': FieldValue.delete(),
        });
      });
      if (donorId == null) return false;
      await _firestore.collection('notifications').add({
        'recipientUid': donorId,
        'payloadType': 'cancellation',
        'listingId': pickupId,
        'message':
            'A consumer cancelled their claim on "$listingTitle". The listing is available again.',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<String?> submitBulkRequest({
    required String orgName,
    required String contactPerson,
    required String phone,
    required String address,
    required DateTime requiredDate,
    required int peopleToFeed,
    required List<Map<String, String>> items,
    String? notes,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return 'Not signed in.';
    try {
      await _firestore.collection('requests').add({
        'consumerId': uid,
        'orgName': orgName,
        'contactPerson': contactPerson,
        'phone': phone,
        'address': address,
        'requiredDate': Timestamp.fromDate(requiredDate),
        'peopleToFeed': peopleToFeed,
        'items': items,
        'notes': notes,
        'status': RequestStatusModel.pending.name,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (_) {
      return 'Failed to submit request.';
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _listingSub?.cancel();
    _userDocSub?.cancel();
    super.dispose();
  }
}