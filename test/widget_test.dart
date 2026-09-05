// Basic smoke test for the Rice Journey app.
import 'package:flutter_test/flutter_test.dart';
import 'package:rice_journey/main.dart';

void main() {
  testWidgets('App smoke test - RiceJourneyApp builds', (WidgetTester tester) async {
    // Verify the app widget can be instantiated without crashing.
    await tester.pumpWidget(const RiceJourneyApp());
    // Just verify it builds; the app requires platform channels
    // so we won't test deep interactions here.
    expect(find.byType(RiceJourneyApp), findsOneWidget);
  });
}
