/**
 * FoodRescue-Sync push relay.
 *
 * Paste this into a new Google Apps Script project (script.google.com) and
 * deploy it as a Web App. The Flutter app calls the deployed URL right
 * after writing a notification document to Firestore, so it gets a real
 * FCM push immediately — this project's Firebase plan has no billing
 * enabled, which Cloud Functions requires even for a single trigger (see
 * functions/index.js for the equivalent Cloud Function to switch to once
 * the project moves to a paid plan). Apps Script runs for free under your
 * own Google account, no separate signup and no billing.
 *
 * Setup: see README.md "Push Notifications" section.
 */

const FIREBASE_PROJECT_ID = 'foodrescue-sync';
// Any of the project's Firebase API keys works here — these identify the
// project for client SDK calls and are not secret (they're already public,
// shipped inside the app in firebase_options.dart / google-services.json).
// Access is governed by Firestore/Auth rules, not by keeping this key
// hidden.
const FIREBASE_WEB_API_KEY = 'AIzaSyC8fJXkfjEJfYUPh-ZOE5rlvqSTEEs9qfs';

const NOTIFICATION_TITLES = {
  listing: 'New listing nearby',
  request: 'Request update',
  pickup: 'Pickup update',
  cancellation: 'Cancellation',
  system: 'FoodRescue Sync',
};

/**
 * Run this once from the Apps Script editor (select it in the function
 * dropdown next to the Run button, then click Run) BEFORE deploying. It
 * forces the full OAuth consent screen for all three scopes this script
 * needs — deploying alone doesn't always trigger that prompt reliably, and
 * an unauthorized script fails every request with a generic "couldn't
 * open this file" error instead of a real error message.
 */
function testAuthorization() {
  // Fetching google.com doesn't need any special scope, so it succeeding
  // proves nothing about the Firestore/FCM permissions this script
  // actually needs — call Firestore directly instead, which requires the
  // `datastore` scope to return anything but 401/403.
  var url = 'https://firestore.googleapis.com/v1/projects/' + FIREBASE_PROJECT_ID + '/databases/(default)/documents/users';
  var resp = UrlFetchApp.fetch(url, {
    headers: { Authorization: 'Bearer ' + ScriptApp.getOAuthToken() },
    muteHttpExceptions: true,
  });
  Logger.log('Firestore status: ' + resp.getResponseCode());
  Logger.log('Firestore body: ' + resp.getContentText().substring(0, 500));
}

function doPost(e) {
  var result;
  try {
    var body = JSON.parse(e.postData.contents);
    var idToken = body.idToken;
    var recipientUid = body.recipientUid;
    var message = body.message;
    var payloadType = body.payloadType;
    var notificationId = body.notificationId;

    if (!idToken || !recipientUid || !message) {
      result = { error: 'Missing required fields.' };
    } else if (!verifyIdToken(idToken)) {
      // Every request must come from a signed-in Firebase user. This
      // mirrors the app's existing trust model — any signed-in user can
      // already write a notification doc addressed to anyone, per
      // firestore.rules — so this only adds push delivery on top of a
      // write that was already allowed.
      result = { error: 'Invalid auth token.' };
    } else {
      var tokens = getFcmTokens(recipientUid);
      var title = NOTIFICATION_TITLES[payloadType] || NOTIFICATION_TITLES.system;
      var sent = 0;
      for (var i = 0; i < tokens.length; i++) {
        var ok = sendFcmMessage(tokens[i], title, message, {
          notificationId: notificationId || '',
          payloadType: payloadType || 'system',
        });
        if (ok) sent++;
      }
      result = { ok: true, sent: sent };
    }
  } catch (err) {
    result = { error: String(err) };
  }
  return ContentService.createTextOutput(JSON.stringify(result)).setMimeType(ContentService.MimeType.JSON);
}

/** Verifies a Firebase Auth ID token via the Identity Toolkit REST API. */
function verifyIdToken(idToken) {
  var url = 'https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=' + FIREBASE_WEB_API_KEY;
  var resp = UrlFetchApp.fetch(url, {
    method: 'post',
    contentType: 'application/json',
    payload: JSON.stringify({ idToken: idToken }),
    muteHttpExceptions: true,
  });
  if (resp.getResponseCode() !== 200) return false;
  var data = JSON.parse(resp.getContentText());
  return !!(data.users && data.users.length > 0);
}

/**
 * Reads `users/{uid}.fcmTokens` via the Firestore REST API, authenticated
 * with the script owner's own OAuth token (scoped via appsscript.json) —
 * this bypasses Firestore Security Rules the same way the Admin SDK would,
 * since it's an IAM-authenticated call, not a Firebase Auth client call.
 */
function getFcmTokens(uid) {
  var url = 'https://firestore.googleapis.com/v1/projects/' + FIREBASE_PROJECT_ID + '/databases/(default)/documents/users/' + uid;
  var resp = UrlFetchApp.fetch(url, {
    method: 'get',
    headers: { Authorization: 'Bearer ' + ScriptApp.getOAuthToken() },
    muteHttpExceptions: true,
  });
  if (resp.getResponseCode() !== 200) return [];
  var doc = JSON.parse(resp.getContentText());
  var arrayValue = doc.fields && doc.fields.fcmTokens && doc.fields.fcmTokens.arrayValue;
  var values = (arrayValue && arrayValue.values) || [];
  var tokens = [];
  for (var i = 0; i < values.length; i++) {
    if (values[i].stringValue) tokens.push(values[i].stringValue);
  }
  return tokens;
}

/** Sends one FCM v1 push, authenticated the same way as getFcmTokens. */
function sendFcmMessage(token, title, body, data) {
  var url = 'https://fcm.googleapis.com/v1/projects/' + FIREBASE_PROJECT_ID + '/messages:send';
  var resp = UrlFetchApp.fetch(url, {
    method: 'post',
    contentType: 'application/json',
    headers: { Authorization: 'Bearer ' + ScriptApp.getOAuthToken() },
    payload: JSON.stringify({
      message: {
        token: token,
        notification: { title: title, body: body },
        data: data,
      },
    }),
    muteHttpExceptions: true,
  });
  return resp.getResponseCode() === 200;
}
