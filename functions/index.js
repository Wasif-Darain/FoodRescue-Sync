/**
 * Cloud Functions for FoodRescue-Sync.
 *
 * Whenever a document is added to the `notifications` collection, this
 * function sends an FCM push to all of the recipient's registered device
 * tokens (users/{uid}.fcmTokens).
 *
 * Deploy with:  cd functions && npm install && npm run deploy
 */
const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');

initializeApp();

exports.sendNotificationPush = onDocumentCreated(
  'notifications/{notificationId}',
  async (event) => {
    const snap = event.data;
    if (!snap) return null;
    const data = snap.data() || {};
    const recipientUid = data.recipientUid;
    const message = data.message || 'You have a new notification.';
    const payloadType = data.payloadType || 'system';

    if (!recipientUid) return null;

    const titles = {
      listing: 'New listing nearby',
      request: 'Request update',
      pickup: 'Pickup update',
      system: 'FoodRescue Sync',
    };

    try {
      const userDoc = await getFirestore().collection('users').doc(recipientUid).get();
      const tokens = (userDoc.get('fcmTokens') || []).filter(Boolean);
      if (tokens.length === 0) return null;

      await getMessaging().sendEachForMulticast({
        tokens,
        notification: {
          title: titles[payloadType] || titles.system,
          body: message,
        },
        data: {
          notificationId: event.params.notificationId,
          payloadType,
        },
      });
    } catch (err) {
      console.error('Failed to send push:', err);
    }
    return null;
  }
);