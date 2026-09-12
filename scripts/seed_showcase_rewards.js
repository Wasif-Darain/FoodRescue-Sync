/**
 * Showcase seeding for Rewards + Leaderboard demos.
 *
 * Populates old (pre-existing, e.g. 30-300 days ago) data so weekly/monthly/
 * yearly timeframes have visibly different contents, and spreads the four
 * consumer demo accounts evenly across tiers:
 *
 *   fatema.shelter@foodrescue.test  -> high activity   (Gold/Platinum band)
 *   mannan.ngo@foodrescue.test      -> medium activity (Silver band)
 *   rownak.foodbank@foodrescue.test -> low activity    (Bronze band)
 *   shafiq.kitchen@foodrescue.test  -> minimal         (Novice band)
 *
 * Design notes (match how the app actually computes these screens):
 *  - Rewards level is lifetime totalWeight on donation_logs where
 *    donorId == uid: Novice <50, Bronze >=50, Silver >=200, Gold >=500,
 *    Platinum >=1000. Consumers appear as donors only via donorId logs, so
 *    showcase weight is written with the consumer's own uid as donorId.
 *  - Rewards period points are period donation_logs count (*10) +
 *    period completed pickups (*5).
 *  - Leaderboard donors tab counts donation_logs in-period grouped by
 *    donorId; consumers tab counts completed pickups in-period grouped by
 *    consumerId.
 *  - completedAt is the period filter on both collections, so every doc
 *    gets a spread-out old completedAt (weekly / monthly / yearly visible).
 *
 * This script only ADDS docs (never deletes) and fixes the missing users-doc
 * fields (role/name) for the demo accounts. Safe to re-run: it skips when
 * the showcase marker `meta/showcase_rewards_v1` already exists (pass
 * --force to re-seed).
 *
 * Usage:
 *   node scripts/seed_showcase_rewards.js [--force]
 *   (uses scripts/serviceAccountKey.json like the other scripts)
 */
const admin = require('firebase-admin/app');
const { getFirestore, Timestamp } = require('firebase-admin/firestore');
const { getAuth } = require('firebase-admin/auth');
const path = require('path');

try {
  const serviceAccount = require(path.join(__dirname, 'serviceAccountKey.json'));
  admin.initializeApp({ credential: admin.cert(serviceAccount) });
} catch (_) {
  admin.initializeApp();
}

const db = getFirestore();

const FORCE = process.argv.includes('--force');

// Target lifetime weights per account (tier bands in rewards_screen.dart).
const PLAN = [
  { email: 'fatema.shelter@foodrescue.test', name: 'Fatema Begum', totalWeight: 1200, pickupsCompleted: 18 },
  { email: 'mannan.ngo@foodrescue.test', name: 'Abdul Mannan', totalWeight: 320, pickupsCompleted: 10 },
  { email: 'rownak.foodbank@foodrescue.test', name: 'Rownak Jahan', totalWeight: 90, pickupsCompleted: 5 },
  { email: 'shafiq.kitchen@foodrescue.test', name: 'Shafiq Ahmed', totalWeight: 20, pickupsCompleted: 2 },
];

// Ages (days ago) spread so Weekly (<=7d) < Monthly (<=~30d) < Yearly counts
// differ visibly per account.
const AGES = [2, 4, 6, 10, 15, 22, 29, 45, 70, 100, 140, 200, 260, 330];

function daysAgo(d) {
  return Timestamp.fromDate(new Date(Date.now() - d * 24 * 3600 * 1000));
}

async function main() {
  const metaRef = db.collection('meta').doc('showcase_rewards_v1');
  if (!FORCE && (await metaRef.get()).exists) {
    console.log('Showcase already seeded (meta/showcase_rewards_v1 exists). Pass --force to re-seed.');
    process.exit(0);
  }

  for (const { email, name, totalWeight, pickupsCompleted } of PLAN) {
    let uid;
    try {
      uid = (await getAuth().getUserByEmail(email)).uid;
    } catch (e) {
      console.log(`  ! ${email} has no Auth user — skipping (${e.code || e.message})`);
      continue;
    }
    // Fix missing users-doc fields seen on some demo accounts.
    await db.collection('users').doc(uid).set(
      { role: 'consumer', name, email },
      { merge: true },
    );

    // Donation logs: even weights summing to the target lifetime total.
    // Count chosen so every account also shows on the donors leaderboard.
    const logCount = Math.max(4, Math.round(pickupsCompleted / 2));
    const perLog = Math.round((totalWeight / logCount) * 10) / 10;
    for (let i = 0; i < logCount; i++) {
      await db.collection('donation_logs').add({
        donorId: uid,
        donorName: name,
        recipientId: uid,
        totalWeight: i === logCount - 1
          ? Math.round((totalWeight - perLog * (logCount - 1)) * 10) / 10
          : perLog,
        itemSummary: { rice: 5, curry: 3 },
        completedAt: daysAgo(AGES[i % AGES.length]),
      });
    }

    // Completed pickups: spread ages identically.
    for (let i = 0; i < pickupsCompleted; i++) {
      const at = daysAgo(AGES[(i * 2 + 1) % AGES.length]);
      await db.collection('pickups').add({
        consumerId: uid,
        consumerName: name,
        requestId: '',
        listingId: '',
        isBulk: false,
        status: 'completed',
        scheduledTime: at,
        completedAt: at,
        latitude: 23.79,
        longitude: 90.4,
        address: 'Dhaka',
        createdAt: at,
      });
    }
    console.log(`  + ${email}: ${logCount} donation_logs (${totalWeight}kg lifetime), ${pickupsCompleted} completed pickups`);
  }

  await metaRef.set({ appliedAt: new Date(), plan: PLAN.map((p) => p.email) });
  console.log('Showcase seeding complete.');
  process.exit(0);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
