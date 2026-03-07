import 'package:uuid/uuid.dart';

const _uuid = Uuid();

String generateId() => _uuid.v4();

String todayDateStr() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

String dateStr(DateTime dt) {
  return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

String formatTime(int seconds) {
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

String formatDuration(int seconds) {
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return '${m}m ${s}s';
}

({int currentStreak, int longestStreak, DateTime lastSessionDate}) calculateStreak({
  required DateTime? lastSessionDate,
  required int currentStreak,
}) {
  final today = DateTime.now();
  final todayStr = dateStr(today);
  final yesterday = today.subtract(const Duration(days: 1));
  final yesterdayStr = dateStr(yesterday);
  final lastStr = lastSessionDate != null ? dateStr(lastSessionDate) : null;

  int newStreak;
  if (lastStr == null) {
    newStreak = 1;
  } else if (lastStr == todayStr) {
    newStreak = currentStreak; // already practiced today
  } else if (lastStr == yesterdayStr) {
    newStreak = currentStreak + 1; // consecutive day
  } else {
    newStreak = 1; // gap — reset
  }

  return (
    currentStreak: newStreak,
    longestStreak: newStreak,
    lastSessionDate: today,
  );
}
