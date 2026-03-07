import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymantra/src/core/models/mantra.dart';
import 'package:mymantra/src/core/providers/app_provider.dart';
import 'helpers.dart';

void main() {
  group('SettingsScreen — Practice section', () {
    testWidgets('Default cycle dropdown is visible', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Default cycle'), findsOneWidget);
      // Default value is Session
      expect(find.text('Session'), findsWidgets);
    });

    testWidgets('Limit tap rate toggle is visible and on by default', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Limit tap rate'), findsOneWidget);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );
      expect(container.read(appProvider).settings.limitClickRate, isTrue);
    });

    testWidgets('toggling Limit tap rate updates the setting', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );

      // Switches in order: haptic (0), limitClickRate (1), notifications (2).
      await tester.tap(find.byType(Switch).at(1));
      await tester.pumpAndSettle();

      expect(container.read(appProvider).settings.limitClickRate, isFalse);
    });

    testWidgets('Default cycle persists when changed to Daily', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );

      // Open the Default cycle dropdown and pick Daily.
      final cycleDropdowns = find.byWidgetPredicate(
        (w) => w is DropdownButton<RepetitionCycle>,
      );
      await tester.tap(cycleDropdowns.first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Daily').last);
      await tester.pumpAndSettle();

      expect(
        container.read(appProvider).settings.defaultRepetitionCycle,
        RepetitionCycle.daily,
      );
    });
  });
}
