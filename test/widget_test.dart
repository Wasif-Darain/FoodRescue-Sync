import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodrescue_sync/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_mocks.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FoodRescueApp());
    await tester.pump();
    expect(find.text('FoodRescue Sync'), findsOneWidget);
  });
}
