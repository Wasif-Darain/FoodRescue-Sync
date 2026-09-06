/**
 * Cloud Functions for FoodRescue-Sync.
 *
 * Whenever a document is added to the `notifications` collection, this
 * function sends an FCM push to all of the recipient's registered device
 * tokens (users/{uid}.fcmTokens).
 *
 * Deploy with:  cd functions && npm install && npm run deploy
 */
const { onDocumentCreated, onDocumentWritten } = require('firebase-functions/v2/firestore');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore, AggregateField } = require('firebase-admin/firestore');
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
      cancellation: 'Cancellation',
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

/**
 * Recomputes the public, pre-login welcome-screen stats (total meals saved,
 * donor count, partner count) into `stats/summary`, using the Admin SDK
 * (which bypasses Firestore Security Rules). This is the only document the
 * client is allowed to read while signed out — see firestore.rules — so the
 * welcome screen never needs direct, unauthenticated access to `users`,
 * `donation_logs`, or `organization_profiles` (which would otherwise expose
 * personal data like emails, phone numbers, and location).
 */
async function recomputePublicStats() {
  const db = getFirestore();

  const [weightAgg, donorsAgg, partnersAgg] = await Promise.all([
    db.collection('donation_logs').aggregate({
      totalWeight: AggregateField.sum('totalWeight'),
    }).get(),
    db.collection('users').where('role', '==', 'donor').count().get(),
    db.collection('organization_profiles').count().get(),
  ]);

  await db.collection('stats').doc('summary').set({
    totalWeightKg: weightAgg.data().totalWeight || 0,
    donorsCount: donorsAgg.data().count,
    partnersCount: partnersAgg.data().count,
    updatedAt: new Date(),
  });
}

exports.recomputeStatsOnDonationLog = onDocumentWritten(
  'donation_logs/{logId}',
  () => recomputePublicStats()
);

exports.recomputeStatsOnUser = onDocumentWritten(
  'users/{uid}',
  () => recomputePublicStats()
);

exports.recomputeStatsOnOrgProfile = onDocumentWritten(
  'organization_profiles/{orgId}',
  () => recomputePublicStats()
);