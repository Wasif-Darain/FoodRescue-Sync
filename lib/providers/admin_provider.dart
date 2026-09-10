import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../models/report.dart';
import '../models/review.dart';

class AdminProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Maximum time (in days) an account can stay pending without NID submission
  static const int pendingExpiryDays = 7;

  Stream<List<RegisteredAccount>> get accountsStream {
    return _firestore.collection('users').snapshots().map((snapshot) {
      final accounts = snapshot.docs.map((doc) => registeredAccountFromDoc(doc)).toList();
      // Auto-expire pending accounts without NID after the grace period
      for (final account in accounts) {
        _autoExpireIfStale(account);
      }
      return accounts;
    });
  }

  /// Flags accounts that have been pending for over [pendingExpiryDays] days
  /// without submitting NID photos as `expired` instead of deleting them, so
  /// admins can review and bring them back on track from the Expired tab.
  /// Called reactively by the accounts stream.
  Future<void> _autoExpireIfStale(RegisteredAccount account) async {
    if (account.status != AccountStatus.pending) return;
    final age = DateTime.now().difference(account.joinedAt);
    if (age.inDays > pendingExpiryDays && !account.hasSubmittedDocuments) {
      await setStatus(account.uid, AccountStatus.expired);
    }
  }

  /// Returns an expired account to the pending queue so the admin can review
  /// and approve it once the missing documents are provided.
  Future<void> reactivateAccount(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'status': AccountStatus.pending.name,
      'isVerified': false,
    });
  }

  /// Approves all existing accounts that are still pending. Used to bring
  /// pre-existing accounts into compliance with the new approval requirement.
  Future<void> approveAllExisting() async {
    final pending = await _firestore
        .collection('users')
        .where('status', isEqualTo: 'pending')
        .get();
    final batch = _firestore.batch();
    for (final doc in pending.docs) {
      batch.update(doc.reference, {'status': 'approved', 'isVerified': true});
    }
    await batch.commit();
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
    case 'expired':
      return AccountStatus.expired;
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
