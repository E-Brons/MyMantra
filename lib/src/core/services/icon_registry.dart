import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:yaml/yaml.dart';

/// Loads `assets/data/icons.yml` at startup and provides runtime lookups
/// from section/key → [IconData].
///
/// **icons.yml is the single source of truth** for every icon assignment in the
/// app (achievements, tags, categories, progress screen, etc.).
///
/// The [_nameToIconData] table is only a *translator* from Material-icon name
/// strings to Dart [IconData] objects — it does not decide which icon is used
/// where.  To change an icon, edit icons.yml; the app picks it up at next launch.
///
/// Call [IconRegistry.init] once at app startup.
class IconRegistry {
  IconRegistry._();

  static final IconRegistry instance = IconRegistry._();

  late final Map<String, Map<String, IconData>> _sections;
  bool _ready = false;

  bool get ready => _ready;

  // ── Initialisation ──────────────────────────────────────────────────────

  Future<void> init() async {
    if (_ready) return;
    final raw = await rootBundle.loadString('assets/data/icons.yml');
    final doc = loadYaml(raw) as YamlMap;

    _sections = {};
    for (final entry in doc.entries) {
      final sectionName = entry.key as String;
      final sectionMap = entry.value;
      if (sectionMap is! YamlMap) continue;
      final resolved = <String, IconData>{};
      for (final kv in sectionMap.entries) {
        final key = kv.key.toString();
        final iconStr = kv.value.toString().trim();
        final icon = resolve(iconStr);
        if (icon != null) resolved[key] = icon;
      }
      _sections[sectionName] = resolved;
    }
    _ready = true;
  }

  // ── Public lookups ──────────────────────────────────────────────────────

  /// All icons in a named section (e.g. "Achievement Badges", "Tags").
  Map<String, IconData> section(String name) => _sections[name] ?? {};

  /// Single icon from a section.
  IconData? icon(String sectionName, String key) =>
      _sections[sectionName]?[key];

  /// Flat lookup across every section; returns the first match.
  IconData? find(String key) {
    for (final sec in _sections.values) {
      if (sec.containsKey(key)) return sec[key];
    }
    return null;
  }

  // ── Name → IconData resolution ──────────────────────────────────────────

  /// Resolve a string like `"Icons.whatshot"` to an [IconData].
  /// Returns null if the name is unknown.
  static IconData? resolve(String name) {
    final stripped = name.startsWith('Icons.') ? name.substring(6) : name;
    return _nameToIconData[stripped];
  }

  /// Comprehensive translator from Material-icon identifier strings to
  /// [IconData].  This map enables icons.yml to use human-readable names;
  /// add entries here whenever a new icon name is used in the YML.
  static const Map<String, IconData> _nameToIconData = {
    'ac_unit': Icons.ac_unit,
    'access_alarm': Icons.access_alarm,
    'access_time': Icons.access_time,
    'add': Icons.add,
    'add_circle': Icons.add_circle,
    'air': Icons.air,
    'alarm': Icons.alarm,
    'all_inclusive': Icons.all_inclusive,
    'android': Icons.android,
    'api': Icons.api,
    'app_registration': Icons.app_registration,
    'arrow_back': Icons.arrow_back,
    'arrow_forward': Icons.arrow_forward,
    'audiotrack': Icons.audiotrack,
    'auto_awesome': Icons.auto_awesome,
    'auto_fix_high': Icons.auto_fix_high,
    'auto_stories': Icons.auto_stories,
    'blur_circular': Icons.blur_circular,
    'bolt': Icons.bolt,
    'book': Icons.book,
    'bookmark': Icons.bookmark,
    'brightness_1': Icons.brightness_1,
    'brightness_2': Icons.brightness_2,
    'brightness_3': Icons.brightness_3,
    'brightness_4': Icons.brightness_4,
    'brightness_5': Icons.brightness_5,
    'brightness_6': Icons.brightness_6,
    'brightness_7': Icons.brightness_7,
    'castle': Icons.castle,
    'celebration': Icons.celebration,
    'chat_bubble_outline': Icons.chat_bubble_outline,
    'check': Icons.check,
    'check_circle': Icons.check_circle,
    'church': Icons.church,
    'close': Icons.close,
    'cloud': Icons.cloud,
    'dark_mode': Icons.dark_mode,
    'delete': Icons.delete,
    'diamond': Icons.diamond,
    'eco': Icons.eco,
    'edit': Icons.edit,
    'emoji_events': Icons.emoji_events,
    'error_outline': Icons.error_outline,
    'event': Icons.event,
    'explore': Icons.explore,
    'extension': Icons.extension,
    'favorite': Icons.favorite,
    'favorite_border': Icons.favorite_border,
    'filter_drama': Icons.filter_drama,
    'filter_vintage': Icons.filter_vintage,
    'flare': Icons.flare,
    'flash_on': Icons.flash_on,
    'flight': Icons.flight,
    'forest': Icons.forest,
    'front_hand': Icons.front_hand,
    'grass': Icons.grass,
    'healing': Icons.healing,
    'history_edu': Icons.history_edu,
    'home': Icons.home,
    'kayaking': Icons.kayaking,
    'landscape': Icons.landscape,
    'laptop_mac': Icons.laptop_mac,
    'light_mode': Icons.light_mode,
    'lightbulb': Icons.lightbulb,
    'local_fire_department': Icons.local_fire_department,
    'local_florist': Icons.local_florist,
    'lock_outline': Icons.lock_outline,
    'loyalty': Icons.loyalty,
    'menu_book': Icons.menu_book,
    'military_tech': Icons.military_tech,
    'monitor_heart': Icons.monitor_heart,
    'mosque': Icons.mosque,
    'music_note': Icons.music_note,
    'nightlight_round': Icons.nightlight_round,
    'nights_stay': Icons.nights_stay,
    'opacity': Icons.opacity,
    'park': Icons.park,
    'phone_iphone': Icons.phone_iphone,
    'pool': Icons.pool,
    'psychology': Icons.psychology,
    'psychology_alt': Icons.psychology_alt,
    'public': Icons.public,
    'queue_music': Icons.queue_music,
    'radio_button_checked': Icons.radio_button_checked,
    'sailing': Icons.sailing,
    'school': Icons.school,
    'search': Icons.search,
    'security': Icons.security,
    'self_improvement': Icons.self_improvement,
    'settings': Icons.settings,
    'settings_accessibility': Icons.settings_accessibility,
    'settings_suggest': Icons.settings_suggest,
    'shield': Icons.shield,
    'spa': Icons.spa,
    'star': Icons.star,
    'star_border': Icons.star_border,
    'star_rate': Icons.star_rate,
    'stars': Icons.stars,
    'surfing': Icons.surfing,
    'synagogue': Icons.synagogue,
    'temple_buddhist': Icons.temple_buddhist,
    'temple_hindu': Icons.temple_hindu,
    'terrain': Icons.terrain,
    'terminal': Icons.terminal,
    'thumb_up': Icons.thumb_up,
    'trending_up': Icons.trending_up,
    'tsunami': Icons.tsunami,
    'verified': Icons.verified,
    'visibility': Icons.visibility,
    'volunteer_activism': Icons.volunteer_activism,
    'water_drop': Icons.water_drop,
    'waves': Icons.waves,
    'wb_sunny': Icons.wb_sunny,
    'wb_twilight': Icons.wb_twilight,
    'whatshot': Icons.whatshot,
    'workspace_premium': Icons.workspace_premium,
  };
}
