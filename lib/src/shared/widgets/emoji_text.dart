import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';

/// A small helper widget for rendering emoji characters in a consistent font.
///
/// On iOS the system emoji font is `AppleColorEmoji`. On other platforms we
/// fall back to `NotoColorEmoji` (bundled in the app) so we don't end up showing
/// placeholder glyphs when the current text style uses a custom font.
class EmojiText extends StatelessWidget {
  const EmojiText(
    this.emoji, {
    super.key,
    this.size = 24,
    this.style,
  });

  final String emoji;
  final double size;
  final TextStyle? style;

  String get _fontFamily => 'NotoColorEmoji';

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
      fontSize: size,
      fontFamily: _fontFamily,
      fontFamilyFallback: const ['NotoColorEmoji'],
    );
    return Text(emoji, style: base.merge(style));
  }
}
