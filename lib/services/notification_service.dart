import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Top-level background message handler (must not be an instance method).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background pushes are delivered by the OS; nothing to persist here since
  // the Cloud Function already writes the notification document to Firestore.
  debugPrint('FCM background message: ${message.messageId}');
}

/// Wires up Firebase Cloud Messaging:
///  - requests notification permission,
///  - stores/refreshes each user's FCM token on their user document so the
///    backend can target them,
///  - exposes foreground messages as a stream for in-app banners.
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<User?>? _authSub;
  String? _currentToken;
  User? _currentUser;

  final _foregroundController = StreamController<RemoteMessage>.broadcast();
  /// Messages received while the app is in the foreground. The OS doesn't
  /// show these in the notification tray by itself, so the app needs to
  /// surface them (e.g. as an in-app banner) — see `main.dart`.
  Stream<RemoteMessage> get foregroundMessages => _foregroundController.stream;

  final _openedController = StreamController<RemoteMessage>.broadcast();
  /// Fires when the user taps a push notification — either one that
  /// resumed the app from the background, or (via [checkInitialMessage])
  /// one that launched the app fresh from a terminated state.
  Stream<RemoteMessage> get messageOpened => _openedController.stream;

  Future<void> initialize() async {
    // Register the background handler.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Ask the user for permission (needed on iOS / Android 13+).
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Foreground messages.
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('FCM foreground message: ${message.notification?.title}');
      _foregroundController.add(message);
    });

    // Tapping a notification that opened/resumed the app from the
    // background.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('FCM opened from notification: ${message.messageId}');
      _openedController.add(message);
    });

    // Keep the token fresh and bound to the signed-in user.
    _authSub = _auth.authStateChanges().listen(_onAuthChanged);
    _currentToken = await _messaging.getToken();
    _currentUser = _auth.currentUser;
    if (_currentUser != null && _currentToken != null) {
      await _saveToken(_currentUser!.uid, _currentToken!);
    }
    _messaging.onTokenRefresh.listen((token) async {
      final old = _currentToken;
      _currentToken = token;
      final uid = _auth.currentUser?.uid ?? _currentUser?.uid;
      if (uid == null) return;
      await _saveToken(uid, token);
      if (old != null && old != token) {
        try {
          await _firestore.collection('users').doc(uid).update({
            'fcmTokens': FieldValue.arrayRemove([old]),
          });
        } catch (_) {}
      }
    });
  }

  Future<void> _onAuthChanged(User? user) async {
    // Detach the previous user's token before switching accounts.
    if (_currentUser != null && _currentToken != null) {
      try {
        await _firestore.collection('users').doc(_currentUser!.uid).update({
          'fcmTokens': FieldValue.arrayRemove([_currentToken!]),
        });
      } catch (_) {}
    }
    _currentUser = user;
    if (user == null) return;
    _currentToken ??= await _messaging.getToken();
    if (_currentToken != null) {
      await _saveToken(user.uid, _currentToken!);
    }
  }

  Future<void> _saveToken(String uid, String token) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
      });
    } catch (_) {
      // The user doc may not exist yet — create it minimally.
      try {
        await _firestore.collection('users').doc(uid).set({
          'fcmTokens': [token],
        }, SetOptions(merge: true));
      } catch (_) {}
    }
  }

  /// Checks whether the app was launched by tapping a push notification
  /// while fully terminated, and if so, emits it on [messageOpened]. Call
  /// once after the widget tree (and its navigator) is ready.
  Future<void> checkInitialMessage() async {
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _openedController.add(initial);
  }

  void dispose() {
    _authSub?.cancel();
    _foregroundController.close();
    _openedController.close();
  }
}