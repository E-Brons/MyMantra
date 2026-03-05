class UnlockedAchievement {
  final String id;
  final DateTime unlockedAt;

  const UnlockedAchievement({required this.id, required this.unlockedAt});

  Map<String, dynamic> toJson() => {
    'id': id,
    'unlockedAt': unlockedAt.toIso8601String(),
  };

  factory UnlockedAchievement.fromJson(Map<String, dynamic> j) =>
      UnlockedAchievement(
        id: j['id'] as String,
        unlockedAt: DateTime.parse(j['unlockedAt'] as String),
      );
}

class Progress {
  final int currentStreak;
  final int longestStreak;
  final int totalSessions;
  final int totalRepetitions;
  final DateTime? lastSessionDate;
  final List<UnlockedAchievement> unlockedAchievements;
  final DateTime memberSince;

  const Progress({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalSessions,
    required this.totalRepetitions,
    this.lastSessionDate,
    required this.unlockedAchievements,
    required this.memberSince,
  });

  static Progress empty() => Progress(
    currentStreak: 0,
    longestStreak: 0,
    totalSessions: 0,
    totalRepetitions: 0,
    lastSessionDate: null,
    unlockedAchievements: const [],
    memberSince: DateTime.now(),
  );

  Progress copyWith({
    int? currentStreak,
    int? longestStreak,
    int? totalSessions,
    int? totalRepetitions,
    DateTime? lastSessionDate,
    bool clearLastSessionDate = false,
    List<UnlockedAchievement>? unlockedAchievements,
    DateTime? memberSince,
  }) {
    return Progress(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalSessions: totalSessions ?? this.totalSessions,
      totalRepetitions: totalRepetitions ?? this.totalRepetitions,
      lastSessionDate: clearLastSessionDate
          ? null
          : (lastSessionDate ?? this.lastSessionDate),
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      memberSince: memberSince ?? this.memberSince,
    );
  }

  Map<String, dynamic> toJson() => {
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'totalSessions': totalSessions,
    'totalRepetitions': totalRepetitions,
    'lastSessionDate': lastSessionDate?.toIso8601String(),
    'unlockedAchievements':
        unlockedAchievements.map((a) => a.toJson()).toList(),
    'memberSince': memberSince.toIso8601String(),
  };

  factory Progress.fromJson(Map<String, dynamic> j) => Progress(
    currentStreak: j['currentStreak'] as int,
    longestStreak: j['longestStreak'] as int,
    totalSessions: j['totalSessions'] as int,
    totalRepetitions: j['totalRepetitions'] as int,
    lastSessionDate: j['lastSessionDate'] != null
        ? DateTime.parse(j['lastSessionDate'] as String)
        : null,
    unlockedAchievements: (j['unlockedAchievements'] as List)
        .map((a) => UnlockedAchievement.fromJson(a as Map<String, dynamic>))
        .toList(),
    memberSince: DateTime.parse(j['memberSince'] as String),
  );
}
