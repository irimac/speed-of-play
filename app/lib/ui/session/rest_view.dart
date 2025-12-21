import 'package:flutter/material.dart';

import 'phase_ring_timer.dart';

class RestView extends StatelessWidget {
  const RestView({
    super.key,
    required this.secondsRemaining,
    required this.totalSeconds,
    required this.indicatorSize,
    required this.strokeWidth,
    required this.innerPadding,
    required this.backgroundColor,
    required this.textStyle,
    required this.minTextDigits,
    required this.labelStyle,
    required this.labelGap,
  });

  final int secondsRemaining;
  final int totalSeconds;
  final double indicatorSize;
  final double strokeWidth;
  final double innerPadding;
  final Color backgroundColor;
  final TextStyle textStyle;
  final int minTextDigits;
  final TextStyle labelStyle;
  final double labelGap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: indicatorSize,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'RECOVER',
              style: labelStyle,
              textAlign: TextAlign.center,
              maxLines: 1,
              softWrap: false,
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false,
                applyHeightToLastDescent: false,
              ),
            ),
          ),
        ),
        SizedBox(height: labelGap),
        PhaseRingTimer(
          totalSeconds: totalSeconds,
          remainingSeconds: secondsRemaining,
          diameter: indicatorSize,
          strokeWidth: strokeWidth,
          innerPadding: innerPadding,
          textStyle: textStyle,
          backgroundRingColor: backgroundColor,
          minTextDigits: minTextDigits,
          alwaysShowMinutes: true,
        ),
      ],
    );
  }
}
