enum RepetitionCycle { session, daily, weekly }

extension RepetitionCycleLabel on RepetitionCycle {
  String get label {
    switch (this) {
      case RepetitionCycle.session:
        return 'Session';
      case RepetitionCycle.daily:
        return 'Daily';
      case RepetitionCycle.weekly:
        return 'Weekly';
    }
  }
}

class Reminder {
  final String id;
  final String time; // "HH:MM"
  final List<int> days; // 0-6, Sun–Sat
  final bool enabled;

  const Reminder({
    required this.id,
    required this.time,
    required this.days,
    required this.enabled,
  });

  Reminder copyWith({
    String? id,
    String? time,
    List<int>? days,
    bool? enabled,
  }) {
    return Reminder(
      id: id ?? this.id,
      time: time ?? this.time,
      days: days ?? this.days,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'time': time,
    'days': days,
    'enabled': enabled,
  };

  factory Reminder.fromJson(Map<String, dynamic> j) => Reminder(
    id: j['id'] as String,
    time: j['time'] as String,
    days: List<int>.from(j['days'] as List),
    enabled: j['enabled'] as bool,
  );
}

class Mantra {
  final String id;
  final String title;
  final String text;
  final String? transliteration;
  final String? translation;
  final int targetRepetitions;
  final RepetitionCycle targetCycle;
  final bool isCustom;
  final String? tradition;
  final List<Reminder> reminders;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Mantra({
    required this.id,
    required this.title,
    required this.text,
    this.transliteration,
    this.translation,
    required this.targetRepetitions,
    this.targetCycle = RepetitionCycle.session,
    required this.isCustom,
    this.tradition,
    required this.reminders,
    required this.createdAt,
    required this.updatedAt,
  });

  Mantra copyWith({
    String? id,
    String? title,
    String? text,
    String? transliteration,
    String? translation,
    int? targetRepetitions,
    RepetitionCycle? targetCycle,
    bool? isCustom,
    String? tradition,
    List<Reminder>? reminders,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Mantra(
      id: id ?? this.id,
      title: title ?? this.title,
      text: text ?? this.text,
      transliteration: transliteration ?? this.transliteration,
      translation: translation ?? this.translation,
      targetRepetitions: targetRepetitions ?? this.targetRepetitions,
      targetCycle: targetCycle ?? this.targetCycle,
      isCustom: isCustom ?? this.isCustom,
      tradition: tradition ?? this.tradition,
      reminders: reminders ?? this.reminders,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'text': text,
    'transliteration': transliteration,
    'translation': translation,
    'targetRepetitions': targetRepetitions,
    'targetCycle': targetCycle.name,
    'isCustom': isCustom,
    'tradition': tradition,
    'reminders': reminders.map((r) => r.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Mantra.fromJson(Map<String, dynamic> j) => Mantra(
    id: j['id'] as String,
    title: j['title'] as String,
    text: j['text'] as String,
    transliteration: j['transliteration'] as String?,
    translation: j['translation'] as String?,
    targetRepetitions: j['targetRepetitions'] as int,
    targetCycle: RepetitionCycle.values.firstWhere(
      (e) => e.name == j['targetCycle'],
      orElse: () => RepetitionCycle.session,
    ),
    isCustom: j['isCustom'] as bool,
    tradition: j['tradition'] as String?,
    reminders: (j['reminders'] as List)
        .map((r) => Reminder.fromJson(r as Map<String, dynamic>))
        .toList(),
    createdAt: DateTime.parse(j['createdAt'] as String),
    updatedAt: DateTime.parse(j['updatedAt'] as String),
  );
}
