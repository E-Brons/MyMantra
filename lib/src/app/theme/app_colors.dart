import 'package:flutter/material.dart';
import '../../core/services/theme_registry.dart';

/// App-wide colour tokens, resolved from `assets/data/theme.yml` at runtime.
///
/// Call [AppColors.setBrightness] when the theme changes.
/// **theme.yml is the single source of truth** — no hex values are hardcoded here.
class AppColors {
  AppColors._();

  static Brightness _brightness = Brightness.dark;

  static void setBrightness(Brightness b) => _brightness = b;
  static bool get isDark => _brightness == Brightness.dark;

  static ThemeRegistry get _r => ThemeRegistry.instance;

  // ── Brand (from Dark palette, shared) ────────────────────────────────
  static Color get violet300 => _r.dark('Brand.violet300');
  static Color get violet400 => _r.dark('Brand.violet400');
  static Color get violet500 => _r.dark('Brand.violet500');
  static Color get violet600 => _r.dark('Brand.violet600');
  static Color get violet700 => _r.dark('Brand.violet700');

  // ── Background layers ────────────────────────────────────────────────
  static Color get bgBase    => _r.color('Background.base',    _brightness);
  static Color get bgSurface => _r.color('Background.surface', _brightness);
  static Color get bgCard    => _r.color('Background.card',    _brightness);
  static Color get sessionBg => _r.dark('Background.session');

  // ── Text ─────────────────────────────────────────────────────────────
  static Color get textPrimary   => _r.color('Text.primary',   _brightness);
  static Color get textSecondary => _r.color('Text.secondary', _brightness);
  static Color get textMuted     => _r.color('Text.muted',     _brightness);

  // ── Accent ───────────────────────────────────────────────────────────
  static Color get orange  => _r.dark('Accent.orange');
  static Color get emerald => _r.dark('Accent.emerald');
  static Color get red     => _r.dark('Accent.red');
  static Color get amber   => _r.dark('Accent.amber');

  // ── Borders ──────────────────────────────────────────────────────────
  static Color get border       => _r.color('Border.default', _brightness);
  static Color get borderSubtle => _r.color('Border.subtle',  _brightness);
}
