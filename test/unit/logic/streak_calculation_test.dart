import 'package:flutter_test/flutter_test.dart';
import 'package:mymantra/src/core/utils/date_utils.dart';

// Note: calculateStreak() calls DateTime.now() internally, so the test inputs
// are computed relative to "now" so they stay correct regardless of when the
// suite runs.

void main() {
  group('calculateStreak()', () {
    test('very first session ever → streak starts at 1', () {
      final result = calculateStreak(lastSessionDate: null, currentStreak: 0);
      expect(result.currentStreak, 1);
    });

    test('second session on the same day → streak stays the same', () {
      final today = DateTime.now();
      final result = calculateStreak(lastSessionDate: today, currentStreak: 5);
      expect(result.currentStreak, 5);
    });

    test('session on consecutive day → streak increments by 1', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final result = calculateStreak(lastSessionDate: yesterday, currentStreak: 4);
      expect(result.currentStreak, 5);
    });

    test('2-day gap → streak resets to 1', () {
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      final result = calculateStreak(lastSessionDate: twoDaysAgo, currentStreak: 7);
      expect(result.currentStreak, 1);
    });

    test('1-week gap → streak resets to 1', () {
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final result = calculateStreak(lastSessionDate: weekAgo, currentStreak: 100);
      expect(result.currentStreak, 1);
    });

    test('1-year gap → streak resets to 1', () {
      final yearAgo = DateTime.now().subtract(const Duration(days: 365));
      final result = calculateStreak(lastSessionDate: yearAgo, currentStreak: 30);
      expect(result.currentStreak, 1);
    });

    test('lastSessionDate in result is today', () {
      final result = calculateStreak(lastSessionDate: null, currentStreak: 0);
      final todayStr = dateStr(DateTime.now());
      expect(dateStr(result.lastSessionDate), todayStr);
    });

    test('same-day session on day 1 keeps streak at 1 (not 0)', () {
      final today = DateTime.now();
      final result = calculateStreak(lastSessionDate: today, currentStreak: 1);
      expect(result.currentStreak, 1);
    });

    test('consecutive build-up: null → yesterday → today produces streak 2', () {
      // Simulate two consecutive days
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      calculateStreak(lastSessionDate: null, currentStreak: 0);
      // first call gives streak=1, last=today
      // Now pretend that happened "yesterday" by computing as if yesterday was today
      final step2 = calculateStreak(lastSessionDate: yesterday, currentStreak: 1);
      expect(step2.currentStreak, 2);
    });
  });

  // ── dateStr() ─────────────────────────────────────────────────────────────

  group('dateStr()', () {
    test('formats single-digit month and day with zero padding', () {
      expect(dateStr(DateTime(2026, 3, 7)), '2026-03-07');
    });

    test('formats January 1st', () {
      expect(dateStr(DateTime(2026, 1, 1)), '2026-01-01');
    });

    test('formats December 31st', () {
      expect(dateStr(DateTime(2026, 12, 31)), '2026-12-31');
    });

    test('time component does not affect date string', () {
      expect(dateStr(DateTime(2026, 3, 7, 23, 59, 59)), '2026-03-07');
      expect(dateStr(DateTime(2026, 3, 7, 0, 0, 0)), '2026-03-07');
    });
  });

  // ── formatTime() ──────────────────────────────────────────────────────────

  group('formatTime()', () {
    test('zero seconds → 00:00', () => expect(formatTime(0), '00:00'));
    test('65 seconds → 01:05', () => expect(formatTime(65), '01:05'));
    test('3600 seconds → 60:00', () => expect(formatTime(3600), '60:00'));
    test('single-digit seconds padded → 00:09', () => expect(formatTime(9), '00:09'));
    test('59 seconds → 00:59', () => expect(formatTime(59), '00:59'));
    test('60 seconds → 01:00', () => expect(formatTime(60), '01:00'));
  });

  // ── formatDuration() ──────────────────────────────────────────────────────

  group('formatDuration()', () {
    test('0 seconds → 0m 0s', () => expect(formatDuration(0), '0m 0s'));
    test('65 seconds → 1m 5s', () => expect(formatDuration(65), '1m 5s'));
    test('3661 seconds → 61m 1s', () => expect(formatDuration(3661), '61m 1s'));
    test('60 seconds → 1m 0s', () => expect(formatDuration(60), '1m 0s'));
    test('108 seconds → 1m 48s', () => expect(formatDuration(108), '1m 48s'));
  });
}
