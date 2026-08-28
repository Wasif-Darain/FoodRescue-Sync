import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/listing.dart';
import '../models/pickup.dart';
import '../models/request.dart';
import '../models/models.dart';

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
      _unattendedAfterHours =
          (data['unattendedAfterHours'] as num?)?.toInt() ?? 24;
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
            if (listing.claimDeadline != null &&
                listing.claimDeadline!.isBefore(now)) {
              continue;
            }
            final ageHours = now.difference(listing.createdAt).inHours;
            final distanceKm = (_latitude != null && _longitude != null)
                ? _haversineKm(
                    _latitude!,
                    _longitude!,
                    listing.latitude,
                    listing.longitude,
                  )
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

  Future<void> _notifyListing(
    String uid,
    String listingId,
    String message,
  ) async {
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

  Future<void> _notifyUser(
    String? recipientUid, {
    required String payloadType,
    String? listingId,
    required String message,
  }) async {
    if (recipientUid == null ||
        recipientUid.isEmpty ||
        recipientUid == _auth.currentUser?.uid) {
      return;
    }
    await _firestore.collection('notifications').add({
      'recipientUid': recipientUid,
      'payloadType': payloadType,
      'senderUid': _auth.currentUser?.uid ?? '',
      ...?(listingId != null ? {'listingId': listingId} : null),
      'message': message,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _degToRad(double deg) => deg * pi / 180;

  Stream<List<ListingModel>> get availableListingsStream {
    return _firestore
        .collection('listings')
        .where('status', isEqualTo: ListingStatusModel.active.name)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ListingModel.fromFirestore(doc))
              .where((l) => l.quantity > 0)
              .where(
                (l) =>
                    l.claimDeadline == null ||
                    l.claimDeadline!.isAfter(DateTime.now()),
              )
              .toList(),
        );
  }

  Stream<List<RequestModel>> get myRequestsStream {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);
    return _firestore
        .collection('requests')
        .where('consumerId', isEqualTo: uid)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => RequestModel.fromFirestore(doc))
                  .toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        );
  }

  Stream<List<ScheduledDonation>> get myDirectDonationsStream {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);
    return _firestore
        .collection('direct_donations')
        .where('consumerId', isEqualTo: uid)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            final scheduled = data['scheduledTime'];
            final created = data['createdAt'];
            return ScheduledDonation(
              id: doc.id.hashCode,
              docId: doc.id,
              consumerId: 0,
              consumerName: '',
              donorName: data['donorName'] as String? ?? '',
              itemName: data['itemName'] as String? ?? '',
              description: data['description'] as String? ?? '',
              category: data['category'] as String? ?? '',
              quantity: (data['quantity'] as num?)?.toInt() ?? 0,
              scheduledTime: scheduled is Timestamp
                  ? scheduled.toDate()
                  : DateTime.now(),
              location: data['location'] as String? ?? '',
              status: DonationScheduleStatus.values.firstWhere(
                (e) => e.name == (data['status'] as String? ?? 'scheduled'),
                orElse: () => DonationScheduleStatus.scheduled,
              ),
              createdAt: created is Timestamp
                  ? created.toDate()
                  : DateTime.now(),
              lastModifiedAt: DateTime.now(),
            );
          }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        );
  }

  Future<void> respondDirectDonation(String docId, bool accept) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final ref = _firestore.collection('direct_donations').doc(docId);
    final snap = await ref.get();
    if (!snap.exists) return;
    final data = snap.data() as Map<String, dynamic>;
    final donorId = data['donorId'] as String?;
    final itemName = data['itemName'] as String? ?? 'a donation';
    final location = data['location'] as String?;
    final scheduled = data['scheduledTime'];
    if (accept) {
      await ref.update({'status': 'accepted'});
      await _firestore.collection('pickups').add({
        'consumerId': uid,
        'requestId': '',
        'listingId': '',
        'isBulk': false,
        'directDonationId': docId,
        'donorName': data['donorName'] as String? ?? '',
        'listingTitle': itemName,
        'status': PickupStatusModel.scheduled.name,
        'scheduledTime': scheduled is Timestamp ? scheduled : null,
        'latitude': 0,
        'longitude': 0,
        'address': location,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await _notifyUser(
        donorId,
        payloadType: 'request',
        message: 'A consumer accepted your direct donation: $itemName.',
      );
    } else {
      await ref.update({'status': 'cancelled'});
      await _notifyUser(
        donorId,
        payloadType: 'request',
        message: 'A consumer rejected your direct donation: $itemName.',
      );
    }
  }

  Future<void> respondToRequest(String requestId, bool accept) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final ref = _firestore.collection('requests').doc(requestId);
    final snap = await ref.get();
    if (!snap.exists) return;
    final data = snap.data() as Map<String, dynamic>;
    await ref.update({
      'status': accept
          ? RequestStatusModel.accepted.name
          : RequestStatusModel.rejected.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    final listingId = data['listingId'] as String? ?? '';
    if (accept && listingId.isNotEmpty) {
      final listingSnap = await _firestore
          .collection('listings')
          .doc(listingId)
          .get();
      if (listingSnap.exists) {
        final listingData = listingSnap.data() as Map<String, dynamic>;
        await _firestore.collection('pickups').add({
          'consumerId': uid,
          'requestId': requestId,
          'listingId': listingId,
          'isBulk': false,
          'donorName': listingData['donorName'] as String? ?? '',
          'listingTitle': listingData['title'] as String? ?? '',
          'status': PickupStatusModel.scheduled.name,
          'scheduledTime': null,
          'latitude': (listingData['latitude'] as num?)?.toDouble() ?? 0,
          'longitude': (listingData['longitude'] as num?)?.toDouble() ?? 0,
          'address': listingData['address'] as String?,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      final donorId = listingSnap.data()?['donorId'] as String?;
      await _notifyUser(
        donorId,
        payloadType: 'request',
        message:
            'A consumer accepted the request for "${listingSnap.data()?['title'] ?? 'your listing'}".',
      );
    } else if (!accept && listingId.isNotEmpty) {
      final listingSnap = await _firestore
          .collection('listings')
          .doc(listingId)
          .get();
      final donorId = listingSnap.data()?['donorId'] as String?;
      await _notifyUser(
        donorId,
        payloadType: 'request',
        message:
            'A consumer rejected the request for "${listingSnap.data()?['title'] ?? 'your listing'}".',
      );
    }
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
      late final Map<String, dynamic> listingData;
      var claimed = false;
      await _firestore.runTransaction((transaction) async {
        final listingRef = _firestore.collection('listings').doc(listingId);
        final snapshot = await transaction.get(listingRef);
        if (!snapshot.exists) return;
        final data = snapshot.data() as Map<String, dynamic>;
        final currentStatus =
            data['status'] as String? ?? ListingStatusModel.active.name;
        if (currentStatus != ListingStatusModel.active.name) return;
        final currentQty = (data['quantity'] as num?)?.toDouble() ?? 0;
        if (currentQty < claimQuantity) return;
        claimed = true;
        listingData = data;
        final remaining = currentQty - claimQuantity;
        lat = (listingData['latitude'] as num?)?.toDouble() ?? 0;
        lng = (listingData['longitude'] as num?)?.toDouble() ?? 0;
        transaction.update(listingRef, {
          'quantity': remaining,
          'claimedBy': uid,
          'status': remaining <= 0
              ? ListingStatusModel.claimed.name
              : ListingStatusModel.active.name,
        });
      });
      if (!claimed) return false;
      final requestRef = await _firestore.collection('requests').add({
        'consumerId': uid,
        'listingId': listingId,
        'requestedQuantity': claimQuantity.toDouble(),
        'unit': listingData['unit'] as String? ?? 'kg',
        'isBulk': false,
        'status': RequestStatusModel.accepted.name,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await _firestore.collection('pickups').add({
        'consumerId': uid,
        'requestId': requestRef.id,
        'listingId': listingId,
        'isBulk': false,
        'quantity': claimQuantity,
        'donorName': listingData['donorName'] as String? ?? '',
        'listingTitle': listingData['title'] as String? ?? '',
        'status': PickupStatusModel.scheduled.name,
        'scheduledTime': scheduledTime == null
            ? null
            : Timestamp.fromDate(scheduledTime),
        'latitude': lat,
        'longitude': lng,
        'address': deliveryAddress,
        'createdAt': FieldValue.serverTimestamp(),
      });
      final donorId = listingData['donorId'] as String?;
      await _notifyUser(
        donorId,
        payloadType: 'request',
        message:
            'Your listing "${listingData['title'] ?? 'a listing'}" was claimed by a consumer.',
      );
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
        final listingId =
            pickupData['listingId'] as String? ??
            pickupData['requestId'] as String? ??
            '';
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
      await _notifyUser(
        donorId,
        payloadType: 'cancellation',
        listingId: pickupId,
        message:
            'A consumer cancelled their claim on "$listingTitle". The listing is available again.',
      );
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
    double? latitude,
    double? longitude,
    required DateTime requiredDate,
    required int peopleToFeed,
    required List<Map<String, String>> items,
    String? notes,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return 'Not signed in.';
    try {
      await _firestore.collection('requests').add({
        'isBulk': true,
        'consumerId': uid,
        'orgName': orgName,
        'contactPerson': contactPerson,
        'phone': phone,
        'address': address,
        'latitude': latitude ?? 0,
        'longitude': longitude ?? 0,
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
