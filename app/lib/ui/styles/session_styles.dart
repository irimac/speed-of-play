import 'package:flutter/material.dart';

import 'app_tokens.dart';

class SessionStyles {
  const SessionStyles({
    required this.screenPadding,
    required this.numberTextStyle,
    required this.numberShadowBlur,
    required this.numberShadowOffset,
    required this.numberShadowOpacity,
    required this.numberShadowBoost,
    required this.largeNumberHeightFractionLandscape,
    required this.headerRoundTextStyle,
    required this.headerTimerTextStyle,
    required this.headerHeight,
    required this.footerHeight,
    required this.headerPadding,
    required this.footerPadding,
    required this.scrimLuminanceThreshold,
    required this.scrimLightOpacity,
    required this.scrimDarkOpacity,
    required this.restIndicatorSize,
    required this.restStrokeWidth,
    required this.restInnerPadding,
    required this.restIndicatorBackground,
    required this.restSecondsTextStyle,
    required this.overlayMaxWidth,
    required this.overlayCardColor,
    required this.overlayScrimColor,
    required this.overlayTitleStyle,
    required this.overlaySubtitleStyle,
    required this.overlayPadding,
    required this.footerTextStyle,
    required this.overlayButtonSpacing,
    required this.overlaySectionSpacing,
    required this.overlayButtonMinHeight,
  });

  final EdgeInsets screenPadding;
  final TextStyle numberTextStyle;
  final double numberShadowBlur;
  final Offset numberShadowOffset;
  final double numberShadowOpacity;
  final double numberShadowBoost;
  final double largeNumberHeightFractionLandscape;
  final TextStyle headerRoundTextStyle;
  final TextStyle headerTimerTextStyle;
  final double headerHeight;
  final double footerHeight;
  final EdgeInsets headerPadding;
  final EdgeInsets footerPadding;
  final double scrimLuminanceThreshold;
  final double scrimLightOpacity;
  final double scrimDarkOpacity;
  final double restIndicatorSize;
  final double restStrokeWidth;
  final double restInnerPadding;
  final Color restIndicatorBackground;
  final TextStyle restSecondsTextStyle;
  final double overlayMaxWidth;
  final Color overlayCardColor;
  final Color overlayScrimColor;
  final TextStyle overlayTitleStyle;
  final TextStyle overlaySubtitleStyle;
  final EdgeInsets overlayPadding;
  final TextStyle footerTextStyle;
  final double overlayButtonSpacing;
  final double overlaySectionSpacing;
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
    );
    return SessionStyles(
      screenPadding: AppTokens.screenPadding,
      numberTextStyle: baseNumberStyle,
      numberShadowBlur: 10,
      numberShadowOffset: const Offset(0, 2),
      numberShadowOpacity: 0.24,
      numberShadowBoost: 1.25,
      largeNumberHeightFractionLandscape: 0.8,
      headerRoundTextStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
      headerTimerTextStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
      headerHeight: 56,
      footerHeight: 52,
      headerPadding: const EdgeInsets.symmetric(
        horizontal: AppTokens.spacingL,
        vertical: AppTokens.spacingS,
      ),
      footerPadding: const EdgeInsets.symmetric(
        horizontal: AppTokens.spacingL,
        vertical: AppTokens.spacingS,
      ),
      scrimLuminanceThreshold: 0.4,
      scrimLightOpacity: 0.18,
      scrimDarkOpacity: 0.08,
      restIndicatorSize: 268,
      restStrokeWidth: 28,
      restInnerPadding: 12,
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
      overlayTitleStyle: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      overlaySubtitleStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white70,
      ),
      overlayPadding: const EdgeInsets.all(AppTokens.spacingL),
      footerTextStyle:
          (textTheme.bodyMedium ?? const TextStyle(fontSize: 20)).copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      overlayButtonSpacing: AppTokens.spacingS,
      overlaySectionSpacing: AppTokens.spacingM,
      overlayButtonMinHeight: AppTokens.primaryButtonHeight,
    );
  }

  List<Shadow> numberShadowsForText(Color textColor, {double intensity = 1}) {
    final baseColor = textColor == Colors.black ? Colors.white : Colors.black;
    final opacity = (numberShadowOpacity * intensity).clamp(0.0, 1.0);
    final alpha = (opacity * 255).round().clamp(0, 255);
    return [
      Shadow(
        color: baseColor.withAlpha(alpha),
        blurRadius: numberShadowBlur * intensity,
        offset: numberShadowOffset,
      ),
    ];
  }

  Color scrimColorForBackground(Color background) {
    final isLight = background.computeLuminance() >= scrimLuminanceThreshold;
    final base = isLight ? Colors.black : Colors.white;
    final opacity = isLight ? scrimLightOpacity : scrimDarkOpacity;
    final alpha = (opacity * 255).round().clamp(0, 255);
    return base.withAlpha(alpha);
  }

  Color textOnStimulus(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.4 ? Colors.black : Colors.white;
  }

  double largeNumberHeightFractionFor(Size size) {
    final isLandscape = size.width > size.height;
    final ratio =
        isLandscape ? size.width / size.height : size.height / size.width;
    if (isLandscape) {
      return largeNumberHeightFractionLandscape;
    }
    return largeNumberHeightFractionLandscape / ratio;
  }
}
