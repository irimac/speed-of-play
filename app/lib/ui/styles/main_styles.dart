import 'package:flutter/material.dart';

import 'app_tokens.dart';

class MainStyles {
  const MainStyles({
    required this.screenPadding,
    required this.contentMaxWidth,
    required this.backgroundGradient,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.logoHeight,
    required this.logoMaxWidth,
    required this.summaryStyle,
    required this.activeColorsLabelStyle,
    required this.secondaryInfoStyle,
    required this.activeSwatchSize,
    required this.activeSwatchBorderColor,
    required this.playButtonWidth,
    required this.playButtonHeight,
    required this.playButtonColor,
    required this.playButtonForegroundColor,
    required this.playButtonTextStyle,
    required this.buttonIconSize,
    required this.secondaryButtonHeight,
    required this.secondaryButtonTextStyle,
    required this.sectionSpacing,
    required this.summarySpacing,
    required this.buttonSpacing,
  });

  final EdgeInsets screenPadding;
  final double contentMaxWidth;
  final Gradient backgroundGradient;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final double logoHeight;
  final double logoMaxWidth;
  final TextStyle summaryStyle;
  final TextStyle activeColorsLabelStyle;
  final TextStyle secondaryInfoStyle;
  final double activeSwatchSize;
  final Color activeSwatchBorderColor;
  final double playButtonWidth;
  final double playButtonHeight;
  final Color playButtonColor;
  final Color playButtonForegroundColor;
  final TextStyle playButtonTextStyle;
  final double buttonIconSize;
  final double secondaryButtonHeight;
  final TextStyle secondaryButtonTextStyle;
  final double sectionSpacing;
  final double summarySpacing;
  final double buttonSpacing;

  factory MainStyles.defaults(ThemeData theme) {
    return const MainStyles(
      screenPadding: EdgeInsets.all(AppTokens.spacingL),
      contentMaxWidth: 520,
      backgroundGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFF8F8F4),
          Color(0xFFEEF1F4),
        ],
      ),
      primaryTextColor: Color(0xFF1C1C1C),
      secondaryTextColor: Color(0xFF4A4A4A),
      logoHeight: 160,
      logoMaxWidth: 280,
      summaryStyle: TextStyle(
        color: Color.fromRGBO(58, 58, 58, 1),
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      activeColorsLabelStyle: TextStyle(
        color: Color(0xFF2A2A2A),
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      secondaryInfoStyle: TextStyle(
        color: Color(0xFF2A2A2A),
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      activeSwatchSize: 22,
      activeSwatchBorderColor: Color(0xFF1C1C1C),
      playButtonWidth: 240,
      playButtonHeight: AppTokens.primaryButtonHeight,
      playButtonColor: Color(0xFF1E88E5),
      playButtonForegroundColor: Colors.white,
      playButtonTextStyle: TextStyle(
        color: Colors.white,
        fontSize: AppTokens.primaryActionTextSize,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
      buttonIconSize: AppTokens.actionIconSize,
      secondaryButtonHeight: AppTokens.primaryButtonHeight,
      secondaryButtonTextStyle: TextStyle(
        color: Color(0xFF1C1C1C),
        fontSize: AppTokens.secondaryActionTextSize,
        fontWeight: FontWeight.w700,
      ),
      sectionSpacing: 24,
      summarySpacing: 12,
      buttonSpacing: 12,
    );
  }
}
