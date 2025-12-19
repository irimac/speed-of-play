import 'package:flutter/material.dart';

import 'app_tokens.dart';

class HistoryStyles {
  const HistoryStyles({
    required this.screenPadding,
    required this.listPadding,
    required this.emptyStatePadding,
    required this.contentMaxWidth,
    required this.backgroundGradient,
    required this.headerBackgroundColor,
    required this.titleStyle,
    required this.primaryTextStyle,
    required this.secondaryTextStyle,
    required this.selectionCountStyle,
    required this.emptyStateTitleStyle,
    required this.emptyStateSubtitleStyle,
    required this.accentColor,
    required this.cardColor,
    required this.cardSelectedColor,
    required this.cardSelectedBorder,
    required this.cardRadius,
    required this.cardPadding,
    required this.cardSpacing,
    required this.cardMinHeight,
    required this.cardShadows,
    required this.checkboxSize,
    required this.actionBarColor,
    required this.actionBarPadding,
    required this.actionBarShadows,
    required this.actionButtonHeight,
    required this.actionButtonSpacing,
    required this.primaryButtonStyle,
    required this.secondaryButtonStyle,
    required this.sectionSpacing,
  });

  final EdgeInsets screenPadding;
  final EdgeInsets listPadding;
  final EdgeInsets emptyStatePadding;
  final double contentMaxWidth;
  final Gradient backgroundGradient;
  final Color headerBackgroundColor;
  final TextStyle titleStyle;
  final TextStyle primaryTextStyle;
  final TextStyle secondaryTextStyle;
  final TextStyle selectionCountStyle;
  final TextStyle emptyStateTitleStyle;
  final TextStyle emptyStateSubtitleStyle;
  final Color accentColor;
  final Color cardColor;
  final Color cardSelectedColor;
  final Color cardSelectedBorder;
  final double cardRadius;
  final EdgeInsets cardPadding;
  final double cardSpacing;
  final double cardMinHeight;
  final List<BoxShadow> cardShadows;
  final double checkboxSize;
  final Color actionBarColor;
  final EdgeInsets actionBarPadding;
  final List<BoxShadow> actionBarShadows;
  final double actionButtonHeight;
  final double actionButtonSpacing;
  final ButtonStyle primaryButtonStyle;
  final ButtonStyle secondaryButtonStyle;
  final double sectionSpacing;

  factory HistoryStyles.defaults(ThemeData theme) {
    const accentColor = Color(0xFF1E88E5);
    const headerBackgroundColor = Color(0xFFF8F8F4);
    return HistoryStyles(
      screenPadding: AppTokens.screenPadding,
      listPadding: const EdgeInsets.fromLTRB(
        AppTokens.spacingL,
        AppTokens.spacingM,
        AppTokens.spacingL,
        AppTokens.spacingL,
      ),
      emptyStatePadding: const EdgeInsets.symmetric(
        horizontal: AppTokens.spacingL,
        vertical: AppTokens.spacingL,
      ),
      contentMaxWidth: 560,
      backgroundGradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          headerBackgroundColor,
          Color(0xFFEEF1F4),
        ],
      ),
      headerBackgroundColor: headerBackgroundColor,
      titleStyle: const TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1C1C1C),
      ),
      primaryTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1C1C1C),
        fontFeatures: [FontFeature.tabularFigures()],
      ),
      secondaryTextStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF4A4A4A),
        fontFeatures: [FontFeature.tabularFigures()],
      ),
      selectionCountStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF4A4A4A),
      ),
      emptyStateTitleStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1C1C1C),
      ),
      emptyStateSubtitleStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF4A4A4A),
      ),
      accentColor: accentColor,
      cardColor: Colors.white,
      cardSelectedColor: const Color(0xFFEAF2FF),
      cardSelectedBorder: accentColor,
      cardRadius: AppTokens.cornerL,
      cardPadding: const EdgeInsets.all(16),
      cardSpacing: 12,
      cardMinHeight: 88,
      cardShadows: [
        BoxShadow(
          color: const Color(0xFF000000).withAlpha(18),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
      checkboxSize: 48,
      actionBarColor: Colors.white,
      actionBarPadding: const EdgeInsets.all(AppTokens.spacingL),
      actionBarShadows: [
        BoxShadow(
          color: const Color(0xFF000000).withAlpha(12),
          blurRadius: 12,
          offset: const Offset(0, -4),
        ),
      ],
      actionButtonHeight: AppTokens.primaryButtonHeight,
      actionButtonSpacing: AppTokens.spacingS,
      primaryButtonStyle: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        textStyle: const TextStyle(
          fontSize: AppTokens.primaryActionTextSize,
          fontWeight: FontWeight.w700,
        ),
      ),
      secondaryButtonStyle: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF1C1C1C),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(
          fontSize: AppTokens.secondaryActionTextSize,
          fontWeight: FontWeight.w700,
        ),
      ),
      sectionSpacing: AppTokens.spacingL,
    );
  }
}
