import 'mantra.dart';

enum AppThemeMode { light, dark, system }

class Settings {
  final AppThemeMode theme;
  final bool notificationsEnabled;
  final bool vibrationEnabled;
  final int defaultRepetitions;
  final RepetitionCycle defaultRepetitionCycle;
  final bool limitClickRate;
  final String fontSize; // 'small' | 'medium' | 'large'

  const Settings({
    required this.theme,
    required this.notificationsEnabled,
    required this.vibrationEnabled,
    required this.defaultRepetitions,
    this.defaultRepetitionCycle = RepetitionCycle.session,
    this.limitClickRate = true,
    required this.fontSize,
  });

  static Settings defaults() => const Settings(
    theme: AppThemeMode.dark,
    notificationsEnabled: true,
    vibrationEnabled: true,
    defaultRepetitions: 108,
    defaultRepetitionCycle: RepetitionCycle.session,
    limitClickRate: true,
    fontSize: 'medium',
  );

  AppThemeMode get effectiveTheme => theme;

  Settings copyWith({
    AppThemeMode? theme,
    bool? notificationsEnabled,
    bool? vibrationEnabled,
    int? defaultRepetitions,
    RepetitionCycle? defaultRepetitionCycle,
    bool? limitClickRate,
    String? fontSize,
  }) {
    return Settings(
      theme: theme ?? this.theme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      defaultRepetitions: defaultRepetitions ?? this.defaultRepetitions,
      defaultRepetitionCycle: defaultRepetitionCycle ?? this.defaultRepetitionCycle,
      limitClickRate: limitClickRate ?? this.limitClickRate,
      fontSize: fontSize ?? this.fontSize,
    );
  }

  Map<String, dynamic> toJson() => {
    'theme': theme.name,
    'notificationsEnabled': notificationsEnabled,
    'vibrationEnabled': vibrationEnabled,
    'defaultRepetitions': defaultRepetitions,
    'defaultRepetitionCycle': defaultRepetitionCycle.name,
    'limitClickRate': limitClickRate,
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
    defaultRepetitionCycle: RepetitionCycle.values.firstWhere(
      (e) => e.name == j['defaultRepetitionCycle'],
      orElse: () => RepetitionCycle.session,
    ),
    limitClickRate: j['limitClickRate'] as bool? ?? true,
    fontSize: j['fontSize'] as String? ?? 'medium',
  );
}
