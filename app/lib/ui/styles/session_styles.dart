import 'package:flutter/material.dart';

import 'app_tokens.dart';

class SessionStyles {
  const SessionStyles({
    required this.screenPadding,
    required this.numberTextStyle,
    required this.numberShadows,
    required this.headerRoundTextStyle,
    required this.headerTimerTextStyle,
    required this.restIndicatorSize,
    required this.restStrokeWidth,
    required this.restIndicatorBackground,
    required this.restSecondsTextStyle,
    required this.overlayMaxWidth,
    required this.overlayCardColor,
    required this.overlayScrimColor,
    required this.overlayTitleStyle,
    required this.overlayPadding,
    required this.hintTextStyle,
    required this.overlayButtonSpacing,
    required this.overlayButtonMinHeight,
  });

  final EdgeInsets screenPadding;
  final TextStyle numberTextStyle;
  final List<Shadow> numberShadows;
  final TextStyle headerRoundTextStyle;
  final TextStyle headerTimerTextStyle;
  final double restIndicatorSize;
  final double restStrokeWidth;
  final Color restIndicatorBackground;
  final TextStyle restSecondsTextStyle;
  final double overlayMaxWidth;
  final Color overlayCardColor;
  final Color overlayScrimColor;
  final TextStyle overlayTitleStyle;
  final EdgeInsets overlayPadding;
  final TextStyle hintTextStyle;
  final double overlayButtonSpacing;
  final double overlayButtonMinHeight;

  factory SessionStyles.defaults(ThemeData theme,
      {bool largeSessionText = false}) {
    final textTheme = theme.textTheme;
    final double numberSize = largeSessionText ? 300 : 180;
    final baseNumberStyle =
        (textTheme.displayLarge ?? const TextStyle()).copyWith(
      fontSize: numberSize,
      fontWeight: FontWeight.bold,
      height: 1,
      fontFeatures: const [FontFeature.tabularFigures()],
      shadows: const [
        Shadow(
          color: Color.fromRGBO(0, 0, 0, 0.35),
          blurRadius: 12,
          offset: Offset(0, 2),
        ),
      ],
    );
    return SessionStyles(
      screenPadding: AppTokens.screenPadding,
      numberTextStyle: baseNumberStyle,
      numberShadows: const [
        Shadow(
          color: Color.fromRGBO(0, 0, 0, 0.35),
          blurRadius: 12,
          offset: Offset(0, 2),
        ),
      ],
      headerRoundTextStyle: const TextStyle(fontSize: 24),
      headerTimerTextStyle: const TextStyle(fontSize: 20),
      restIndicatorSize: 240,
      restStrokeWidth: 24,
      restIndicatorBackground: const Color.fromRGBO(255, 255, 255, 0.3),
      restSecondsTextStyle:
          (textTheme.displayMedium ?? const TextStyle()).copyWith(
        fontSize: 96,
        fontWeight: FontWeight.w700,
        height: 1,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      overlayMaxWidth: 420,
      overlayCardColor: Colors.grey.shade900,
      overlayScrimColor: const Color.fromRGBO(0, 0, 0, 0.75),
      overlayTitleStyle:
          const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      overlayPadding: const EdgeInsets.all(AppTokens.spacingL),
      hintTextStyle: textTheme.bodyMedium ?? const TextStyle(fontSize: 16),
      overlayButtonSpacing: AppTokens.spacingS / 2,
      overlayButtonMinHeight: 52,
    );
  }

  Color textOnStimulus(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.4 ? Colors.black : Colors.white;
  }
}
