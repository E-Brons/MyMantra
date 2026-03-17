import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mantra.dart';
import '../models/session.dart';
import '../models/progress.dart';
import '../models/settings.dart';
import '../models/achievement.dart';
import '../services/storage_service.dart';
import '../utils/date_utils.dart';

// ─── App State ────────────────────────────────────────────────────────────────

class AppState {
  final List<Mantra> mantras;
  final List<Session> sessions;
  final Progress progress;
  final Settings settings;

  const AppState({
    required this.mantras,
    required this.sessions,
    required this.progress,
    required this.settings,
  });

  AppState copyWith({
    List<Mantra>? mantras,
    List<Session>? sessions,
    Progress? progress,
    Settings? settings,
  }) {
    return AppState(
      mantras: mantras ?? this.mantras,
      sessions: sessions ?? this.sessions,
      progress: progress ?? this.progress,
      settings: settings ?? this.settings,
    );
  }

  static AppState initial() => AppState(
    mantras: const [],
    sessions: const [],
    progress: Progress.empty(),
    settings: Settings.defaults(),
  );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class AppNotifier extends Notifier<AppState> {
  @override
  AppState build() {
    _loadFromStorage();
    return AppState.initial();
  }

  Future<void> _loadFromStorage() async {
    final data = await StorageService.instance.load();
    if (data == null) return;
    try {
      final loaded = AppState(
        mantras: (data['mantras'] as List?)
                ?.map((m) => Mantra.fromJson(m as Map<String, dynamic>))
                .toList() ??
            const [],
        sessions: (data['sessions'] as List?)
                ?.map((s) => Session.fromJson(s as Map<String, dynamic>))
                .toList() ??
            [],
        progress: data['progress'] != null
            ? Progress.fromJson(data['progress'] as Map<String, dynamic>)
            : Progress.empty(),
        settings: data['settings'] != null
            ? Settings.fromJson(data['settings'] as Map<String, dynamic>)
            : Settings.defaults(),
      );
      state = loaded;
    } catch (_) {
      // Keep initial state if parse fails
    }
  }

  void _persist() {
    StorageService.instance.save(
      mantras: state.mantras,
      sessions: state.sessions,
      progress: state.progress,
      settings: state.settings,
    );
  }

  // ── Mantra actions ──────────────────────────────────────────────────────────

  Mantra createMantra({
    required String title,
    required String text,
    String? transliteration,
    String? translation,
    required int targetRepetitions,
    RepetitionCycle targetCycle = RepetitionCycle.session,
    String? tradition,
  }) {
    final now = DateTime.now();
    final mantra = Mantra(
      id: generateId(),
      title: title,
      text: text,
      transliteration: transliteration,
      translation: translation,
      targetRepetitions: targetRepetitions,
      targetCycle: targetCycle,
      isCustom: true,
      tradition: tradition,
      reminders: const [],
      createdAt: now,
      updatedAt: now,
    );
    state = state.copyWith(mantras: [mantra, ...state.mantras]);

    // Unlock Creator badge on first custom mantra
    final alreadyUnlocked = state.progress.unlockedAchievements.map((a) => a.id).toSet();
    if (!alreadyUnlocked.contains('ACH-SPL-CREATE')) {
      state = state.copyWith(
        progress: state.progress.copyWith(
          unlockedAchievements: [
            ...state.progress.unlockedAchievements,
            UnlockedAchievement(id: 'ACH-SPL-CREATE', unlockedAt: DateTime.now()),
          ],
        ),
      );
    }

    _persist();
    return mantra;
  }

  void updateMantra(String id, {
    String? title,
    String? text,
    String? transliteration,
    String? translation,
    int? targetRepetitions,
    RepetitionCycle? targetCycle,
    String? tradition,
  }) {
    state = state.copyWith(
      mantras: state.mantras.map((m) {
        if (m.id != id) return m;
        return m.copyWith(
          title: title,
          text: text,
          transliteration: transliteration,
          translation: translation,
          targetRepetitions: targetRepetitions,
          targetCycle: targetCycle,
          tradition: tradition,
          updatedAt: DateTime.now(),
        );
      }).toList(),
    );
    _persist();
  }

  void deleteMantra(String id) {
    state = state.copyWith(
      mantras: state.mantras.where((m) => m.id != id).toList(),
    );
    _persist();
  }

  Mantra? getMantra(String id) {
    try {
      return state.mantras.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Reminder actions ────────────────────────────────────────────────────────

  void addReminder(String mantraId, {
    required String time,
    required List<int> days,
  }) {
    final reminder = Reminder(
      id: generateId(),
      time: time,
      days: days,
      enabled: true,
    );
    state = state.copyWith(
      mantras: state.mantras.map((m) {
        if (m.id != mantraId) return m;
        return m.copyWith(
          reminders: [...m.reminders, reminder],
          updatedAt: DateTime.now(),
        );
      }).toList(),
    );
    _persist();
  }

  void updateReminder(String mantraId, String reminderId, {bool? enabled, String? time, List<int>? days}) {
    state = state.copyWith(
      mantras: state.mantras.map((m) {
        if (m.id != mantraId) return m;
        return m.copyWith(
          reminders: m.reminders.map((r) {
            if (r.id != reminderId) return r;
            return r.copyWith(enabled: enabled, time: time, days: days);
          }).toList(),
          updatedAt: DateTime.now(),
        );
      }).toList(),
    );
    _persist();
  }

  void deleteReminder(String mantraId, String reminderId) {
    state = state.copyWith(
      mantras: state.mantras.map((m) {
        if (m.id != mantraId) return m;
        return m.copyWith(
          reminders: m.reminders.where((r) => r.id != reminderId).toList(),
          updatedAt: DateTime.now(),
        );
      }).toList(),
    );
    _persist();
  }

  // ── Session actions ─────────────────────────────────────────────────────────

  /// Records a completed session, updates streak + stats, returns newly unlocked achievements.
  List<UnlockedAchievement> completeSession({
    required String mantraId,
    required String mantraTitle,
    required int repsCompleted,
    required int targetReps,
    RepetitionCycle targetCycle = RepetitionCycle.session,
    required int duration,
    required DateTime startTime,
    required bool completed,
  }) {
    final session = Session(
      id: generateId(),
      mantraId: mantraId,
      mantraTitle: mantraTitle,
      repsCompleted: repsCompleted,
      targetReps: targetReps,
      targetCycle: targetCycle,
      duration: duration,
      startTime: startTime,
      completed: completed,
    );

    final newTotalSessions = state.progress.totalSessions + 1;
    final newTotalReps = state.progress.totalRepetitions + repsCompleted;

    final streak = calculateStreak(
      lastSessionDate: state.progress.lastSessionDate,
      currentStreak: state.progress.currentStreak,
    );
    final newStreak = streak.currentStreak;
    final newLongest = newStreak > state.progress.longestStreak
        ? newStreak
        : state.progress.longestStreak;

    final newAchievements = _checkNewAchievements(
      progress: state.progress,
      session: session,
      newStreak: newStreak,
      newTotalSessions: newTotalSessions,
      newTotalReps: newTotalReps,
    );

    state = state.copyWith(
      sessions: [session, ...state.sessions],
      progress: state.progress.copyWith(
        currentStreak: newStreak,
        longestStreak: newLongest,
        totalSessions: newTotalSessions,
        totalRepetitions: newTotalReps,
        lastSessionDate: streak.lastSessionDate,
        unlockedAchievements: [
          ...state.progress.unlockedAchievements,
          ...newAchievements,
        ],
      ),
    );
    _persist();
    return newAchievements;
  }

  // ── Settings ────────────────────────────────────────────────────────────────

  void updateSettings(Settings updated) {
    state = state.copyWith(settings: updated);
    _persist();
  }

  // ── Utilities ───────────────────────────────────────────────────────────────

  List<Session> getRecentSessions({String? mantraId, int limit = 10}) {
    var filtered = state.sessions;
    if (mantraId != null) {
      filtered = filtered.where((s) => s.mantraId == mantraId).toList();
    }
    return filtered.take(limit).toList();
  }

  /// Returns the suspended (ongoing) session for [mantraId], if any.
  Session? suspendedSessionFor(String mantraId) {
    try {
      return state.sessions.firstWhere(
        (s) => s.mantraId == mantraId && !s.completed,
      );
    } catch (_) {
      return null;
    }
  }

  /// Discards the suspended session for [mantraId], if any (used when starting a new session).
  void discardSuspendedSession(String mantraId) {
    state = state.copyWith(
      sessions: state.sessions
          .where((s) => !(s.mantraId == mantraId && !s.completed))
          .toList(),
    );
    _persist();
  }

  /// Creates or replaces the suspended session for [mantraId].
  ///
  /// Calling this removes any existing suspended session for the same mantra
  /// and inserts the new one at the front of the list.
  void suspendSession({
    required String mantraId,
    required String mantraTitle,
    required int repsCompleted,
    required int targetReps,
    RepetitionCycle targetCycle = RepetitionCycle.session,
    required int duration,
    required DateTime startTime,
  }) {
    // Drop any prior suspended session for this mantra.
    final filtered = state.sessions
        .where((s) => !(s.mantraId == mantraId && !s.completed))
        .toList();

    final session = Session(
      id: generateId(),
      mantraId: mantraId,
      mantraTitle: mantraTitle,
      repsCompleted: repsCompleted,
      targetReps: targetReps,
      targetCycle: targetCycle,
      duration: duration,
      startTime: startTime,
      completed: false,
    );

    state = state.copyWith(sessions: [session, ...filtered]);
    _persist();
  }

  /// Sum of repsCompleted for [mantraId] within the current day (daily cycle)
  /// or ISO week starting Monday (weekly cycle).
  /// Only counts completed sessions; suspended sessions are excluded.
  /// Returns 0 for [RepetitionCycle.session] — sessions are always independent.
  int getAccumulatedReps(String mantraId, RepetitionCycle cycle) {
    if (cycle == RepetitionCycle.session) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return state.sessions
        .where((s) => s.mantraId == mantraId && s.completed)
        .where((s) {
          final day = DateTime(s.startTime.year, s.startTime.month, s.startTime.day);
          if (cycle == RepetitionCycle.daily) {
            return day == today;
          } else {
            // ISO week: Monday (weekday=1) … Sunday (weekday=7)
            final monday = today.subtract(Duration(days: today.weekday - 1));
            return !day.isBefore(monday);
          }
        })
        .fold(0, (sum, s) => sum + s.repsCompleted);
  }
}

// ─── Achievement checker ──────────────────────────────────────────────────────

List<UnlockedAchievement> _checkNewAchievements({
  required Progress progress,
  required Session session,
  required int newStreak,
  required int newTotalSessions,
  required int newTotalReps,
}) {
  final alreadyUnlocked = progress.unlockedAchievements.map((a) => a.id).toSet();
  final result = <UnlockedAchievement>[];

  for (final ach in kAchievements) {
    if (alreadyUnlocked.contains(ach.id)) continue;
    final hour = session.startTime.hour;
    bool unlock = false;
    switch (ach.metric) {
      case AchievementMetric.sessions:
        unlock = newTotalSessions >= ach.value;
      case AchievementMetric.streak:
        unlock = newStreak >= ach.value;
      case AchievementMetric.totalReps:
        unlock = newTotalReps >= ach.value;
      case AchievementMetric.hour:
        unlock = ach.before == true ? hour < ach.value : hour >= ach.value;
      case AchievementMetric.platform:
        unlock = _matchesPlatform(ach.platformId);
      case AchievementMetric.customMantra:
        break; // handled in createMantra, not via completeSession
    }
    if (unlock) {
      result.add(UnlockedAchievement(id: ach.id, unlockedAt: DateTime.now()));
    }
  }
  return result;
}

bool _matchesPlatform(String? platformId) {
  if (platformId == null) return false;
  if (kIsWeb) return platformId == 'web';
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => platformId == 'android',
    TargetPlatform.iOS     => platformId == 'ios',
    TargetPlatform.macOS   => platformId == 'macos',
    TargetPlatform.linux   => platformId == 'linux',
    _                      => false,
  };
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final appProvider = NotifierProvider<AppNotifier, AppState>(AppNotifier.new);
