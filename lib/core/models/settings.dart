enum AppThemeMode { light, dark, system }

class Settings {
  final AppThemeMode theme;
  final bool notificationsEnabled;
  final bool vibrationEnabled;
  final int defaultRepetitions;
  final String fontSize; // 'small' | 'medium' | 'large'

  const Settings({
    required this.theme,
    required this.notificationsEnabled,
    required this.vibrationEnabled,
    required this.defaultRepetitions,
    required this.fontSize,
  });

  static Settings defaults() => const Settings(
    theme: AppThemeMode.dark,
    notificationsEnabled: true,
    vibrationEnabled: true,
    defaultRepetitions: 108,
    fontSize: 'medium',
  );

  AppThemeMode get effectiveTheme => theme;

  Settings copyWith({
    AppThemeMode? theme,
    bool? notificationsEnabled,
    bool? vibrationEnabled,
    int? defaultRepetitions,
    String? fontSize,
  }) {
    return Settings(
      theme: theme ?? this.theme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      defaultRepetitions: defaultRepetitions ?? this.defaultRepetitions,
      fontSize: fontSize ?? this.fontSize,
    );
  }

  Map<String, dynamic> toJson() => {
    'theme': theme.name,
    'notificationsEnabled': notificationsEnabled,
    'vibrationEnabled': vibrationEnabled,
    'defaultRepetitions': defaultRepetitions,
    'fontSize': fontSize,
  };

  factory Settings.fromJson(Map<String, dynamic> j) => Settings(
    theme: AppThemeMode.values.firstWhere(
      (e) => e.name == j['theme'],
      orElse: () => AppThemeMode.dark,
    ),
    notificationsEnabled: j['notificationsEnabled'] as bool? ?? true,
    vibrationEnabled: j['vibrationEnabled'] as bool? ?? true,
    defaultRepetitions: j['defaultRepetitions'] as int? ?? 108,
    fontSize: j['fontSize'] as String? ?? 'medium',
  );
}
