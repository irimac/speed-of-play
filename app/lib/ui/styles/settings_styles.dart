import 'package:flutter/material.dart';

import 'app_tokens.dart';

class SettingsStyles {
  const SettingsStyles({
    required this.backgroundColor,
    required this.cardColor,
    required this.accentColor,
    required this.onAccentColor,
    required this.textColor,
    required this.mutedTextColor,
    required this.screenPadding,
    required this.cardPadding,
    required this.sectionSpacing,
    required this.cardSpacing,
    required this.cardRadius,
    required this.buttonRadius,
    required this.stepperButtonSize,
    required this.stepperIconSize,
    required this.valueWidth,
    required this.dropdownRadius,
    required this.paletteSwatchRadius,
    required this.paletteSwatchWidth,
    required this.paletteSwatchHeight,
    required this.stepperButtonRadius,
    required this.valueTapRadius,
    required this.activeSwatchSize,
    required this.activeSwatchBorderWidth,
    required this.cardShadows,
    required this.appBarTitleStyle,
    required this.appBarActionStyle,
    required this.appBarLeadingWidth,
    required this.sectionTitleStyle,
    required this.rowLabelStyle,
    required this.rowValueStyle,
    required this.helperStyle,
    required this.primaryButtonTextStyle,
  });

  final Color backgroundColor;
  final Color cardColor;
  final Color accentColor;
  final Color onAccentColor;
  final Color textColor;
  final Color mutedTextColor;
  final EdgeInsets screenPadding;
  final EdgeInsets cardPadding;
  final double sectionSpacing;
  final double cardSpacing;
  final double cardRadius;
  final double buttonRadius;
  final double stepperButtonSize;
  final double stepperIconSize;
  final double valueWidth;
  final double dropdownRadius;
  final double paletteSwatchRadius;
  final double paletteSwatchWidth;
  final double paletteSwatchHeight;
  final double stepperButtonRadius;
  final double valueTapRadius;
  final double activeSwatchSize;
  final double activeSwatchBorderWidth;
  final List<BoxShadow> cardShadows;
  final TextStyle appBarTitleStyle;
  final TextStyle appBarActionStyle;
  final double appBarLeadingWidth;
  final TextStyle sectionTitleStyle;
  final TextStyle rowLabelStyle;
  final TextStyle rowValueStyle;
  final TextStyle helperStyle;
  final TextStyle primaryButtonTextStyle;

  factory SettingsStyles.defaults(ThemeData theme) {
    return const SettingsStyles(
      backgroundColor: Color(0xFFF5F5F5),
      cardColor: Colors.white,
      accentColor: Color(0xFF1E88E5),
      onAccentColor: Colors.white,
      textColor: Color(0xFF111111),
      mutedTextColor: Color(0xFF666666),
      screenPadding: EdgeInsets.all(20),
      cardPadding: EdgeInsets.symmetric(
        horizontal: AppTokens.spacingM,
        vertical: 14,
      ),
      sectionSpacing: 20,
      cardSpacing: 12,
      cardRadius: 14,
      buttonRadius: 14,
      stepperButtonSize: 48,
      stepperIconSize: 26,
      valueWidth: 64,
      dropdownRadius: 12,
      paletteSwatchRadius: 6,
      paletteSwatchWidth: 36,
      paletteSwatchHeight: 24,
      stepperButtonRadius: 16,
      valueTapRadius: 8,
      activeSwatchSize: 52,
      activeSwatchBorderWidth: 3,
      cardShadows: [
        BoxShadow(
          color: Color.fromARGB(18, 0, 0, 0),
          blurRadius: 12,
          offset: Offset(0, 6),
        ),
      ],
      appBarTitleStyle: TextStyle(
        color: Color(0xFF111111),
        fontWeight: FontWeight.w800,
        fontSize: 24,
      ),
      appBarActionStyle: TextStyle(
        color: Color(0xFF1E88E5),
        fontWeight: FontWeight.w800,
        fontSize: 18,
      ),
      appBarLeadingWidth: 112,
      sectionTitleStyle: TextStyle(
        color: Color(0xFF111111),
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
      rowLabelStyle: TextStyle(
        color: Color(0xFF111111),
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      rowValueStyle: TextStyle(
        color: Color(0xFF111111),
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
      helperStyle: TextStyle(
        color: Color(0xFF555555),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      primaryButtonTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
