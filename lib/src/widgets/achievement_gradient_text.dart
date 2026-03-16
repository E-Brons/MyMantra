import 'package:flutter/material.dart';

/// Widget that displays text with an animated gradient wave effect.
/// Used for animated achievement rarities (exotic, mythic, legendary, divine).
class AchievementGradientText extends StatefulWidget {
  final String text;
  final List<Color> colors;
  final TextStyle? baseStyle;

  const AchievementGradientText({
    super.key,
    required this.text,
    required this.colors,
    this.baseStyle,
  });

  @override
  State<AchievementGradientText> createState() =>
      _AchievementGradientTextState();
}

class _AchievementGradientTextState extends State<AchievementGradientText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            // Create gradient with more stops for smoother animation
            final stops = <double>[];
            final colors = <Color>[];

            for (int i = 0; i < widget.colors.length; i++) {
              final position = _controller.value + (i / widget.colors.length);
              stops.add(position.remainder(1.0));
              colors.add(widget.colors[i]);
            }

            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: stops,
              colors: colors,
              tileMode: TileMode.mirror,
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style: (widget.baseStyle ?? const TextStyle()).copyWith(
              color: Colors.white, // Required for ShaderMask
              shadows: [
                Shadow(
                  offset: const Offset(2, 2),
                  blurRadius: 3,
                  color: Colors.black.withAlpha(77),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
