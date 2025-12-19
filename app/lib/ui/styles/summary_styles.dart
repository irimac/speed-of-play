import 'package:flutter/material.dart';

import 'app_tokens.dart';

class SummaryStyles {
  const SummaryStyles({
    required this.screenPadding,
    required this.contentMaxWidth,
    required this.backgroundGradient,
    required this.titleStyle,
    required this.subtitleStyle,
    required this.sectionTitleStyle,
    required this.emptyStateStyle,
    required this.cardColor,
    required this.detailCardColor,
    required this.cardRadius,
    required this.cardPadding,
    required this.cardSpacing,
    required this.cardShadows,
    required this.statLabelStyle,
    required this.statValueStyle,
    required this.statCaptionStyle,
    required this.statCardMinHeight,
    required this.detailLabelStyle,
    required this.detailValueStyle,
    required this.dividerColor,
    required this.actionButtonHeight,
    required this.primaryButtonStyle,
    required this.secondaryButtonStyle,
    required this.buttonSpacing,
    required this.sectionSpacing,
    required this.gridBreakPoint,
  });

  final EdgeInsets screenPadding;
  final double contentMaxWidth;
  final Gradient backgroundGradient;
  final TextStyle titleStyle;
  final TextStyle subtitleStyle;
  final TextStyle sectionTitleStyle;
  final TextStyle emptyStateStyle;
  final Color cardColor;
  final Color detailCardColor;
  final double cardRadius;
  final EdgeInsets cardPadding;
  final double cardSpacing;
  final List<BoxShadow> cardShadows;
  final TextStyle statLabelStyle;
  final TextStyle statValueStyle;
  final TextStyle statCaptionStyle;
  final double statCardMinHeight;
  final TextStyle detailLabelStyle;
  final TextStyle detailValueStyle;
  final Color dividerColor;
  final double actionButtonHeight;
  final ButtonStyle primaryButtonStyle;
  final ButtonStyle secondaryButtonStyle;
  final double buttonSpacing;
  final double sectionSpacing;
  final double gridBreakPoint;

  factory SummaryStyles.defaults(ThemeData theme) {
    return SummaryStyles(
      screenPadding: AppTokens.screenPadding,
      contentMaxWidth: 560,
      backgroundGradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFF8F8F4),
          Color(0xFFEEF1F4),
        ],
      ),
      titleStyle: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1C1C1C),
      ),
      subtitleStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF4A4A4A),
      ),
      sectionTitleStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1C1C1C),
      ),
      emptyStateStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF4A4A4A),
      ),
      cardColor: Colors.white,
      detailCardColor: const Color(0xFFF4F6F8),
      cardRadius: AppTokens.cornerL,
      cardPadding: const EdgeInsets.all(16),
      cardSpacing: 12,
      cardShadows: [
        BoxShadow(
          color: const Color(0xFF000000).withAlpha(18),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
      statLabelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF4A4A4A),
      ),
      statValueStyle: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1C1C1C),
        fontFeatures: [FontFeature.tabularFigures()],
      ),
      statCaptionStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF6A6A6A),
      ),
      statCardMinHeight: 108,
      detailLabelStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2E2E2E),
      ),
      detailValueStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1C1C1C),
        fontFeatures: [FontFeature.tabularFigures()],
      ),
      dividerColor: const Color(0xFFD5D5D5),
      actionButtonHeight: AppTokens.primaryButtonHeight,
      primaryButtonStyle: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E88E5),
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
      buttonSpacing: AppTokens.spacingS,
      sectionSpacing: AppTokens.spacingL,
      gridBreakPoint: 360,
    );
  }
}
