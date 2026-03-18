import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymantra/src/app/router.dart';
import 'package:mymantra/src/core/providers/app_provider.dart';
import 'helpers.dart';

void main() {
  group('CreateMantraScreen', () {
    testWidgets('title and mantra text fields are visible', (tester) async {
      await pumpApp(tester);
      // Tap the Create button from the empty-state
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(TextFormField, 'e.g. Om Namah Shivaya'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(TextFormField, 'Sanskrit, Hebrew, or any script'),
        findsOneWidget,
      );
    });

    testWidgets('saving a new mantra creates it in the provider', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'e.g. Om Namah Shivaya'),
        'Test Mantra',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Sanskrit, Hebrew, or any script'),
        'Om Test',
      );

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );
      expect(
        container.read(appProvider).mantras.any((m) => m.title == 'Test Mantra'),
        isTrue,
      );
    });

    testWidgets('editing a mantra shows its existing title', (tester) async {
      await pumpApp(tester);
      final id = seedMantra(tester, title: 'Existing Mantra', text: 'Om');
      await tester.pumpAndSettle();

      appRouter.go('/mantras/$id/edit');
      await tester.pumpAndSettle();

      expect(find.text('Existing Mantra'), findsOneWidget);
    });
  });
}
