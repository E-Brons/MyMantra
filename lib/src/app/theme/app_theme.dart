import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import '../../core/services/theme_registry.dart';

class AppTheme {
  AppTheme._();

  static ThemeRegistry get _r => ThemeRegistry.instance;

  static ThemeData dark() {
    AppColors.setBrightness(Brightness.dark);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: _r.dark('Brand.violet600'),
        onPrimary: Colors.white,
        primaryContainer: _r.dark('Brand.violet700'),
        secondary: _r.dark('Brand.violet500'),
        onSecondary: Colors.white,
        surface: _r.dark('Background.surface'),
        onSurface: _r.dark('Text.primary'),
        surfaceContainerHighest: _r.dark('Background.card'),
        outline: _r.dark('Border.default'),
        error: _r.dark('Accent.red'),
      ),
      scaffoldBackgroundColor: _r.dark('Background.base'),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: _r.dark('Text.primary'),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: _r.dark('Text.primary')),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _r.dark('Background.surface'),
        selectedItemColor: _r.dark('Brand.violet400'),
        unselectedItemColor: _r.dark('Text.muted'),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: _r.dark('Text.primary'), fontFamily: 'Cinzel'),
        displayMedium: TextStyle(color: _r.dark('Text.primary'), fontFamily: 'Cinzel'),
        headlineLarge: TextStyle(color: _r.dark('Text.primary'), fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(color: _r.dark('Text.primary'), fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: _r.dark('Text.primary'), fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: _r.dark('Text.primary'), fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: _r.dark('Text.primary')),
        bodyMedium: TextStyle(color: _r.dark('Text.secondary')),
        bodySmall: TextStyle(color: _r.dark('Text.muted')),
        labelLarge: TextStyle(color: _r.dark('Text.primary'), fontWeight: FontWeight.w600),
        labelMedium: TextStyle(color: _r.dark('Text.secondary')),
        labelSmall: TextStyle(color: _r.dark('Text.muted')),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _r.dark('Brand.violet400').withAlpha(0x14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _r.dark('Border.default')),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _r.dark('Border.subtle')),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _r.dark('Brand.violet500'), width: 1.5),
        ),
        labelStyle: TextStyle(color: _r.dark('Text.muted')),
        hintStyle: TextStyle(color: _r.dark('Text.muted')),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _r.dark('Brand.violet600'),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: _r.dark('Background.card'),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _r.dark('Border.subtle')),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: _r.dark('Border.subtle'),
        thickness: 1,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData light() {
    AppColors.setBrightness(Brightness.light);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: _r.light('Brand.primary'),
        onPrimary: Colors.white,
        primaryContainer: _r.dark('Brand.violet300'),
        secondary: _r.dark('Brand.violet600'),
        onSecondary: Colors.white,
        surface: _r.light('Background.surface'),
        onSurface: _r.light('Text.primary'),
        surfaceContainerHighest: _r.light('Background.card'),
        outline: _r.light('Border.default'),
        error: _r.dark('Accent.red'),
      ),
      scaffoldBackgroundColor: _r.light('Background.base'),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: _r.light('Text.primary'),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: _r.light('Text.primary')),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _r.light('Background.surface'),
        selectedItemColor: _r.light('Brand.primary'),
        unselectedItemColor: _r.light('Text.muted'),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: _r.light('Text.primary'), fontFamily: 'Cinzel'),
        displayMedium: TextStyle(color: _r.light('Text.primary'), fontFamily: 'Cinzel'),
        headlineLarge: TextStyle(color: _r.light('Text.primary'), fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(color: _r.light('Text.primary'), fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: _r.light('Text.primary'), fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: _r.light('Text.primary'), fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: _r.light('Text.primary')),
        bodyMedium: TextStyle(color: _r.light('Text.secondary')),
        bodySmall: TextStyle(color: _r.light('Text.muted')),
        labelLarge: TextStyle(color: _r.light('Text.primary'), fontWeight: FontWeight.w600),
        labelMedium: TextStyle(color: _r.light('Text.secondary')),
        labelSmall: TextStyle(color: _r.light('Text.muted')),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _r.light('Brand.primary').withAlpha(0x14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _r.light('Border.default')),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _r.light('Border.subtle')),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _r.dark('Brand.violet500'), width: 1.5),
        ),
        labelStyle: TextStyle(color: _r.light('Text.muted')),
        hintStyle: TextStyle(color: _r.light('Text.muted')),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _r.light('Brand.primary'),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: _r.light('Background.card'),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _r.light('Border.subtle')),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: _r.light('Border.subtle'),
        thickness: 1,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
