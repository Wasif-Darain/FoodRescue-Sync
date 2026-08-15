import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/models.dart';

class DonorProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<QuerySnapshot>? _inventorySub;
  StreamSubscription<QuerySnapshot>? _listingsSub;

  List<InventoryItem> _inventory = [];
  List<Listing> _listings = [];
  bool _isLoading = true;

  List<InventoryItem> get inventory => List.unmodifiable(_inventory);
  List<Listing> get listings => List.unmodifiable(_listings);
  bool get isLoading => _isLoading;

  Stream<List<InventoryItem>> get inventoryStream {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);
    return _firestore
        .collection('inventory_items')
        .where('donorId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _inventoryItemFromDoc(doc))
            .toList());
  }

  Stream<List<Listing>> get listingsStream {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);
    return _firestore
        .collection('listings')
        .where('donorId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _listingFromDoc(doc))
            .toList());
  }

  DonorProvider() {
    _subscribe();
  }

  void _subscribe() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
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
      _listings = snapshot.docs
          .map((doc) => _listingFromDoc(doc))
          .toList();
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
    final start = data['pickupStart'];
    final end = data['pickupEnd'];
    return Listing(
      id: int.tryParse(doc.id) ?? 0,
      docId: doc.id,
      donorId: 0,
      donorName: data['donorName'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      listingType: data['listingType'] == 'flashSale'
          ? ListingType.flashSale
          : ListingType.donation,
      pickupStart: start is Timestamp ? start.toDate() : DateTime.now(),
      pickupEnd: end is Timestamp ? end.toDate() : DateTime.now(),
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
      status: ListingStatus.values.firstWhere(
        (e) => e.name == (data['status'] as String? ?? 'active'),
        orElse: () => ListingStatus.active,
      ),
      category: data['category'] as String? ?? '',
      imageUrl: (data['photoUrls'] as List?)?.isNotEmpty == true
          ? (data['photoUrls'] as List).first as String?
          : null,
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

  Future<void> updateListingPhotoUrls(String listingId, List<String> photoUrls) async {
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
  int _nextScheduledDonationId = 1;
  List<ScheduledDonation> get scheduledDonations =>
      List.unmodifiable(_scheduledDonations);

  int donationCountFor(String consumerName) =>
      mockDonationLogs.where((l) => l.recipientOrg == consumerName).length +
      _scheduledDonations
          .where(
            (d) =>
                d.consumerName == consumerName &&
                d.status != DonationScheduleStatus.cancelled,
          )
          .length;

  void donateToConsumer({
    required int consumerId,
    required String consumerName,
    required String itemName,
    required String category,
    required int quantity,
    required DateTime scheduledTime,
    required String location,
    String donorName = 'You',
  }) {
    final now = DateTime.now();
    _scheduledDonations.insert(
      0,
      ScheduledDonation(
        id: _nextScheduledDonationId++,
        consumerId: consumerId,
        consumerName: consumerName,
        donorName: donorName,
        itemName: itemName,
        category: category,
        quantity: quantity,
        scheduledTime: scheduledTime,
        location: location,
        status: DonationScheduleStatus.scheduled,
        createdAt: now,
        lastModifiedAt: now,
      ),
    );
    notifyListeners();
  }

  void _notifyConsumer(String message) {
    mockNotifications.insert(
      0,
      AppNotification(
        id: mockNotifications.length + 1,
        message: message,
        isRead: false,
        createdAt: DateTime.now(),
        type: NotificationType.pickup,
      ),
    );
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
    _scheduledDonations[i] = d.copyWith(
      scheduledTime: newTime,
      location: newLocation,
      lastModifiedAt: DateTime.now(),
    );
    _notifyConsumer(
      '${d.donorName} rescheduled your donation pickup to '
      '${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')} '
      'on ${newTime.day}/${newTime.month}/${newTime.year} at $newLocation.',
    );
    notifyListeners();
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
    _scheduledDonations[i] = d.copyWith(
      status: DonationScheduleStatus.cancelled,
      lastModifiedAt: DateTime.now(),
    );
    _notifyConsumer(
      '${d.donorName} cancelled the donation scheduled for '
      '${d.scheduledTime.day}/${d.scheduledTime.month}/${d.scheduledTime.year}.',
    );
    notifyListeners();
    return null;
  }

  String setAvailability(bool available) {
    _isAvailable = available;
    if (!available) {
      final now = DateTime.now();
      var cancelled = 0;
      var blocked = 0;
      for (var i = 0; i < _scheduledDonations.length; i++) {
        final d = _scheduledDonations[i];
        if (d.status != DonationScheduleStatus.scheduled) continue;
        if (d.scheduledTime.difference(now).inHours < 12) {
          blocked++;
          continue;
        }
        _scheduledDonations[i] = d.copyWith(
          status: DonationScheduleStatus.cancelled,
          lastModifiedAt: now,
        );
        _notifyConsumer(
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
    _inventorySub?.cancel();
    _listingsSub?.cancel();
    super.dispose();
  }
}