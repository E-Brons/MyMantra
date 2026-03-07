import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers.dart';

void main() {
  group('HomeScreen', () {
    testWidgets('seed mantras are visible on first launch', (tester) async {
      await pumpApp(tester);
      expect(find.text('Om Mani Padme Hum'), findsOneWidget);
      expect(find.text('Abhyāsa-Vairāgya (Yoga Sutra I.12)'), findsOneWidget);
    });

    testWidgets('search field filters the mantra list', (tester) async {
      await pumpApp(tester);
      await tester.enterText(find.byType(TextField), 'Yoga');
      await tester.pumpAndSettle();
      expect(find.text('Abhyāsa-Vairāgya (Yoga Sutra I.12)'), findsOneWidget);
      expect(find.text('Om Mani Padme Hum'), findsNothing);
    });

    testWidgets('search with no match shows empty-state message', (tester) async {
      await pumpApp(tester);
      await tester.enterText(find.byType(TextField), 'zzznomatch');
      await tester.pumpAndSettle();
      expect(find.textContaining('No mantras found'), findsOneWidget);
    });

    testWidgets('tapping a mantra card navigates to MantraDetailScreen', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Om Mani Padme Hum'));
      await tester.pumpAndSettle();
      expect(find.text('Start Session'), findsOneWidget);
    });

    testWidgets('FAB navigates to CreateMantraScreen', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(find.text('New Mantra'), findsOneWidget);
    });
  });
}
