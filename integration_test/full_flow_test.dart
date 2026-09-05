// End-to-end verification of the donor -> rider -> consumer -> distribution
// flow, run against the REAL Firebase project (no emulator). Every document
// this test creates is tagged `e2eTest: true` and uses throwaway
// `e2e-...@e2etest.foodrescuesync.invalid` accounts so it's easy to spot and
// purge later; the test also deletes everything it created and signs out at
// the end regardless of pass/fail.
//
// Run with: flutter test integration_test/full_flow_test.dart -d <deviceId>
// Use a mobile simulator/device (not Chrome) — the distribution-photo upload
// path uses dart:io File, which isn't supported on Flutter Web.

import 'dart:io';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:foodrescue_sync/firebase_options.dart';
import 'package:foodrescue_sync/models/models.dart';
import 'package:foodrescue_sync/providers/auth_provider.dart';
import 'package:foodrescue_sync/providers/block_provider.dart';
import 'package:foodrescue_sync/providers/consumer_provider.dart';
import 'package:foodrescue_sync/providers/donor_provider.dart';
import 'package:foodrescue_sync/providers/rider_provider.dart';

// A minimal valid 1x1-pixel JPEG, used as the distribution proof photo.
final Uint8List _tinyJpeg = base64Decode(
  '/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAj/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCdABmX/9k=',
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final results = <String>[];
  final issues = <String>[];
  void pass(String label) {
    results.add('PASS: $label');
    debugPrint('PASS: $label');
  }

  void recordFailure(String label, Object error) {
    results.add('FAIL: $label -> $error');
    issues.add('$label -> $error');
    debugPrint('FAIL: $label -> $error');
  }

  setUpAll(() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  });

  testWidgets('full donor-rider-consumer-distribution flow', (tester) async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    final stamp = DateTime.now().millisecondsSinceEpoch;

    final donorEmail = 'e2e-donor-$stamp@e2etest.foodrescuesync.invalid';
    final riderEmail = 'e2e-rider-$stamp@e2etest.foodrescuesync.invalid';
    final consumerEmail = 'e2e-consumer-$stamp@e2etest.foodrescuesync.invalid';
    const password = 'TestPass123!';

    final createdDocs = <(String, String)>[]; // (collection, docId)

    Future<String> signUp(String email, AccountType type, String name) async {
      // Deliberately never disposed: AuthProvider's own internal auth
      // listener finishes loading the new profile (and calls
      // notifyListeners()) on its own async schedule, racing any dispose()
      // called right after signUp() returns. Three leaked instances for the
      // life of this test process is harmless.
      final authProvider = AuthProvider();
      await authProvider.signUp(
        name: name,
        email: email,
        password: password,
        phone: '01700000000',
        address: 'Test Address, Dhaka',
        accountType: type,
      );
      final uid = auth.currentUser!.uid;
      await firestore.collection('users').doc(uid).update({
        'e2eTest': true,
        'latitude': 23.81,
        'longitude': 90.41,
      });
      return uid;
    }

    // Switches the active account WITHOUT an intermediate signOut(). Donor/
    // Consumer/Rider providers each subscribe several `.snapshots()`
    // listeners in their constructor with no onError handler (pre-existing,
    // not something this test can fix) — a real, if brief, signed-out gap
    // between accounts makes those *still-live* listeners see `request.auth
    // == null` and throw an unhandled `permission-denied`, crashing the
    // whole test run. Signing straight into the next account avoids that
    // gap; the SDK swaps the current user directly.
    Future<void> signInAs(String email) async {
      if (auth.currentUser?.email == email) return;
      await auth.signInWithEmailAndPassword(email: email, password: password);
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }

    Future<Map<String, dynamic>?> getDoc(String collection, String id) async {
      final snap = await firestore.collection(collection).doc(id).get();
      return snap.data();
    }

    try {
      // ---- Setup: three throwaway accounts ----------------------------
      late String donorUid, riderUid, consumerUid;
      try {
        donorUid = await signUp(donorEmail, AccountType.restaurant, '[E2E] Donor');
        pass('Setup: donor account created ($donorUid)');
      } catch (e) {
        recordFailure('Setup: donor account created', e);
        rethrow;
      }
      try {
        riderUid = await signUp(riderEmail, AccountType.rider, '[E2E] Rider');
        pass('Setup: rider account created ($riderUid)');
      } catch (e) {
        recordFailure('Setup: rider account created', e);
        rethrow;
      }
      try {
        consumerUid = await signUp(consumerEmail, AccountType.individual, '[E2E] Consumer');
        pass('Setup: consumer account created ($consumerUid)');
      } catch (e) {
        recordFailure('Setup: consumer account created', e);
        rethrow;
      }

      // ==================================================================
      // CASE A: regular donation -> consumer assigns rider (open pool) ->
      // rider full delivery lifecycle -> consumer distributes with photo ->
      // donor verifies (block + report).
      // ==================================================================
      String? caseAPickupId;
      try {
        await signInAs(donorEmail);
        final donor = DonorProvider();
        final listingId = await donor.createListing(
          title: '[E2E] Case A donation',
          description: 'test',
          category: 'Produce',
          quantity: 10,
          listingType: ListingType.donation,
          pickupStart: DateTime.now(),
          pickupEnd: DateTime.now().add(const Duration(hours: 4)),
          latitude: 23.81,
          longitude: 90.41,
          address: 'Donor address',
        );
        if (listingId == null) throw StateError('createListing returned null');
        createdDocs.add(('listings', listingId));
        await firestore.collection('listings').doc(listingId).update({'e2eTest': true});
        pass('Case A: donor posts donation');

        await signInAs(consumerEmail);
        final consumer = ConsumerProvider();
        final claimed = await consumer.claimListing(listingId, 5, selfPickup: false);
        if (!claimed) throw StateError('claimListing returned false');
        final pickupQuery = await firestore
            .collection('pickups')
            .where('consumerId', isEqualTo: consumerUid)
            .where('listingId', isEqualTo: listingId)
            .get();
        if (pickupQuery.docs.isEmpty) throw StateError('no pickup created after claim');
        caseAPickupId = pickupQuery.docs.first.id;
        createdDocs.add(('pickups', caseAPickupId));
        await firestore.collection('pickups').doc(caseAPickupId).update({'e2eTest': true});
        final afterClaim = await getDoc('pickups', caseAPickupId);
        if (afterClaim?['status'] != 'scheduled') throw StateError('expected scheduled, got ${afterClaim?['status']}');
        if (afterClaim?['deliveryMethod'] != null) throw StateError('expected null deliveryMethod for pool pickup');
        pass('Case A: consumer claims for rider delivery (posted to pool)');

        await signInAs(riderEmail);
        final rider = RiderProvider();
        final available = await firestore
            .collection('pickups')
            .where('status', isEqualTo: 'scheduled')
            .get();
        final visible = available.docs.any((d) => d.id == caseAPickupId && d.data()['volunteerDriverId'] == null);
        if (!visible) throw StateError('pickup not visible in open pool to rider');
        final claimErr = await rider.claimPickup(caseAPickupId);
        if (claimErr != null) throw StateError('claimPickup failed: $claimErr');
        final afterRiderClaim = await getDoc('pickups', caseAPickupId);
        if (afterRiderClaim?['volunteerDriverId'] != riderUid) throw StateError('volunteerDriverId not set to rider');
        pass('Case A: rider sees and grabs open pickup');

        await rider.markEnRoute(caseAPickupId);
        var doc = await getDoc('pickups', caseAPickupId);
        if (doc?['status'] != 'enRoute') throw StateError('expected enRoute, got ${doc?['status']}');
        await rider.markPickedUp(caseAPickupId);
        doc = await getDoc('pickups', caseAPickupId);
        if (doc?['status'] != 'pickedUp') throw StateError('expected pickedUp, got ${doc?['status']}');
        await rider.markCompleted(caseAPickupId);
        doc = await getDoc('pickups', caseAPickupId);
        if (doc?['status'] != 'delivered') throw StateError('expected delivered, got ${doc?['status']}');
        pass('Case A: rider navigation lifecycle enRoute -> pickedUp -> delivered');

        await signInAs(consumerEmail);
        await consumer.startDistribution(caseAPickupId);
        doc = await getDoc('pickups', caseAPickupId);
        if (doc?['status'] != 'distributing') throw StateError('expected distributing, got ${doc?['status']}');
        pass('Case A: consumer starts distribution after rider delivery');

        String photoUrl;
        try {
          photoUrl = await consumer.uploadDistributionPhoto(_tinyJpeg);
          if (!photoUrl.startsWith('http')) throw StateError('unexpected upload result: $photoUrl');
          pass('Case A: distribution proof photo uploaded ($photoUrl)');
        } catch (e) {
          recordFailure('Case A: distribution proof photo uploaded', e);
          photoUrl = 'https://example.invalid/upload-failed.jpg';
        }

        await consumer.markDistributionComplete(caseAPickupId, photoUrl);
        doc = await getDoc('pickups', caseAPickupId);
        if (doc?['status'] != 'completed') throw StateError('expected completed, got ${doc?['status']}');
        if (doc?['distributionPhotoUrl'] != photoUrl) throw StateError('distributionPhotoUrl not saved');
        if (doc?['completedAt'] == null) throw StateError('completedAt not set');
        pass('Case A: consumer marks distribution complete with photo');

        await signInAs(donorEmail);
        final donorView = await firestore
            .collection('pickups')
            .where('donorId', isEqualTo: donorUid)
            .get();
        final verifiable = donorView.docs.any((d) =>
            d.id == caseAPickupId && d.data()['status'] == 'completed' && d.data()['distributionPhotoUrl'] != null);
        if (!verifiable) throw StateError('donor cannot see completed pickup with photo');
        pass('Case A: donor sees completed pickup + proof photo for verification');

        final blockProv = BlockProvider();
        await Future<void>.delayed(const Duration(milliseconds: 400));
        await blockProv.toggleBlock(consumerUid);
        await Future<void>.delayed(const Duration(milliseconds: 400));
        var donorDoc = await getDoc('users', donorUid);
        final blockedList = (donorDoc?['blockedUids'] as List?) ?? [];
        if (!blockedList.contains(consumerUid)) throw StateError('block did not persist');
        await blockProv.toggleBlock(consumerUid); // unblock (cleanup)
        pass('Case A: donor can block the consumer');

        final reportRef = await firestore.collection('reports').add({
          'reporterId': donorUid,
          'reportedUid': consumerUid,
          'reportedLabel': '[E2E] Consumer',
          'pickupId': caseAPickupId,
          'reason': 'e2e test report',
          'status': 'open',
          'e2eTest': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
        createdDocs.add(('reports', reportRef.id));
        final reportDoc = await getDoc('reports', reportRef.id);
        if (reportDoc == null) throw StateError('report was not written');
        pass('Case A: donor can report a mismatch');
      } catch (e) {
        recordFailure('Case A (rider-delivered flow)', e);
      }

      // ==================================================================
      // CASE B: regular donation -> consumer self-pickup end-to-end.
      // ==================================================================
      try {
        await signInAs(donorEmail);
        final donor = DonorProvider();
        final listingId = await donor.createListing(
          title: '[E2E] Case B self-pickup donation',
          description: 'test',
          category: 'Bakery',
          quantity: 10,
          listingType: ListingType.donation,
          pickupStart: DateTime.now(),
          pickupEnd: DateTime.now().add(const Duration(hours: 4)),
          latitude: 23.81,
          longitude: 90.41,
          address: 'Donor address',
        );
        if (listingId == null) throw StateError('createListing returned null');
        createdDocs.add(('listings', listingId));
        await firestore.collection('listings').doc(listingId).update({'e2eTest': true});

        await signInAs(consumerEmail);
        final consumer = ConsumerProvider();
        final claimed = await consumer.claimListing(listingId, 5, selfPickup: true);
        if (!claimed) throw StateError('claimListing (self) returned false');
        final pickupQuery = await firestore
            .collection('pickups')
            .where('consumerId', isEqualTo: consumerUid)
            .where('listingId', isEqualTo: listingId)
            .get();
        if (pickupQuery.docs.isEmpty) throw StateError('no pickup created after self-pickup claim');
        final pickupId = pickupQuery.docs.first.id;
        createdDocs.add(('pickups', pickupId));
        await firestore.collection('pickups').doc(pickupId).update({'e2eTest': true});
        var doc = await getDoc('pickups', pickupId);
        if (doc?['deliveryMethod'] != 'self') throw StateError('expected deliveryMethod=self');
        pass('Case B: consumer claims with self-pickup');

        await consumer.markSelfEnRoute(pickupId);
        doc = await getDoc('pickups', pickupId);
        if (doc?['status'] != 'enRoute') throw StateError('expected enRoute, got ${doc?['status']}');
        await consumer.markSelfPickedUp(pickupId);
        doc = await getDoc('pickups', pickupId);
        if (doc?['status'] != 'pickedUp') throw StateError('expected pickedUp, got ${doc?['status']}');
        await consumer.startDistribution(pickupId);
        doc = await getDoc('pickups', pickupId);
        if (doc?['status'] != 'distributing') throw StateError('expected distributing, got ${doc?['status']}');
        pass('Case B: self-pickup navigation lifecycle enRoute -> pickedUp -> distributing');

        final photoUrl = await consumer.uploadDistributionPhoto(_tinyJpeg);
        await consumer.markDistributionComplete(pickupId, photoUrl);
        doc = await getDoc('pickups', pickupId);
        if (doc?['status'] != 'completed') throw StateError('expected completed, got ${doc?['status']}');
        if (doc?['volunteerDriverId'] != null) throw StateError('self-pickup should never have a rider assigned');
        pass('Case B: self-pickup consumer completes distribution with photo, no rider involved');
      } catch (e) {
        recordFailure('Case B (self-pickup flow)', e);
      }

      // ==================================================================
      // CASE C: flash sale listing -> consumer claim (mock payment is UI
      // -only; verifies listingType/price round-trip and claim still works).
      // ==================================================================
      try {
        await signInAs(donorEmail);
        final donor = DonorProvider();
        final listingId = await donor.createListing(
          title: '[E2E] Case C flash sale',
          description: 'test',
          category: 'Produce',
          quantity: 4,
          listingType: ListingType.flashSale,
          price: 150,
          pickupStart: DateTime.now(),
          pickupEnd: DateTime.now().add(const Duration(hours: 4)),
          latitude: 23.81,
          longitude: 90.41,
          address: 'Donor address',
        );
        if (listingId == null) throw StateError('createListing returned null');
        createdDocs.add(('listings', listingId));
        await firestore.collection('listings').doc(listingId).update({'e2eTest': true});
        final listingDoc = await getDoc('listings', listingId);
        if (listingDoc?['listingType'] != 'flashSale') throw StateError('listingType did not persist as flashSale');
        if ((listingDoc?['price'] as num?)?.toDouble() != 150) throw StateError('price did not persist');
        pass('Case C: donor posts flash sale with correct listingType/price');

        await signInAs(consumerEmail);
        final consumer = ConsumerProvider();
        final claimed = await consumer.claimListing(listingId, 2, selfPickup: false);
        if (!claimed) throw StateError('claimListing (flash sale) returned false');
        final pickupQuery = await firestore
            .collection('pickups')
            .where('consumerId', isEqualTo: consumerUid)
            .where('listingId', isEqualTo: listingId)
            .get();
        if (pickupQuery.docs.isEmpty) throw StateError('no pickup created after flash-sale claim');
        createdDocs.add(('pickups', pickupQuery.docs.first.id));
        await firestore.collection('pickups').doc(pickupQuery.docs.first.id).update({'e2eTest': true});
        pass('Case C: consumer claims flash sale item (payment is a local-only mock dialog, not gating this write)');
      } catch (e) {
        recordFailure('Case C (flash sale flow)', e);
      }

      // ==================================================================
      // CASE D: direct donation to a specific consumer -> accept -> choose
      // self-pickup.
      // ==================================================================
      try {
        await signInAs(donorEmail);
        final donor = DonorProvider();
        await donor.donateToConsumer(
          consumerId: consumerUid,
          consumerName: '[E2E] Consumer',
          itemName: '[E2E] Case D direct donation',
          category: 'Produce',
          quantity: 3,
          scheduledTime: DateTime.now().add(const Duration(hours: 2)),
          location: 'Donor address',
          donorName: '[E2E] Donor',
        );
        final directQuery = await firestore
            .collection('direct_donations')
            .where('donorId', isEqualTo: donorUid)
            .where('itemName', isEqualTo: '[E2E] Case D direct donation')
            .get();
        if (directQuery.docs.isEmpty) throw StateError('direct_donations doc not created');
        final directId = directQuery.docs.first.id;
        createdDocs.add(('direct_donations', directId));
        await firestore.collection('direct_donations').doc(directId).update({'e2eTest': true});
        pass('Case D: donor sends a direct donation offer to a specific consumer');

        await signInAs(consumerEmail);
        final consumer = ConsumerProvider();
        final pickupId = await consumer.respondDirectDonation(directId, true);
        if (pickupId == null) throw StateError('respondDirectDonation(accept) returned null');
        createdDocs.add(('pickups', pickupId));
        await firestore.collection('pickups').doc(pickupId).update({'e2eTest': true});
        final directAfter = await getDoc('direct_donations', directId);
        if (directAfter?['status'] != 'accepted') throw StateError('direct donation status not accepted');
        pass('Case D: consumer accepts the direct donation, pickup created');

        await consumer.chooseSelfPickup(pickupId);
        final doc = await getDoc('pickups', pickupId);
        if (doc?['deliveryMethod'] != 'self') throw StateError('expected deliveryMethod=self after choice');
        pass('Case D: consumer chooses self-pickup for the accepted direct donation');
      } catch (e) {
        recordFailure('Case D (direct donation -> accept -> self-pickup)', e);
      }

      // ==================================================================
      // CASE E: direct donation -> accept -> assign specific rider ->
      // rider declines (back to pool) -> re-assign -> rider accepts.
      // ==================================================================
      try {
        await signInAs(donorEmail);
        final donor = DonorProvider();
        await donor.donateToConsumer(
          consumerId: consumerUid,
          consumerName: '[E2E] Consumer',
          itemName: '[E2E] Case E direct donation',
          category: 'Produce',
          quantity: 3,
          scheduledTime: DateTime.now().add(const Duration(hours: 2)),
          location: 'Donor address',
          donorName: '[E2E] Donor',
        );
        final directQuery = await firestore
            .collection('direct_donations')
            .where('donorId', isEqualTo: donorUid)
            .where('itemName', isEqualTo: '[E2E] Case E direct donation')
            .get();
        final directId = directQuery.docs.first.id;
        createdDocs.add(('direct_donations', directId));
        await firestore.collection('direct_donations').doc(directId).update({'e2eTest': true});

        await signInAs(consumerEmail);
        final consumer = ConsumerProvider();
        final pickupId = await consumer.respondDirectDonation(directId, true);
        if (pickupId == null) throw StateError('respondDirectDonation(accept) returned null');
        createdDocs.add(('pickups', pickupId));
        await firestore.collection('pickups').doc(pickupId).update({'e2eTest': true});

        final assignErr = await consumer.assignRider(pickupId, riderUid);
        if (assignErr != null) throw StateError('assignRider failed: $assignErr');
        var doc = await getDoc('pickups', pickupId);
        if (doc?['volunteerDriverId'] != riderUid) throw StateError('volunteerDriverId not set');
        if (doc?['assignmentPending'] != true) throw StateError('assignmentPending should be true');
        pass('Case E: consumer directly assigns a specific rider');

        await signInAs(riderEmail);
        final rider = RiderProvider();
        final pending = await firestore
            .collection('pickups')
            .where('volunteerDriverId', isEqualTo: riderUid)
            .get();
        final seenPending = pending.docs.any((d) => d.id == pickupId && d.data()['assignmentPending'] == true);
        if (!seenPending) throw StateError('rider cannot see the pending assignment');
        await rider.declineAssignment(pickupId);
        doc = await getDoc('pickups', pickupId);
        if (doc?['volunteerDriverId'] != null) throw StateError('declined assignment should clear volunteerDriverId');
        if (doc?['assignmentPending'] != false) throw StateError('declined assignment should clear assignmentPending');
        pass('Case E: rider declines the direct assignment, it returns to the open pool');

        await signInAs(consumerEmail);
        final reassignErr = await consumer.assignRider(pickupId, riderUid);
        if (reassignErr != null) throw StateError('re-assignRider failed: $reassignErr');

        await signInAs(riderEmail);
        await rider.acceptAssignment(pickupId);
        doc = await getDoc('pickups', pickupId);
        if (doc?['assignmentPending'] != false) throw StateError('accepted assignment should clear assignmentPending');
        if (doc?['volunteerDriverId'] != riderUid) throw StateError('accepted assignment should keep the rider assigned');
        pass('Case E: rider accepts the direct assignment on the second offer, it enters active deliveries');
      } catch (e) {
        recordFailure('Case E (direct donation -> assign rider -> decline/accept)', e);
      }

      // ==================================================================
      // CASE F: direct donation -> accept -> post to open pool (no specific
      // rider) -> any rider grabs it.
      // ==================================================================
      try {
        await signInAs(donorEmail);
        final donor = DonorProvider();
        await donor.donateToConsumer(
          consumerId: consumerUid,
          consumerName: '[E2E] Consumer',
          itemName: '[E2E] Case F direct donation',
          category: 'Produce',
          quantity: 3,
          scheduledTime: DateTime.now().add(const Duration(hours: 2)),
          location: 'Donor address',
          donorName: '[E2E] Donor',
        );
        final directQuery = await firestore
            .collection('direct_donations')
            .where('donorId', isEqualTo: donorUid)
            .where('itemName', isEqualTo: '[E2E] Case F direct donation')
            .get();
        final directId = directQuery.docs.first.id;
        createdDocs.add(('direct_donations', directId));
        await firestore.collection('direct_donations').doc(directId).update({'e2eTest': true});

        await signInAs(consumerEmail);
        final consumer = ConsumerProvider();
        final pickupId = await consumer.respondDirectDonation(directId, true);
        if (pickupId == null) throw StateError('respondDirectDonation(accept) returned null');
        createdDocs.add(('pickups', pickupId));
        await firestore.collection('pickups').doc(pickupId).update({'e2eTest': true});
        // Deliberately do nothing else — this is the "post to pool" case.
        pass('Case F: consumer accepts direct donation and leaves it for the open pool');

        await signInAs(riderEmail);
        final rider = RiderProvider();
        final available = await firestore.collection('pickups').where('status', isEqualTo: 'scheduled').get();
        final visible = available.docs.any((d) => d.id == pickupId && d.data()['volunteerDriverId'] == null);
        if (!visible) throw StateError('accepted direct donation not visible in open pool');
        final claimErr = await rider.claimPickup(pickupId);
        if (claimErr != null) throw StateError('claimPickup failed: $claimErr');
        pass('Case F: any rider can grab the open-pool pickup from an accepted direct donation');
      } catch (e) {
        recordFailure('Case F (direct donation -> post to pool -> rider grabs)', e);
      }

      // ==================================================================
      // CASE G: consumer rejects a direct donation offer.
      // ==================================================================
      try {
        await signInAs(donorEmail);
        final donor = DonorProvider();
        await donor.donateToConsumer(
          consumerId: consumerUid,
          consumerName: '[E2E] Consumer',
          itemName: '[E2E] Case G direct donation (reject)',
          category: 'Produce',
          quantity: 1,
          scheduledTime: DateTime.now().add(const Duration(hours: 2)),
          location: 'Donor address',
          donorName: '[E2E] Donor',
        );
        final directQuery = await firestore
            .collection('direct_donations')
            .where('donorId', isEqualTo: donorUid)
            .where('itemName', isEqualTo: '[E2E] Case G direct donation (reject)')
            .get();
        final directId = directQuery.docs.first.id;
        createdDocs.add(('direct_donations', directId));
        await firestore.collection('direct_donations').doc(directId).update({'e2eTest': true});

        await signInAs(consumerEmail);
        final consumer = ConsumerProvider();
        final pickupId = await consumer.respondDirectDonation(directId, false);
        if (pickupId != null) throw StateError('rejecting should not create a pickup');
        final directAfter = await getDoc('direct_donations', directId);
        if (directAfter?['status'] != 'cancelled') throw StateError('rejected direct donation should be cancelled');
        pass('Case G: consumer rejects a direct donation offer, no pickup created');
      } catch (e) {
        recordFailure('Case G (direct donation reject)', e);
      }
    } finally {
      // ---- Cleanup: delete every doc we created, then the 3 accounts ----
      for (final (collection, id) in createdDocs) {
        try {
          await firestore.collection(collection).doc(id).delete();
        } catch (_) {}
      }
      for (final email in [donorEmail, riderEmail, consumerEmail]) {
        try {
          if (auth.currentUser?.email != email) {
            await auth.signInWithEmailAndPassword(email: email, password: password);
            await Future<void>.delayed(const Duration(milliseconds: 400));
          }
          await firestore.collection('users').doc(auth.currentUser!.uid).delete();
          await firestore.collection('organization_profiles').where('contactEmail', isEqualTo: email).get().then(
                (snap) async {
                  for (final d in snap.docs) {
                    await d.reference.delete();
                  }
                },
              );
          await auth.currentUser!.delete();
        } catch (_) {}
      }
      await auth.signOut();

      debugPrint('\n================ FULL FLOW RESULTS ================');
      for (final r in results) {
        debugPrint(r);
      }
      debugPrint('=====================================================\n');

      final resultsFile = File('${Directory.systemTemp.path}/foodrescue_e2e_results.txt');
      await resultsFile.writeAsString(results.join('\n'));

      if (issues.isNotEmpty) {
        fail('Full flow completed with ${issues.length} failing case(s):\n${issues.join('\n')}');
      }
    }
  });
}
