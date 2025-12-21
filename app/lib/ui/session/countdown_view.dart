import 'package:flutter/material.dart';

import 'phase_ring_timer.dart';

class CountdownView extends StatelessWidget {
  const CountdownView({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.indicatorSize,
    required this.strokeWidth,
    required this.innerPadding,
    required this.backgroundColor,
    required this.textStyle,
    required this.labelStyle,
    required this.minTextDigits,
    required this.labelGap,
    required this.pulseScale,
    required this.pulseDuration,
  });

  final int remainingSeconds;
  final int totalSeconds;
  final double indicatorSize;
  final double strokeWidth;
  final double innerPadding;
  final Color backgroundColor;
  final TextStyle textStyle;
  final TextStyle labelStyle;
  final int minTextDigits;
  final double labelGap;
  final double pulseScale;
  final Duration pulseDuration;

  @override
  Widget build(BuildContext context) {
    final pulseActive = remainingSeconds > 0 && remainingSeconds <= 3;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: indicatorSize,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'GET READY',
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
          remainingSeconds: remainingSeconds,
          diameter: indicatorSize,
          strokeWidth: strokeWidth,
          innerPadding: innerPadding,
          textStyle: textStyle,
          backgroundRingColor: backgroundColor,
          minTextDigits: minTextDigits,
          alwaysShowMinutes: false,
          pulse: pulseActive,
          pulseTrigger: remainingSeconds,
          pulseScale: pulseScale,
          pulseDuration: pulseDuration,
        ),
      ],
    );
  }
}
