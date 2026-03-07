import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymantra/src/core/models/mantra.dart';
import 'package:mymantra/src/core/providers/app_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Build a fresh [AppNotifier] backed by an in-memory [ProviderContainer],
/// bypassing storage so tests are fully hermetic.
AppNotifier _notifier() {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  return container.read(appProvider.notifier);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // SharedPreferences (used by StorageService) requires the Flutter binding.
  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  // ── createMantra ──────────────────────────────────────────────────────────

  group('AppNotifier.createMantra', () {
    test('default targetCycle is session', () {
      final n = _notifier();
      final m = n.createMantra(title: 'Om', text: 'Om', targetRepetitions: 108);
      expect(m.targetCycle, RepetitionCycle.session);
    });

    test('explicit targetCycle is stored', () {
      final n = _notifier();
      final m = n.createMantra(
        title: 'Om', text: 'Om', targetRepetitions: 108,
        targetCycle: RepetitionCycle.daily,
      );
      expect(m.targetCycle, RepetitionCycle.daily);
    });

    test('mantra is retrievable after create', () {
      final n = _notifier();
      final m = n.createMantra(title: 'Test', text: 'Om', targetRepetitions: 54);
      expect(n.getMantra(m.id)?.targetRepetitions, 54);
    });
  });

  // ── updateMantra ──────────────────────────────────────────────────────────

  group('AppNotifier.updateMantra', () {
    test('targetCycle can be updated independently', () {
      final n = _notifier();
      final m = n.createMantra(title: 'Om', text: 'Om', targetRepetitions: 108);
      n.updateMantra(m.id, targetCycle: RepetitionCycle.weekly);
      expect(n.getMantra(m.id)?.targetCycle, RepetitionCycle.weekly);
    });

    test('updating targetCycle does not change targetRepetitions', () {
      final n = _notifier();
      final m = n.createMantra(title: 'Om', text: 'Om', targetRepetitions: 54);
      n.updateMantra(m.id, targetCycle: RepetitionCycle.daily);
      expect(n.getMantra(m.id)?.targetRepetitions, 54);
    });
  });

  // ── completeSession ───────────────────────────────────────────────────────

  group('AppNotifier.completeSession', () {
    test('default targetCycle is session', () {
      final n = _notifier();
      final m = n.createMantra(title: 'Om', text: 'Om', targetRepetitions: 108);
      n.completeSession(
        mantraId: m.id, mantraTitle: m.title,
        repsCompleted: 108, targetReps: 108,
        duration: 300, startTime: DateTime.now(), completed: true,
      );
      final sessions = n.getRecentSessions(mantraId: m.id);
      expect(sessions.first.targetCycle, RepetitionCycle.session);
    });

    test('explicit targetCycle is stored in session', () {
      final n = _notifier();
      final m = n.createMantra(title: 'Om', text: 'Om', targetRepetitions: 108);
      n.completeSession(
        mantraId: m.id, mantraTitle: m.title,
        repsCompleted: 108, targetReps: 108,
        targetCycle: RepetitionCycle.daily,
        duration: 300, startTime: DateTime.now(), completed: true,
      );
      final sessions = n.getRecentSessions(mantraId: m.id);
      expect(sessions.first.targetCycle, RepetitionCycle.daily);
    });
  });

  // ── getAccumulatedReps ────────────────────────────────────────────────────

  group('AppNotifier.getAccumulatedReps', () {
    test('session cycle always returns 0', () {
      final n = _notifier();
      final m = n.createMantra(title: 'Om', text: 'Om', targetRepetitions: 108);
      n.completeSession(
        mantraId: m.id, mantraTitle: m.title,
        repsCompleted: 50, targetReps: 108,
        duration: 120, startTime: DateTime.now(), completed: false,
      );
      expect(n.getAccumulatedReps(m.id, RepetitionCycle.session), 0);
    });

    test('daily: sums reps from sessions today only', () {
      final n = _notifier();
      final m = n.createMantra(title: 'Om', text: 'Om', targetRepetitions: 108);
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      n.completeSession(
        mantraId: m.id, mantraTitle: m.title,
        repsCompleted: 40, targetReps: 108,
        targetCycle: RepetitionCycle.daily,
        duration: 100, startTime: today, completed: false,
      );
      n.completeSession(
        mantraId: m.id, mantraTitle: m.title,
        repsCompleted: 30, targetReps: 108,
        targetCycle: RepetitionCycle.daily,
        duration: 80, startTime: today, completed: false,
      );
      n.completeSession(
        mantraId: m.id, mantraTitle: m.title,
        repsCompleted: 108, targetReps: 108,
        targetCycle: RepetitionCycle.daily,
        duration: 300, startTime: yesterday, completed: true,
      );

      // Only today's two sessions count (40 + 30 = 70)
      expect(n.getAccumulatedReps(m.id, RepetitionCycle.daily), 70);
    });

    test('daily: returns 0 when no sessions today', () {
      final n = _notifier();
      final m = n.createMantra(title: 'Om', text: 'Om', targetRepetitions: 108);
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      n.completeSession(
        mantraId: m.id, mantraTitle: m.title,
        repsCompleted: 108, targetReps: 108,
        duration: 300, startTime: yesterday, completed: true,
      );
      expect(n.getAccumulatedReps(m.id, RepetitionCycle.daily), 0);
    });

    test('weekly: sums reps from sessions within the ISO week', () {
      final n = _notifier();
      final m = n.createMantra(title: 'Om', text: 'Om', targetRepetitions: 108);
      final now = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final lastMonday = monday.subtract(const Duration(days: 7));

      n.completeSession(
        mantraId: m.id, mantraTitle: m.title,
        repsCompleted: 54, targetReps: 108,
        targetCycle: RepetitionCycle.weekly,
        duration: 150, startTime: monday, completed: false,
      );
      n.completeSession(
        mantraId: m.id, mantraTitle: m.title,
        repsCompleted: 54, targetReps: 108,
        targetCycle: RepetitionCycle.weekly,
        duration: 150, startTime: now, completed: false,
      );
      n.completeSession(
        mantraId: m.id, mantraTitle: m.title,
        repsCompleted: 108, targetReps: 108,
        targetCycle: RepetitionCycle.weekly,
        duration: 300, startTime: lastMonday, completed: true,
      );

      // Only this week's two sessions count (54 + 54 = 108)
      expect(n.getAccumulatedReps(m.id, RepetitionCycle.weekly), 108);
    });

    test('only counts sessions for the given mantraId', () {
      final n = _notifier();
      final m1 = n.createMantra(title: 'Om', text: 'Om', targetRepetitions: 108);
      final m2 = n.createMantra(title: 'Gayatri', text: 'Om Tat', targetRepetitions: 108);
      final today = DateTime.now();

      n.completeSession(
        mantraId: m1.id, mantraTitle: m1.title,
        repsCompleted: 60, targetReps: 108,
        targetCycle: RepetitionCycle.daily,
        duration: 150, startTime: today, completed: false,
      );
      n.completeSession(
        mantraId: m2.id, mantraTitle: m2.title,
        repsCompleted: 108, targetReps: 108,
        targetCycle: RepetitionCycle.daily,
        duration: 300, startTime: today, completed: true,
      );

      expect(n.getAccumulatedReps(m1.id, RepetitionCycle.daily), 60);
      expect(n.getAccumulatedReps(m2.id, RepetitionCycle.daily), 108);
    });
  });
}
