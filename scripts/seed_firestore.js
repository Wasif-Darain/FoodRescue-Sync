/**
 * Firestore seed data for FoodRescue-Sync.
 *
 * Usage:
 *   1. cd functions && npm install   (firebase-admin is already a dependency)
 *   2. Download a service account key from Firebase Console:
 *      Project Settings > Service accounts > Generate new private key
 *      Save it as scripts/serviceAccountKey.json
 *   3. node scripts/seed_firestore.js
 *
 * Seeds users, organization profiles, listings (across time/status/location),
 * donation logs and notifications with Bangladeshi names.
 */
const admin = require('firebase-admin/app');
const { getFirestore, Timestamp } = require('firebase-admin/firestore');
const { getAuth } = require('firebase-admin/auth');
const path = require('path');

try {
  const serviceAccount = require(path.join(__dirname, 'serviceAccountKey.json'));
  admin.initializeApp({ credential: admin.cert(serviceAccount) });
} catch (_) {
  admin.initializeApp(); // falls back to Application Default Credentials / emulator
}

const db = getFirestore();

const donors = [
  { name: 'Rahim Uddin', org: 'Kacchi Bhai Restaurant', email: 'rahim.kacchi@foodrescue.test', phone: '+8801711000001', lat: 23.7806, lng: 90.4193, address: 'Morshed Sarani, Gulshan 2, Dhaka' },
  { name: 'Nusrat Jahan', org: 'Nusrat Bakery & Cafe', email: 'nusrat.bakery@foodrescue.test', phone: '+8801711000002', lat: 23.7509, lng: 90.3935, address: 'Road 27, Dhanmondi, Dhaka' },
  { name: 'Tanvir Hasan', org: 'Tanvir Superstore', email: 'tanvir.store@foodrescue.test', phone: '+8801711000003', lat: 23.8103, lng: 90.4125, address: 'Banani 11, Dhaka' },
  { name: 'Sadia Islam', org: 'Sadia Catering Service', email: 'sadia.catering@foodrescue.test', phone: '+8801711000004', lat: 23.7831, lng: 90.3647, address: 'Mohammadpur, Dhaka' },
  { name: 'Mahmudul Karim', org: 'Karim Hotel & Restaurant', email: 'mahmud.hotel@foodrescue.test', phone: '+8801711000005', lat: 23.8759, lng: 90.3195, address: 'Sector 7, Uttara, Dhaka' },
];

const consumers = [
  { name: 'Fatema Begum', org: 'Ashraya Shelter Home', email: 'fatema.shelter@foodrescue.test', phone: '+8801811000001', lat: 23.7925, lng: 90.4078, address: 'Gulshan 1, Dhaka' },
  { name: 'Abdul Mannan', org: 'Manchitro NGO', email: 'mannan.ngo@foodrescue.test', phone: '+8801811000002', lat: 23.7639, lng: 90.3887, address: 'Dhanmondi 15, Dhaka' },
  { name: 'Rownak Jahan', org: 'Rownak Food Bank', email: 'rownak.foodbank@foodrescue.test', phone: '+8801811000003', lat: 23.8206, lng: 90.3667, address: 'Mirpur DOHS, Dhaka' },
  { name: 'Shafiq Ahmed', org: 'Shafiq Community Kitchen', email: 'shafiq.kitchen@foodrescue.test', phone: '+8801811000004', lat: 23.7685, lng: 90.4255, address: 'Bashundhara R/A, Dhaka' },
];

const categories = ['Cooked Meals', 'Bakery', 'Dairy', 'Produce', 'Grains'];
const items = [
  ['Basmati rice & chicken curry', 'Cooked Meals'],
  ['Fresh naan & paratha', 'Bakery'],
  ['Milk & yogurt packs', 'Dairy'],
  ['Seasonal vegetables mix', 'Produce'],
  ['Red lentils & flour', 'Grains'],
  ['Beef biryani (evening batch)', 'Cooked Meals'],
  ['Croissants & muffins', 'Bakery'],
  ['Paneer & butter blocks', 'Dairy'],
  ['Bananas & papayas', 'Produce'],
  ['Semolina & oats', 'Grains'],
];

