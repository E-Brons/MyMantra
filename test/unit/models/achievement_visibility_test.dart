import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:mymantra/src/core/models/achievement.dart';
import 'package:mymantra/src/core/services/icon_registry.dart';

String? _currentPlatformAchievementId() {
  if (kIsWeb) return 'ACH-PLT-WEB';
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => 'ACH-PLT-ANDROID',
    TargetPlatform.iOS => 'ACH-PLT-IOS',
    TargetPlatform.macOS => 'ACH-PLT-MAC',
    TargetPlatform.linux => 'ACH-PLT-LINUX',
    _ => null,
  };
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await IconRegistry.instance.init();
  });

  group('visibleAchievements', () {
    test('shows chain heads plus always-visible achievements for a new user', () {
      final visible = visibleAchievements({});

      expect(
        visible.map((a) => a.id),
        orderedEquals([
          'ACH-STR-001',
          'ACH-REP-1K',
          'ACH-SES-010',
          'ACH-SPL-CREATE',
        ]),
      );
    });

    test('reveals the next streak achievement after the predecessor is unlocked', () {
      final visible = visibleAchievements({'ACH-STR-001'});

      expect(visible.any((a) => a.id == 'ACH-STR-001'), isTrue);
      expect(visible.any((a) => a.id == 'ACH-STR-003'), isTrue);
      expect(visible.any((a) => a.id == 'ACH-STR-007'), isFalse);
    });

    test('reveals only one teaser ahead in progressive chains', () {
      final visible = visibleAchievements({
        'ACH-STR-001',
        'ACH-STR-003',
        'ACH-REP-1K',
      });

      expect(visible.any((a) => a.id == 'ACH-STR-007'), isTrue);
      expect(visible.any((a) => a.id == 'ACH-STR-014'), isFalse);
      expect(visible.any((a) => a.id == 'ACH-REP-5K'), isTrue);
      expect(visible.any((a) => a.id == 'ACH-REP-10K'), isFalse);
    });

    test('shows all items in a progressive group once the chain is complete', () {
      final unlocked = kAchievements
          .where((a) => a.id.startsWith('ACH-SES-'))
          .map((a) => a.id)
          .toSet();

      final visible = visibleAchievements(unlocked);
      final sessionIds = visible
          .where((a) => a.id.startsWith('ACH-SES-'))
          .map((a) => a.id)
          .toList();

      expect(sessionIds.length, 9);
      expect(sessionIds.last, 'ACH-SES-100K');
    });

    test('never-visible groups stay hidden until earned', () {
      final visible = visibleAchievements({});

      expect(visible.any((a) => a.id == 'ACH-TIME-EARLY'), isFalse);
      expect(visible.any((a) => a.id == 'ACH-PLT-ANDROID'), isFalse);
    });

    test('never-visible achievements appear once earned', () {
      final currentPlatformId = _currentPlatformAchievementId();
      final unlocked = <String>{'ACH-TIME-EARLY'};
      if (currentPlatformId != null) unlocked.add(currentPlatformId);

      final visible = visibleAchievements(unlocked);

      expect(visible.any((a) => a.id == 'ACH-TIME-EARLY'), isTrue);
      expect(visible.any((a) => a.id == 'ACH-TIME-NIGHT'), isFalse);

      const platformIds = [
        'ACH-PLT-ANDROID',
        'ACH-PLT-IOS',
        'ACH-PLT-MAC',
        'ACH-PLT-LINUX',
        'ACH-PLT-WEB',
      ];
      for (final id in platformIds) {
        expect(
          visible.any((a) => a.id == id),
          id == currentPlatformId,
          reason: 'Only current platform badge should be visible after earn: $id',
        );
      }
    });

    test('always-visible achievements are shown even when locked', () {
      final visible = visibleAchievements({});

      expect(visible.any((a) => a.id == 'ACH-SPL-CREATE'), isTrue);
    });
  });
}