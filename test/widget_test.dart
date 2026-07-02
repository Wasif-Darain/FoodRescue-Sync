import 'package:flutter_test/flutter_test.dart';
import 'package:foodrescue_sync/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FoodRescueApp());
    expect(find.text('FoodRescue'), findsOneWidget);
  });
}