const areas = [
  { name: 'Gulshan 1, Dhaka', lat: 23.7925, lng: 90.4078 },
  { name: 'Banani, Dhaka', lat: 23.7936, lng: 90.4043 },
  { name: 'Dhanmondi 27, Dhaka', lat: 23.7509, lng: 90.3737 },
  { name: 'Uttara Sector 10, Dhaka', lat: 23.8663, lng: 90.4004 },
  { name: 'Mirpur 10, Dhaka', lat: 23.8069, lng: 90.3687 },
  { name: 'Bashundhara R/A, Dhaka', lat: 23.7827, lng: 90.4249 },
  { name: 'Mohammadpur, Dhaka', lat: 23.7659, lng: 90.3596 },
];

function hoursFromNow(h) {
  return Timestamp.fromDate(new Date(Date.now() + h * 3600 * 1000));
}
function daysAgo(d) {
  return Timestamp.fromDate(new Date(Date.now() - d * 24 * 3600 * 1000));
}

async function ensureAuthUser(email, name) {
  try {
    return await getAuth().createUser({ email, password: 'password123', displayName: name });
  } catch (e) {
    if (e.code === 'auth/email-already-exists' || e.code === 'auth/uid-already-exists') {
      return await getAuth().getUserByEmail(email);
    }
    throw e;
  }
}

