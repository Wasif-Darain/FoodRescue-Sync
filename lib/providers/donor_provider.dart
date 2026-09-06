import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/push_notification_sender.dart';

class DonorProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<QuerySnapshot>? _inventorySub;
  StreamSubscription<QuerySnapshot>? _listingsSub;
  StreamSubscription<QuerySnapshot>? _directDonationsSub;
  StreamSubscription<User?>? _authSub;

  List<InventoryItem> _inventory = [];
  List<Listing> _listings = [];
  List<Listing> _allListings = [];
  bool _isLoading = true;

  List<InventoryItem> get inventory => List.unmodifiable(_inventory);
  List<Listing> get listings => List.unmodifiable(_listings);
  List<Listing> get allListings => List.unmodifiable(_allListings);
  bool get isLoading => _isLoading;

  Stream<List<InventoryItem>> get inventoryStream {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);
    return _firestore
        .collection('inventory_items')
        .where('donorId', isEqualTo: uid)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => _inventoryItemFromDoc(doc)).toList(),
        );
  }

  Stream<List<Listing>> get listingsStream {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);
    return _firestore
        .collection('listings')
        .where('donorId', isEqualTo: uid)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => _listingFromDoc(doc)).toList(),
        );
  }

  DonorProvider() {
    _authSub = _auth.authStateChanges().listen((user) {
      _inventorySub?.cancel();
      _listingsSub?.cancel();
      _directDonationsSub?.cancel();
      _inventorySub = null;
      _listingsSub = null;
      _directDonationsSub = null;
      _inventory = [];
      _listings = [];
      _scheduledDonations.clear();
      notifyListeners();
      _subscribe();
    });
    _subscribeAllListings();
  }

  void _subscribeAllListings() {
    _firestore.collection('listings').snapshots().listen((snapshot) {
      _allListings = snapshot.docs.map(_listingFromDoc).toList();
      notifyListeners();
    });
  }

  void _subscribe() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    _subscribeDirectDonations(uid);
    _inventorySub = _firestore
        .collection('inventory_items')
        .where('donorId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
          _inventory = snapshot.docs
              .map((doc) => _inventoryItemFromDoc(doc))
              .toList();
          _isLoading = false;
          notifyListeners();
        });
    _listingsSub = _firestore
        .collection('listings')
        .where('donorId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
          _listings = snapshot.docs.map((doc) => _listingFromDoc(doc)).toList();
          notifyListeners();
        });
  }

  InventoryItem _inventoryItemFromDoc(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final exp = data['expiryDate'];
    return InventoryItem(
      id: int.tryParse(doc.id) ?? 0,
      docId: doc.id,
      name: data['name'] as String? ?? '',
      barcode: data['barcode'] as String?,
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      expiryDate: exp is Timestamp ? exp.toDate() : DateTime.now(),
      isSurplus: data['isSurplus'] as bool? ?? false,
      category: data['category'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
    );
  }

  Listing _listingFromDoc(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final created = data['createdAt'] is Timestamp
        ? (data['createdAt'] as Timestamp).toDate()
        : DateTime.now();
    final deadline = data['claimDeadline'];
    final end = deadline is Timestamp
        ? deadline.toDate()
        : created.add(const Duration(hours: 4));
    final photoUrls =
        (data['photoUrls'] as List?)?.cast<String>() ?? const <String>[];
    return Listing(
      id: int.tryParse(doc.id) ?? 0,
      docId: doc.id,
      donorId: 0,
      donorName:
          (data['donorName'] as String?) ?? (data['donorId'] as String?) ?? '',
      donorUid: data['donorId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      listingType: data['listingType'] == 'flashSale'
          ? ListingType.flashSale
          : ListingType.donation,
      pickupStart: created,
      pickupEnd: end,
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
      status: ListingStatus.values.firstWhere(
        (e) => e.name == (data['status'] as String? ?? 'active'),
        orElse: () => ListingStatus.active,
      ),
      category: data['category'] as String? ?? '',
      imageUrl: photoUrls.isNotEmpty ? photoUrls.first : null,
      imageCount: photoUrls.length,
      address: data['address'] as String?,
    );
  }

  Future<void> addInventoryItem({
    required String name,
    String? barcode,
    required int quantity,
    required DateTime expiryDate,
    required bool isSurplus,
    required String category,
    Uint8List? imageBytes,
    String donorName = 'You',
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore.collection('inventory_items').add({
      'donorId': uid,
      'name': name,
      'barcode': barcode,
      'quantity': quantity,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'isSurplus': isSurplus,
      'category': category,
      'imageUrl': null,
    });
  }

  Future<void> updateInventoryItem(
    String docId, {
    String? name,
    String? barcode,
    int? quantity,
    DateTime? expiryDate,
    bool? isSurplus,
    String? category,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (barcode != null) data['barcode'] = barcode;
    if (quantity != null) data['quantity'] = quantity;
    if (expiryDate != null) data['expiryDate'] = Timestamp.fromDate(expiryDate);
    if (isSurplus != null) data['isSurplus'] = isSurplus;
    if (category != null) data['category'] = category;
    await _firestore.collection('inventory_items').doc(docId).update(data);
  }

  Future<void> deleteInventoryItem(String docId) async {
    await _firestore.collection('inventory_items').doc(docId).delete();
  }

  Future<String?> createListing({
    required String title,
    required String description,
    required String category,
    required int quantity,
    required ListingType listingType,
    double price = 0,
    required DateTime pickupStart,
    required DateTime pickupEnd,
    List<String>? photoUrls,
    String donorName = 'You',
    double? latitude,
    double? longitude,
    String? address,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final docRef = await _firestore.collection('listings').add({
      'donorId': uid,
      'donorName': donorName,
      'title': title,
      'description': description,
      'price': price,
      'quantity': quantity,
      'listingType': listingType.name,
      'pickupStart': Timestamp.fromDate(pickupStart),
      'pickupEnd': Timestamp.fromDate(pickupEnd),
      'latitude': latitude ?? 23.81,
      'longitude': longitude ?? 90.41,
      'status': ListingStatus.active.name,
      'category': category,
      'photoUrls': photoUrls ?? [],
      'address': address,
    });
    return docRef.id;
  }

  Future<void> updateListingPhotoUrls(
    String listingId,
    List<String> photoUrls,
  ) async {
    await _firestore.collection('listings').doc(listingId).update({
      'photoUrls': photoUrls,
    });
  }

  Future<void> markListingClaimed(String listingId) async {
    await _firestore.collection('listings').doc(listingId).update({
      'status': ListingStatus.claimed.name,
    });
  }

  TimeOfDay _preferredPickupTime = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay get preferredPickupTime => _preferredPickupTime;
  void setPreferredPickupTime(TimeOfDay time) {
    _preferredPickupTime = time;
    notifyListeners();
  }

  bool _isAvailable = true;
  bool get isAvailable => _isAvailable;

  final List<ScheduledDonation> _scheduledDonations = [];
  List<ScheduledDonation> get scheduledDonations =>
      List.unmodifiable(_scheduledDonations);

  int donationCountFor(String consumerName) => _scheduledDonations
      .where(
        (d) =>
            d.consumerName == consumerName &&
            d.status != DonationScheduleStatus.cancelled,
      )
      .length;

  void _subscribeDirectDonations(String uid) {
    _directDonationsSub ??= _firestore
        .collection('direct_donations')
        .where('donorId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
          _scheduledDonations
            ..clear()
            ..addAll(
              snapshot.docs.map(_directDonationFromDoc).toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
            );
          notifyListeners();
        });
  }

  ScheduledDonation _directDonationFromDoc(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final scheduled = data['scheduledTime'];
    final created = data['createdAt'];
    return ScheduledDonation(
      id: doc.id.hashCode,
      docId: doc.id,
      consumerId: 0,
      consumerUid: data['consumerId'] as String? ?? '',
      consumerName: data['consumerName'] as String? ?? '',
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
      createdAt: created is Timestamp ? created.toDate() : DateTime.now(),
      lastModifiedAt: DateTime.now(),
    );
  }

  Future<void> donateToConsumer({
    required String consumerId,
    required String consumerName,
    required String itemName,
    required String category,
    required int quantity,
    required DateTime scheduledTime,
    required String location,
    String description = '',
    String donorName = 'You',
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore.collection('direct_donations').add({
      'donorId': uid,
      'donorName': donorName,
      'consumerId': consumerId,
      'consumerName': consumerName,
      'itemName': itemName,
      'description': description,
      'category': category,
      'quantity': quantity,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'location': location,
      'status': DonationScheduleStatus.scheduled.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _notifyConsumerUid(
      consumerId,
      '$donorName offered you a direct donation: $itemName. Open Requests to accept or reject it.',
    );
  }

  Future<void> _notifyConsumerUid(String? uid, String message) async {
    if (uid == null ||
        uid.isEmpty ||
        uid == '0' ||
        uid == _auth.currentUser?.uid) {
      return;
    }
    final ref = await _firestore.collection('notifications').add({
      'recipientUid': uid,
      'payloadType': 'pickup',
      'senderUid': _auth.currentUser?.uid ?? '',
      'message': message,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    unawaited(sendPushNotification(recipientUid: uid, message: message, payloadType: 'pickup', notificationId: ref.id));
  }

  String? rescheduleDonation(int id, DateTime newTime, String newLocation) {
    final i = _scheduledDonations.indexWhere((d) => d.id == id);
    if (i == -1) return 'Donation not found.';
    final d = _scheduledDonations[i];
    if (d.status != DonationScheduleStatus.scheduled) {
      return 'This donation can no longer be edited.';
    }
    if (d.scheduledTime.difference(DateTime.now()).inHours < 12) {
      return 'Changes must be made at least 12 hours before the scheduled pickup time.';
    }
    if (d.docId != null) {
      _firestore.collection('direct_donations').doc(d.docId).update({
        'scheduledTime': Timestamp.fromDate(newTime),
        'location': newLocation,
      });
    }
    _notifyConsumerUid(
      d.consumerId.toString() == '0' ? null : d.consumerId.toString(),
      '${d.donorName} rescheduled your donation pickup to '
      '${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')} '
      'on ${newTime.day}/${newTime.month}/${newTime.year} at $newLocation.',
    );
    return null;
  }

  String? cancelDonation(int id) {
    final i = _scheduledDonations.indexWhere((d) => d.id == id);
    if (i == -1) return 'Donation not found.';
    final d = _scheduledDonations[i];
    if (d.status != DonationScheduleStatus.scheduled) {
      return 'This donation can no longer be cancelled.';
    }
    if (d.scheduledTime.difference(DateTime.now()).inHours < 12) {
      return 'Cancellations must be made at least 12 hours before the scheduled pickup time.';
    }
    if (d.docId != null) {
      _firestore.collection('direct_donations').doc(d.docId).update({
        'status': DonationScheduleStatus.cancelled.name,
      });
    }
    _notifyConsumerUid(
      d.consumerId.toString() == '0' ? null : d.consumerId.toString(),
      '${d.donorName} cancelled the donation scheduled for '
      '${d.scheduledTime.day}/${d.scheduledTime.month}/${d.scheduledTime.year}.',
    );
    return null;
  }

  String setAvailability(bool available) {
    _isAvailable = available;
    if (!available) {
      final now = DateTime.now();
      var cancelled = 0;
      var blocked = 0;
      for (final d in _scheduledDonations) {
        if (d.status != DonationScheduleStatus.scheduled) continue;
        if (d.scheduledTime.difference(now).inHours < 12) {
          blocked++;
          continue;
        }
        if (d.docId != null) {
          _firestore.collection('direct_donations').doc(d.docId).update({
            'status': DonationScheduleStatus.cancelled.name,
          });
        }
        _notifyConsumerUid(
          d.consumerId.toString() == '0' ? null : d.consumerId.toString(),
          '${d.donorName} has marked themselves unavailable and cancelled '
          'the donation scheduled for '
          '${d.scheduledTime.day}/${d.scheduledTime.month}/${d.scheduledTime.year}.',
        );
        cancelled++;
      }
      notifyListeners();
      if (cancelled == 0 && blocked == 0) return 'Marked unavailable.';
      if (blocked > 0) {
        return 'Marked unavailable. $cancelled donation(s) cancelled and '
            'recipients notified. $blocked donation(s) starting within 12 '
            'hours could not be cancelled.';
      }
      return 'Marked unavailable. $cancelled donation(s) cancelled and '
          'recipients notified.';
    }
    notifyListeners();
    return 'You are now marked as available.';
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _inventorySub?.cancel();
    _listingsSub?.cancel();
    _directDonationsSub?.cancel();
    super.dispose();
  }
}
