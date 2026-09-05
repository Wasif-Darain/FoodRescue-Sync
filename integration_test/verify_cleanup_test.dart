// Verifies (and, as a safety net, finishes) cleanup after full_flow_test.dart
// — that run's own cleanup mostly succeeded despite noisy "permission-denied"
// errors from leaked provider listeners hitting the real signed-out moment
// during account deletion. This confirms nothing e2eTest-tagged was left
// behind in Firestore, deleting anything that was.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:foodrescue_sync/firebase_options.dart';
import 'package:foodrescue_sync/models/models.dart';
import 'package:foodrescue_sync/providers/auth_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  });

  testWidgets('verify + finish e2e cleanup', (tester) async {
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;

    // Need to be signed in for the security rules to allow any read at all.
    final email = 'e2e-cleanup-checker-${DateTime.now().millisecondsSinceEpoch}@e2etest.foodrescuesync.invalid';
    final authProvider = AuthProvider();
    await authProvider.signUp(
      name: '[E2E] Cleanup Checker',
      email: email,
      password: 'TestPass123!',
      phone: '01700000000',
      address: 'Test Address',
      accountType: AccountType.individual,
    );
    final checkerUid = auth.currentUser!.uid;

    final leftovers = <String>[];
    for (final collection in ['pickups', 'listings', 'direct_donations', 'reports', 'requests', 'notifications']) {
      final snap = await firestore.collection(collection).where('e2eTest', isEqualTo: true).get();
      for (final doc in snap.docs) {
        leftovers.add('$collection/${doc.id}');
        await doc.reference.delete();
      }
    }

    // users/organization_profiles don't carry e2eTest reliably if signUp's
    // own transaction failed partway, so also sweep by the email domain used
    // for every throwaway account this suite ever created.
    final usersSnap = await firestore.collection('users').get();
    for (final doc in usersSnap.docs) {
      final data = doc.data();
      final docEmail = data['email'] as String? ?? '';
      if (docEmail.endsWith('@e2etest.foodrescuesync.invalid') && doc.id != checkerUid) {
        leftovers.add('users/${doc.id} ($docEmail)');
        await doc.reference.delete();
      }
    }

    debugPrint('\n================ CLEANUP VERIFICATION ================');
    if (leftovers.isEmpty) {
      debugPrint('No leftover e2e-tagged documents found — prior cleanup fully succeeded.');
    } else {
      debugPrint('Found and removed ${leftovers.length} leftover document(s):');
      for (final l in leftovers) {
        debugPrint(' - $l');
      }
    }
    debugPrint('========================================================\n');

    // Clean up the checker account itself.
    await firestore.collection('users').doc(checkerUid).delete();
    await auth.currentUser!.delete();
  });
}
