import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<User?>? _authSubscription;

  AppUser? _user;
  String? _errorMessage;
  bool _isLoading = false;
  double _maxRadiusKm = 10;
  int _unattendedAfterHours = 24;
  double? _latitude;
  double? _longitude;
  String? _address;
  String _phone = '';
  bool _notifNewListings = true;
  bool _notifRequests = true;
  bool _notifPickups = false;
  bool _notifPromotions = false;
  bool _privacyVisible = true;
  bool _privacyLoginAlerts = true;
  bool _privacyDataSharing = false;

  AppUser? get user => _user;
  String? get address => _address;
  double get maxRadiusKm => _maxRadiusKm;
  int get unattendedAfterHours => _unattendedAfterHours;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String get phone => _phone;
  bool get notifNewListings => _notifNewListings;
  bool get notifRequests => _notifRequests;
  bool get notifPickups => _notifPickups;
  bool get notifPromotions => _notifPromotions;
  bool get privacyVisible => _privacyVisible;
  bool get privacyLoginAlerts => _privacyLoginAlerts;
  bool get privacyDataSharing => _privacyDataSharing;
  bool get isAuthenticated => _user != null;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _authSubscription = _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? firebaseUser) {
    if (firebaseUser == null) {
      _user = null;
      notifyListeners();
      return;
    }
    _loadUserProfile(firebaseUser);
  }

  Future<void> _loadUserProfile(User firebaseUser) async {
    try {
      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final role = data['role'] as String? ?? 'consumer';
        _maxRadiusKm = (data['maxRadiusKm'] as num?)?.toDouble() ?? 10;
        _unattendedAfterHours = (data['unattendedAfterHours'] as num?)?.toInt() ?? 24;
        _latitude = (data['latitude'] as num?)?.toDouble();
        _longitude = (data['longitude'] as num?)?.toDouble();
        _address = data['address'] as String?;
        _phone = data['phone'] as String? ?? '';
        _notifNewListings = data['notifNewListings'] as bool? ?? true;
        _notifRequests = data['notifRequests'] as bool? ?? true;
        _notifPickups = data['notifPickups'] as bool? ?? false;
        _notifPromotions = data['notifPromotions'] as bool? ?? false;
        _privacyVisible = data['privacyVisible'] as bool? ?? true;
        _privacyLoginAlerts = data['privacyLoginAlerts'] as bool? ?? true;
        _privacyDataSharing = data['privacyDataSharing'] as bool? ?? false;
        _user = AppUser(
          id: 0,
          name: data['name'] as String? ?? firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? '',
          accountType: _accountTypeFromRole(role),
          mode: _modeFromRole(role),
        );
      } else {
        _user = AppUser(
          id: 0,
          name: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? '',
          accountType: AccountType.individual,
          mode: UserMode.consumer,
        );
      }
      notifyListeners();
    } catch (e) {
      _user = AppUser(
        id: 0,
        name: firebaseUser.displayName ?? 'User',
        email: firebaseUser.email ?? '',
        accountType: AccountType.individual,
        mode: UserMode.consumer,
      );
      notifyListeners();
    }
  }

  UserMode _modeFromRole(String role) {
    switch (role) {
      case 'admin':
        return UserMode.admin;
      case 'donor':
        return UserMode.donor;
      default:
        return UserMode.consumer;
    }
  }

  AccountType _accountTypeFromRole(String role) {
    switch (role) {
      case 'admin':
        return AccountType.individual;
      case 'donor':
        return AccountType.restaurant;
      default:
        return AccountType.ngo;
    }
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      _errorMessage = _authExceptionMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required AccountType accountType,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = userCredential.user!.uid;
      final role = accountType == AccountType.individual ? 'consumer' : 'donor';
      final orgId = _firestore.collection('organization_profiles').doc().id;

      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(uid);
        final orgRef = _firestore.collection('organization_profiles').doc(orgId);
        transaction.set(userRef, {
          'uid': uid,
          'email': email.trim(),
          'role': role,
          'name': name,
          'profileRef': orgRef,
        });
        transaction.set(orgRef, {
          'orgName': name,
          'address': address,
          'contactEmail': email.trim(),
          'contactPhone': phone,
          'isVerified': false,
        });
      });
    } on FirebaseAuthException catch (e) {
      debugPrint('signUp FirebaseAuthException: code=${e.code} message=${e.message}');
      _errorMessage = _authExceptionMessage(e);
    } catch (e) {
      debugPrint('signUp error: $e');
      _errorMessage = 'Something went wrong. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    _errorMessage = null;
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      debugPrint('sendPasswordResetEmail FirebaseAuthException: code=${e.code} message=${e.message}');
      _errorMessage = _authExceptionMessage(e);
    } catch (e) {
      debugPrint('sendPasswordResetEmail error: $e');
      _errorMessage = 'Something went wrong. Please try again.';
    }
    notifyListeners();
  }

  String _authExceptionMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password should be at least 8 characters and include a mix of uppercase, lowercase, numbers, and special characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  void logout() {
    signOut();
  }

  void toggleMode() {
    if (_user != null) {
      _user = _user!.copyWith(
        mode: _user!.mode == UserMode.donor
            ? UserMode.consumer
            : UserMode.donor,
      );
      notifyListeners();
    }
  }

  Future<void> updateMaxRadiusKm(double km) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return;
    final previous = _maxRadiusKm;
    _maxRadiusKm = km;
    notifyListeners();
    try {
      await _firestore.collection('users').doc(firebaseUser.uid).update({
        'maxRadiusKm': km,
      });
    } catch (_) {
      _maxRadiusKm = previous;
      notifyListeners();
    }
  }

  Future<void> updateUnattendedAfterHours(int hours) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return;
    final previous = _unattendedAfterHours;
    _unattendedAfterHours = hours;
    notifyListeners();
    try {
      await _firestore.collection('users').doc(firebaseUser.uid).update({
        'unattendedAfterHours': hours,
      });
    } catch (_) {
      _unattendedAfterHours = previous;
      notifyListeners();
    }
  }

  Future<void> updateOwnLocation({
    required double lat,
    required double lng,
    required String address,
  }) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return;
    try {
      _address = address;
      await _firestore.collection('users').doc(firebaseUser.uid).update({
        'latitude': lat,
        'longitude': lng,
        'address': address,
      });
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update location. Please try again.';
      notifyListeners();
    }
  }

  Future<void> _updateBoolField(String field, bool value, void Function(bool) apply, bool previous) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return;
    apply(value);
    notifyListeners();
    try {
      await _firestore.collection('users').doc(firebaseUser.uid).update({field: value});
    } catch (_) {
      apply(previous);
      notifyListeners();
    }
  }

  Future<void> updateNotifNewListings(bool value) =>
      _updateBoolField('notifNewListings', value, (v) => _notifNewListings = v, _notifNewListings);
  Future<void> updateNotifRequests(bool value) =>
      _updateBoolField('notifRequests', value, (v) => _notifRequests = v, _notifRequests);
  Future<void> updateNotifPickups(bool value) =>
      _updateBoolField('notifPickups', value, (v) => _notifPickups = v, _notifPickups);
  Future<void> updateNotifPromotions(bool value) =>
      _updateBoolField('notifPromotions', value, (v) => _notifPromotions = v, _notifPromotions);
  Future<void> updatePrivacyVisible(bool value) =>
      _updateBoolField('privacyVisible', value, (v) => _privacyVisible = v, _privacyVisible);
  Future<void> updatePrivacyLoginAlerts(bool value) =>
      _updateBoolField('privacyLoginAlerts', value, (v) => _privacyLoginAlerts = v, _privacyLoginAlerts);
  Future<void> updatePrivacyDataSharing(bool value) =>
      _updateBoolField('privacyDataSharing', value, (v) => _privacyDataSharing = v, _privacyDataSharing);

  Future<bool> updateProfile({required String name, required String phone}) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return false;
    try {
      await _firestore.collection('users').doc(firebaseUser.uid).update({
        'name': name,
        'phone': phone,
      });
      _phone = phone;
      if (_user != null) _user = _user!.copyWith(name: name);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null || firebaseUser.email == null) return false;
    _errorMessage = null;
    try {
      final credential = EmailAuthProvider.credential(
        email: firebaseUser.email!,
        password: currentPassword,
      );
      await firebaseUser.reauthenticateWithCredential(credential);
      await firebaseUser.updatePassword(newPassword);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _authExceptionMessage(e);
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}