import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

/// Sends a real OS-level push through a small Google Apps Script "relay"
/// web app, called right after a notification document is written to
/// Firestore. This project's Firebase plan has no billing enabled, which
/// Cloud Functions requires even for a single trigger — see
/// `functions/index.js` for the equivalent Cloud Function this stands in
/// for, ready to switch to once the project is on a paid plan. Apps Script
/// runs for free under the project owner's own Google account, with no
/// separate signup and no billing.
///
/// Every request carries the caller's Firebase ID token, which the script
/// verifies server-side (via the Identity Toolkit REST API) before sending
/// anything. This doesn't weaken the app's trust model — any signed-in
/// user can already write a notification doc addressed to anyone, per
/// firestore.rules — it only adds OS push delivery on top of a write that
/// was already allowed. No credential of any kind is embedded in the app;
/// the FCM-sending credential lives only inside the Apps Script project.
///
/// The deployed Apps Script Web App URL (ends in `/exec`) — see the
/// deployment steps in README.md. If this is ever reset to a
/// `REPLACE_`-prefixed placeholder (e.g. redeploying to a different Google
/// account), calls become a silent no-op so the app still works.
const String _pushRelayUrl =
    'https://script.google.com/macros/s/AKfycbzR-Z3WmO79RALuTO_iVY9aYKNUOK-HLJvCgGcEuzAkZpOki7_mIhs8LCgxswqBclQP-A/exec';

/// Fire-and-forget: failures here must never surface to the user or block
/// the caller — the Firestore notification document is the source of
/// truth or the in-app Notification Center; this is a best-effort extra.
Future<void> sendPushNotification({
  required String recipientUid,
  required String message,
  required String payloadType,
  String? notificationId,
}) async {
  if (_pushRelayUrl.startsWith('REPLACE_')) return;
  try {
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (idToken == null) return;
    var resp = await http
        .post(
          Uri.parse(_pushRelayUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'idToken': idToken,
            'recipientUid': recipientUid,
            'message': message,
            'payloadType': payloadType,
            'notificationId': notificationId,
          }),
        )
        .timeout(const Duration(seconds: 10));
    // Apps Script Web Apps respond to POST with a 302 to a
    // script.googleusercontent.com URL carrying the actual result — the
    // script has already run (including sending the push) by this point,
    // this is purely to fetch the response body. dart:io's HttpClient
    // doesn't auto-follow redirects for POST, so follow it manually.
    final location = resp.headers['location'];
    if (location != null) {
      resp = await http.get(Uri.parse(location)).timeout(const Duration(seconds: 10));
    }
  } catch (_) {}
}
