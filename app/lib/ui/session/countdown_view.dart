import 'package:flutter/material.dart';

class CountdownView extends StatelessWidget {
  const CountdownView({
    super.key,
    required this.remainingSeconds,
    required this.textStyle,
    required this.sizingText,
  });

  final int remainingSeconds;
  final TextStyle textStyle;
  final String sizingText;

  @override
  Widget build(BuildContext context) {
    final safeRemaining = remainingSeconds < 0 ? 0 : remainingSeconds;
    final strutSize = textStyle.fontSize ?? 180;
    final strutStyle = StrutStyle(
      forceStrutHeight: true,
      fontSize: strutSize,
      height: textStyle.height ?? 1,
      leading: 0,
      fontFamily: textStyle.fontFamily,
      fontWeight: textStyle.fontWeight,
      fontStyle: textStyle.fontStyle,
    );
    final textScaler = MediaQuery.textScalerOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final measured = _measureTextSize(
          context,
          sizingText,
          textStyle,
          strutStyle,
          textScaler,
        );
        final sized = constraints.constrain(measured);
        return SizedBox(
          width: sized.width,
          height: sized.height,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              '-$safeRemaining',
              style: textStyle,
              textAlign: TextAlign.center,
              softWrap: false,
              textWidthBasis: TextWidthBasis.longestLine,
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false,
                applyHeightToLastDescent: false,
              ),
              strutStyle: strutStyle,
            ),
          ),
        );
      },
    );
  }
}

Size _measureTextSize(
  BuildContext context,
  String text,
  TextStyle style,
  StrutStyle strutStyle,
  TextScaler textScaler,
) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: Directionality.of(context),
    textScaler: textScaler,
    maxLines: 1,
    strutStyle: strutStyle,
  )..layout();
  return painter.size;
}
