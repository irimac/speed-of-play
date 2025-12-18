import 'package:flutter/material.dart';

class RestView extends StatelessWidget {
  const RestView({
    super.key,
    required this.secondsRemaining,
    required this.totalSeconds,
    required this.indicatorSize,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.textStyle,
  });

  final int secondsRemaining;
  final int totalSeconds;
  final double indicatorSize;
  final double strokeWidth;
  final Color backgroundColor;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    final total = totalSeconds <= 0 ? 1 : totalSeconds;
    final clampedRemaining = secondsRemaining.clamp(0, total);
    final int remainingSeconds = clampedRemaining.toInt();
    final progress = (remainingSeconds / total).clamp(0.0, 1.0).toDouble();
    final strutSize = textStyle.fontSize ?? 72;

    return SizedBox(
      width: indicatorSize,
      height: indicatorSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: indicatorSize,
            height: indicatorSize,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: strokeWidth,
              backgroundColor: backgroundColor,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(strokeWidth),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                '$remainingSeconds',
                style: textStyle,
                textAlign: TextAlign.center,
                softWrap: false,
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
                strutStyle: StrutStyle(
                  forceStrutHeight: true,
                  fontSize: strutSize,
                  height: textStyle.height ?? 1,
                  leading: 0,
                  fontFamily: textStyle.fontFamily,
                  fontWeight: textStyle.fontWeight,
                  fontStyle: textStyle.fontStyle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
