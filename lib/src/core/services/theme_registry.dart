import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:yaml/yaml.dart';

/// Loads `assets/data/theme.yml` at startup and exposes every colour token
/// so the rest of the app never hardcodes hex values.
///
/// Call [ThemeRegistry.init] once (after `WidgetsFlutterBinding`).
class ThemeRegistry {
  ThemeRegistry._();
  static final ThemeRegistry instance = ThemeRegistry._();

  bool _ready = false;
  bool get ready => _ready;

  // ── Parsed colour maps ────────────────────────────────────────────────
  late final Map<String, Color> _darkColors;
  late final Map<String, Color> _lightColors;
  late final Map<String, List<Color>> _darkGradients;
  late final Map<String, List<Color>> _lightGradients;

  Future<void> init() async {
    if (_ready) return;
    final raw = await rootBundle.loadString('assets/data/theme.yml');
    final doc = loadYaml(raw) as YamlMap;

    _darkColors = _flattenSection(doc['Dark'] as YamlMap?);
    _lightColors = _flattenSection(doc['Light'] as YamlMap?);
    _darkGradients = _flattenGradients(doc['Dark'] as YamlMap?);
    _lightGradients = _flattenGradients(doc['Light'] as YamlMap?);
    _ready = true;
  }

  /// Retrieve a colour by dot-path (e.g. "Text.primary") for the given
  /// brightness, falling back to the dark palette if the light palette
  /// doesn't define it.
  Color color(String key, Brightness brightness) {
    if (!_ready) {
      return const Color(0xFFFF00FF); // magenta = missing/uninitialized
    }
    final map = brightness == Brightness.dark ? _darkColors : _lightColors;
    return map[key] ?? _darkColors[key] ?? const Color(0xFFFF00FF); // magenta = missing
  }

  Color dark(String key) => color(key, Brightness.dark);
  Color light(String key) => color(key, Brightness.light);

  /// Retrieve a gradient (color array) by dot-path for the given brightness.
  List<Color>? gradient(String key, Brightness brightness) {
    if (!_ready) return null;
    final map = brightness == Brightness.dark ? _darkGradients : _lightGradients;
    return map[key] ?? _darkGradients[key];
  }

  List<Color>? darkGradient(String key) => gradient(key, Brightness.dark);
  List<Color>? lightGradient(String key) => gradient(key, Brightness.light);

  // ── Internal helpers ──────────────────────────────────────────────────

  /// Walk a YamlMap tree like { Brand: { violet300: "#C4B5FD" } } and produce
  /// a flat map: { "Brand.violet300": Color(...), "violet300": Color(...) }.
  /// Both the fully-qualified and short key are stored so callers can use
  /// either form.
  static Map<String, Color> _flattenSection(YamlMap? section) {
    final result = <String, Color>{};
    if (section == null) return result;
    for (final topEntry in section.entries) {
      final groupName = topEntry.key.toString();
      final value = topEntry.value;
      if (value is YamlMap) {
        for (final kv in value.entries) {
          final leafKey = kv.key.toString();
          // Skip arrays (handled by _flattenGradients)
          if (kv.value is! YamlList) {
            final color = _parseColor(kv.value.toString());
            if (color != null) {
              result['$groupName.$leafKey'] = color;
              // Also store by short key (last wins if duplicated across groups).
              result[leafKey] = color;
            }
          }
        }
      }
    }
    return result;
  }

  /// Extract color arrays (gradients) from YamlMap.
  static Map<String, List<Color>> _flattenGradients(YamlMap? section) {
    final result = <String, List<Color>>{};
    if (section == null) return result;
    for (final topEntry in section.entries) {
      final groupName = topEntry.key.toString();
      final value = topEntry.value;
      if (value is YamlMap) {
        for (final kv in value.entries) {
          final leafKey = kv.key.toString();
          if (kv.value is YamlList) {
            final colors = <Color>[];
            for (final item in (kv.value as YamlList)) {
              final color = _parseColor(item.toString());
              if (color != null) colors.add(color);
            }
            if (colors.isNotEmpty) {
              result['$groupName.$leafKey'] = colors;
              result[leafKey] = colors;
            }
          }
        }
      }
    }
    return result;
  }

  /// Parse "#RRGGBB", "#RRGGBBAA", or "#AARRGGBB"-style hex strings.
  static Color? _parseColor(String raw) {
    // Strip surrounding quotes and comments (e.g. '#A78BFA33    # violet400 / 20%')
    var hex = raw.replaceAll(RegExp(r'#.*$'), '').trim(); // remove trailing comment
    // But that also removes the leading #.  Re-parse from the original.
    hex = raw.trim();
    if (hex.contains('#')) {
      // Take only the first # token
      hex = hex.split(RegExp(r'\s+')).firstWhere((s) => s.startsWith('"#') || s.startsWith('#'), orElse: () => hex);
    }
    hex = hex.replaceAll('"', '').replaceAll("'", '').trim();
    if (!hex.startsWith('#')) return null;
    hex = hex.substring(1); // strip '#'

    if (hex.length == 6) {
      final v = int.tryParse('FF$hex', radix: 16);
      return v != null ? Color(v) : null;
    }
    if (hex.length == 8) {
      // Could be RRGGBBAA or AARRGGBB.  theme.yml uses RRGGBBAA.
      final v = int.tryParse(hex, radix: 16);
      if (v == null) return null;
      // Swap from RRGGBBAA → AARRGGBB (Flutter's format).
      final r = (v >> 24) & 0xFF;
      final g = (v >> 16) & 0xFF;
      final b = (v >> 8) & 0xFF;
      final a = v & 0xFF;
      return Color.fromARGB(a, r, g, b);
    }
    return null;
  }
}
