import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../models/report.dart';
import '../models/review.dart';

class AdminProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<RegisteredAccount>> get accountsStream {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => registeredAccountFromDoc(doc)).toList();
    });
  }

  /// All reports ever filed, newest first — the admin-facing view of what
  /// `report_button.dart` writes.
  Stream<List<ReportModel>> get reportsStream {
    return _firestore
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ReportModel.fromFirestore).toList());
  }

  /// All reviews ever left, newest first.
  Stream<List<ReviewModel>> get reviewsStream {
    return _firestore
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ReviewModel.fromFirestore).toList());
  }

  Stream<List<ReportModel>> reportsFor(String uid) {
    return _firestore
        .collection('reports')
        .where('reportedUid', isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.docs.map(ReportModel.fromFirestore).toList());
  }

  Stream<List<ReviewModel>> reviewsFor(String uid) {
    return _firestore
        .collection('reviews')
        .where('targetUid', isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.docs.map(ReviewModel.fromFirestore).toList());
  }

  /// Approving is also how an account gets its verified tick — the admin
  /// is expected to have reviewed the submitted document/NID first (see
  /// [RegisteredAccount.hasSubmittedDocuments]).
  Future<void> approve(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'status': AccountStatus.approved.name,
      'isVerified': true,
    });
  }

  Future<void> setStatus(String uid, AccountStatus status) async {
    await _firestore.collection('users').doc(uid).update({
      'status': status.name,
      if (status != AccountStatus.approved) 'isVerified': false,
    });
  }

  Future<void> removeAccount(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }
}

AccountStatus statusFromString(String? s) {
  switch (s) {
    case 'approved':
      return AccountStatus.approved;
    case 'suspended':
      return AccountStatus.suspended;
    default:
      return AccountStatus.pending;
  }
}

RegisteredAccount registeredAccountFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data() ?? {};
  final role = data['role'] as String? ?? 'consumer';
  final storedType = data['accountType'] as String?;
  final (fallbackType, mode) = switch (role) {
    'donor' => (AccountType.restaurant, UserMode.donor),
    'rider' => (AccountType.rider, UserMode.rider),
    'admin' => (AccountType.individual, UserMode.admin),
    _ => (AccountType.individual, UserMode.consumer),
  };
  final accountType = storedType == null
      ? fallbackType
      : AccountType.values.firstWhere((t) => t.name == storedType, orElse: () => fallbackType);
  return RegisteredAccount(
    id: 0,
    uid: doc.id,
    name: data['name'] as String? ?? '',
    email: data['email'] as String? ?? '',
    accountType: accountType,
    mode: mode,
    status: statusFromString(data['status'] as String?),
    joinedAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    isAvailable: data['isAvailable'] as bool? ?? true,
    latitude: (data['latitude'] as num?)?.toDouble(),
    longitude: (data['longitude'] as num?)?.toDouble(),
    address: data['address'] as String?,
    phone: data['phone'] as String?,
    isVerified: data['isVerified'] as bool? ?? false,
    verificationDocUrl: data['verificationDocUrl'] as String?,
    nidFrontUrl: data['nidFrontUrl'] as String?,
    nidBackUrl: data['nidBackUrl'] as String?,
    reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
    rating: (data['reviewCount'] as num?) != null && (data['reviewCount'] as num).toInt() > 0
        ? ((data['ratingSum'] as num?)?.toDouble() ?? 0) / (data['reviewCount'] as num).toInt()
        : 0,
  );
}
