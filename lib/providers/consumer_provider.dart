import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/listing.dart';
import '../models/request.dart';
import '../models/models.dart';

class ConsumerProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<ListingModel>> get availableListingsStream {
    final now = Timestamp.now();
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

  Future<bool> claimListing(String listingId, int claimQuantity) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final listingRef = _firestore.collection('listings').doc(listingId);
        final snapshot = await transaction.get(listingRef);
        if (!snapshot.exists) return;
        final data = snapshot.data() as Map<String, dynamic>;
        final currentQty = (data['quantity'] as num?)?.toDouble() ?? 0;
        final remaining = currentQty - claimQuantity;
        transaction.update(listingRef, {
          'quantity': remaining,
          if (remaining <= 0) 'status': ListingStatusModel.claimed.name,
        });
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
}