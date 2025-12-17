import 'package:flutter/material.dart';

import 'app_tokens.dart';

class SessionStyles {
  const SessionStyles({
    required this.screenPadding,
    required this.numberTextStyle,
    required this.headerRoundTextStyle,
    required this.headerTimerTextStyle,
    required this.restIndicatorSize,
    required this.restStrokeWidth,
    required this.restIndicatorBackground,
    required this.overlayMaxWidth,
    required this.overlayCardColor,
    required this.overlayScrimColor,
    required this.overlayTitleStyle,
    required this.overlayPadding,
    required this.hintTextStyle,
  });

  final EdgeInsets screenPadding;
  final TextStyle numberTextStyle;
  final TextStyle headerRoundTextStyle;
  final TextStyle headerTimerTextStyle;
  final double restIndicatorSize;
  final double restStrokeWidth;
  final Color restIndicatorBackground;
  final double overlayMaxWidth;
  final Color overlayCardColor;
  final Color overlayScrimColor;
  final TextStyle overlayTitleStyle;
  final EdgeInsets overlayPadding;
  final TextStyle hintTextStyle;

  factory SessionStyles.defaults(ThemeData theme) {
    final textTheme = theme.textTheme;
    return SessionStyles(
      screenPadding: AppTokens.screenPadding,
      numberTextStyle: textTheme.displayLarge ?? const TextStyle(fontSize: 180, fontWeight: FontWeight.bold),
      headerRoundTextStyle: const TextStyle(fontSize: 24),
      headerTimerTextStyle: const TextStyle(fontSize: 20),
      restIndicatorSize: 180,
      restStrokeWidth: 8,
      restIndicatorBackground: const Color.fromRGBO(255, 255, 255, 0.3),
      overlayMaxWidth: 420,
      overlayCardColor: Colors.grey.shade900,
      overlayScrimColor: const Color.fromRGBO(0, 0, 0, 0.75),
      overlayTitleStyle: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      overlayPadding: const EdgeInsets.all(AppTokens.spacingL),
      hintTextStyle: textTheme.bodyMedium ?? const TextStyle(fontSize: 16),
    );
  }
}