async function seed() {
  const donorIds = [];
  const consumerIds = [];

  for (const d of donors) {
    const authUser = await ensureAuthUser(d.email, d.name);
    const uid = authUser.uid;
    const orgRef = db.collection('organization_profiles').doc();
    await orgRef.set({
      orgName: d.org,
      address: d.address,
      contactEmail: d.email,
      contactPhone: d.phone,
      isVerified: true,
    });
    await db.collection('users').doc(uid).set({
      uid,
      email: d.email,
      role: 'donor',
      name: d.name,
      profileRef: orgRef,
      latitude: d.lat,
      longitude: d.lng,
      address: d.address,
      maxRadiusKm: 10,
      unattendedAfterHours: 24,
      createdAt: daysAgo(30),
    });
    donorIds.push(uid);
  }

  for (const c of consumers) {
    const authUser = await ensureAuthUser(c.email, c.name);
    const uid = authUser.uid;
    const orgRef = db.collection('organization_profiles').doc();
    await orgRef.set({
      orgName: c.org,
      address: c.address,
      contactEmail: c.email,
      contactPhone: c.phone,
      isVerified: true,
    });
    await db.collection('users').doc(uid).set({
      uid,
      email: c.email,
      role: 'consumer',
      name: c.name,
      profileRef: orgRef,
      latitude: c.lat,
      longitude: c.lng,
      address: c.address,
      maxRadiusKm: 10,
      unattendedAfterHours: 24,
      createdAt: daysAgo(25),
    });
    consumerIds.push(uid);
  }

  // Listings spread across time, status and locations.
  let n = 0;
  for (const [title, category] of items) {
    for (let i = 0; i < 3; i++) {
      const donorIdx = n % donors.length;
      const area = areas[n % areas.length];
      const statusCycle = n % 5; // 0-2 active, 3 claimed, 4 expired
      const status = statusCycle <= 2 ? 'active' : statusCycle === 3 ? 'claimed' : 'expired';
      const ageHours = 2 + (n % 60); // some fresh, some old enough to be "unattended"
      const createdAt = hoursFromNow(-ageHours);
      const isDonation = n % 3 !== 0;
      await db.collection('listings').add({
        donorId: donorIds[donorIdx],
        donorName: donors[donorIdx].name,
        title: `${title} #${i + 1}`,
        description: `${title} from ${donors[donorIdx].org}, safe to consume, packed hygienically.`,
        price: isDonation ? 0 : 50 + (n % 5) * 30,
        quantity: 5 + (n % 20),
        listingType: isDonation ? 'donation' : 'flashSale',
        pickupStart: createdAt,
        pickupEnd: hoursFromNow(ageHours > 48 ? -ageHours + 72 : 6 + (n % 12)),
        claimDeadline: hoursFromNow(status === 'active' ? 4 + (n % 20) : -1),
        latitude: area.lat + (Math.random() - 0.5) * 0.01,
        longitude: area.lng + (Math.random() - 0.5) * 0.01,
        address: area.name,
        status,
        category,
        photoUrls: [],
        itemIds: [],
        createdAt,
      });
      n++;
    }
  }

  // Donation logs across the last 14 days (feeds the welcome-screen stat).
  for (let day = 1; day <= 14; day++) {
    for (let k = 0; k < 3; k++) {
      const consumerIdx = (day + k) % consumers.length;
      await db.collection('donation_logs').add({
        donorId: donorIds[(day + k) % donors.length],
        recipientId: consumerIds[consumerIdx],
        totalWeight: 8 + ((day * 7 + k * 13) % 40),
        itemSummary: { rice: 5, curry: 3 },
        completedAt: daysAgo(day),
      });
    }
  }

  // Bulk/ordinary requests across all statuses for the first two consumers.
  const requestStatuses = ['pending', 'accepted', 'rejected', 'completed'];
  for (let i = 0; i < 8; i++) {
    const consumerId = consumerIds[i % 2];
    await db.collection('requests').add({
      consumerId,
      listingId: '',
      requestedQuantity: 10 + i * 5,
      unit: 'kg',
      isBulk: true,
      orgName: consumers[i % 2].org,
      contactPerson: consumers[i % 2].name,
      phone: consumers[i % 2].phone,
      address: consumers[i % 2].address,
      requiredDate: hoursFromNow(24 + i * 12),
      peopleToFeed: 20 + i * 10,
      items: [{ name: items[i % items.length][0], quantity: `${5 + i}` }],
      notes: i % 2 === 0 ? 'Evening delivery preferred.' : null,
      status: requestStatuses[i % requestStatuses.length],
      createdAt: hoursFromNow(-(i + 1) * 20),
      updatedAt: hoursFromNow(-(i + 1) * 10),
    });
  }

  // Pickups across all statuses for the first two consumers.
  const pickupStatuses = ['scheduled', 'enRoute', 'completed'];
  for (let i = 0; i < 6; i++) {
    const consumerId = consumerIds[i % 2];
    const area = areas[i % areas.length];
    await db.collection('pickups').add({
      consumerId,
      requestId: '',
      listingId: '',
      isBulk: false,
      volunteerDriverId: null,
      status: pickupStatuses[i % pickupStatuses.length],
      scheduledTime: hoursFromNow(i % 3 === 2 ? -(24 + i) : 6 + i * 8),
      completedAt: i % 3 === 2 ? hoursFromNow(-(24 + i) + 2) : null,
      latitude: area.lat,
      longitude: area.lng,
      address: area.name,
      createdAt: hoursFromNow(-(i + 1) * 12),
    });
  }

  // Inventory items for each donor (surplus and regular).
  for (let i = 0; i < donors.length; i++) {
    for (let k = 0; k < 4; k++) {
      const [name, category] = items[(i * 4 + k) % items.length];
      await db.collection('inventory_items').add({
        donorId: donorIds[i],
        name: `${name} (stock ${k + 1})`,
        barcode: `BD${100000 + i * 10 + k}`,
        quantity: 10 + ((i * 4 + k) % 30),
        expiryDate: hoursFromNow(24 + ((i * 4 + k) % 10) * 24),
        isSurplus: k % 2 === 0,
        category,
        imageUrl: null,
      });
    }
  }

  // A few notifications for the first consumer.
  for (let i = 0; i < 4; i++) {
    await db.collection('notifications').add({
      recipientUid: consumerIds[0],
      payloadType: i % 2 === 0 ? 'listing' : 'pickup',
      message: i % 2 === 0
        ? `New listing "${items[i][0]}" is available near you.`
        : `${donors[i].name} rescheduled your donation pickup.`,
      isRead: i > 1,
      createdAt: hoursFromNow(-(i + 1) * 3),
    });
  }

  console.log('Seed complete:');
  console.log(`  ${donors.length} donors, ${consumers.length} consumers`);
  console.log(`  ${n} listings (active/claimed/expired, varied times & locations)`);
  console.log('  8 requests (pending/accepted/rejected/completed)');
  console.log('  6 pickups (scheduled/enRoute/completed)');
  console.log(`  ${donors.length * 4} inventory items`);
  console.log('  42 donation logs, 4 notifications');
  console.log('  Sign in with any seed email (e.g. fatema.shelter@foodrescue.test), password: password123');
  process.exit(0);
}

seed().catch((e) => {
  console.error(e);
  process.exit(1);
});