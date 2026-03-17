import 'package:flutter_test/flutter_test.dart';
import 'package:mymantra/src/core/models/mantra.dart';
import 'package:mymantra/src/core/models/session.dart';

void main() {
  group('Session — serialisation', () {
    final base = Session(
      id: 'sess-001',
      mantraId: 'mantra-abc',
      mantraTitle: 'Om Mani Padme Hum',
      repsCompleted: 108,
      targetReps: 108,
      duration: 325, // seconds
      startTime: DateTime(2026, 3, 7, 7, 15, 0),
      completed: true,
    );

    test('all fields survive toJson / fromJson round-trip', () {
      final s = Session.fromJson(base.toJson());
      expect(s.id, base.id);
      expect(s.mantraId, base.mantraId);
      expect(s.mantraTitle, base.mantraTitle);
      expect(s.repsCompleted, base.repsCompleted);
      expect(s.targetReps, base.targetReps);
      expect(s.duration, base.duration);
      expect(s.startTime, base.startTime);
      expect(s.completed, base.completed);
    });

    test('partial session (completed=false) serialises correctly', () {
      final partial = Session(
        id: 'sess-002',
        mantraId: 'mantra-abc',
        mantraTitle: 'Gayatri Mantra',
        repsCompleted: 54,
        targetReps: 108,
        duration: 180,
        startTime: DateTime(2026, 3, 7, 22, 0),
        completed: false,
      );
      final s = Session.fromJson(partial.toJson());
      expect(s.completed, isFalse);
      expect(s.repsCompleted, 54);
    });

    test('zero-rep zero-duration session serialises', () {
      final zero = Session(
        id: 'sess-003',
        mantraId: 'm-1',
        mantraTitle: 'Test',
        repsCompleted: 0,
        targetReps: 108,
        duration: 0,
        startTime: DateTime(2026, 3, 7),
        completed: false,
      );
      final s = Session.fromJson(zero.toJson());
      expect(s.repsCompleted, 0);
      expect(s.duration, 0);
    });

    test('repsCompleted can exceed targetReps', () {
      // Users may tap past the target before auto-complete fires
      final over = Session(
        id: 'sess-004',
        mantraId: 'm-1',
        mantraTitle: 'Om',
        repsCompleted: 110,
        targetReps: 108,
        duration: 300,
        startTime: DateTime(2026, 3, 7),
        completed: true,
      );
      expect(Session.fromJson(over.toJson()).repsCompleted, 110);
    });

    test('Unicode mantra title survives round-trip', () {
      final unicode = Session(
        id: 'sess-005',
        mantraId: 'm-2',
        mantraTitle: 'ॐ नमः शिवाय',
        repsCompleted: 108,
        targetReps: 108,
        duration: 300,
        startTime: DateTime(2026, 1, 1),
        completed: true,
      );
      expect(Session.fromJson(unicode.toJson()).mantraTitle, 'ॐ नमः शिवाय');
    });

    test('startTime DateTime precision preserved', () {
      final precise = Session(
        id: 'sess-006',
        mantraId: 'm-1',
        mantraTitle: 'Om',
        repsCompleted: 108,
        targetReps: 108,
        duration: 300,
        startTime: DateTime(2026, 3, 7, 23, 59, 58),
        completed: true,
      );
      expect(Session.fromJson(precise.toJson()).startTime, DateTime(2026, 3, 7, 23, 59, 58));
    });
  });

  // ── targetCycle ───────────────────────────────────────────────────────────

  group('Session — targetCycle serialisation', () {
    Session makeSession({RepetitionCycle cycle = RepetitionCycle.session}) => Session(
      id: 's-cyc', mantraId: 'm-1', mantraTitle: 'Om',
      repsCompleted: 108, targetReps: 108, targetCycle: cycle,
      duration: 300, startTime: DateTime(2026, 1, 1), completed: true,
    );

    test('default targetCycle is session', () {
      final s = Session(
        id: 's-def', mantraId: 'm-1', mantraTitle: 'Om',
        repsCompleted: 108, targetReps: 108,
        duration: 300, startTime: DateTime(2026, 1, 1), completed: true,
      );
      expect(s.targetCycle, RepetitionCycle.session);
    });

    test('session cycle survives round-trip', () {
      expect(Session.fromJson(makeSession(cycle: RepetitionCycle.session).toJson()).targetCycle,
          RepetitionCycle.session);
    });

    test('daily cycle survives round-trip', () {
      expect(Session.fromJson(makeSession(cycle: RepetitionCycle.daily).toJson()).targetCycle,
          RepetitionCycle.daily);
    });

    test('weekly cycle survives round-trip', () {
      expect(Session.fromJson(makeSession(cycle: RepetitionCycle.weekly).toJson()).targetCycle,
          RepetitionCycle.weekly);
    });

    test('missing targetCycle in old JSON falls back to session', () {
      final json = makeSession().toJson()..remove('targetCycle');
      expect(Session.fromJson(json).targetCycle, RepetitionCycle.session);
    });
  });

  // ── copyWith ──────────────────────────────────────────────────────────────

  group('Session.copyWith', () {
    final base = Session(
      id: 'cw-01',
      mantraId: 'm-1',
      mantraTitle: 'Om',
      repsCompleted: 0,
      targetReps: 108,
      duration: 0,
      startTime: DateTime(2026, 1, 1),
      completed: false,
    );

    test('no-arg copyWith returns equal values', () {
      final copy = base.copyWith();
      expect(copy.id, base.id);
      expect(copy.completed, base.completed);
      expect(copy.repsCompleted, base.repsCompleted);
    });

    test('copyWith updates repsCompleted', () {
      final copy = base.copyWith(repsCompleted: 54);
      expect(copy.repsCompleted, 54);
      expect(copy.targetReps, base.targetReps);
    });

    test('copyWith marks completed', () {
      final copy = base.copyWith(completed: true, repsCompleted: 108, duration: 300);
      expect(copy.completed, isTrue);
      expect(copy.repsCompleted, 108);
      expect(copy.duration, 300);
    });

    test('copyWith does not mutate original', () {
      base.copyWith(completed: true);
      expect(base.completed, isFalse);
    });
  });
}
