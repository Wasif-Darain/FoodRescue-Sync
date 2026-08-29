import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

class AdminProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<RegisteredAccount>> get accountsStream {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final role = data['role'] as String? ?? 'consumer';
        final (accountType, mode) = switch (role) {
          'donor' => (AccountType.restaurant, UserMode.donor),
          'rider' => (AccountType.rider, UserMode.rider),
          _ => (AccountType.ngo, UserMode.consumer),
        };
        return RegisteredAccount(
          id: 0,
          name: data['name'] as String? ?? '',
          email: data['email'] as String? ?? '',
          accountType: accountType,
          mode: mode,
          status: _statusFromString(data['status'] as String?),
          joinedAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          isAvailable: data['isAvailable'] as bool? ?? true,
          latitude: data['latitude'] as double?,
          longitude: data['longitude'] as double?,
          address: data['address'] as String?,
        );
      }).toList();
    });
  }

  AccountStatus _statusFromString(String? s) {
    switch (s) {
      case 'approved':
        return AccountStatus.approved;
      case 'suspended':
        return AccountStatus.suspended;
      default:
        return AccountStatus.pending;
    }
  }

  Future<void> setStatus(String email, AccountStatus status) async {
    final query = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return;
    await query.docs.first.reference.update({
      'status': status.name,
    });
  }

  Future<void> removeAccount(String email) async {
    final query = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return;
    await query.docs.first.reference.delete();
  }
}
