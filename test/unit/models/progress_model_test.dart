import 'package:flutter_test/flutter_test.dart';
import 'package:mymantra/src/core/models/progress.dart';

void main() {
  // ── Progress.empty() initial state ────────────────────────────────────────

  group('Progress.empty()', () {
    late Progress p;
    setUp(() => p = Progress.empty());

    test('currentStreak is 0', () => expect(p.currentStreak, 0));
    test('longestStreak is 0', () => expect(p.longestStreak, 0));
    test('totalSessions is 0', () => expect(p.totalSessions, 0));
    test('totalRepetitions is 0', () => expect(p.totalRepetitions, 0));
    test('lastSessionDate is null', () => expect(p.lastSessionDate, isNull));
    test('unlockedAchievements is empty', () => expect(p.unlockedAchievements, isEmpty));
  });

  // ── Serialisation ─────────────────────────────────────────────────────────

  group('Progress — serialisation', () {
    test('empty progress round-trips correctly', () {
      final rt = Progress.fromJson(Progress.empty().toJson());
      expect(rt.currentStreak, 0);
      expect(rt.totalSessions, 0);
      expect(rt.lastSessionDate, isNull);
      expect(rt.unlockedAchievements, isEmpty);
    });

    test('populated progress round-trips correctly', () {
      final p = Progress(
        currentStreak: 7,
        longestStreak: 14,
        totalSessions: 42,
        totalRepetitions: 4536,
        lastSessionDate: DateTime(2026, 3, 7),
        unlockedAchievements: [
          UnlockedAchievement(id: 'ACH-001', unlockedAt: DateTime(2026, 1, 1)),
          UnlockedAchievement(id: 'ACH-002', unlockedAt: DateTime(2026, 1, 3)),
        ],
        memberSince: DateTime(2026, 1, 1),
      );
      final rt = Progress.fromJson(p.toJson());
      expect(rt.currentStreak, 7);
      expect(rt.longestStreak, 14);
      expect(rt.totalSessions, 42);
      expect(rt.totalRepetitions, 4536);
      expect(rt.lastSessionDate, DateTime(2026, 3, 7));
      expect(rt.unlockedAchievements.length, 2);
      expect(rt.unlockedAchievements.first.id, 'ACH-001');
      expect(rt.unlockedAchievements.last.id, 'ACH-002');
    });

    test('null lastSessionDate survives round-trip as null', () {
      final rt = Progress.fromJson(Progress.empty().toJson());
      expect(rt.lastSessionDate, isNull);
    });

    test('large repetition counts survive round-trip', () {
      final p = Progress(
        currentStreak: 365, longestStreak: 365,
        totalSessions: 1000, totalRepetitions: 100000,
        unlockedAchievements: [],
        memberSince: DateTime(2026, 1, 1),
      );
      final rt = Progress.fromJson(p.toJson());
      expect(rt.totalRepetitions, 100000);
      expect(rt.currentStreak, 365);
    });
  });

  // ── copyWith ──────────────────────────────────────────────────────────────

  group('Progress.copyWith()', () {
    final base = Progress(
      currentStreak: 5, longestStreak: 10,
      totalSessions: 20, totalRepetitions: 2160,
      lastSessionDate: DateTime(2026, 3, 6),
      unlockedAchievements: [],
      memberSince: DateTime(2026, 1, 1),
    );

    test('updates streak without touching other fields', () {
      final updated = base.copyWith(currentStreak: 6, longestStreak: 10);
      expect(updated.currentStreak, 6);
      expect(updated.totalSessions, 20);    // unchanged
      expect(updated.totalRepetitions, 2160); // unchanged
    });

    test('clearLastSessionDate resets lastSessionDate to null', () {
      final cleared = base.copyWith(clearLastSessionDate: true);
      expect(cleared.lastSessionDate, isNull);
      expect(cleared.currentStreak, base.currentStreak); // rest unchanged
    });

    test('adding achievements does not touch streak', () {
      final withAch = base.copyWith(unlockedAchievements: [
        UnlockedAchievement(id: 'ACH-001', unlockedAt: DateTime(2026, 1, 1)),
      ]);
      expect(withAch.unlockedAchievements.length, 1);
      expect(withAch.currentStreak, base.currentStreak);
    });
  });

  // ── UnlockedAchievement ───────────────────────────────────────────────────

  group('UnlockedAchievement', () {
    test('toJson / fromJson round-trip', () {
      final a = UnlockedAchievement(
        id: 'ACH-003',
        unlockedAt: DateTime(2026, 2, 14, 10, 30),
      );
      final rt = UnlockedAchievement.fromJson(a.toJson());
      expect(rt.id, 'ACH-003');
      expect(rt.unlockedAt, DateTime(2026, 2, 14, 10, 30));
    });

    test('all 14 achievement IDs are valid strings', () {
      final ids = ['ACH-001', 'ACH-002', 'ACH-003', 'ACH-004', 'ACH-005',
                   'ACH-006', 'ACH-007', 'ACH-008', 'ACH-009', 'ACH-010',
                   'ACH-011', 'ACH-012', 'ACH-013', 'ACH-014'];
      for (final id in ids) {
        final a = UnlockedAchievement(id: id, unlockedAt: DateTime(2026, 1, 1));
        expect(UnlockedAchievement.fromJson(a.toJson()).id, id);
      }
    });
  });
}
