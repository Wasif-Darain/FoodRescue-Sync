/**
 * One-time Firestore migration for FoodRescue-Sync.
 *
 * Backfills the new schema fields onto all existing documents:
 *   - requests:  adds `isBulk` (true when the doc has orgName/items,
 *                i.e. a bulk request; false for ordinary claim requests)
 *   - pickups:   adds `isBulk` and links `listingId` from the request
 *   - listings:  ensures `listingType`, `status`, `photoUrls`, `itemIds`
 *                exist with sane defaults
 *
 * Usage:
 *   1. cd functions && npm install   (firebase-admin is already a dependency)
 *   2. Download a service account key from Firebase Console:
 *      Project Settings > Service accounts > Generate new private key
 *      Save it as scripts/serviceAccountKey.json
 *   3. node scripts/migrate_firestore.js
 */
const admin = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const path = require('path');

try {
  const serviceAccount = require(path.join(__dirname, 'serviceAccountKey.json'));
  admin.initializeApp({ credential: admin.cert(serviceAccount) });
} catch (_) {
  admin.initializeApp(); // falls back to Application Default Credentials / emulator
}

const db = getFirestore();

async function migrateRequests() {
  const snap = await db.collection('requests').get();
  let updated = 0;
  for (const doc of snap.docs) {
    const data = doc.data() || {};
    // Bulk requests carry orgName / items / peopleToFeed; ordinary claim
    // requests reference a listing instead.
    const isBulk = typeof data.isBulk === 'boolean'
      ? data.isBulk
      : data.orgName != null || Array.isArray(data.items);
    const patch = { isBulk };
    if (!data.listingId) patch.listingId = '';
    if (!data.unit) patch.unit = 'kg';
    await doc.ref.set(patch, { merge: true });
    updated++;
  }
  console.log(`requests migrated: ${updated}`);
}

async function migratePickups() {
  const snap = await db.collection('pickups').get();
  let updated = 0;
  for (const doc of snap.docs) {
    const data = doc.data() || {};
    const patch = {};
    if (typeof data.isBulk !== 'boolean') patch.isBulk = false;
    if (!data.listingId && data.requestId) {
      // Older docs stored the listing id in requestId.
      patch.listingId = data.requestId;
    }
    if (!data.consumerId) patch.consumerId = '';
    await doc.ref.set(patch, { merge: true });
    updated++;
  }
  console.log(`pickups migrated: ${updated}`);
}

async function migrateListings() {
  const snap = await db.collection('listings').get();
  let updated = 0;
  for (const doc of snap.docs) {
    const data = doc.data() || {};
    const patch = {};
    if (!data.listingType) patch.listingType = 'donation';
    if (!data.status) patch.status = 'active';
    if (!Array.isArray(data.photoUrls)) patch.photoUrls = [];
    if (!Array.isArray(data.itemIds)) patch.itemIds = [];
    if (!data.category) patch.category = 'Cooked Meals';
    if (!data.donorName) patch.donorName = 'Donor';
    await doc.ref.set(patch, { merge: true });
    updated++;
  }
  console.log(`listings migrated: ${updated}`);
}

async function main() {
  await migrateListings();
  await migrateRequests();
  await migratePickups();
  console.log('Migration complete.');
  process.exit(0);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});