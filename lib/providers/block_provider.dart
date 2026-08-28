import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class BlockProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userDocSub;
  StreamSubscription<User?>? _authSub;

  Set<String> _blockedUids = {};

  Set<String> get blockedUids => Set.unmodifiable(_blockedUids);

  BlockProvider() {
    _authSub = _auth.authStateChanges().listen(_onAuthChanged);
  }

  void _onAuthChanged(User? user) {
    _userDocSub?.cancel();
    _userDocSub = null;
    _blockedUids = {};
    notifyListeners();
    if (user == null) return;
    _userDocSub = _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((doc) {
          final data = doc.data();
          final blocked = data?['blockedUids'];
          _blockedUids = blocked is List
              ? blocked.whereType<String>().toSet()
              : <String>{};
          notifyListeners();
        });
  }

  bool isBlocked(String? uid) =>
      uid != null && uid.isNotEmpty && _blockedUids.contains(uid);

  Future<void> toggleBlock(String uid) async {
    final me = _auth.currentUser?.uid;
    if (me == null || uid.isEmpty || uid == me) return;
    final currentlyBlocked = _blockedUids.contains(uid);
    await _firestore.collection('users').doc(me).update({
      'blockedUids': currentlyBlocked
          ? FieldValue.arrayRemove([uid])
          : FieldValue.arrayUnion([uid]),
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _userDocSub?.cancel();
    super.dispose();
  }
}
